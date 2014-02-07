Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1FAFB6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:44:22 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so1688278eaj.21
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:44:21 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id s6si9550673eel.161.2014.02.07.09.44.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 09:44:20 -0800 (PST)
Date: Fri, 7 Feb 2014 12:44:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2014-02-05 list_lru_add lockdep splat
Message-ID: <20140207174417.GF6963@cmpxchg.org>
References: <alpine.LSU.2.11.1402051944210.27326@eggly.anvils>
 <20140206164136.GC6963@cmpxchg.org>
 <alpine.LSU.2.11.1402061413330.27968@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402061413330.27968@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 06, 2014 at 02:18:24PM -0800, Hugh Dickins wrote:
> On Thu, 6 Feb 2014, Johannes Weiner wrote:
> > On Wed, Feb 05, 2014 at 07:50:10PM -0800, Hugh Dickins wrote:
> > > ======================================================
> > > [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
> > > 3.14.0-rc1-mm1 #1 Not tainted
> > > ------------------------------------------------------
> > > kswapd0/48 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
> > >  (&(&lru->node[i].lock)->rlock){+.+.-.}, at: [<ffffffff81117064>] list_lru_add+0x80/0xf4
> > > 
> > > s already holding:
> > >  (&(&mapping->tree_lock)->rlock){..-.-.}, at: [<ffffffff81108c63>] __remove_mapping+0x3b/0x12d
> > > which would create a new lock dependency:
> > >  (&(&mapping->tree_lock)->rlock){..-.-.} -> (&(&lru->node[i].lock)->rlock){+.+.-.}
> > 
> > Thanks for the report.  The first time I saw this on my own machine, I
> > misinterpreted it as a false positive (could have sworn the "possible
> > unsafe scenario" section looked different, too).
> > 
> > Looking at it again, there really is a deadlock scenario when the
> > shadow shrinker races with a page cache insertion or deletion and is
> > interrupted by the IO completion handler while holding the list_lru
> > lock:
> > 
> > >  Possible interrupt unsafe locking scenario:
> > > 
> > >        CPU0                    CPU1
> > >        ----                    ----
> > >   lock(&(&lru->node[i].lock)->rlock);
> > >                                local_irq_disable();
> > >                                lock(&(&mapping->tree_lock)->rlock);
> > >                                lock(&(&lru->node[i].lock)->rlock);
> > >   <Interrupt>
> > >     lock(&(&mapping->tree_lock)->rlock);
> > 
> > Could you please try with the following patch?
> 
> Sure, that fixes it for me (with one trivial correction appended), thanks.
> But don't imagine I've given it anything as demanding as thought!
>
> --- hannes/mm/list_lru.c	2014-02-06 08:50:25.104032277 -0800
> +++ hughd/mm/list_lru.c	2014-02-06 08:58:36.884043965 -0800
> @@ -143,7 +143,7 @@ int list_lru_init_key(struct list_lru *l
>  	}
>  	return 0;
>  }
> -EXPORT_SYMBOL_GPL(list_lru_init);
> +EXPORT_SYMBOL_GPL(list_lru_init_key);
>  
>  void list_lru_destroy(struct list_lru *lru)
>  {

Oops, yes, I usually do non-modular builds.  Thanks, will merge this
into the above patch unless Andrew beats me to it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
