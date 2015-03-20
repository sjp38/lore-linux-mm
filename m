Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7558C6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 06:46:48 -0400 (EDT)
Received: by pagj4 with SMTP id j4so14317991pag.2
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 03:46:48 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ly4si8502497pdb.192.2015.03.20.03.46.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 20 Mar 2015 03:46:47 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NLI00NUDBGH2Q50@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Mar 2015 10:50:41 +0000 (GMT)
Message-id: <550BFA8F.9050803@partner.samsung.com>
Date: Fri, 20 Mar 2015 13:46:39 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v4 1/5] mm: cma: add trace events to debug
 physically-contiguous memory allocations
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
 <a1127b32325d3c527636912eefd6892bd8fc746d.1426521377.git.s.strogin@partner.samsung.com>
 <550741BD.9080109@partner.samsung.com>
 <20150316194750.04885ee7@grimm.local.home>
 <550B2F0A.3010909@partner.samsung.com>
 <20150319163406.4050cdaf@gandalf.local.home>
In-reply-to: <20150319163406.4050cdaf@gandalf.local.home>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com, Ingo Molnar <mingo@redhat.com>

On 19/03/15 23:34, Steven Rostedt wrote:
> On Thu, 19 Mar 2015 23:18:18 +0300
> Stefan Strogin <s.strogin@partner.samsung.com> wrote:
> 
>> Thank you for the reply, Steven.
>> I supposed that page_to_pfn() cannot change after mem_map
>> initialization, can it? I'm not sure about such things as memory hotplug
>> though...
>> Also cma_alloc() calls alloc_contig_range() which returns pfn, then it's
>> converted to struct page * and cma_alloc() returns struct page *, and
>> vice versa in cma_release() (receives struct page * and passes pfn to
>> free_contig_rage()).
>> Do you mean that printing pfn (or struct page *) in trace event is
>> redundant?
> 
> I'm concerned about the time TP_printk() is executed and when
> TP_fast_assign() is. That is, when the tracepoint is called,
> TP_fast_assign() is executed, but TP_printk() is called when someone
> reads the trace files, which can happen seconds, hours, days, weeks,
> months later.
> 
> As long as the result of page_to_pfn() and pfn_to_page() stay the same
> throughout the life of the boot, things will be fine. But if they could
> ever change, due to hotplug memory or whatever. The data in the trace
> buffer will become stale, and report the wrong information.
> 
> -- Steve
> 

Ah, thanks, I see. So will this solve the described issue?
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->pfn = page_to_pfn(__entry->page) : 0;
/* or -1 as Ingo suggested */
+		__entry->count = count;
+	),
+
+	TP_printk("page=%p pfn=%lu count=%u",
+		  __entry->page,
+		  __entry->pfn,
+		  __entry->count)

Should we do the same in trace/events/kmem.h then?

But really I'm not sure why page_to_pfn()/pfn_to_page() can return
different results... I thought that there can appear new 'struct page'
entries arrays throughout one boot due to memory hotplug or smth. But
how can existing 'struct page' entries associated with the same physical
pages change their physical addresses? Or how can one physical address
correspond to different physical page throughout one boot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
