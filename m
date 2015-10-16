Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFF782F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 17:05:18 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so196135pab.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 14:05:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c12si31889714pbu.20.2015.10.16.14.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 14:05:17 -0700 (PDT)
Date: Fri, 16 Oct 2015 14:05:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Make sendfile(2) killable
Message-Id: <20151016140516.8b6e1a10cb06fdd15e60320b@linux-foundation.org>
In-Reply-To: <20151016064027.GA22182@quack.suse.cz>
References: <1444653923-22111-1-git-send-email-jack@suse.com>
	<20151015134644.c072dd7ce26a74d8daa26a12@linux-foundation.org>
	<20151016064027.GA22182@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Jan Kara <jack@suse.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>

On Fri, 16 Oct 2015 08:40:27 +0200 Jan Kara <jack@suse.cz> wrote:

> > >  		balance_dirty_pages_ratelimited(mapping);
> > > -		if (fatal_signal_pending(current)) {
> > > -			status = -EINTR;
> > > -			break;
> > > -		}
> > >  	} while (iov_iter_count(i));
> > >  
> > >  	return written ? written : status;
> > 
> > This won't work, will it?  If user hits ^C after we've written a few
> > pages, `written' is non-zero and the same thing happens?
> 
> It does work - I've tested it :). Sure, the generic_perform_write() call
> that is running when the signal is delivered will return with value > 0.
> But the interesting thing is what happens after that: Either we return to
> userspace (and then we are fine) or generic_perform_write() gets called
> again because there's more to write and *that* call will return -EINTR
> which ends up terminating the whole sendfile syscall.

OK.  I guess that's better behaviour than overwriting a non-zero
`written' when signalled.

I'm going to tag this one for -stable.  It's a bit of a DoS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
