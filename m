Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2E67C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:42:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CBF320854
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:42:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="MNTzlg5m";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="52x4htrS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CBF320854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 149C46B0003; Thu, 14 Mar 2019 16:42:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F7056B0005; Thu, 14 Mar 2019 16:42:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F00DB6B0006; Thu, 14 Mar 2019 16:42:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2E546B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 16:42:50 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y6so5926897qke.1
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 13:42:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GPcuQpeZUQypxhfb/X1fuW5HqXqyjX+cimfaauJosb8=;
        b=oAhcBYWPnnwPrYo8VDWW7RVbh6r4a/sDp8tfAE/3Bg5kMY1nI2tta6H7gxfBSjbsVM
         gb/ykrIEc917ggl8DO3zsQZI+Gj/hUPgkEqMy72iCfA5N3yoYZ9frY8ExC/Fl8+I1LHz
         GTcBCqUp1XEL44+H44L0zWEE6/PgZykJ8ZJP3kHX82d7/pP0Bk4iJ/bepruniKlPaKPX
         4X8V/AtNqYSnM+J2KWYY7gmwlDaWVOH1tWJUWskHKlT13uaq0zfy2FKMaIbSizeP028B
         yvNyr0lcbHS2/VZYrApuH5M1pZqDFmIhDk5RiwmX0fJyPxNEQPp++AJuJgjGbCQIGbPU
         9jUg==
X-Gm-Message-State: APjAAAXm9rKJH1RGc1BKTZnQ6lMJB24Ei/QN3IYXOKW4fN8OPieTficL
	4wTQXGERdt0wwNqHqDlx9IPTMfaD4zScP5ntqCZ4QF6dGUKlroZO2QEpn1T+pfD5i8LzOv7pKuC
	WS3tm8GrhKxgJYkljRlJyLBTawUGS213RimJqJp+AeVAbqF4raPtQRD7yVpyK2ZBhDQ==
X-Received: by 2002:aed:3c75:: with SMTP id u50mr62536qte.128.1552596170568;
        Thu, 14 Mar 2019 13:42:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwx2dA9mNDFd15yNLicnDkP8vNxFf1bVtJUt3v+SCLHcClzysjyml9VBAO2dj88vpdBmlyr
