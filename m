Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9D96B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 04:41:10 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so88711708pad.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 01:41:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id rb8si18934632pab.112.2015.09.07.01.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 01:41:09 -0700 (PDT)
Date: Mon, 7 Sep 2015 10:41:01 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 1/3] net: introduce kfree_skb_bulk() user of
 kmem_cache_free_bulk()
Message-ID: <20150907104101.3e392a6d@redhat.com>
In-Reply-To: <CALx6S36R2zGwj5XF0GZWPOC1Ng5HviPWxBM-cn=DDMXU9Auoxg@mail.gmail.com>
References: <20150904165944.4312.32435.stgit@devil>
	<20150904170046.4312.38018.stgit@devil>
	<CALx6S36R2zGwj5XF0GZWPOC1Ng5HviPWxBM-cn=DDMXU9Auoxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Herbert <tom@herbertland.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, aravinda@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com, brouer@redhat.com

On Fri, 4 Sep 2015 11:47:17 -0700 Tom Herbert <tom@herbertland.com> wrote:

> On Fri, Sep 4, 2015 at 10:00 AM, Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > Introduce the first user of SLAB bulk free API kmem_cache_free_bulk(),
> > in the network stack in form of function kfree_skb_bulk() which bulk
> > free SKBs (not skb clones or skb->head, yet).
> >
[...]
> > +/**
> > + *     kfree_skb_bulk - bulk free SKBs when refcnt allows to
> > + *     @skbs: array of SKBs to free
> > + *     @size: number of SKBs in array
> > + *
> > + *     If SKB refcnt allows for free, then release any auxiliary data
> > + *     and then bulk free SKBs to the SLAB allocator.
> > + *
> > + *     Note that interrupts must be enabled when calling this function.
> > + */
> > +void kfree_skb_bulk(struct sk_buff **skbs, unsigned int size)
> > +{
>
> What not pass a list of skbs (e.g. using skb->next)?

Because the next layer, the slab API needs an array:
  kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)

Look at the patch:
 [PATCH V2 3/3] slub: build detached freelist with look-ahead
 http://thread.gmane.org/gmane.linux.kernel.mm/137469/focus=137472

Where I use this array to progressively scan for objects belonging to
the same page.  (A subtle detail is I manage to zero out the array,
which is good from a security/error-handling point of view, as pointers
to the objects are not left dangling on the stack).


I cannot argue that, writing skb->next comes as an additional cost,
because the slUb free also writes into this cacheline.  Perhaps the
slAb allocator does not?

[...]
> > +       if (likely(cnt)) {
> > +               kmem_cache_free_bulk(skbuff_head_cache, cnt, (void **) skbs);
> > +       }
> > +}
> > +EXPORT_SYMBOL(kfree_skb_bulk);

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
