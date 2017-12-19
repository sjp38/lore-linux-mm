Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63C126B026B
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 11:20:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t15so1361079wmh.3
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:20:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l15si12089359wrb.144.2017.12.19.08.20.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 08:20:34 -0800 (PST)
Date: Tue, 19 Dec 2017 17:20:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/5] mm: Extends local cpu counter vm_diff_nodestat
 from s8 to s16
Message-ID: <20171219162029.GD2787@dhcp22.suse.cz>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-3-git-send-email-kemi.wang@intel.com>
 <alpine.DEB.2.20.1712191004420.17324@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1712191004420.17324@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Kemi Wang <kemi.wang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue 19-12-17 10:05:48, Cristopher Lameter wrote:
> On Tue, 19 Dec 2017, Kemi Wang wrote:
> 
> > The type s8 used for vm_diff_nodestat[] as local cpu counters has the
> > limitation of global counters update frequency, especially for those
> > monotone increasing type of counters like NUMA counters with more and more
> > cpus/nodes. This patch extends the type of vm_diff_nodestat from s8 to s16
> > without any functionality change.
> 
> Well the reason for s8 was to keep the data structures small so that they
> fit in the higher level cpu caches. The large these structures become the
> more cachelines are used by the counters and the larger the performance
> influence on the code that should not be impacted by the overhead.
 
I am not sure I understand. We usually do not access more counters in
the single code path (well, PGALLOC and NUMA counteres is more of an
exception). So it is rarely an advantage that the whole array is in the
same cache line. Besides that this is allocated by the percpu allocator
aligns to the type size rather than cache lines AFAICS.

Maybe it used to be all different back then when the code has been added
but arguing about cache lines seems to be a bit problematic here. Maybe
you have some specific workloads which can prove me wrong?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
