Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43196C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:49:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C60412171F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:49:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="ADaTHuQp";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="qFlK/M0T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C60412171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A39A8E0004; Mon, 11 Mar 2019 21:49:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 451378E0002; Mon, 11 Mar 2019 21:49:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 319898E0004; Mon, 11 Mar 2019 21:49:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 063688E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:49:52 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d24so882372qtj.19
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:49:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YyPeyimv+Z2foouSsfMReWrGC3gFbrrEnqHChVRGudU=;
        b=ZW6IAzfKAeifPnz2eOv8gwCAJw4g6pzsjyXzA/UFrksQi5KnIsGT4lvGXJ3g1F291j
         LAx+PWMHo5y7UY6dESFzvy2IVY0KgXRQaW4smNX2PxGakAc53DzyOaBqB2C8/1EaOycT
         TJcTI2EkVRkdUQErjXDQ01LJNwQQ8tN9I3+55zcnPTh8anZspxk9JtcjxyixsKDtakBx
         Vy6/77QqG2MJw4mxAbvqhKfxXgfOUiLYcoVqFCp9uzFFAHcdYJEgpODi25DUu8hyJdXz
         3gwXPXmxAOv04GNiQPONvRgpSEXNWcMsqzLIfYaYQp1/toxXRpCGUqUiOBd/UOdNt+f9
         6vBQ==
X-Gm-Message-State: APjAAAViepfD9gt/Xonn7LQxGrqKoG6b+uc0hJCF1yWCvvYhKGkUa6bE
	E04xu0WeYILQ108z/5LXZ43/bfVYKp+w77zARt6QM39os/JkiueVxvH6L7YhTG3oMWNr3cRmKC/
	f7opO3yGF0QnMiUPoDI9RR2JgmYtMvTJScNxk+jMu1tssrzeszJI+J7HkuISXXgxkig==
X-Received: by 2002:ae9:ebd5:: with SMTP id b204mr26311088qkg.37.1552355391702;
        Mon, 11 Mar 2019 18:49:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzObBnq4/jRQ/a0GkB/YC1rFqv+IHj9pzZERNQbi85iTK12H1klCScT2w8Xe+YzjgWHG/+E
X-Received: by 2002:ae9:ebd5:: with SMTP id b204mr26311047qkg.37.1552355390674;
        Mon, 11 Mar 2019 18:49:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552355390; cv=none;
        d=google.com; s=arc-20160816;
        b=VSBepwqI1iKZPQE5iWQjqUbl1yguMVf7Jp7uCb/NoqYEfWEw5iRtZVc/zstUkbl74A
         hrlMxgGaKL9QAAyp8/Qy3AmnsRmIl5yqk3qZXt6P9yNx4gXReq8/09PJFa0a2yfdorzp
         V0M1JYf0qGrPCGqmJIpdH2TdTylYdQX5tOE5EaFQIHmCUhLvA3y7JACxdL/vnXqdCFMP
         po78RBTzzmlH6UxILbqHe8cFLJZA7NrvpmFXB9gPGDmkkgn03DrBomEHYLVhIJajQCDo
         UKGYt5U/oaxz+GN/W39DUQAoFewXqF4NZcVCgrcHsWUyGSyVsgV38kw8jGCewIzWzzkL
         Qb9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=YyPeyimv+Z2foouSsfMReWrGC3gFbrrEnqHChVRGudU=;
        b=dhmQCTHZe+ik1tRhCCpzKK9SAY2pQ9r/kNprB1rvuFywyDbOJksxtRRF17s4vnI1RM
         VYHzEd/gFUhIHqOsWfnw2TIURiJUJagR8lB3DIfA37dEa70u0uHFUlIL4yEQbww+StUf
         lyWFXKt2KgYD+RJNcvgKFShu+fjYLawot8JkALA4yh2h2QSZvVmpJTgKX0crz1Pnq72S
         kxy8Pe9a0q2cXIOQzA4o8LMJ3oJY5yFQJA9/ABvES8j3L7qAgbN7uWo4Nr16WxfwhE5H
         0jnWpZv3nBefe4loMs78yo7UxmIkIz5JPTpJIwQlV36LoJyvo4LD9NKc9QK10d3YRevI
         TOGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=ADaTHuQp;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="qFlK/M0T";
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id r21si381549qtr.49.2019.03.11.18.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 18:49:50 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=ADaTHuQp;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="qFlK/M0T";
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 539D5231A4;
	Mon, 11 Mar 2019 21:49:50 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 21:49:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=YyPeyimv+Z2foouSsfMReWrGC3g
	FbrrEnqHChVRGudU=; b=ADaTHuQpo2zF3di0te0iudLBbrnq3nl4t2V4EwufNSN
	FHZTJMDlbnBg3L3l+BOHqNiMolN+IC1CBrRaQQ+MkDoPOJ75hx4GQ9GI2PO0iPk/
	TefwTBU/3bM6FZt1FpcQDIbaIKRgatw5O9iq5e0S+595gq1mMXa7qj+t/XzZD6ar
	uMk0PLOvjoDBYr9aFLZjZC+csVlLfSm11pnIwyg/Al9EWrAQ+t+yzCzfLpvWdxSG
	ujVd/zFwM2V4u3NAhlUgcggbr/ln7J4+7rOQEQVpHHGicQ4n15hyU0ygzzkxR8Dk
	sGpg1F9lOdsvt/h/clOkprOA1NBN8HtK85Zp4TmijXw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=YyPeyi
	mv+Z2foouSsfMReWrGC3gFbrrEnqHChVRGudU=; b=qFlK/M0TDnVD1G6cf6ctWg
	D4Awhs5Sgx90Z0WZOrhsuQ0/gwP30txed85MT3/9eYZaSHs0Qa3iBT8TW441ZGYw
	pDp8apYyMqPe5UTYeHzBHT/Z/kJ77bp1lLlcnEs5SEiYFP5kxBbGQtLNLNrjbh4r
	gmzRpH7faJLsN/lvnRIz+Vikaeg1WeLHh7xg76kYiXSqb4pXO6/i2zd8juXffJ/U
	8LkincrqT4gPP2nS8jLEVAboOoPY7vNxP1RwAKroIrrCyG8+Ms6bny074ulbvxXp
	Zli6qEu9RuPYQYjGgb6h2dn+j5gCQczFuTx+TfMcd2K7GVCmqVD6eynkDE19K7lw
	==
