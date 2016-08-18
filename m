Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C8C3A8309D
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:45:43 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id n128so69521695ith.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:45:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b76si3288776iti.17.2016.08.18.07.45.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 07:45:43 -0700 (PDT)
Message-ID: <1471531541.2581.16.camel@redhat.com>
Subject: Re: Maybe move ->anon_vma_chain ?
From: Rik van Riel <riel@redhat.com>
Date: Thu, 18 Aug 2016 10:45:41 -0400
In-Reply-To: <CACVxJT8xH5MLtbqMcNFScNx6chOvQ69OHan8coACeUAVkGkS=g@mail.gmail.com>
References: 
	<CACVxJT8xH5MLtbqMcNFScNx6chOvQ69OHan8coACeUAVkGkS=g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

On Thu, 2016-08-18 at 17:39 +0300, Alexey Dobriyan wrote:
> FYI,
> 
> on x86_64, ->anon_vma_chain has offset 120 inside the structure
> which means that:
> * on CONFIG_NUMA=n CONFIG_USERFAULTFD=n kernels
> every 4-th VMA has this list head spanning 2 cachelines and,
> 
> * on CONFIG_NUMA=y CONFIG_USERFAULTFD=y kernels
> _every_ VMA has this peculiar property.

It may make sense to move vm_pgoff into the first
cache line, since that is likely to be used in
conjunction with the rb tree, in rb tree walks.

> Now I don't know good benchmark for anon vmas,
> but maybe you do.

I am not sure what we would use to benchmark this.

> struct vm_area_struct {
> vm_start;A A A A A A A A A A A A A /*A A A A A 0A A A A A 8 */
> vm_end;A A A A A A A A A A A A A A A /*A A A A A 8A A A A A 8 */
> vm_next;A A A A A A A A A A A A A A /*A A A A 16A A A A A 8 */
> vm_prev;A A A A A A A A A A A A A A /*A A A A 24A A A A A 8 */
> vm_rb;A A A A A A A A A A A A A A A A /*A A A A 32A A A A 24 */
> rb_subtree_gap;A A A A A A A /*A A A A 56A A A A A 8 */
> A A A A A A A A /* --- cacheline 1 boundary (64 bytes) --- */
> vm_mm;A A A A A A A A A A A A A A A A /*A A A A 64A A A A A 8 */
> vm_page_prot;A A A A A A A A A /*A A A A 72A A A A A 8 */
> vm_flags;A A A A A A A A A A A A A /*A A A A 80A A A A A 8 */
> 
> rb;A A A A A A A A A A A A A A A A A A A /*A A A A 88A A A A 24 */
> rb_subtree_last;A A A A A A /*A A A 112A A A A A 8 */
> A A A A A A A A A A A A A A A A A A A A A A /*A A A A 88A A A A 32 */
> 
> 
> ===>A A A struct list_head anon_vma_chain; /*A A A 120A A A A 16 */
> A A A A A A A A /* --- cacheline 2 boundary (128 bytes) was 8 bytes ago ---
> */
> 
> 
> anon_vma;A A A A A A A A A A A A A /*A A A 136A A A A A 8 */
> structA A * vm_ops;A A A A A /*A A A 144A A A A A 8 */
> vm_pgoff;A A A A A A A A A A A A A /*A A A 152A A A A A 8 */
> vm_file;A A A A A A A A A A A A A A /*A A A 160A A A A A 8 */
> vm_private_data;A A A A A A /*A A A 168A A A A A 8 */
> vm_userfaultfd_ctx;A A A /*A A A 176A A A A A 0 */
> 
> A A A A A A A A /* size: 176, cachelines: 3, members: 17 */
> A A A A A A A A /* last cacheline: 48 bytes */
> };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
