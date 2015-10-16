Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id B90126B0038
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 02:40:31 -0400 (EDT)
Received: by lbbpp2 with SMTP id pp2so63015620lbb.0
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 23:40:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id il2si22158404wjb.60.2015.10.15.23.40.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Oct 2015 23:40:29 -0700 (PDT)
Date: Fri, 16 Oct 2015 08:40:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Make sendfile(2) killable
Message-ID: <20151016064027.GA22182@quack.suse.cz>
References: <1444653923-22111-1-git-send-email-jack@suse.com>
 <20151015134644.c072dd7ce26a74d8daa26a12@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151015134644.c072dd7ce26a74d8daa26a12@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>

On Thu 15-10-15 13:46:44, Andrew Morton wrote:
> On Mon, 12 Oct 2015 14:45:23 +0200 Jan Kara <jack@suse.com> wrote:
> 
> > Currently a simple program below issues a sendfile(2) system call which
> > takes about 62 days to complete in my test KVM instance.
> 
> Geeze some people are impatient.
> 
> >         int fd;
> >         off_t off = 0;
> > 
> >         fd = open("file", O_RDWR | O_TRUNC | O_SYNC | O_CREAT, 0644);
> >         ftruncate(fd, 2);
> >         lseek(fd, 0, SEEK_END);
> >         sendfile(fd, fd, &off, 0xfffffff);
> > 
> > Now you should not ask kernel to do a stupid stuff like copying 256MB in
> > 2-byte chunks and call fsync(2) after each chunk but if you do, sysadmin
> > should have a way to stop you.
> > 
> > We actually do have a check for fatal_signal_pending() in
> > generic_perform_write() which triggers in this path however because we
> > always succeed in writing something before the check is done, we return
> > value > 0 from generic_perform_write() and thus the information about
> > signal gets lost.
> 
> ah.
> 
> > Fix the problem by doing the signal check before writing anything. That
> > way generic_perform_write() returns -EINTR, the error gets propagated up
> > and the sendfile loop terminates early.
> >
> > ...
> >
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2488,6 +2488,11 @@ again:
> >  			break;
> >  		}
> >  
> > +		if (fatal_signal_pending(current)) {
> > +			status = -EINTR;
> > +			break;
> > +		}
> > +
> >  		status = a_ops->write_begin(file, mapping, pos, bytes, flags,
> >  						&page, &fsdata);
> >  		if (unlikely(status < 0))
> > @@ -2525,10 +2530,6 @@ again:
> >  		written += copied;
> >  
> >  		balance_dirty_pages_ratelimited(mapping);
> > -		if (fatal_signal_pending(current)) {
> > -			status = -EINTR;
> > -			break;
> > -		}
> >  	} while (iov_iter_count(i));
> >  
> >  	return written ? written : status;
> 
> This won't work, will it?  If user hits ^C after we've written a few
> pages, `written' is non-zero and the same thing happens?

It does work - I've tested it :). Sure, the generic_perform_write() call
that is running when the signal is delivered will return with value > 0.
But the interesting thing is what happens after that: Either we return to
userspace (and then we are fine) or generic_perform_write() gets called
again because there's more to write and *that* call will return -EINTR
which ends up terminating the whole sendfile syscall.

Actually there is one general lesson to be learned here: When you check for
fatal signal and bail out, it's better to do it before doing any work. That
way things keep working even if the function is called in a loop.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
