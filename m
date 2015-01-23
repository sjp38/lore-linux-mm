Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4936B006E
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 07:32:17 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id ft15so8327113pdb.5
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 04:32:17 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ki7si669937pbc.210.2015.01.23.04.32.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 23 Jan 2015 04:32:16 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIM00M9ER0FHW90@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Jan 2015 12:36:15 +0000 (GMT)
Content-transfer-encoding: 8BIT
Message-id: <54C23F49.8040109@partner.samsung.com>
Date: Fri, 23 Jan 2015 15:32:09 +0300
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: Re: [PATCH 2/3] mm: cma: introduce /proc/cmainfo
References: <cover.1419602920.git.s.strogin@partner.samsung.com>
 <264ce8ad192124f2afec9a71a2fc28779d453ba7.1419602920.git.s.strogin@partner.samsung.com>
 <xa1tzjaaz9f9.fsf@mina86.com> <54A160B6.5030605@gmail.com>
 <54A34E01.2050405@lge.com>
In-reply-to: <54A34E01.2050405@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Stefan Strogin <stefan.strogin@gmail.com>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, s.strogin@partner.samsung.com

Hello Gioh,

On 31/12/14 04:14, Gioh Kim wrote:
>
> Is it ok if the information is too big?
> I'm not sure but I remember that seq_printf has 4K limitation.

Thanks for reviewing, excuse me for a long delay.

If I understand correctly it is OK, since it's written in comments for
seq_has_overflowed():
>  * seq_files have a buffer which may overflow. When this happens a larger
>  * buffer is reallocated and all the data will be printed again.
>  * The overflow state is true when m->count == m->size.
And exactly this happens in traverse().

But I think that it's not important anymore as I intent not to use
seq_files in the second version.


>
> So I made seq_operations with seq_list_start/next functions.
>
> EX)
>
> static void *debug_seq_start(struct seq_file *s, loff_t *pos)
> {
> A>>       mutex_lock(&debug_lock);
> A>>       return seq_list_start(&debug_list, *pos);
> }   
>
> static void debug_seq_stop(struct seq_file *s, void *data)
> {
> A>>       struct debug_header *header = data;
>
> A>>       if (header == NULL || &header->head_list == &debug_list) {
> A>>       A>>       seq_printf(s, "end of info");
> A>>       }
>
> A>>       mutex_unlock(&debug_lock);
> }
>
> static void *debug_seq_next(struct seq_file *s, void *data, loff_t *pos)
> {
> A>>       return seq_list_next(data, &debug_list, pos);
> }
>
> static int debug_seq_show(struct seq_file *sfile, void *data)
> {
> A>>       struct debug_header *header;
> A>>       char *p;
>
> A>>       header= list_entry(data,
> A>>       A>>       A>>          struct debug_header,   
> A>>       A>>       A>>          head_list);
>
> A>>       seq_printf(sfile, "print info");
> A>>       return 0;
> }
> static const struct seq_operations debug_seq_ops = {
> A>>       .start = debug_seq_start,   
> A>>       .next = debug_seq_next,   
> A>>       .stop = debug_seq_stop,   
> A>>       .show = debug_seq_show,   
> };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
