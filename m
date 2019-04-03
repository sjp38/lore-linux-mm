Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 144C8C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 22:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CB2820882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 22:15:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="pWn6Lfbo";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="mt9Aq5PM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CB2820882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BACC06B0010; Wed,  3 Apr 2019 18:15:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B84896B0269; Wed,  3 Apr 2019 18:15:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A719E6B026A; Wed,  3 Apr 2019 18:15:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81B5D6B0010
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 18:15:04 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id b1so517067qtk.11
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 15:15:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PXNaA02TbTVP8tEtw5M4gplr/AS7L4pD4MCo/RGPH2o=;
        b=n/gVT7k074DXrLjFt+9/rDvUrL0SCQyVC0oI4xHTwGfwNvBirhNl39lWJsh6aYRadF
         qTKqE2rZtscUFBSE1nTCcWmQjW7uyrQF7RgKH0p8SeVrsBBtlDMbN4H8lJdnZ6aXoC9i
         Fyde5kbzIDFQHG5tVt5Z3KIlTY3QOkaY36WJ3gQHJZzSj8DBPitm4qMlEYX3XxTwUaKl
         THAwkTyqCsacVxjSpUyxCHgWprdyaoYSh2Bju4reVR7B+6C/zOQkt5v8UCBzRAhfkDBF
         295dZDL7WpbAQb1K8548dzajFamDjZPS1709hD1vhJFxtjqCHxXNDc2iUv5QjRQ4Nf/a
         wgoQ==
X-Gm-Message-State: APjAAAXqcwxNI7EbAuOYQhGLkyWhV7PcZBonU/hp5tBLWZqUitkRDwXk
	PLMVvKYQwGL/6eqoykFHMmZEyraC9AxoAv21oS49N87gM4RCeaj6Vdo9lyVc9UHE6kLDuFXhxOc
	eJFx+cLx9tL7b4K5cNeoMxyG+BEJ6kRFQ3f2C262QNcZ3TxwgGRvE6aLfzhX3YAVKAw==
X-Received: by 2002:ac8:2c89:: with SMTP id 9mr2197966qtw.287.1554329704252;
        Wed, 03 Apr 2019 15:15:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw88I8kHtDHDET2gLNe0RWRip8djSv5tomOsGwJYBufpVbbBhtDgnHEHbadChM5dArENsPO
