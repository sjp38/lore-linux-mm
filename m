Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 26C226B0069
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 18:37:46 -0500 (EST)
Date: Wed, 16 Jan 2013 15:37:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 0/6] solve deadlock caused by memory allocation with
 I/O
Message-Id: <20130116153744.70210fa3.akpm@linux-foundation.org>
In-Reply-To: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
References: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>

On Sat,  5 Jan 2013 10:25:38 +0800
Ming Lei <ming.lei@canonical.com> wrote:

> This patchset try to solve one deadlock problem which might be caused
> by memory allocation with block I/O during runtime PM and block device
> error handling path. Traditionly, the problem is addressed by passing
> GFP_NOIO statically to mm, but that is not a effective solution, see
> detailed description in patch 1's commit log.
> 
> This patch set introduces one process flag and trys to fix the deadlock
> problem on block device/network device during runtime PM or usb bus reset.

The patchset doesn't look like the worst thing I've ever applied ;)

One thing I'm wondering: during suspend and resume, why are GFP_KERNEL
allocation attempts even getting down to the device layer?  Presumably
the page scanner is encountering dirty pagecache or dirty swapcache
pages?

If so, I wonder if we could avoid the whole problem by appropriately
syncing all dirty memory back to storage before starting to turn devices
off?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