X-Received: by 2002:aed:3c75:: with SMTP id u50mr62496qte.128.1552596169831;
        Thu, 14 Mar 2019 13:42:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552596169; cv=none;
        d=google.com; s=arc-20160816;
        b=nxfYp7VvS09O9MZdQ3CzJ0j+YMH3I49a6gBbKlzZNKF3qAW2ixXd3BVupFMRhk796e
         cO23ls6aLwLH3ky9gfnfon0Tw7zmwCtRag1cAzetmmaZB3AJvCt5USih1sSi6krHeOrS
         hJuI783X1GwksGHn3FObCip8aklhaRKwMnGGMJNeMWMGvuQpiU2Yb3tOE3npMQxEzNgC
         faLXeOssJGDEhu8ssAFPLMADaRoW1+FnTjHt58tIhQ8RtzLLHjgzfWtDftfyP/VebSei
         1ZVeX1kXt8t2MIl+wVRUvlWQ9UdGsJhPHq0xXpypThuxPpBFJc2XOylXAXhjHmq3SS1e
         fZ4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=GPcuQpeZUQypxhfb/X1fuW5HqXqyjX+cimfaauJosb8=;
        b=f/G3Ep2ID+Z9IXSlNoMxq0xRPMoyKBEJ4SMnWQ1PtQU8iZGGDXWXOkv0PorwDCQUYa
         7MSWcrdxJPJaJxxtVAHm6tCzQi8lfb2ppvvJgi5WgfXfCswf3DNIqWq8SwV5M9tIDUtu
         Huwbw8MFmkWYSLSpB3CFiOgQDMp7NBp8XyYiQGT3fAC3jZjEz2ic0yGE1Bi/1GdXgKGi
         nD9yLM6M6E1eRDPk5cspRGKXhywLAtQIZGBTLsua4GpeGf7VF9dWS/sHcZAUOItzZzs5
         pto3KMc/1VGCNcvQ8+X9c4v/P3pZYB8kNc2no3Np/dqhkOEuxGZ+3HLsaTEK0JzNChQ8
         vVGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=MNTzlg5m;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=52x4htrS;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id k59si39411qte.324.2019.03.14.13.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 13:42:49 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=MNTzlg5m;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=52x4htrS;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 85DE521FB6;
	Thu, 14 Mar 2019 16:42:49 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Thu, 14 Mar 2019 16:42:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=GPcuQpeZUQypxhfb/X1fuW5HqXq
	yjX+cimfaauJosb8=; b=MNTzlg5meF3G9z50WAZaxFf1weg9PT9owKQuD3XVIqK
	RbMcNT1/EYyXezO7u5W/rmNdgNR8WO1yXmby41sZW+aHBoEz/Q22eDTjjEpLW58f
	1L2HxADpuCEv6MbTKpAvTFQVASeiQpgGS2663aJpSGG7rMJgMnRIihwFuTxir9ZM
	uTJ9FhGffvJYpUhsCll7Z+snjwqcUN9kVzfKBKxjS6vJ/ABXSor58rGnPUqm0XL0
	SwKg/vWEIgbP+P/35ZJKHaxI2a9Vrsw3PPGyKcVvwMWyfMRlLlLcPZm2f5uCiPln
	wwr/j6oXPs9BBo+bYg6WpuylsVpb6WnarheembZSxtw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=GPcuQp
	eZUQypxhfb/X1fuW5HqXqyjX+cimfaauJosb8=; b=52x4htrSL9JL+Dzv4JKzHu
	FAB0yBEcXMEGA5F5fs2b64NNPzxffGiO2NmLAf3e1arFC92KcsL1E2tJJ2PSrYxm
	jT8nod5JfqvJIVemBrq6crqfn/V2e2lBjCvUkaNrw4nN1+42NscH7rEDzmwneHMN
	lEtDxvpAp2sLeDdEdu8fDSlraUy4sl1Vy46BC6vllWy2fhqfhlDad9chM0NWhuB4
	jTzCOM9EmI9Lj2PMW3w3RrvKUVZ9k0Er1+ANE0M76DTznAW/fibgpEcDbX+H6YhA
	ifXbovF6d/ZERJj93L014Vkj4HlYfnM3bH/rPfux4bj4lCQjORBMcqIE6MeSgsnw
	==
X-ME-Sender: <xms:x7yKXKixbnMJlv-Dprsma6vc501R4nTUIcGP9WMggL_KUuJoLLULDA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrheefgdehtdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculddutddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:x7yKXDTfG39-FcPY5ogcixdigII8mCwqJgYGDqM9S3drUd8JCiVndQ>
    <xmx:x7yKXH8RNAPuuVOTn1qBp2RrayGhdSSPq0EUKECQk6oma0lAd5qnFA>
    <xmx:x7yKXE-pUeMReVX6wQkQOXRtkwL2eHELLvbZwhtcLjpdOxbx_iGOiw>
    <xmx:ybyKXH-Gl0TGsHanyN3DTDzlQfu6Q7zNGF4unQyRI0_RdyNOV1vPpA>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id D39011030F;
	Thu, 14 Mar 2019 16:42:46 -0400 (EDT)
Date: Fri, 15 Mar 2019 07:42:20 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v3 3/7] slob: Use slab_list instead of lru
Message-ID: <20190314204220.GB22506@eros.localdomain>
References: <20190314053135.1541-1-tobin@kernel.org>
 <20190314053135.1541-4-tobin@kernel.org>
 <20190314185219.GA6441@tower.DHCP.thefacebook.com>
 <20190314203809.GA22506@eros.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314203809.GA22506@eros.localdomain>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 07:38:09AM +1100, Tobin C. Harding wrote:
