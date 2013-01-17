Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id F34A16B005D
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 04:44:21 -0500 (EST)
From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v7 0/6] solve deadlock caused by memory allocation with I/O
Date: Thu, 17 Jan 2013 10:44:17 +0100
Message-ID: <2496969.ClbQ8gLATp@linux-5eaq.site>
In-Reply-To: <CACVXFVOipr0VMyPQaZTLckxTaPan7ZneERUqZ1S_mYo11A5AeA@mail.gmail.com>
References: <1357352744-8138-1-git-send-email-ming.lei@canonical.com> <20130116153744.70210fa3.akpm@linux-foundation.org> <CACVXFVOipr0VMyPQaZTLckxTaPan7ZneERUqZ1S_mYo11A5AeA@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>, Minchan Kim <minchan@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>

On Thursday 17 January 2013 09:28:14 Ming Lei wrote:
>      - we still need some synchronization to avoid accessing the storage
>        between sys_sync and device suspend, just like system sleep case,
>        pm_restrict_gfp_mask is needed even sys_sync has been done
>        inside enter_state().
> 
> So looks the approach in the patch is simpler and more efficient, 

Even worse. The memory may be needed to resume and the reason
we need to resume may be that we need to write out memory. And
there is no way to make sure we don't dirty memory unless user space
is frozen, so it is either this approach, or GFP_NOIO in the whole resume
code path.

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
