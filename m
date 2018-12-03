Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6EAF6B6B79
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 17:49:23 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id m3so11468645pfj.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 14:49:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d9si14229034pgb.105.2018.12.03.14.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Dec 2018 14:49:22 -0800 (PST)
Date: Mon, 3 Dec 2018 14:49:20 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Number of arguments in vmalloc.c
Message-ID: <20181203224920.GQ10377@bombadil.infradead.org>
References: <20181128140136.GG10377@bombadil.infradead.org>
 <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
 <20181203161352.GP10377@bombadil.infradead.org>
 <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

On Mon, Dec 03, 2018 at 02:04:41PM -0800, Nadav Amit wrote:
> On Dec 3, 2018, at 8:13 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > On Mon, Dec 03, 2018 at 02:59:36PM +0100, Vlastimil Babka wrote:
> >> On 11/28/18 3:01 PM, Matthew Wilcox wrote:
> >>> Some of the functions in vmalloc.c have as many as nine arguments.
> >>> So I thought I'd have a quick go at bundling the ones that make sense
> >>> into a struct and pass around a pointer to that struct.  Well, it made
> >>> the generated code worse,
> >> 
> >> Worse in which metric?
> > 
> > More instructions to accomplish the same thing.
> > 
> >>> so I thought I'd share my attempt so nobody
> >>> else bothers (or soebody points out that I did something stupid).
> >> 
> >> I guess in some of the functions the args parameter could be const?
> >> Might make some difference.
> >> 
> >> Anyway this shouldn't be a fast path, so even if the generated code is
> >> e.g. somewhat larger, then it still might make sense to reduce the
> >> insane parameter lists.
> > 
> > It might ... I'm not sure it's even easier to program than the original
> > though.
> 
> My intuition is that if all the fields of vm_args were initialized together
> (in the same function), and a 'const struct vm_args *' was provided as
> an argument to other functions, code would be better (at least better than
> what you got right now).
> 
> I’m not saying it is easily applicable in this use-case (since I didn’t
> check).

Your intuition is wrong ...

   text	   data	    bss	    dec	    hex	filename
   9466	     81	     32	   9579	   256b	before.o
   9546	     81	     32	   9659	   25bb	.build-tiny/mm/vmalloc.o
   9546	     81	     32	   9659	   25bb	const.o

indeed, there's no difference between with or without the const, according
to 'cmp'.

Now, only alloc_vmap_area() gets to take a const argument.
__get_vm_area_node() intentionally modifies the arguments.  But feel
free to play around with this; you might be able to make it do something
worthwhile.
