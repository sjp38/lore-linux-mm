Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 464AC6B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 23:09:01 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 20so117390153ioj.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 20:09:01 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id j79si23216027itb.44.2016.09.18.20.08.59
        for <linux-mm@kvack.org>;
        Sun, 18 Sep 2016 20:09:00 -0700 (PDT)
Date: Mon, 19 Sep 2016 12:05:58 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v3 03/15] lockdep: Refactor lookup_chain_cache()
Message-ID: <20160919030558.GI2279@X58A-UD3R>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
 <1473759914-17003-4-git-send-email-byungchul.park@lge.com>
 <CACbG308kitsX23FTCJiUDVpN2uusabHiN1ifao53yR5fM4Z7VA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACbG308kitsX23FTCJiUDVpN2uusabHiN1ifao53yR5fM4Z7VA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nilay Vaish <nilayvaish@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Thu, Sep 15, 2016 at 10:33:46AM -0500, Nilay Vaish wrote:
> On 13 September 2016 at 04:45, Byungchul Park <byungchul.park@lge.com> wrote:
> > @@ -2215,6 +2178,75 @@ cache_hit:
> >         return 1;
> >  }
> >
> > +/*
> > + * Look up a dependency chain.
> > + */
> > +static inline struct lock_chain *lookup_chain_cache(u64 chain_key)
> > +{
> > +       struct hlist_head *hash_head = chainhashentry(chain_key);
> > +       struct lock_chain *chain;
> > +
> > +       /*
> > +        * We can walk it lock-free, because entries only get added
> > +        * to the hash:
> > +        */
> > +       hlist_for_each_entry_rcu(chain, hash_head, entry) {
> > +               if (chain->chain_key == chain_key) {
> > +                       debug_atomic_inc(chain_lookup_hits);
> > +                       return chain;
> > +               }
> > +       }
> > +       return NULL;
> > +}
> 
> Byungchul,  do you think we should increment chain_lookup_misses
> before returning NULL from the above function?

Hello,

No, I don't think so.
It will be done in add_chain_cache().

Thank you,
Byungchul

> 
> --
> Nilay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
