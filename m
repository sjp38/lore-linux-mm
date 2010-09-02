Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AB5526B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 16:30:25 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] vmscan: don't use return value trick when oom_killer_disabled
Date: Thu, 2 Sep 2010 22:04:14 +0200
References: <1283442461-16290-1-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1283442461-16290-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Message-Id: <201009022204.14661.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "M. Vefa Bicakci" <bicave@superonline.com>, stable@kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thursday, September 02, 2010, Minchan Kim wrote:
> M. Vefa Bicakci reported 2.6.35 kernel hang up when hibernation on his
> 32bit 3GB mem machine. (https://bugzilla.kernel.org/show_bug.cgi?id=16771)
> Also he was bisected first bad commit is below
> 
>   commit bb21c7ce18eff8e6e7877ca1d06c6db719376e3c
>   Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>   Date:   Fri Jun 4 14:15:05 2010 -0700
> 
>      vmscan: fix do_try_to_free_pages() return value when priority==0 reclaim failure
> 
> At first impression, this seemed very strange because the above commit only
> chenged function return value and hibernate_preallocate_memory() ignore
> return value of shrink_all_memory(). But it's related.
> 
> Now, page allocation from hibernation code may enter infinite loop if
> the system has highmem.
> 
> The reasons are two. 1) hibernate_preallocate_memory() call
> alloc_pages() wrong order

This isn't the case, as explained here: http://lkml.org/lkml/2010/9/1/316 .

The ordering of calls is correct, but it's better to check if there are any
non-highmem pages to allocate from before the last call (for performance
reasons, but that also would eliminate the failure in question).

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
