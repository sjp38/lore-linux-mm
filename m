Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADEFA83099
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:39:51 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so13853127lfg.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:39:51 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id g8si30330691wmf.22.2016.08.18.07.39.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 07:39:50 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id i5so35357301wmg.0
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:39:50 -0700 (PDT)
MIME-Version: 1.0
From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Thu, 18 Aug 2016 17:39:49 +0300
Message-ID: <CACVxJT8xH5MLtbqMcNFScNx6chOvQ69OHan8coACeUAVkGkS=g@mail.gmail.com>
Subject: Maybe move ->anon_vma_chain ?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: riel@redhat.com, Andrew Morton <akpm@linux-foundation.org>

FYI,

on x86_64, ->anon_vma_chain has offset 120 inside the structure
which means that:
* on CONFIG_NUMA=n CONFIG_USERFAULTFD=n kernels
every 4-th VMA has this list head spanning 2 cachelines and,

* on CONFIG_NUMA=y CONFIG_USERFAULTFD=y kernels
_every_ VMA has this peculiar property.

Now I don't know good benchmark for anon vmas,
but maybe you do.


struct vm_area_struct {
vm_start;             /*     0     8 */
vm_end;               /*     8     8 */
vm_next;              /*    16     8 */
vm_prev;              /*    24     8 */
vm_rb;                /*    32    24 */
rb_subtree_gap;       /*    56     8 */
        /* --- cacheline 1 boundary (64 bytes) --- */
vm_mm;                /*    64     8 */
vm_page_prot;         /*    72     8 */
vm_flags;             /*    80     8 */

rb;                   /*    88    24 */
rb_subtree_last;      /*   112     8 */
                      /*    88    32 */


===>   struct list_head anon_vma_chain; /*   120    16 */
        /* --- cacheline 2 boundary (128 bytes) was 8 bytes ago --- */


anon_vma;             /*   136     8 */
struct  * vm_ops;     /*   144     8 */
vm_pgoff;             /*   152     8 */
vm_file;              /*   160     8 */
vm_private_data;      /*   168     8 */
vm_userfaultfd_ctx;   /*   176     0 */

        /* size: 176, cachelines: 3, members: 17 */
        /* last cacheline: 48 bytes */
};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
