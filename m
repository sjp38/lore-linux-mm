Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7036B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 03:44:26 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so54503071wib.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 00:44:26 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id z7si9416828wiw.51.2015.08.07.00.44.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 00:44:25 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so50823050wib.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 00:44:24 -0700 (PDT)
Date: Fri, 7 Aug 2015 09:44:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
Message-ID: <20150807074422.GE26566@dhcp22.suse.cz>
References: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

On Fri 07-08-15 12:38:54, Pintu Kumar wrote:
> This patch add new counter slowpath_entered in /proc/vmstat to
> track how many times the system entered into slowpath after
> first allocation attempt is failed.

This is too lowlevel to be exported in the regular user visible
interface IMO.

> This is useful to know the rate of allocation success within
> the slowpath.

What would be that information good for? Is a regular administrator
expected to consume this value or this is aimed more to kernel
developers? If the later then I think a trace point sounds like a better
interface.

> This patch is tested on ARM with 512MB RAM.
> A sample output is shown below after successful boot-up:
> shell> cat /proc/vmstat
> nr_free_pages 4712
> pgalloc_normal 1319432
> pgalloc_movable 0
> pageoutrun 379
> allocstall 0
> slowpath_entered 585
> compact_stall 0
> compact_fail 0
> compact_success 0
> 
> >From the above output we can see that the system entered
> slowpath 585 times.
> But the existing counter kswapd(pageoutrun), direct_reclaim(allocstall),
> direct_compact(compact_stall) does not tell this value.
> >From the above value, it clearly indicates that the system have
> entered slowpath 585 times. Out of which 379 times allocation passed
> through kswapd, without performing direct reclaim/compaction.
> That means the remaining 206 times the allocation would have succeeded
> using the alloc_pages_high_priority.
> 
> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
