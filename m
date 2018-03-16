Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4FE6B0006
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:06:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t24so5589765pfe.20
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:06:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v12-v6si6938471plk.615.2018.03.16.12.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Mar 2018 12:06:07 -0700 (PDT)
Date: Fri, 16 Mar 2018 12:06:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v9 09/61] xarray: Replace exceptional entries
Message-ID: <20180316190604.GF27498@bombadil.infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180313132639.17387-10-willy@infradead.org>
 <20180316185349.c4ebbwuzlhihec5f@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180316185349.c4ebbwuzlhihec5f@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Fri, Mar 16, 2018 at 02:53:50PM -0400, Josef Bacik wrote:
> On Tue, Mar 13, 2018 at 06:25:47AM -0700, Matthew Wilcox wrote:
> > @@ -453,18 +449,14 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
> >  			new += bit;
> >  			if (new < 0)
> >  				return -ENOSPC;
> > -			if (ebit < BITS_PER_LONG) {
> > -				bitmap = (void *)((1UL << ebit) |
> > -						RADIX_TREE_EXCEPTIONAL_ENTRY);
> > -				radix_tree_iter_replace(root, &iter, slot,
> > -						bitmap);
> > -				*id = new;
> > -				return 0;
> > +			if (bit < BITS_PER_XA_VALUE) {
> > +				bitmap = xa_mk_value(1UL << bit);
> > +			} else {
> > +				bitmap = this_cpu_xchg(ida_bitmap, NULL);
> > +				if (!bitmap)
> > +					return -EAGAIN;
> > +				__set_bit(bit, bitmap->bitmap);
> >  			}
> > -			bitmap = this_cpu_xchg(ida_bitmap, NULL);
> > -			if (!bitmap)
> > -				return -EAGAIN;
> > -			__set_bit(bit, bitmap->bitmap);
> >  			radix_tree_iter_replace(root, &iter, slot, bitmap);
> >  		}
> >  
> 
> This threw me off a bit, but we do *id = new below.

Yep.  Fortunately, I have a test-suite for the IDA, so I'm relatively
sure this works.

> > @@ -495,9 +487,9 @@ void ida_remove(struct ida *ida, int id)
> >  		goto err;
> >  
> >  	bitmap = rcu_dereference_raw(*slot);
> > -	if (radix_tree_exception(bitmap)) {
> > +	if (xa_is_value(bitmap)) {
> >  		btmp = (unsigned long *)slot;
> > -		offset += RADIX_TREE_EXCEPTIONAL_SHIFT;
> > +		offset += 1; /* Intimate knowledge of the xa_data encoding */
> >  		if (offset >= BITS_PER_LONG)
> >  			goto err;
> >  	} else {
> 
> Ick.

I know.  I feel quite ashamed of this code.  I do have a rewrite to use
the XArray, but I didn't want to include it as part of *this* merge request.
And that rewrite decodes the value into an unsigned long, sets the bit,
reencodes it as an xa_value and stores it.

> > @@ -393,11 +393,11 @@ void ida_check_conv(void)
> >  	for (i = 0; i < 1000000; i++) {
> >  		int err = ida_get_new(&ida, &id);
> >  		if (err == -EAGAIN) {
> > -			assert((i % IDA_BITMAP_BITS) == (BITS_PER_LONG - 2));
> > +			assert((i % IDA_BITMAP_BITS) == (BITS_PER_LONG - 1));
> >  			assert(ida_pre_get(&ida, GFP_KERNEL));
> >  			err = ida_get_new(&ida, &id);
> >  		} else {
> > -			assert((i % IDA_BITMAP_BITS) != (BITS_PER_LONG - 2));
> > +			assert((i % IDA_BITMAP_BITS) != (BITS_PER_LONG - 1));
> 
> Can we just use BITS_PER_XA_VALUE here?

Yes!  I'll change that.

> Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks!
