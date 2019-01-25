Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2808E00CD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 07:28:01 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id x7so6277018pll.23
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 04:28:01 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id d4si27374602plj.334.2019.01.25.04.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 04:27:59 -0800 (PST)
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
	by mailout2.w1.samsung.com (KnoxPortal) with ESMTP id 20190125122756euoutp02709b8372c4272e0ccca23cc9395a6a5f~9FyC_eEi20335803358euoutp02K
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 12:27:56 +0000 (GMT)
Subject: Re: [PATCH 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_insert_range_buggy
From: Marek Szyprowski <m.szyprowski@samsung.com>
Message-ID: <febb9775-20da-69d5-4f0e-cd87253eb8f9@samsung.com>
Date: Fri, 25 Jan 2019 13:27:53 +0100
MIME-Version: 1.0
In-Reply-To: <CAFqt6zbYHq-pS=rGx+3ncJ7rO-LvL5=iOou21oguKjrc=3qouA@mail.gmail.com>
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
References: <CGME20190111150806epcas2p4ecaac58547db019e7dc779349d495f4d@epcas2p4.samsung.com>
	<20190111151154.GA2819@jordon-HP-15-Notebook-PC>
	<241810e0-2288-c59b-6c21-6d853d9fe84a@samsung.com>
	<CAFqt6zbYHq-pS=rGx+3ncJ7rO-LvL5=iOou21oguKjrc=3qouA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

Hi Souptick,

On 2019-01-25 05:55, Souptick Joarder wrote:
> On Tue, Jan 22, 2019 at 8:37 PM Marek Szyprowski
> <m.szyprowski@samsung.com> wrote:
>> On 2019-01-11 16:11, Souptick Joarder wrote:
>>> Convert to use vm_insert_range_buggy to map range of kernel memory
>>> to user vma.
>>>
>>> This driver has ignored vm_pgoff. We could later "fix" these drivers
>>> to behave according to the normal vm_pgoff offsetting simply by
>>> removing the _buggy suffix on the function name and if that causes
>>> regressions, it gives us an easy way to revert.
>> Just a generic note about videobuf2: videobuf2-dma-sg is ignoring vm_pgoff by design. vm_pgoff is used as a 'cookie' to select a buffer to mmap and videobuf2-core already checks that. If userspace provides an offset, which doesn't match any of the registered 'cookies' (reported to userspace via separate v4l2 ioctl), an error is returned.
> Ok, it means once the buf is selected, videobuf2-dma-sg should always
> mapped buf->pages[i]
> from index 0 ( irrespective of vm_pgoff value). So although we are
> replacing the code with
> vm_insert_range_buggy(), *_buggy* suffix will mislead others and
> should not be used.
> And if we replace this code with  vm_insert_range(), this will
> introduce bug for *non zero*
> value of vm_pgoff.
>
> Please correct me if my understanding is wrong.

You are correct. IMHO the best solution in this case would be to add
following fix:


diff --git a/drivers/media/common/videobuf2/videobuf2-core.c
b/drivers/media/common/videobuf2/videobuf2-core.c
index 70e8c3366f9c..ca4577a7d28a 100644
--- a/drivers/media/common/videobuf2/videobuf2-core.c
+++ b/drivers/media/common/videobuf2/videobuf2-core.c
@@ -2175,6 +2175,13 @@ int vb2_mmap(struct vb2_queue *q, struct
vm_area_struct *vma)
         goto unlock;
     }
 
+    /*
+     * vm_pgoff is treated in V4L2 API as a 'cookie' to select a buffer,
+     * not as a in-buffer offset. We always want to mmap a whole buffer
+     * from its beginning.
+     */
+    vma->vm_pgoff = 0;
+
     ret = call_memop(vb, mmap, vb->planes[plane].mem_priv, vma);
 
 unlock:
diff --git a/drivers/media/common/videobuf2/videobuf2-dma-contig.c
b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
index aff0ab7bf83d..46245c598a18 100644
--- a/drivers/media/common/videobuf2/videobuf2-dma-contig.c
+++ b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
@@ -186,12 +186,6 @@ static int vb2_dc_mmap(void *buf_priv, struct
vm_area_struct *vma)
         return -EINVAL;
     }
 
-    /*
-     * dma_mmap_* uses vm_pgoff as in-buffer offset, but we want to
-     * map whole buffer
-     */
-    vma->vm_pgoff = 0;
-
     ret = dma_mmap_attrs(buf->dev, vma, buf->cookie,
         buf->dma_addr, buf->size, buf->attrs);
 
-- 

Then you can simply use non-buggy version of your function in
drivers/media/common/videobuf2/videobuf2-dma-sg.c.

I can send above as a formal patch if you want.

> So what your opinion about this patch ? Shall I drop this patch from
> current series ?
> or,
> There is any better way to handle this scenario ?
>
>
>>> There is an existing bug inside gem_mmap_obj(), where user passed
>>> length is not checked against buf->num_pages. For any value of
>>> length > buf->num_pages it will end up overrun buf->pages[i],
>>> which could lead to a potential bug.
> It is not gem_mmap_obj(), it should be vb2_dma_sg_mmap().
> Sorry about it.
>
> What about this issue ? Does it looks like a valid issue ?

It is already handled in vb2_mmap(). Such call will be rejected.


> ...

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
