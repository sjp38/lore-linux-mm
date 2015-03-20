Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE086B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 10:31:44 -0400 (EDT)
Received: by ignm3 with SMTP id m3so30794422ign.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 07:31:44 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0116.hostedemail.com. [216.40.44.116])
        by mx.google.com with ESMTP id d65si4385522iod.11.2015.03.20.07.31.43
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 07:31:43 -0700 (PDT)
Date: Fri, 20 Mar 2015 10:31:39 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 1/5] mm: cma: add trace events to debug
 physically-contiguous memory allocations
Message-ID: <20150320103139.1f5e79ea@gandalf.local.home>
In-Reply-To: <550BFA8F.9050803@partner.samsung.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
	<a1127b32325d3c527636912eefd6892bd8fc746d.1426521377.git.s.strogin@partner.samsung.com>
	<550741BD.9080109@partner.samsung.com>
	<20150316194750.04885ee7@grimm.local.home>
	<550B2F0A.3010909@partner.samsung.com>
	<20150319163406.4050cdaf@gandalf.local.home>
	<550BFA8F.9050803@partner.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com, Ingo Molnar <mingo@redhat.com>

On Fri, 20 Mar 2015 13:46:39 +0300
Stefan Strogin <s.strogin@partner.samsung.com> wrote:
 
> Ah, thanks, I see. So will this solve the described issue?
> +	TP_fast_assign(
> +		__entry->page = page;
> +		__entry->pfn = page_to_pfn(__entry->page) : 0;
> /* or -1 as Ingo suggested */
> +		__entry->count = count;
> +	),
> +
> +	TP_printk("page=%p pfn=%lu count=%u",
> +		  __entry->page,
> +		  __entry->pfn,
> +		  __entry->count)
> 
> Should we do the same in trace/events/kmem.h then?
> 
> But really I'm not sure why page_to_pfn()/pfn_to_page() can return
> different results... I thought that there can appear new 'struct page'
> entries arrays throughout one boot due to memory hotplug or smth. But
> how can existing 'struct page' entries associated with the same physical
> pages change their physical addresses? Or how can one physical address
> correspond to different physical page throughout one boot?

I don't know if those mappings can change. I'm just warning you that if
they can, then you can have an issue with it. If that's the case, then
it would be best to do the work in the tracepoint instead of the print.

One benefit for making this change is that it will let userspace tools
such as perf and trace-cmd parse it better.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