X-ME-Sender: <xms:PhCHXK9csHdboGNR7-HO0TdhCzsRTOW-mW7FxjT6NqLirvVMzcgXng>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgdefiecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculddutddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgepud
X-ME-Proxy: <xmx:PhCHXOTlsKQZADrLlmNzJXkx6q09w_fUwIzVvDMrKtGbFBg5Z2Vz0A>
    <xmx:PhCHXJRct0V7GtYOPLBZ2gGlFslNnc6duv58ZePebXUl0JpLKvkA5Q>
    <xmx:PhCHXGZdEXggPjLwg05h9TajdeezeSB-50xQHlx6KBHmlEb6O64ERA>
    <xmx:PhCHXG-ZbSzY6uQGSeAOSU7ipkeh8CjWH56MX2CiN5gyKAjkDR9mUg>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6BB5310319;
	Mon, 11 Mar 2019 21:49:49 -0400 (EDT)
Date: Tue, 12 Mar 2019 12:49:24 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC 09/15] slub: Enable slab defragmentation using SMO
Message-ID: <20190312014924.GH9362@eros.localdomain>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-10-tobin@kernel.org>
 <20190311233523.GA20098@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311233523.GA20098@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 11:35:29PM +0000, Roman Gushchin wrote:
> On Fri, Mar 08, 2019 at 03:14:20PM +1100, Tobin C. Harding wrote:
> > If many objects are allocated with the slab allocator and freed in an
> > arbitrary order then the slab caches can become internally fragmented.
> > Now that the slab allocator supports movable objects we can defragment
> > any cache that has this feature enabled.
> > 
> > Slab defragmentation may occur:
> > 
> > 1. Unconditionally when __kmem_cache_shrink() is called on a slab cache
> >    by the kernel calling kmem_cache_shrink().
> > 
> > 2. Unconditionally through the use of the slabinfo command.
> > 
> > 	slabinfo <cache> -s
> > 
> > 3. Conditionally via the use of kmem_cache_defrag()
> > 
> > Use SMO when shrinking cache.  Currently when the kernel calls
> > kmem_cache_shrink() we curate the partial slabs list.  If object
> > migration is not enabled for the cache we still do this, if however SMO
> > is enabled, we attempt to move objects in partially full slabs in order
> > to defragment the cache.  Shrink attempts to move all objects in order
> > to reduce the cache to a single partial slab for each node.
> > 
> > kmem_cache_defrag() differs from shrink in that it operates dependent on
> > the defrag_used_ratio and only attempts to move objects if the number of
> > partial slabs exceeds MAX_PARTIAL (for each node).
> > 
> > Add function kmem_cache_defrag(int node).
> > 
> >    kmem_cache_defrag() only performs defragmentation if the usage ratio
> >    of the slab is lower than the configured percentage (sysfs file added
> >    in previous patch).  Fragmentation ratios are measured by calculating
> >    the percentage of objects in use compared to the total number of
> >    objects that the slab page can accommodate.
> > 
> >    The scanning of slab caches is optimized because the defragmentable
> >    slabs come first on the list. Thus we can terminate scans on the
> >    first slab encountered that does not support defragmentation.
> > 
> >    kmem_cache_defrag() takes a node parameter. This can either be -1 if
> >    defragmentation should be performed on all nodes, or a node number.
> > 
> >    Defragmentation may be disabled by setting defrag ratio to 0
> > 
> > 	echo 0 > /sys/kernel/slab/<cache>/defrag_used_ratio
> > 
> > In order for a cache to be defragmentable the cache must support object
> > migration (SMO).  Enabling SMO for a cache is done via a call to the
> > recently added function:
> > 
> > 	void kmem_cache_setup_mobility(struct kmem_cache *,
> > 				       kmem_cache_isolate_func,
> > 			               kmem_cache_migrate_func);
> > 
> > Co-developed-by: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > ---
> >  include/linux/slab.h |   1 +
> >  mm/slub.c            | 266 +++++++++++++++++++++++++++++++------------
> >  2 files changed, 194 insertions(+), 73 deletions(-)
> > 
> > diff --git a/include/linux/slab.h b/include/linux/slab.h
> > index 22e87c41b8a4..b9b46bc9937e 100644
> > --- a/include/linux/slab.h
> > +++ b/include/linux/slab.h
> > @@ -147,6 +147,7 @@ struct kmem_cache *kmem_cache_create_usercopy(const char *name,
> >  			void (*ctor)(void *));
> >  void kmem_cache_destroy(struct kmem_cache *);
> >  int kmem_cache_shrink(struct kmem_cache *);
> > +int kmem_cache_defrag(int node);
> >  
> >  void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
> >  void memcg_deactivate_kmem_caches(struct mem_cgroup *);
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 515db0f36c55..53dd4cb5b5a4 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -354,6 +354,12 @@ static __always_inline void slab_lock(struct page *page)
> >  	bit_spin_lock(PG_locked, &page->flags);
> >  }
> >  
> > +static __always_inline int slab_trylock(struct page *page)
> > +{
> > +	VM_BUG_ON_PAGE(PageTail(page), page);
> > +	return bit_spin_trylock(PG_locked, &page->flags);
> > +}
> > +
> >  static __always_inline void slab_unlock(struct page *page)
> >  {
> >  	VM_BUG_ON_PAGE(PageTail(page), page);
> > @@ -3959,79 +3965,6 @@ void kfree(const void *x)
> >  }
> >  EXPORT_SYMBOL(kfree);
> >  
> > -#define SHRINK_PROMOTE_MAX 32
> > -
> > -/*
> > - * kmem_cache_shrink discards empty slabs and promotes the slabs filled
> > - * up most to the head of the partial lists. New allocations will then
> > - * fill those up and thus they can be removed from the partial lists.
> > - *
> > - * The slabs with the least items are placed last. This results in them
> > - * being allocated from last increasing the chance that the last objects
> > - * are freed in them.
> > - */
> > -int __kmem_cache_shrink(struct kmem_cache *s)
> > -{
> > -	int node;
> > -	int i;
> > -	struct kmem_cache_node *n;
> > -	struct page *page;
> > -	struct page *t;
> > -	struct list_head discard;
> > -	struct list_head promote[SHRINK_PROMOTE_MAX];
> > -	unsigned long flags;
> > -	int ret = 0;
> > -
> > -	flush_all(s);
> > -	for_each_kmem_cache_node(s, node, n) {
> > -		INIT_LIST_HEAD(&discard);
> > -		for (i = 0; i < SHRINK_PROMOTE_MAX; i++)
> > -			INIT_LIST_HEAD(promote + i);
> > -
> > -		spin_lock_irqsave(&n->list_lock, flags);
> > -
> > -		/*
> > -		 * Build lists of slabs to discard or promote.
> > -		 *
> > -		 * Note that concurrent frees may occur while we hold the
> > -		 * list_lock. page->inuse here is the upper limit.
> > -		 */
> > -		list_for_each_entry_safe(page, t, &n->partial, lru) {
> > -			int free = page->objects - page->inuse;
> > -
> > -			/* Do not reread page->inuse */
> > -			barrier();
> > -
> > -			/* We do not keep full slabs on the list */
> > -			BUG_ON(free <= 0);
> > -
> > -			if (free == page->objects) {
> > -				list_move(&page->lru, &discard);
> > -				n->nr_partial--;
> > -			} else if (free <= SHRINK_PROMOTE_MAX)
> > -				list_move(&page->lru, promote + free - 1);
> > -		}
> > -
> > -		/*
> > -		 * Promote the slabs filled up most to the head of the
> > -		 * partial list.
> > -		 */
> > -		for (i = SHRINK_PROMOTE_MAX - 1; i >= 0; i--)
> > -			list_splice(promote + i, &n->partial);
> > -
> > -		spin_unlock_irqrestore(&n->list_lock, flags);
> > -
> > -		/* Release empty slabs */
> > -		list_for_each_entry_safe(page, t, &discard, lru)
> > -			discard_slab(s, page);
> > -
> > -		if (slabs_node(s, node))
> > -			ret = 1;
> > -	}
> > -
> > -	return ret;
> > -}
> > -
> >  #ifdef CONFIG_MEMCG
> >  static void kmemcg_cache_deact_after_rcu(struct kmem_cache *s)
> >  {
> > @@ -4411,6 +4344,193 @@ static void __move(struct page *page, void *scratch, int node)
> >  	s->migrate(s, vector, count, node, private);
> >  }
> >  
> > +/*
> > + * __defrag() - Defragment node.
> > + * @s: cache we are working on.
> > + * @node: The node to move objects from.
> > + * @target_node: The node to move objects to.
> > + * @ratio: The defrag ratio (percentage, between 0 and 100).
> > + *
> > + * Release slabs with zero objects and try to call the migration function
> > + * for slabs with less than the 'ratio' percentage of objects allocated.
> > + *
> > + * Moved objects are allocated on @target_node.
> > + *
> > + * Return: The number of partial slabs left on the node after the operation.
> > + */
> > +static unsigned long __defrag(struct kmem_cache *s, int node, int target_node,
> > +			      int ratio)
> 
> Maybe kmem_cache_defrag_node()?
> 
> > +{
> > +	struct kmem_cache_node *n = get_node(s, node);
> > +	struct page *page, *page2;
> > +	LIST_HEAD(move_list);
> > +	unsigned long flags;
> > +
> > +	if (node == target_node && n->nr_partial <= 1) {
> > +		/*
> > +		 * Trying to reduce fragmentation on a node but there is
> > +		 * only a single or no partial slab page. This is already
> > +		 * the optimal object density that we can reach.
> > +		 */
> > +		return n->nr_partial;
> > +	}
> > +
> > +	spin_lock_irqsave(&n->list_lock, flags);
> > +	list_for_each_entry_safe(page, page2, &n->partial, lru) {
> > +		if (!slab_trylock(page))
> > +			/* Busy slab. Get out of the way */
> > +			continue;
> > +
> > +		if (page->inuse) {
> > +			if (page->inuse > ratio * page->objects / 100) {
> > +				slab_unlock(page);
> > +				/*
> > +				 * Skip slab because the object density
> > +				 * in the slab page is high enough.
> > +				 */
> > +				continue;
> > +			}
> > +
> > +			list_move(&page->lru, &move_list);
> > +			if (s->migrate) {
> > +				/* Stop page being considered for allocations */
> > +				n->nr_partial--;
> > +				page->frozen = 1;
> > +			}
> > +			slab_unlock(page);
> > +		} else {	/* Empty slab page */
> > +			list_del(&page->lru);
> > +			n->nr_partial--;
> > +			slab_unlock(page);
> > +			discard_slab(s, page);
> > +		}
> > +	}
> > +
> > +	if (!s->migrate) {
> > +		/*
> > +		 * No defrag method. By simply putting the zaplist at the
> > +		 * end of the partial list we can let them simmer longer
> > +		 * and thus increase the chance of all objects being
> > +		 * reclaimed.
> > +		 *
> > +		 */
> > +		list_splice(&move_list, n->partial.prev);
> > +	}
> > +
> > +	spin_unlock_irqrestore(&n->list_lock, flags);
> > +
> > +	if (s->migrate && !list_empty(&move_list)) {
> > +		void **scratch = alloc_scratch(s);
> > +		struct page *page, *page2;
> > +
> > +		if (scratch) {
> > +			/* Try to remove / move the objects left */
> > +			list_for_each_entry(page, &move_list, lru) {
> > +				if (page->inuse)
> > +					__move(page, scratch, target_node);
> > +			}
> > +			kfree(scratch);
> > +		}
> > +
> > +		/* Inspect results and dispose of pages */
> > +		spin_lock_irqsave(&n->list_lock, flags);
> > +		list_for_each_entry_safe(page, page2, &move_list, lru) {
> > +			list_del(&page->lru);
> > +			slab_lock(page);
> > +			page->frozen = 0;
> > +
> > +			if (page->inuse) {
> > +				/*
> > +				 * Objects left in slab page, move it to the
> > +				 * tail of the partial list to increase the
> > +				 * chance that the freeing of the remaining
> > +				 * objects will free the slab page.
> > +				 */
> > +				n->nr_partial++;
> > +				list_add_tail(&page->lru, &n->partial);
> > +				slab_unlock(page);
> > +			} else {
> > +				slab_unlock(page);
> > +				discard_slab(s, page);
> > +			}
> > +		}
> > +		spin_unlock_irqrestore(&n->list_lock, flags);
> > +	}
> > +
> > +	return n->nr_partial;
> > +}
> > +
> > +/**
> > + * kmem_cache_defrag() - Defrag slab caches.
> > + * @node: The node to defrag or -1 for all nodes.
> > + *
> > + * Defrag slabs conditional on the amount of fragmentation in a page.
> > + */
> > +int kmem_cache_defrag(int node)
> > +{
> > +	struct kmem_cache *s;
> > +	unsigned long left = 0;
> > +
> > +	/*
> > +	 * kmem_cache_defrag may be called from the reclaim path which may be
> > +	 * called for any page allocator alloc. So there is the danger that we
> > +	 * get called in a situation where slub already acquired the slub_lock
> > +	 * for other purposes.
> > +	 */
> > +	if (!mutex_trylock(&slab_mutex))
> > +		return 0;
> > +
> > +	list_for_each_entry(s, &slab_caches, list) {
> > +		/*
> > +		 * Defragmentable caches come first. If the slab cache is not
> > +		 * defragmentable then we can stop traversing the list.
> > +		 */
> > +		if (!s->migrate)
> > +			break;
> > +
> > +		if (node == -1) {
> > +			int nid;
> > +
> > +			for_each_node_state(nid, N_NORMAL_MEMORY)
> > +				if (s->node[nid]->nr_partial > MAX_PARTIAL)
> > +					left += __defrag(s, nid, nid, s->defrag_used_ratio);
> > +		} else {
> > +			if (s->node[node]->nr_partial > MAX_PARTIAL)
> > +				left += __defrag(s, node, node, s->defrag_used_ratio);
> > +		}
> > +	}
> > +	mutex_unlock(&slab_mutex);
> > +	return left;
> > +}
> > +EXPORT_SYMBOL(kmem_cache_defrag);
> > +
> > +/**
> > + * __kmem_cache_shrink() - Shrink a cache.
> > + * @s: The cache to shrink.
> > + *
> > + * Reduces the memory footprint of a slab cache by as much as possible.
> > + *
> > + * This works by:
> > + *  1. Removing empty slabs from the partial list.
> > + *  2. Migrating slab objects to denser slab pages if the slab cache
> > + *  supports migration.  If not, reorganizing the partial list so that
> > + *  more densely allocated slab pages come first.
> > + *
> > + * Not called directly, called by kmem_cache_shrink().
> > + */
> > +int __kmem_cache_shrink(struct kmem_cache *s)
> > +{
> > +	int node;
> > +	int left = 0;
> 
> s/int/unsigned long? Or s/unsigned long/int in __defrag()?

Nice catch, thank you.

     Tobin

