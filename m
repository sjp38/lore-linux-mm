Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8B186B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 00:41:44 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so697758777pfb.6
        for <linux-mm@kvack.org>; Sun, 01 Jan 2017 21:41:44 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id i21si50008628pgj.273.2017.01.01.21.41.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 01 Jan 2017 21:41:43 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from epcas1p3.samsung.com (unknown [182.195.41.47])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OJ500KC715HU820@mailout1.samsung.com> for linux-mm@kvack.org;
 Mon, 02 Jan 2017 14:41:42 +0900 (KST)
Content-transfer-encoding: 8BIT
Subject: Re: [PATCH] mm: cma: print allocation failure reason and bitmap status
From: Jaewon Kim <jaewon31.kim@samsung.com>
Message-id: <5869E849.1040605@samsung.com>
Date: Mon, 02 Jan 2017 14:42:33 +0900
In-reply-to: <xa1tpok6igqb.fsf@mina86.com>
References: 
 <CGME20161229022722epcas5p4be0e1924f3c8d906cbfb461cab8f0374@epcas5p4.samsung.com>
 <1482978482-14007-1-git-send-email-jaewon31.kim@samsung.com>
 <20161229091449.GG29208@dhcp22.suse.cz> <xa1th95m7r6w.fsf@mina86.com>
 <58660BBE.1040807@samsung.com> <20161230094411.GD13301@dhcp22.suse.cz>
 <xa1tpok6igqb.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: gregkh@linuxfoundation.org, akpm@linux-foundation.org, labbott@redhat.com, m.szyprowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com



On 2017e?? 01i?? 02i? 1/4  06:59, Michal Nazarewicz wrote:
> On Fri, Dec 30 2016, Michal Hocko wrote:
>> On Fri 30-12-16 16:24:46, Jaewon Kim wrote:
>> [...]
>>> >From 7577cc94da3af27907aa6eec590d2ef51e4b9d80 Mon Sep 17 00:00:00 2001
>>> From: Jaewon Kim <jaewon31.kim@samsung.com>
>>> Date: Thu, 29 Dec 2016 11:00:16 +0900
>>> Subject: [PATCH] mm: cma: print allocation failure reason and bitmap status
>>>
>>> There are many reasons of CMA allocation failure such as EBUSY, ENOMEM, EINTR.
>>> But we did not know error reason so far. This patch prints the error value.
>>>
>>> Additionally if CONFIG_CMA_DEBUG is enabled, this patch shows bitmap status to
>>> know available pages. Actually CMA internally try all available regions because
>>> some regions can be failed because of EBUSY. Bitmap status is useful to know in
>>> detail on both ENONEM and EBUSY;
>>>  ENOMEM: not tried at all because of no available region
>>>          it could be too small total region or could be fragmentation issue
>>>  EBUSY:  tried some region but all failed
>>>
>>> This is an ENOMEM example with this patch.
>>> [   13.250961]  [1:   Binder:715_1:  846] cma: cma_alloc: alloc failed, req-size: 256 pages, ret: -12
>>> Avabile pages also will be shown if CONFIG_CMA_DEBUG is enabled
>>> [   13.251052]  [1:   Binder:715_1:  846] cma: number of available pages: 4@572+7@585+7@601+8@632+38@730+166@1114+127@1921=>357 pages, total: 2048 pages
>> please mention how to interpret this information.
Thank you Michal Hocko. I added like this
If CONFIG_CMA_DEBUG is enabled, avabile pages also will be shown as concatenated
size@position format. So 4@572 means that there are 4 available pages at 572
position starting from 0 position.
>>
>> some more style suggestions below
>>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
Thank you I added your Ack
Acked-by: Michal Nazarewicz <mina86@mina86.com>
>>> ---
>>>  mm/cma.c | 29 ++++++++++++++++++++++++++++-
>>>  1 file changed, 28 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/cma.c b/mm/cma.c
>>> index c960459..1bcd9db 100644
>>> --- a/mm/cma.c
>>> +++ b/mm/cma.c
>>> @@ -369,7 +369,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>>>      unsigned long start = 0;
>>>      unsigned long bitmap_maxno, bitmap_no, bitmap_count;
>>>      struct page *page = NULL;
>>> -    int ret;
>>> +    int ret = -ENOMEM;
>>>  
>>>      if (!cma || !cma->count)
>>>          return NULL;
>>> @@ -427,6 +427,33 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>>>      trace_cma_alloc(pfn, page, count, align);
>>>  
>>>      pr_debug("%s(): returned %p\n", __func__, page);
> This line should be moved after the a??if (ret != 0)a?? block, i.e. just
> before return.
Thank you Michal Nazarewicz
I moved the pr_debug right before return
     pr_debug("%s(): returned %p\n", __func__, page);
     return page;
>>> +
>>> +    if (ret != 0)
>> you can simply do
>> 	if (!ret) {
Thank you
I changed like this, it should be if(ret) rather than if(!ret)
+    if (ret) {
+        pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
+            __func__, count, ret);
+        debug_show_cma_areas(cma);
+    }
>>
>> 		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
>> 			__func__, count, ret);
>> 		debug_show_cma_areas();
>> 	}
>>
>> 	return page;
>>
>> static void debug_show_cma_areas(void)
>> {
>> #ifdef CONFIG_CMA_DEBUG
>> 	unsigned int nr, nr_total = 0;
>> 	unsigned long next_set_bit;
>>
>> 	mutex_lock(&cma->lock);
>> 	pr_info("number of available pages: ");
>> 	start = 0;
>> 	for (;;) {
>> 		bitmap_no = find_next_zero_bit(cma->bitmap, cma->count, start);
>> 		if (bitmap_no >= cma->count)
>> 		break;
>> 		next_set_bit = find_next_bit(cma->bitmap, cma->count, bitmap_no);
>> 		nr = next_set_bit - bitmap_no;
>> 		pr_cont("%s%u@%lu", nr_total ? "+" : "", nr, bitmap_no);
>> 		nr_total += nr;
>> 		start = bitmap_no + nr;
>> 	}
>> 	pr_cont("=>%u pages, total: %lu pages\n", nr_total, cma->count);
> Perhaps:
> 	pr_cont("=> %u free of %lu total pages\n", nr_total, cma->count);
Thank you I will take this way.
+    pr_cont("=> %u free of %lu total pages\n", nr_total, cma->count);
> or shorter (but more cryptic):
> 	pr_cont("=> %u/%lu pages\n", nr_total, cma->count);
>
>> 	mutex_unlock(&cma->lock);
>> #endif
>> }
> Actually, Linux style is more like:
>
> #ifdef CONFIG_CMA_DEBUG
> static void cma_debug_show_areas()
> {
> 	a?|
> }
> #else
> static inline void cma_debug_show_areas() { }
> #endif
Thank you I will take this way. FYI struct cma address should be passed as a argument.
+#ifdef CONFIG_CMA_DEBUG
+static void debug_show_cma_areas(struct cma *cma)
+{
...
+#else
+static inline void debug_show_cma_areas(struct cma *cma) { }
+#endif
>> -- 
>> Michal Hocko
>> SUSE Labs

Thank you all of you.
Let me reattach my full patch to be clear.
Let me know if I resend this as a new mail thread.
