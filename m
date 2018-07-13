Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 035796B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:02:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g5-v6so2114116pgq.5
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 13:02:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a5-v6si26719104pll.412.2018.07.13.13.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 13:02:45 -0700 (PDT)
Date: Fri, 13 Jul 2018 13:02:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/5] mm/sparse: abstract sparse buffer allocations
Message-Id: <20180713130243.13d02e94bedc8cc3caf275ca@linux-foundation.org>
In-Reply-To: <23f6e4e5-6e32-faf6-433d-67e50d2895a2@oracle.com>
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
	<20180712203730.8703-2-pasha.tatashin@oracle.com>
	<20180713131749.GA16765@techadventures.net>
	<23f6e4e5-6e32-faf6-433d-67e50d2895a2@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Oscar Salvador <osalvador@techadventures.net>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Fri, 13 Jul 2018 09:24:44 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> On 07/13/2018 09:17 AM, Oscar Salvador wrote:
> > On Thu, Jul 12, 2018 at 04:37:26PM -0400, Pavel Tatashin wrote:
> >> +static void *sparsemap_buf __meminitdata;
> >> +static void *sparsemap_buf_end __meminitdata;
> >> +
> >> +void __init sparse_buffer_init(unsigned long size, int nid)
> >> +{
> >> +	BUG_ON(sparsemap_buf);
> > 
> > Why do we need a BUG_ON() here?
> > Looking at the code I cannot really see how we can end up with sparsemap_buf being NULL.
> > Is it just for over-protection?
> 
> This checks that we do not accidentally leak memory by calling sparse_buffer_init() consequently without sparse_buffer_fini() in-between.

A memory leak isn't serious enough to justify crashing the kernel. 
Therefore

--- a/mm/sparse.c~mm-sparse-abstract-sparse-buffer-allocations-fix-fix
+++ a/mm/sparse.c
@@ -469,7 +469,7 @@ static void *sparsemap_buf_end __meminit
 
 void __init sparse_buffer_init(unsigned long size, int nid)
 {
-	BUG_ON(sparsemap_buf);
+	WARN_ON(sparsemap_buf);	/* forgot to call sparse_buffer_fini()? */
 	sparsemap_buf =
 		memblock_virt_alloc_try_nid_raw(size, PAGE_SIZE,
 						__pa(MAX_DMA_ADDRESS),
_
