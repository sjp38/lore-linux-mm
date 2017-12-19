Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB106B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:21:28 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id h200so2615016itb.3
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:21:28 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id p11si10601489ioe.52.2017.12.19.09.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 09:21:27 -0800 (PST)
Date: Tue, 19 Dec 2017 11:21:24 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/5] mm: Extends local cpu counter vm_diff_nodestat
 from s8 to s16
In-Reply-To: <20171219162029.GD2787@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1712191116370.18938@nuc-kabylake>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com> <1513665566-4465-3-git-send-email-kemi.wang@intel.com> <alpine.DEB.2.20.1712191004420.17324@nuc-kabylake> <20171219162029.GD2787@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kemi Wang <kemi.wang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, 19 Dec 2017, Michal Hocko wrote:

> > Well the reason for s8 was to keep the data structures small so that they
> > fit in the higher level cpu caches. The large these structures become the
> > more cachelines are used by the counters and the larger the performance
> > influence on the code that should not be impacted by the overhead.
>
> I am not sure I understand. We usually do not access more counters in
> the single code path (well, PGALLOC and NUMA counteres is more of an
> exception). So it is rarely an advantage that the whole array is in the
> same cache line. Besides that this is allocated by the percpu allocator
> aligns to the type size rather than cache lines AFAICS.

I thought we are talking about NUMA counters here?

Regardless: A typical fault, system call or OS action will access multiple
zone and node counters when allocating or freeing memory. Enlarging the
fields will increase the number of cachelines touched.

> Maybe it used to be all different back then when the code has been added
> but arguing about cache lines seems to be a bit problematic here. Maybe
> you have some specific workloads which can prove me wrong?

Run a workload that does some page faults? Heavy allocation and freeing of
memory?

Maybe that is no longer relevant since the number of the counters is
large that the accesses are so sparse that each action pulls in a whole
cacheline. That would be something we tried to avoid when implementing
the differentials.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
