Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D57306B0038
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 22:09:36 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q92so18509927ioi.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 19:09:36 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f196si5718699oih.40.2016.09.19.19.09.35
        for <linux-mm@kvack.org>;
        Mon, 19 Sep 2016 19:09:36 -0700 (PDT)
Date: Tue, 20 Sep 2016 11:00:12 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 03/15] lockdep: Refactor lookup_chain_cache()
Message-ID: <20160920020012.GJ2279@X58A-UD3R>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-4-git-send-email-byungchul.park@lge.com>
 <CACbG308kitsX23FTCJiUDVpN2uusabHiN1ifao53yR5fM4Z7VA@mail.gmail.com>
 <20160919030558.GI2279@X58A-UD3R>
 <CACbG30_fB6WaXysshhx55KP+vVbtYh1eT-q+RajNMBUbPCaBoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACbG30_fB6WaXysshhx55KP+vVbtYh1eT-q+RajNMBUbPCaBoQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nilay Vaish <nilayvaish@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Mon, Sep 19, 2016 at 11:36:25AM -0500, Nilay Vaish wrote:
> On 18 September 2016 at 22:05, Byungchul Park <byungchul.park@lge.com> wrote:
> > On Thu, Sep 15, 2016 at 10:33:46AM -0500, Nilay Vaish wrote:
> >> On 13 September 2016 at 04:45, Byungchul Park <byungchul.park@lge.com> wrote:
> >> > @@ -2215,6 +2178,75 @@ cache_hit:
> >> >         return 1;
> >> >  }
> >> >
> >> > +/*
> >> > + * Look up a dependency chain.
> >> > + */
> >> > +static inline struct lock_chain *lookup_chain_cache(u64 chain_key)
> >> > +{
> >> > +       struct hlist_head *hash_head = chainhashentry(chain_key);
> >> > +       struct lock_chain *chain;
> >> > +
> >> > +       /*
> >> > +        * We can walk it lock-free, because entries only get added
> >> > +        * to the hash:
> >> > +        */
> >> > +       hlist_for_each_entry_rcu(chain, hash_head, entry) {
> >> > +               if (chain->chain_key == chain_key) {
> >> > +                       debug_atomic_inc(chain_lookup_hits);
> >> > +                       return chain;
> >> > +               }
> >> > +       }
> >> > +       return NULL;
> >> > +}
> >>
> >> Byungchul,  do you think we should increment chain_lookup_misses
> >> before returning NULL from the above function?
> >
> > Hello,
> >
> > No, I don't think so.
> > It will be done in add_chain_cache().
> >
> 
> I think you are assuming that a call to lookup will always be followed
> by add.  I thought the point of breaking the original function into
> two was that each of the functions can be used individually, without
> the other being called.  This means we would not increment the number

Right.

But, we have to remind that counting for cache miss can happen twice if
it's handled in lookup_chain_cache(), because chain_lookup_misses() is
called twice every lookup. One is 'lockless access' for fast path, the
other is 'lock-protected access' for guarranting real miss.

So only when the miss is indentified under lock-protected,
chain_lookup_misses has to be counted. Current chain_lookup_misses means
that "cache miss happened and was _added_ into cache", semantically.
Thus I think it's not bad to handle it in add().

> of misses when only lookup() gets called, but not add().  Or we would

lookup() might be called locklessly for fast path. It would be useful, but
it guarrantees nothing but cache bit. So we cannot count miss in lookup().
Furthermore, we have to assume add() is called when cache miss.

> increment the number of misses when only add() is called and not
> lookup().

Actually add() will not be called without calling lookup(). Anyway, I can
see what you're concerning.. Is there any alterative which is better?

> 
> It really seems odd to me that hits get incremented in lookup and misses don't.
> 
> --
> Nilay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
