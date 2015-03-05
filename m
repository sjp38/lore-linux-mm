Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B97AD6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 09:33:33 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so9449428pab.6
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 06:33:33 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id f8si9555665pat.207.2015.03.05.06.33.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 05 Mar 2015 06:33:32 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKQ004C9TYGW180@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 05 Mar 2015 14:37:28 +0000 (GMT)
Message-id: <54F86933.6040203@partner.samsung.com>
Date: Thu, 05 Mar 2015 17:33:23 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v3 1/4] mm: cma: add trace events to debug
 physically-contiguous memory allocations
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
 <9ae4c45b49e8df6e079448550c2b81ade5d3603a.1424802755.git.s.strogin@partner.samsung.com>
 <87sidma1gj.fsf@linux.vnet.ibm.com>
In-reply-to: <87sidma1gj.fsf@linux.vnet.ibm.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Hi Aneesh,

On 03/03/15 12:13, Aneesh Kumar K.V wrote:
> 
> Are we interested only in successful allocation and release ? Should we also
> have the trace point carry information regarding failure ?
> 
> -aneesh
> 

I think we actually can be interested in tracing allocation failures
too. Thanks for the remark.

Should it be smth like that?
@@ -408,6 +410,8 @@ struct page *cma_alloc(struct cma *cma, int count,
unsigned int align)
 		start = bitmap_no + mask + 1;
 	}

+	trace_cma_alloc(cma, page, count);
+
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
 }

and in include/trace/events/cma.h:
+TRACE_EVENT(cma_alloc,
<...>
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->count = count;
+	),
+
+	TP_printk("page=%p pfn=%lu count=%lu\n",
+		  __entry->page,
+		  __entry->page ? page_to_pfn(__entry->page) : 0,
+		  __entry->count)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