X-Received: by 2002:ac8:2c89:: with SMTP id 9mr2197896qtw.287.1554329703251;
        Wed, 03 Apr 2019 15:15:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554329703; cv=none;
        d=google.com; s=arc-20160816;
        b=Hq7gaoORW0riJp7wWuJUVOoZsqcTdooxKKTqE4QZeh/q/buUEcuOjNtT0R77uHkhwB
         365ASQyyP8J/jX62zM7rqovuGPOZxiMx/bu7kFwuwMhVzVWauDB8exXqkRZV4wH9XPiM
         cNm6EadJUNCNG5ajHqwKPv/yfeeGb2OolQaalLLMgy1uP+grqsY0JLBX/C7eYFXP9ms2
         iiS0+tg7PiP5Uz4TTKaozzSPRObW7Ptb2I12Nx2yI59haRgZy4jTrUjgPGAcIy0Xkh8Z
         J5aV1+8d6iNar9oWAr539sEtQdP/6ubA+hKTkvoW0s7q+5CxlylrcMekI0uFbT9KlNs1
         wgHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=PXNaA02TbTVP8tEtw5M4gplr/AS7L4pD4MCo/RGPH2o=;
        b=pCkphPMvhx0+5FnIy2XdfjJjwkf3bgUOaPEfEUBXvdhpHI6tfgMJoYGnYxs9rqrE5S
         Vnu/aZviZ5nTP+6qIwgfXVfrEEZNOE71us+hNVqH2q5jbwRlmACPtC1mJ4Bs4x/39Q80
         y8lmkvZBYtPLMfuSWQtIJtLd/cxWcGKbOviQN7iQzJE7qWC63PnQRV7yuXXT8vXujGzA
         q/FMapfhCDJNSCQCSn/Cav80ugzZyVbwGkZFmwRhH2g7s6YCj2oq0BRkrdwUzIZsUJFM
         8fdSgN0D15FR+SvUOGMyiK2KzZ0vG7rWEKG9IwNCego/U4foClIpmcU2QwwU6L6vXxS0
         FTGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=pWn6Lfbo;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=mt9Aq5PM;
       spf=neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id d43si2664393qve.150.2019.04.03.15.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 15:15:03 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=pWn6Lfbo;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=mt9Aq5PM;
       spf=neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 8EDC822826;
	Wed,  3 Apr 2019 18:15:02 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Wed, 03 Apr 2019 18:15:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=PXNaA02TbTVP8tEtw5M4gplr/AS
	7L4pD4MCo/RGPH2o=; b=pWn6LfbomuOxdudwA2tKOa+TaalINDsz6jEoUyon3n1
	zsQolXPJxvyKxJ/E6rI/6Zme0837YDDHhVRis2MzC5GXWS4oWBQ70BPgUnz+otFk
	RmkS58JBtEMoeGX4Uc5aU8G2/jDLkllIeeMbw9blPuV3JgPcN+5DMcrFPTRfxIJ7
	aZGv/I3fQrit1RpbIc5zhMAqcUgcsr9qBo0qDbSsklZJn5gjVhVNIoKjPYQ5RmmJ
	j0k1Pv/2bhOBDb+CyOt0+X2fOc9LiuhFze7xIOw0M1R+UJ+b2ZQ7IipyNIcwxBzl
	zcQw9YHM/l2ed4kCH2WS6jadZtB/zEr7qoq2WVAo59A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=PXNaA0
	2TbTVP8tEtw5M4gplr/AS7L4pD4MCo/RGPH2o=; b=mt9Aq5PMcQzv4HWrGoBbYn
	1E1q1pGZHkdJ313aOjz8wC6qzalzVsL6NNXDvrZmK4WSG1Z+xyXyHW0aRiYzQDN1
	ulOb1nR5lB0VwyiwBHqA6Jt7mSu1V6fJLlO6CwS3M567NabOwhvpj2slJJ0OP07c
	HLc5W9F0QEYHVgnQlNOGxQKwtUgeBbfhvdGsr375Kk5mvN0y7C6eD6+pasXO+nWt
	CsScr7HvAgIgFsdIo/YlMxcLuXGB4HLIHGCgxWf52noOZNMhQctBnMTnpK+gI6Al
	d4TDxDxd+YkJL+D8Hfo4f1txOA9EKwR8BLA6NAQ6iy7SrI6b9rm2DLTwKYO2Lxmw
	==
X-ME-Sender: <xms:ZDClXOLnDWqyTfeeQJ9Yho3jnOwtqH9kIxKOALGldJ9lQEGrVUl2UA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggddtieculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenfghrlhcuvffnffculdduhedmnecujfgurhepfffhvffukfhf
    gggtuggjofgfsehttdertdforedvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrug
    hinhhgfdcuoehmvgesthhosghinhdrtggtqeenucfkphepuddvgedrudegledruddugedr
    keeinecurfgrrhgrmhepmhgrihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluh
    hsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:ZDClXN32XZRJqDB6BdqnhW-w9i90WnugOigf1bMgDPE5aPBvbSIdEg>
    <xmx:ZDClXEhAJxe57aqWMfZyGO6IFTUu6mfQTYl_OpAseWv0_xpPwllO0g>
    <xmx:ZDClXExRqay2ZBo9Fz7pT_uhNxpjN6byS1Klcbc28HduDiw33uzK4Q>
    <xmx:ZjClXBa887UBKWcEyoMKPE6R818T-GUAnp0pPnpj4fRLoctx9hBBQQ>
Received: from localhost (124-149-114-86.dyn.iinet.net.au [124.149.114.86])
	by mail.messagingengine.com (Postfix) with ESMTPA id 949B610319;
	Wed,  3 Apr 2019 18:14:59 -0400 (EDT)
Date: Thu, 4 Apr 2019 09:14:31 +1100
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
Subject: Re: [PATCH v5 2/7] slob: Respect list_head abstraction layer
Message-ID: <20190403221431.GA5025@eros.localdomain>
References: <20190402230545.2929-1-tobin@kernel.org>
 <20190402230545.2929-3-tobin@kernel.org>
 <20190403180026.GC6778@tower.DHCP.thefacebook.com>
 <20190403210327.GB23288@eros.localdomain>
 <20190403212322.GA5116@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403212322.GA5116@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 09:23:28PM +0000, Roman Gushchin wrote:
