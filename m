Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34CFDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:38:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA51C2186A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:38:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="C4t2ZAcr";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="C8flOQXS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA51C2186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8760A6B0003; Thu, 14 Mar 2019 16:38:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FE336B0005; Thu, 14 Mar 2019 16:38:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A04C6B0006; Thu, 14 Mar 2019 16:38:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45B5E6B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 16:38:41 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z34so1521516qtz.14
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 13:38:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4W86yzgBmI60fQ5wjGxGK8pZF6QZHKew4cQhSuRbaSg=;
        b=f3ksBUJJ+Jo6Nmfkx9dt0eBJdgBebvpHhNyDg3nnn11uQtqPX9SsXMCnb2XBdiPYXB
         Xr4nQRCqdx2Q5TbLLkkHxk/jCdTMbOXLl2Ol1r1IO7G3Yb40s7J4tkc0qqyXV4+Lir4D
         r+KoAszsNsXZM9oD0+IgdJknoKIpDkxuMz4vf+lbIkJP0PO8MlD7D5GUnxL2ppETdF5F
         M7xxJFGfiyJ0Zeq7jNVFT9F4DoTy9ivri4/hOK1kFjBiUHEDeY7eW6QmHb2MngN/zxSi
         RAZl+3ggQXIiSwien5X5S8kglyHcgouBiP5s2VO36ibDxiPm5QeMYaoTO+dMXo4iBLUe
         qgwQ==
X-Gm-Message-State: APjAAAVOOZwc/12FUpctwA+qqxN5JYdKWqOCINUQD69ORPyftmY4x4Zg
	uAJUYx/GwRgxjTW6lyBZftG/3To4Dg+9vfzu6TsTUfPuPXK5H9eFtOde2YygJyn/0esJtYhWSlw
	hVIAXh9j3CYBJxPvgOdCFSwqRShXFLvac1ZO7cxODfM2zRUrHQsOQBqvBSSt0QAvu4w==
X-Received: by 2002:a37:b704:: with SMTP id h4mr169450qkf.39.1552595921007;
        Thu, 14 Mar 2019 13:38:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzg4AKvQuw8TU6FU79PH+f/y+88yfo1I+g687vduczX3dzcHyx7eoh4QDfEUsAfKeBGXRl8
X-Received: by 2002:a37:b704:: with SMTP id h4mr169409qkf.39.1552595920274;
        Thu, 14 Mar 2019 13:38:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552595920; cv=none;
        d=google.com; s=arc-20160816;
        b=uCQhC3ofw1d2Vl9e2FgbI9OzmMtEFG2C7cKteC746sLqiHIr0EDEvIcFw7fyrGtZeb
         dtfANZrX4pNlUwDFDgprv85h5hkpb9cSUiVr0va5dkHZHLMrrvpWZJ0jo6zmHphmUGOb
         gv7s6RrVz7yFjFLmMWdS+tEf+d4uYHgMEsHjI1OoLInsAOZ9ZPIB5nUdG53knuLETOh+
         zOlqrXPdLbjeDu4/mRivC5Sa5ZoqP3sVaJBoK1ifbgPf4DJ5b9ptzokSAI9kFJ2fH8iq
         C8+smTtg8RKWyJMNHXPd0TZyzrpkCq6QGDzKZHnQT95bmJZ53oc7+Jgyl8I8J5rBVIRt
         yvAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=4W86yzgBmI60fQ5wjGxGK8pZF6QZHKew4cQhSuRbaSg=;
        b=Dz/fvQBLjcJFRaugSis5abou55nL+6Bh8oMzdB21gjEh9hpd2CBnOxn7YQujMGEZrN
         WLHOBaoWVks0egjvIZLzkoIci1HIysR0B04K3hhe7bKdT+fX6yybzv3EcV4rMKRf4U1b
         Wv4+yNWMQ0N2ocq59M82rcXuY0fRGBoxpdlHm4e7vbONIQEUD6RAQhnfTf6Zay+0XVYf
         3fE75TouRCeesQAzuZm/Gnxcls2yg6yBjRvCRfJTDQOPnABwS1ayqbJjXv3vD2LS1IvQ
         H0TSKAYTNyTWIofc6QyhDPDkRKiin8dfidGARzXSDrYPtYGl1zzQhn1Nu4moPQfI+HXI
         Z/ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=C4t2ZAcr;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=C8flOQXS;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id b49si1077404qtb.6.2019.03.14.13.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 13:38:40 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=C4t2ZAcr;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=C8flOQXS;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id C02F821347;
	Thu, 14 Mar 2019 16:38:39 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Thu, 14 Mar 2019 16:38:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=4W86yzgBmI60fQ5wjGxGK8pZF6Q
	ZHKew4cQhSuRbaSg=; b=C4t2ZAcrxhJUM8MAPqV4iBkYgDjl2glRTV2OfcHZi01
	Rdn3fhaaIbeh9vntPVx/HMxx6MtS4MzuDpJ6WxVhSBraCDjbMfKnNI1jTUHww+MK
	jAnpsV2AoEtwoiVZgCPKz5iIyfHBifFZrZ3JHCaNUpjxfqBOo/epfcD0kxChCBMh
	O+Jv91MF1oJzB9lBgzTdeAW7yZJz6+dkacI+li54ijCVXiNfeCrnbRHaWn87VimY
	fPNA7qOHQu3cR/Zh/WJIdK87QfzCitUtWckzyRK7ZhRh62Y7BIyXt2hAaiLSkX3p
	Ww23qIqX4Wkg3B3q/YZaOYLcW89PDNihLhwE56VO4jA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=4W86yz
	gBmI60fQ5wjGxGK8pZF6QZHKew4cQhSuRbaSg=; b=C8flOQXS4ObL5z8WR4MY/V
	/1dtvsvGY8qdzXytlrj0N08J3xXS+QYtbU3H9l3A09tNLh9YhF0ENWQV4MuRs7pu
	G/vG09wzdZAcJZJLAnmp7DQ37W2UpXoJI3Zu7TZkqbj/SNw7xU07t3DCsBCFgy12
	LXMa6T9umfGv/PdAVg02dPtTR76CTVolmp7KFPOsJuHPgoYfZbkaNYpU9E9Vn/uI
	ehHF+uZUY8rXl/Z2qPIhXQuKUMbHTJKwdYTcY1LHa/z2mTCoxuoOzdK8E3xalKV+
	4epmbZG9lTWnIha+GjeBDDCq/d6MWXZNIVobT5I+h04O2+xVBWrqHxCngMgik8eg
	==
