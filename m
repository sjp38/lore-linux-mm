Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7E70F6B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 16:46:46 -0400 (EDT)
Received: by iow1 with SMTP id 1so104033187iow.1
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 13:46:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l6si749622igx.19.2015.10.15.13.46.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 13:46:45 -0700 (PDT)
Date: Thu, 15 Oct 2015 13:46:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Make sendfile(2) killable
Message-Id: <20151015134644.c072dd7ce26a74d8daa26a12@linux-foundation.org>
In-Reply-To: <1444653923-22111-1-git-send-email-jack@suse.com>
References: <1444653923-22111-1-git-send-email-jack@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>

On Mon, 12 Oct 2015 14:45:23 +0200 Jan Kara <jack@suse.com> wrote:

> Currently a simple program below issues a sendfile(2) system call which
> takes about 62 days to complete in my test KVM instance.

Geeze some people are impatient.

>         int fd;
>         off_t off = 0;
> 
>         fd = open("file", O_RDWR | O_TRUNC | O_SYNC | O_CREAT, 0644);
>         ftruncate(fd, 2);
>         lseek(fd, 0, SEEK_END);
>         sendfile(fd, fd, &off, 0xfffffff);
> 
> Now you should not ask kernel to do a stupid stuff like copying 256MB in
> 2-byte chunks and call fsync(2) after each chunk but if you do, sysadmin
> should have a way to stop you.
> 
> We actually do have a check for fatal_signal_pending() in
> generic_perform_write() which triggers in this path however because we
> always succeed in writing something before the check is done, we return
> value > 0 from generic_perform_write() and thus the information about
> signal gets lost.

ah.

> Fix the problem by doing the signal check before writing anything. That
> way generic_perform_write() returns -EINTR, the error gets propagated up
> and the sendfile loop terminates early.
>
> ...
>
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2488,6 +2488,11 @@ again:
>  			break;
>  		}
>  
> +		if (fatal_signal_pending(current)) {
> +			status = -EINTR;
> +			break;
> +		}
> +
>  		status = a_ops->write_begin(file, mapping, pos, bytes, flags,
>  						&page, &fsdata);
>  		if (unlikely(status < 0))
> @@ -2525,10 +2530,6 @@ again:
>  		written += copied;
>  
>  		balance_dirty_pages_ratelimited(mapping);
> -		if (fatal_signal_pending(current)) {
> -			status = -EINTR;
> -			break;
> -		}
>  	} while (iov_iter_count(i));
>  
>  	return written ? written : status;

This won't work, will it?  If user hits ^C after we've written a few
pages, `written' is non-zero and the same thing happens?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
