Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 1F9FA6B005A
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 14:56:28 -0500 (EST)
Date: Wed, 4 Jan 2012 11:56:12 -0800
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and
 related changes in MM
Message-ID: <20120104195612.GB19181@suse.de>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Wed, Jan 04, 2012 at 07:21:53PM +0200, Leonid Moiseichuk wrote:
> The main idea of Used Memory Meter (UMM) is to provide low-cost interface
> for user-space to notify about memory consumption using similar approach /proc/meminfo
> does but focusing only on "modified" pages which cannot be fogotten.
> 
> The calculation formula in terms of meminfo looks the following:
>   UsedMemory = (MemTotal - MemFree - Buffers - Cached - SwapCached) +
>                                                (SwapTotal - SwapFree)
> It reflects well amount of system memory used in applications in heaps and shared pages.
> 
> Previously (n770..n900) we had lowmem.c [1] which used LSM and did a lot other things,
> n9 implementation based on memcg [2] which has own problems, so the proposed variant
> I hope is the best one for n9:
> - Keeps connections from user space
> - When amount of modified pages reaches crossed pointed value for particular connection
>   makes POLLIN and allow user-space app to read it and react
> - Economic as much as possible, so currently its operates if allocation higher than 487
>   pages or last check happened 250 ms before
> Of course if no allocation happened then no activities performed, use-time
> must be not affected.
> 
> Testing results:
> - Checkpatch produced 0 warning
> - Sparse does not produce warnings
> - One check costs ~20 us or less (could be checked with probe=1 insmod)
> - One connection costs 20 bytes in kernel-space  (see observer structure) for 32-bit variant
> - For 10K connections poll update in requested in ~10ms, but for practically device expected
>   to will have about 10 connections (like n9 has now).
> 
> Known weak points which I do not know how to fix but will if you have a brillian idea:
> - Having hook in MM is nasty but MM/shrinker cannot be used there and LSM even worse idea
> - If I made 
> 	$cat /dev/used_memory
>   it is produced lines in non-stop mode. Adding position check in umm_read seems doesn not help,
>   so "head -1 /dev/used_memory" should be used if you need to quick check
> - Format of output is USED_PAGES:AVAILABLE_PAGES, primitive but enough for tasks module does
> 
> Tested on ARM, x86-32 and x86-64 with and without CONFIG_SWAP. Seems works in all combinations.
> Sorry for wide distributions but list of names were produced by scripts/get_maintainer.pl

How does this compare with the lowmemorykiller.c driver from the android
developers that is currently in the linux-next tree?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
