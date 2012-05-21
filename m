Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id ADD856B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 04:51:16 -0400 (EDT)
Message-ID: <4FBA0203.20509@kernel.org>
Date: Mon, 21 May 2012 17:51:15 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] swap: allow swap readahead to be merged
References: <1337587755-4743-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1337587755-4743-2-git-send-email-ehrhardt@linux.vnet.ibm.com>
In-Reply-To: <1337587755-4743-2-git-send-email-ehrhardt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ehrhardt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, axboe@kernel.dk

On 05/21/2012 05:09 PM, ehrhardt@linux.vnet.ibm.com wrote:

> From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> 
> Swap readahead works fine, but the I/O to disk is almost always done in page
> size requests, despite the fact that readahead submits 1<<page-cluster pages
> at a time.
> On older kernels the old per device plugging behavior might have captured
> this and merged the requests, but currently all comes down to much more I/Os
> than required.
> 
> On a single device this might not be an issue, but as soon as a server runs
> on shared san resources savin I/Os not only improves swapin throughput but
> also provides a lower resource utilization.
> 
> With a load running KVM in a lot of memory overcommitment (the hot memory
> is 1.5 times the host memory) swapping throughput improves significantly
> and the lead feels more responsive as well as achieves more throughput.
> 
> In a test setup with 16 swap disks running blocktrace on one of those disks
> shows the improved merging:
> Prior:
> Reads Queued:     560,888,    2,243MiB  Writes Queued:     226,242,  904,968KiB
> Read Dispatches:  544,701,    2,243MiB  Write Dispatches:  159,318,  904,968KiB
> Reads Requeued:         0               Writes Requeued:         0
> Reads Completed:  544,716,    2,243MiB  Writes Completed:  159,321,  904,980KiB
> Read Merges:       16,187,   64,748KiB  Write Merges:       61,744,  246,976KiB
> IO unplugs:       149,614               Timer unplugs:       2,940
> 
> With the patch:
> Reads Queued:     734,315,    2,937MiB  Writes Queued:     300,188,    1,200MiB
> Read Dispatches:  214,972,    2,937MiB  Write Dispatches:  215,176,    1,200MiB
> Reads Requeued:         0               Writes Requeued:         0
> Reads Completed:  214,971,    2,937MiB  Writes Completed:  215,177,    1,200MiB
> Read Merges:      519,343,    2,077MiB  Write Merges:       73,325,  293,300KiB
> IO unplugs:       337,130               Timer unplugs:      11,184
> 
> Signed-off-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Jens Axboe <axboe@kernel.dk>


Reviewed-by: Minchan Kim <minchan@kernel.org>

Didn't I add my Reviewed-by on your previous version?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
