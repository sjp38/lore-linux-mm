Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id CCF5F6B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:57:28 -0500 (EST)
Date: Thu, 17 Jan 2013 13:57:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 0/6] solve deadlock caused by memory allocation with
 I/O
Message-Id: <20130117135726.5b31fd0f.akpm@linux-foundation.org>
In-Reply-To: <CACVXFVOipr0VMyPQaZTLckxTaPan7ZneERUqZ1S_mYo11A5AeA@mail.gmail.com>
References: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
	<20130116153744.70210fa3.akpm@linux-foundation.org>
	<CACVXFVOipr0VMyPQaZTLckxTaPan7ZneERUqZ1S_mYo11A5AeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>

On Thu, 17 Jan 2013 09:28:14 +0800
Ming Lei <ming.lei@canonical.com> wrote:

> > If so, I wonder if we could avoid the whole problem by appropriately
> > syncing all dirty memory back to storage before starting to turn devices
> > off?
> 
> The patchset is to address the probable deadlock problem by GFP_KERNEL
> during runtime suspend/resume which is per block/network device. I am
> wondering if syncing all dirty memory is suitable or necessary during
> per-storage/network device runtime resume/suspend:
> 
>       - sys_sync is very slow and runtime pm operation is frequent
> 
>       - it is not efficient because only sync dirty memory against the affected
>         device is needed in theory and not necessary to sync all
> 
>      - we still need some synchronization to avoid accessing the storage
>        between sys_sync and device suspend, just like system sleep case,
>        pm_restrict_gfp_mask is needed even sys_sync has been done
>        inside enter_state().
> 
> So looks the approach in the patch is simpler and more efficient, :-)
> 
> Also, with the patchset, we can avoid many GFP_NOIO allocation
> which is fragile and not easy to use.

Fair enough, thanks.

I grabbed the patches for 3.9-rc1.  It is good that the page
allocator's newly-added test of current->flags is not on the fastpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
