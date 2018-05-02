Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C53946B0003
	for <linux-mm@kvack.org>; Wed,  2 May 2018 18:17:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y5so3096036pfm.17
        for <linux-mm@kvack.org>; Wed, 02 May 2018 15:17:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y63-v6si10168814pgb.311.2018.05.02.15.17.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 15:17:06 -0700 (PDT)
Date: Thu, 3 May 2018 01:17:02 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 07/16] slub: Remove page->counters
Message-ID: <20180502221702.a2ezdae6akchroze@black.fi.intel.com>
References: <20180430202247.25220-1-willy@infradead.org>
 <20180430202247.25220-8-willy@infradead.org>
 <alpine.DEB.2.21.1805011148060.16325@nuc-kabylake>
 <20180502172639.GC2737@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180502172639.GC2737@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Wed, May 02, 2018 at 05:26:39PM +0000, Matthew Wilcox wrote:
> Option 2:
> 
> @@ -113,9 +113,14 @@ struct page {
>                         struct kmem_cache *slub_cache;  /* shared with slab */
>                         /* Double-word boundary */
>                         void *slub_freelist;            /* shared with slab */
> -                       unsigned inuse:16;
> -                       unsigned objects:15;
> -                       unsigned frozen:1;
> +                       union {
> +                               unsigned long counters;
> +                               struct {
> +                                       unsigned inuse:16;
> +                                       unsigned objects:15;
> +                                       unsigned frozen:1;
> +                               };
> +                       };
>                 };
>                 struct {        /* Tail pages of compound page */
>                         unsigned long compound_head;    /* Bit zero is set */
> 
> Pro: Expresses exactly what we do.
> Con: Back to five levels of indentation in struct page

The indentation issue can be fixed (to some extend) by declaring the union
outside struct page and just use it inside.

I don't advocate for the approach, just listing the option.

-- 
 Kirill A. Shutemov
