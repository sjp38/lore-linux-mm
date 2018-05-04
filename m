Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83D8A6B0003
	for <linux-mm@kvack.org>; Fri,  4 May 2018 17:12:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z24so11397907pfn.5
        for <linux-mm@kvack.org>; Fri, 04 May 2018 14:12:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b36-v6si17072127pli.30.2018.05.04.14.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 14:12:47 -0700 (PDT)
Date: Fri, 4 May 2018 14:12:44 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Proof-of-concept: better(?) page-table manipulation API
Message-ID: <20180504211244.GD29829@bombadil.infradead.org>
References: <20180424154355.mfjgkf47kdp2by4e@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424154355.mfjgkf47kdp2by4e@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 24, 2018 at 06:43:56PM +0300, Kirill A. Shutemov wrote:
> +struct pt_ptr {
> +	unsigned long *ptr;
> +	int lvl;
> +};

On x86, you've got three kinds of paging scheme, referred to in the manual
as 32-bit, PAE and 4-level.  On 32-bit, you've got 3 levels (Directory,
Table and Entry), and you can encode those three levels in the bottom
two bits of the pointer.  With PAE and 4L, pointers are 64-bit aligned,
so you can encode up to eight levels in the bottom three bits of the
pointer.

> +struct pt_val {
> +	unsigned long val;
> +	int lvl;
> +};

I don't think it's possible to shrink this down to a single ulong.
_Maybe_ it is if you can squirm a single bit free from the !pte_present
case.

... this is only for x86 4L and maybe 32 paging, right?  It'd need to
use unsigned long val[2] for PAE.

I'm going to think about this some more.  There's a lot of potential here.
