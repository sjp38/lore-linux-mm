Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 71D726B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 09:37:42 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so16333372igc.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 06:37:42 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id k17si3476933igt.103.2015.09.10.06.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 06:37:41 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so43719961pad.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 06:37:41 -0700 (PDT)
Message-ID: <1441892259.4619.53.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: Is it OK to pass non-acquired objects to kfree?
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Sep 2015 06:37:39 -0700
In-Reply-To: <CACT4Y+YEEZAOMFojv91T5M34ZHBfDBRxGjn6KtP6cyz+ivt=vw@mail.gmail.com>
References: 
	<CACT4Y+bvaJ6cC_=A1VGx=cT_bkB-teXNud0Wgt33E1AtBYNTSg@mail.gmail.com>
	 <alpine.DEB.2.11.1509090901480.18992@east.gentwo.org>
	 <CACT4Y+ZpToAmaboGDvFhgWUqtnUcJACprg=XSTkrJYE4DQ1jcA@mail.gmail.com>
	 <alpine.DEB.2.11.1509090930510.19262@east.gentwo.org>
	 <CACT4Y+b_wDnC3mONjmq+F9kaw1_L_8z=E__1n25ZgLhx-biEmQ@mail.gmail.com>
	 <alpine.DEB.2.11.1509091036590.19663@east.gentwo.org>
	 <CACT4Y+a6rjbEoP7ufgyJimjx3qVh81TToXjL9Rnj-bHNregZXg@mail.gmail.com>
	 <alpine.DEB.2.11.1509091251150.20311@east.gentwo.org>
	 <20150909184415.GJ4029@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1509091346230.20665@east.gentwo.org>
	 <20150909203642.GO4029@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1509091823360.21983@east.gentwo.org>
	 <CACT4Y+aULybVcGWWUDvZ9sFtE7TDvQfZ2enT49xe3VD3Ayv5-Q@mail.gmail.com>
	 <20150910124253.6000cc77@redhat.com>
	 <CACT4Y+YEEZAOMFojv91T5M34ZHBfDBRxGjn6KtP6cyz+ivt=vw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>

On Thu, 2015-09-10 at 14:08 +0200, Dmitry Vyukov wrote:
> On Thu, Sep 10, 2015 at 12:42 PM, Jesper Dangaard Brouer

> > This reminds me of some code in the network stack[1] in kfree_skb()
> > where we have a smp_rmb().  Should we have used smp_load_acquire() ?
> >
> >  void kfree_skb(struct sk_buff *skb)
> >  {
> >         if (unlikely(!skb))
> >                 return;
> >         if (likely(atomic_read(&skb->users) == 1))
> >                 smp_rmb();
> >         else if (likely(!atomic_dec_and_test(&skb->users)))
> >                 return;
> >         trace_kfree_skb(skb, __builtin_return_address(0));
> >         __kfree_skb(skb);
> >  }
> >  EXPORT_SYMBOL(kfree_skb);
> 
> rmb is much better than nothing :)
> I generally prefer to use smp_load_acquire just because it's more
> explicit (you see what memory access the barrier relates to), fewer
> lines of code, agrees with modern atomic APIs in C, C++, Java, etc,
> and FWIW is much better for dynamic race detectors.
> As for semantic difference between rmb and smp_load_acquire, rmb does
> not order stores, so stores from __kfree_skb can hoist above the
> atomic_read(&skb->users) == 1 check. The only architecture that can do
> that is Alpha, I don't know enough about Alpha and barrier
> implementation on Alpha (maybe rmb and smp_load_acquire do the same
> hardware barrier on Alpha) to say whether it can break in real life or
> not. But I would still consider smp_load_acquire as safer and cleaner
> alternative.

smp_load_acquire() is a kid compared to kfree_skb() code written decades
ago.

Sure, new code has plenty of ways to implement all this stuff, and now
we can discuss days about choosing right variant in a single spot.

In the old days, Alexei was writing thousand of lines of code per day,
and he got it mostly right, even for the Alpha ;)

Another discussion is whether or not reading the value before attempting
the lock atomic dec is a win on modern cpus, because it might incur an
additional bus transaction in the case skbs are allocated/freed on
different cpus. I believe I made tests ~4 years ago and it was worth
keeping it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