X-ME-Sender: <xms:zLuKXDanhOKMFpM7uSrAoIm74TVv2WJzYEBUGlUvgSHFru1oEygO-A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrheefgdegkecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculddutddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:zLuKXCQ1YLvO5FN9KJus1cjVqXVk1wD2FeX9MQ4IajbX9vOcHhXj3Q>
    <xmx:zLuKXDT_vMM6V3RgRKj6DTkDSCedKjDEZXmF7zqmZ_n8AU6hR2_42Q>
    <xmx:zLuKXF0YYmj8JrZnSZxRLy0FQ8qzGvwNGVoJoAKZlz5hGGphYRhvOA>
    <xmx:z7uKXOZY-hDvRLsNUJEv7qc0XSrzUBK2nUJHR5TdhmHKu82d550_CA>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id ADBFDE455C;
	Thu, 14 Mar 2019 16:38:35 -0400 (EDT)
Date: Fri, 15 Mar 2019 07:38:09 +1100
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
Message-ID: <20190314203809.GA22506@eros.localdomain>
References: <20190314053135.1541-1-tobin@kernel.org>
 <20190314053135.1541-4-tobin@kernel.org>
 <20190314185219.GA6441@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314185219.GA6441@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 06:52:25PM +0000, Roman Gushchin wrote:
> On Thu, Mar 14, 2019 at 04:31:31PM +1100, Tobin C. Harding wrote:
> > Currently we use the page->lru list for maintaining lists of slabs.  We
> > have a list_head in the page structure (slab_list) that can be used for
> > this purpose.  Doing so makes the code cleaner since we are not
> > overloading the lru list.
> > 
> > The slab_list is part of a union within the page struct (included here
> > stripped down):
> > 
> > 	union {
> > 		struct {	/* Page cache and anonymous pages */
> > 			struct list_head lru;
> > 			...
> > 		};
> > 		struct {
> > 			dma_addr_t dma_addr;
> > 		};
> > 		struct {	/* slab, slob and slub */
> > 			union {
> > 				struct list_head slab_list;
> > 				struct {	/* Partial pages */
> > 					struct page *next;
> > 					int pages;	/* Nr of pages left */
> > 					int pobjects;	/* Approximate count */
> > 				};
> > 			};
> > 		...
> > 
> > Here we see that slab_list and lru are the same bits.  We can verify
> > that this change is safe to do by examining the object file produced from
> > slob.c before and after this patch is applied.
> > 
> > Steps taken to verify:
> > 
> >  1. checkout current tip of Linus' tree
> > 
> >     commit a667cb7a94d4 ("Merge branch 'akpm' (patches from Andrew)")
> > 
> >  2. configure and build (select SLOB allocator)
> > 
> >     CONFIG_SLOB=y
> >     CONFIG_SLAB_MERGE_DEFAULT=y
> > 
> >  3. dissasemble object file `objdump -dr mm/slub.o > before.s
> >  4. apply patch
> >  5. build
> >  6. dissasemble object file `objdump -dr mm/slub.o > after.s
> >  7. diff before.s after.s
> > 
> > Use slab_list list_head instead of the lru list_head for maintaining
> > lists of slabs.
> > 
> > Reviewed-by: Roman Gushchin <guro@fb.com>
> > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > ---
> >  mm/slob.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/slob.c b/mm/slob.c
> > index 39ad9217ffea..94486c32e0ff 100644
> > --- a/mm/slob.c
> > +++ b/mm/slob.c
> > @@ -112,13 +112,13 @@ static inline int slob_page_free(struct page *sp)
> >  
> >  static void set_slob_page_free(struct page *sp, struct list_head *list)
> >  {
> > -	list_add(&sp->lru, list);
> > +	list_add(&sp->slab_list, list);
> >  	__SetPageSlobFree(sp);
> >  }
> >  
> >  static inline void clear_slob_page_free(struct page *sp)
> >  {
> > -	list_del(&sp->lru);
> > +	list_del(&sp->slab_list);
> >  	__ClearPageSlobFree(sp);
> >  }
> >  
> > @@ -282,7 +282,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
> >  
> >  	spin_lock_irqsave(&slob_lock, flags);
> >  	/* Iterate through each partially free page, try to find room */
> > -	list_for_each_entry(sp, slob_list, lru) {
> > +	list_for_each_entry(sp, slob_list, slab_list) {
> >  #ifdef CONFIG_NUMA
> >  		/*
> >  		 * If there's a node specification, search for a partial
> 
> 
> Hi Tobin!
> 
> How about list_rotate_to_front(&next->lru, slob_list) from the previous patch?
> Shouldn't it use slab_list instead of lru too?

Thanks Roman, my mistake - one too many rebases.  I hate when I drop the
ball like this.

Tobin.

