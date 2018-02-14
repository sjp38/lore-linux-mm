Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFD86B000E
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 16:29:41 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id w24so11536592plq.11
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:29:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b21si1812093pfe.31.2018.02.14.13.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 13:29:40 -0800 (PST)
Date: Wed, 14 Feb 2018 13:29:37 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 2/8] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180214212937.GG20627@bombadil.infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
 <20180214201154.10186-3-willy@infradead.org>
 <1518641152.3678.28.camel@perches.com>
 <20180214211203.GF20627@bombadil.infradead.org>
 <1518643449.3678.33.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518643449.3678.33.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Feb 14, 2018 at 01:24:09PM -0800, Joe Perches wrote:
> On Wed, 2018-02-14 at 13:12 -0800, Matthew Wilcox wrote:
> > On Wed, Feb 14, 2018 at 12:45:52PM -0800, Joe Perches wrote:
> > > Perhaps kv[zm]alloc_buf_and_array is better naming.
> > 
> > I think that's actively misleading.  The programmer isn't allocating a
> > buf, they're allocating a struct.  kvzalloc_hdr_arr was the earlier name,
> > and that made some sense; they're allocating an array with a header.
> > But nobody thinks about it like that; they're allocating a structure
> > with a variably sized array at the end of it.
> > 
> > If C macros had decent introspection, I'd like it to be:
> > 
> > 	sev = kvzalloc_struct(elems, GFP_KERNEL);
> > 
> > and have the macro examine the structure pointed to by 'sev', check
> > the last element was an array, calculate the size of the array element,
> > and call kvzalloc_ab_c.  But we don't live in that world, so I have to
> > get the programmer to tell me the structure and the name of the last
> > element in it.
> 
> Look at your patch 4
> 
> -       dev_dax = kzalloc(sizeof(*dev_dax) + sizeof(*res) * count, GFP_KERNEL);
> +       dev_dax = kvzalloc_struct(dev_dax, res, count, GFP_KERNEL);
> 
> Here what is being allocated is exactly a struct
> and an array.

No, it's a struct *containing* an array.  Look at patches 5 & 8 where I
have to convert the structs to contain the array which was silently
being allocated immediately after them.

> And this doesn't compile either.

Does for me.  What error are you seeing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