> On Thu, Apr 04, 2019 at 08:03:27AM +1100, Tobin C. Harding wrote:
> > On Wed, Apr 03, 2019 at 06:00:30PM +0000, Roman Gushchin wrote:
> > > On Wed, Apr 03, 2019 at 10:05:40AM +1100, Tobin C. Harding wrote:
> > > > Currently we reach inside the list_head.  This is a violation of the
> > > > layer of abstraction provided by the list_head.  It makes the code
> > > > fragile.  More importantly it makes the code wicked hard to understand.
> > > > 
> > > > The code reaches into the list_head structure to counteract the fact
> > > > that the list _may_ have been changed during slob_page_alloc().  Instead
> > > > of this we can add a return parameter to slob_page_alloc() to signal
> > > > that the list was modified (list_del() called with page->lru to remove
> > > > page from the freelist).
> > > > 
> > > > This code is concerned with an optimisation that counters the tendency
> > > > for first fit allocation algorithm to fragment memory into many small
> > > > chunks at the front of the memory pool.  Since the page is only removed
> > > > from the list when an allocation uses _all_ the remaining memory in the
> > > > page then in this special case fragmentation does not occur and we
> > > > therefore do not need the optimisation.
> > > > 
> > > > Add a return parameter to slob_page_alloc() to signal that the
> > > > allocation used up the whole page and that the page was removed from the
> > > > free list.  After calling slob_page_alloc() check the return value just
> > > > added and only attempt optimisation if the page is still on the list.
> > > > 
> > > > Use list_head API instead of reaching into the list_head structure to
> > > > check if sp is at the front of the list.
> > > > 
> > > > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > > > ---
> > > >  mm/slob.c | 51 +++++++++++++++++++++++++++++++++++++--------------
> > > >  1 file changed, 37 insertions(+), 14 deletions(-)
> > > > 
> > > > diff --git a/mm/slob.c b/mm/slob.c
> > > > index 307c2c9feb44..07356e9feaaa 100644
> > > > --- a/mm/slob.c
> > > > +++ b/mm/slob.c
> > > > @@ -213,13 +213,26 @@ static void slob_free_pages(void *b, int order)
> > > >  }
> > > >  
> > > >  /*
> > > > - * Allocate a slob block within a given slob_page sp.
> > > > + * slob_page_alloc() - Allocate a slob block within a given slob_page sp.
> > > > + * @sp: Page to look in.
> > > > + * @size: Size of the allocation.
> > > > + * @align: Allocation alignment.
> > > > + * @page_removed_from_list: Return parameter.
> > > > + *
> > > > + * Tries to find a chunk of memory at least @size bytes big within @page.
> > > > + *
> > > > + * Return: Pointer to memory if allocated, %NULL otherwise.  If the
> > > > + *         allocation fills up @page then the page is removed from the
> > > > + *         freelist, in this case @page_removed_from_list will be set to
> > > > + *         true (set to false otherwise).
> > > >   */
> > > > -static void *slob_page_alloc(struct page *sp, size_t size, int align)
> > > > +static void *slob_page_alloc(struct page *sp, size_t size, int align,
> > > > +			     bool *page_removed_from_list)
> > > 
> > > Hi Tobin!
> > > 
> > > Isn't it better to make slob_page_alloc() return a bool value?
> > > Then it's easier to ignore the returned value, no need to introduce "_unused".
> > 
> > We need a pointer to the memory allocated also so AFAICS its either a
> > return parameter for the memory pointer or a return parameter to
> > indicate the boolean value?  Open to any other ideas I'm missing.
> > 
> > In a previous crack at this I used a double pointer to the page struct
> > then set that to null to indicate the boolean value.  I think the
> > explicit boolean parameter is cleaner.
> 
> Yeah, sorry, it's my fault. Please, ignore this comment.
> Bool* argument is perfectly fine here.

Cheers man, no sweat.  I appreciate you looking at this stuff.

	Tobin

