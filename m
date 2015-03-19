Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 20CBE6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 16:34:16 -0400 (EDT)
Received: by ignm3 with SMTP id m3so17951544ign.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 13:34:16 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0165.hostedemail.com. [216.40.44.165])
        by mx.google.com with ESMTP id cu15si2835983icb.46.2015.03.19.13.34.15
        for <linux-mm@kvack.org>;
        Thu, 19 Mar 2015 13:34:15 -0700 (PDT)
Date: Thu, 19 Mar 2015 16:34:06 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 1/5] mm: cma: add trace events to debug
 physically-contiguous memory allocations
Message-ID: <20150319163406.4050cdaf@gandalf.local.home>
In-Reply-To: <550B2F0A.3010909@partner.samsung.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
	<a1127b32325d3c527636912eefd6892bd8fc746d.1426521377.git.s.strogin@partner.samsung.com>
	<550741BD.9080109@partner.samsung.com>
	<20150316194750.04885ee7@grimm.local.home>
	<550B2F0A.3010909@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com, Ingo Molnar <mingo@redhat.com>

On Thu, 19 Mar 2015 23:18:18 +0300
Stefan Strogin <s.strogin@partner.samsung.com> wrote:

> Thank you for the reply, Steven.
> I supposed that page_to_pfn() cannot change after mem_map
> initialization, can it? I'm not sure about such things as memory hotplug
> though...
> Also cma_alloc() calls alloc_contig_range() which returns pfn, then it's
> converted to struct page * and cma_alloc() returns struct page *, and
> vice versa in cma_release() (receives struct page * and passes pfn to
> free_contig_rage()).
> Do you mean that printing pfn (or struct page *) in trace event is
> redundant?

I'm concerned about the time TP_printk() is executed and when
TP_fast_assign() is. That is, when the tracepoint is called,
TP_fast_assign() is executed, but TP_printk() is called when someone
reads the trace files, which can happen seconds, hours, days, weeks,
months later.

As long as the result of page_to_pfn() and pfn_to_page() stay the same
throughout the life of the boot, things will be fine. But if they could
ever change, due to hotplug memory or whatever. The data in the trace
buffer will become stale, and report the wrong information.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