> On Thu, Mar 14, 2019 at 06:52:25PM +0000, Roman Gushchin wrote:
> > On Thu, Mar 14, 2019 at 04:31:31PM +1100, Tobin C. Harding wrote:
> > > Currently we use the page->lru list for maintaining lists of slabs.  We
> > > have a list_head in the page structure (slab_list) that can be used for
> > > this purpose.  Doing so makes the code cleaner since we are not
> > > overloading the lru list.
> > > 
> > > The slab_list is part of a union within the page struct (included here
> > > stripped down):
> > > 
> > > 	union {
> > > 		struct {	/* Page cache and anonymous pages */
> > > 			struct list_head lru;
> > > 			...
> > > 		};
> > > 		struct {
> > > 			dma_addr_t dma_addr;
> > > 		};
> > > 		struct {	/* slab, slob and slub */
> > > 			union {
> > > 				struct list_head slab_list;
> > > 				struct {	/* Partial pages */
> > > 					struct page *next;
> > > 					int pages;	/* Nr of pages left */
> > > 					int pobjects;	/* Approximate count */
> > > 				};
> > > 			};
> > > 		...
> > > 
> > > Here we see that slab_list and lru are the same bits.  We can verify
> > > that this change is safe to do by examining the object file produced from
> > > slob.c before and after this patch is applied.
> > > 
> > > Steps taken to verify:
> > > 
> > >  1. checkout current tip of Linus' tree
> > > 
> > >     commit a667cb7a94d4 ("Merge branch 'akpm' (patches from Andrew)")
> > > 
> > >  2. configure and build (select SLOB allocator)
> > > 
> > >     CONFIG_SLOB=y
> > >     CONFIG_SLAB_MERGE_DEFAULT=y
> > > 
> > >  3. dissasemble object file `objdump -dr mm/slub.o > before.s
> > >  4. apply patch
> > >  5. build
> > >  6. dissasemble object file `objdump -dr mm/slub.o > after.s
> > >  7. diff before.s after.s
> > > 
> > > Use slab_list list_head instead of the lru list_head for maintaining
> > > lists of slabs.
> > > 
> > > Reviewed-by: Roman Gushchin <guro@fb.com>
> > > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > > ---
> > >  mm/slob.c | 8 ++++----
> > >  1 file changed, 4 insertions(+), 4 deletions(-)
> > > 
> > > diff --git a/mm/slob.c b/mm/slob.c
> > > index 39ad9217ffea..94486c32e0ff 100644
> > > --- a/mm/slob.c
> > > +++ b/mm/slob.c
> > > @@ -112,13 +112,13 @@ static inline int slob_page_free(struct page *sp)
> > >  
> > >  static void set_slob_page_free(struct page *sp, struct list_head *list)
> > >  {
> > > -	list_add(&sp->lru, list);
> > > +	list_add(&sp->slab_list, list);
> > >  	__SetPageSlobFree(sp);
> > >  }
> > >  
> > >  static inline void clear_slob_page_free(struct page *sp)
> > >  {
> > > -	list_del(&sp->lru);
> > > +	list_del(&sp->slab_list);
> > >  	__ClearPageSlobFree(sp);
> > >  }
> > >  
> > > @@ -282,7 +282,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
> > >  
> > >  	spin_lock_irqsave(&slob_lock, flags);
> > >  	/* Iterate through each partially free page, try to find room */
> > > -	list_for_each_entry(sp, slob_list, lru) {
> > > +	list_for_each_entry(sp, slob_list, slab_list) {
> > >  #ifdef CONFIG_NUMA
> > >  		/*
> > >  		 * If there's a node specification, search for a partial
> > 
> > 
> > Hi Tobin!
> > 
> > How about list_rotate_to_front(&next->lru, slob_list) from the previous patch?
> > Shouldn't it use slab_list instead of lru too?
> 
> Thanks Roman, my mistake - one too many rebases.  I hate when I drop the
> ball like this.

Oh that's right, its a union so it still builds and boots - I was
thinking that I had rebased and not built.  I guess that's just a fumble
instead of a complete ball drop.

Thanks for the careful review all the same.

	Tobin

