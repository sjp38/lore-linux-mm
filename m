Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAAFFC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 21:04:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5897A206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 21:04:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="CKIrNj18";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="3LGBcvf1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5897A206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 884B86B026C; Wed,  3 Apr 2019 17:04:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8356B6B026D; Wed,  3 Apr 2019 17:04:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FDAF6B026F; Wed,  3 Apr 2019 17:04:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49C4E6B026C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 17:04:03 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d139so342656qke.20
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 14:04:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ii4vLzr0/hkZhS9GYDt0aqtb1MVcJQwo2KZPugK4eL0=;
        b=kaiekne3LSZ4YIDG4jrlzOrEM5Mxrseo5P8UztZVO4LX1pw9iBPHRZ3E98kHvdBkio
         MiOPtkeyEKNnnAXSxGzD3GlLT9+dT0PmtOoApJblHgCe+LOANT2fvxyBeVzUQO3DlrM2
         HSHuv/flDvIRvptJucZ/pT9ZGMXtgn2usW4GzocBMjv5cbfUbycY60vwVwO55WZsp3+s
         CzrpI/B1gvvbxMaACrOPUZht6jkePwnmMFCWS+irkqEhVjdBQtFUltoETHzpDHVBxOMP
         X3KO3xTxHPBAHTRadDmQEQIMlmbvu1TeYcF7qaUGZQFuuZUFV5giUNAkhjaMbL9gxcdI
         AowA==
X-Gm-Message-State: APjAAAV7ywpouJ5t30slvHrsDl3S0Rjb6yT8gRMN3odK/Udxf5B54u7c
	wraaaWSqbXPS3WBfbou6WYVpKYl1HQk30etIZyDQMpfJjY91faBQ1OFdmYkAEj3BLnUq7fsDs6P
	Bga/HhPSsbwxjRJPhPnhfPG7ry6lSA06ON484B+BSOr+Uzo2RRuJ1NHRPNgP86iHZug==
X-Received: by 2002:ac8:1638:: with SMTP id p53mr1976598qtj.257.1554325443028;
        Wed, 03 Apr 2019 14:04:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkxvGVYzf/XU8bClyxpKIDRB2gjeFmxRXJRTCePcdA6MTgC0bf3WWOFoYuLoS377Z4+X81
X-Received: by 2002:ac8:1638:: with SMTP id p53mr1976539qtj.257.1554325442360;
        Wed, 03 Apr 2019 14:04:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554325442; cv=none;
        d=google.com; s=arc-20160816;
        b=YVflO8p3GurbmuF2UDKIpTMIMZnMQnm+iGlK7YG4vLgWS3GP4PTdWcj0GjzTssaz0c
         Sok5R6JfncIWpaxPyyKHsSC/8VeMhFXWf7b9RT2UUv1XDQg+mkEX0Z45SesZcPPbcQfv
         Tt2vBegFfxK0ecBtpC+ws1OUA2lMONSFp6ikHXlwoNhYA+f7WHzGrocPDBVjZZ4tQFPZ
         eeZYAa6+SW4RpSGf1thxwMO27IzPvcuMTY9Lg1aSr/WnKy9CS0efp1RMbDirwu2Vit1o
         hfiExY34QNdmUFZt8+W9NaO8s+cfZ+xjqE/NrMO2nQ2wUgLhqKENgWsO3BJmKlcPTIjt
         0Akw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=ii4vLzr0/hkZhS9GYDt0aqtb1MVcJQwo2KZPugK4eL0=;
        b=VUwk4BsJqLFtHwbCqsYxGxmJoFtSAneuVDfQrQxzNc0DibM97IsRYOZdfzpw9TFDDi
         7mx/cIDUgYu0yPZA3PHOEJBRkKZBKUfzPnXCaWnmLHqs7lV8YhtH24apv3tsPDLrvjL0
         tWbBcAh9HcLuCW2Zio/5bhY7NpNYgh2PPIdz+vKflkSiCflhnbsFnADRvZRgzGj7Mnke
         VgtC0gurUE9bWSYmZ/KYjGt4BoFHDsT+ai8nUsj4eDAVGcPlYNdCN3kuVyRyDUK3wyku
         owQKaZTtAFsbpFLypemA1IShhy0EeE9Xt0sRcWpql0Z4OSbRRuCS3tHP/oQUEULRec12
         fMyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=CKIrNj18;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=3LGBcvf1;
       spf=neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id t16si3874683qkt.220.2019.04.03.14.04.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 14:04:02 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=CKIrNj18;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=3LGBcvf1;
       spf=neutral (google.com: 66.111.4.28 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 15541207E1;
	Wed,  3 Apr 2019 17:04:02 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Wed, 03 Apr 2019 17:04:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=ii4vLzr0/hkZhS9GYDt0aqtb1MV
	cJQwo2KZPugK4eL0=; b=CKIrNj188yEHiLVuSyJLmSVXaTjbJKoHEZLT6ElMwVY
	pAlEbBkXjACgWjv8DwRACN+5pqh23c4Bw+hefHTXYN3QAeMnA9OzmGmPjLn+91t1
	W7ob+apC/O8FRhNF/wR4TD3GevQFmPrF8v/+MrRmUizyW19lUs0fLS2Xl8GMnZYI
	KG5QTpzn/+k9On18L40kxHvxcIqZG3NPUK5ScHayI0IDDxr6o5/5sltTXKZ4ePMv
	L5l/NRgEphzT5azf3bnwONJY+qXli9TxJrMiYGgQhVmbCJH8WLny857h71ORydIG
	UJ48RYBkUDwA88fnwUqZuzqoC0kUo1bafnbmGafl2qg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=ii4vLz
	r0/hkZhS9GYDt0aqtb1MVcJQwo2KZPugK4eL0=; b=3LGBcvf1ki3l0G9LnsH7tk
	YOQX40sT+bKAjnvn0jnfdnkGvpguASUoJ9KC0OqfHHJCcwIRGoao5IOj+5imekoK
	NtLp43AJeGOJHoBagY9XKyxeG+vrt9CvzNmmlyJzBrKStce/fZ6AAjmyQjEAgSdd
	EHa1desRrq8DRhEdw+rcYS1XD+6ak7CVosHfLRoXGAATRbNC1sEpyNwT/GCVrebY
	DMUHIV0UxpgM28MIrttntVj7l8y1vzuOt+IUPq3cCMuQNLwLy0I4iuUPnVDR0xFn
	LgqbM76klIJWpoEhknpmYaMhTvEwxIsojQqCNu+qd9wyOxR/b6FQDIrKVNp/GP/A
	==
X-ME-Sender: <xms:wB-lXH7kVcLxDKCusO0wzsxqqeEim2LnVEJIRpFonys8U_Sn487cjQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdefgddufedtucdltddurdeguddtrddttd
    dmucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfv
    pdfurfetoffkrfgpnffqhgenuceurghilhhouhhtmecufedttdenucesvcftvggtihhpih
    gvnhhtshculddquddttddmnegfrhhlucfvnfffucdludehmdenucfjughrpeffhffvuffk
    fhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrh
    guihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppeduvdegrddugeelrdduudeg
    rdekieenucfrrghrrghmpehmrghilhhfrhhomhepmhgvsehtohgsihhnrdgttgenucevlh
    hushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:wB-lXJV8NhF3UpxA9o052iLYasu69hL_HivBKqbscxDcQnqxyFsxKg>
    <xmx:wB-lXGNxIxDrW6dWR1ZvDc5Pa-Vroc1YhohEVD7yJ5MAirV2wXVhGQ>
    <xmx:wB-lXJCTf2TIdSvn_VtEqFzACu9IedZU2Xs86ENqCMAYUVZqIYcYdQ>
    <xmx:wh-lXPBw1-KR8W_rv-sPsDXnDJEXHy2zcv9h4341OTKmVfZTbSprgA>
Received: from localhost (124-149-114-86.dyn.iinet.net.au [124.149.114.86])
	by mail.messagingengine.com (Postfix) with ESMTPA id EDDBF10316;
	Wed,  3 Apr 2019 17:03:58 -0400 (EDT)
Date: Thu, 4 Apr 2019 08:03:27 +1100
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
Message-ID: <20190403210327.GB23288@eros.localdomain>
References: <20190402230545.2929-1-tobin@kernel.org>
 <20190402230545.2929-3-tobin@kernel.org>
 <20190403180026.GC6778@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403180026.GC6778@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 06:00:30PM +0000, Roman Gushchin wrote:
> On Wed, Apr 03, 2019 at 10:05:40AM +1100, Tobin C. Harding wrote:
> > Currently we reach inside the list_head.  This is a violation of the
> > layer of abstraction provided by the list_head.  It makes the code
> > fragile.  More importantly it makes the code wicked hard to understand.
> > 
> > The code reaches into the list_head structure to counteract the fact
> > that the list _may_ have been changed during slob_page_alloc().  Instead
> > of this we can add a return parameter to slob_page_alloc() to signal
> > that the list was modified (list_del() called with page->lru to remove
> > page from the freelist).
> > 
> > This code is concerned with an optimisation that counters the tendency
> > for first fit allocation algorithm to fragment memory into many small
> > chunks at the front of the memory pool.  Since the page is only removed
> > from the list when an allocation uses _all_ the remaining memory in the
> > page then in this special case fragmentation does not occur and we
> > therefore do not need the optimisation.
> > 
> > Add a return parameter to slob_page_alloc() to signal that the
> > allocation used up the whole page and that the page was removed from the
> > free list.  After calling slob_page_alloc() check the return value just
> > added and only attempt optimisation if the page is still on the list.
> > 
> > Use list_head API instead of reaching into the list_head structure to
> > check if sp is at the front of the list.
> > 
> > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> > ---
> >  mm/slob.c | 51 +++++++++++++++++++++++++++++++++++++--------------
> >  1 file changed, 37 insertions(+), 14 deletions(-)
> > 
> > diff --git a/mm/slob.c b/mm/slob.c
> > index 307c2c9feb44..07356e9feaaa 100644
> > --- a/mm/slob.c
> > +++ b/mm/slob.c
> > @@ -213,13 +213,26 @@ static void slob_free_pages(void *b, int order)
> >  }
> >  
> >  /*
> > - * Allocate a slob block within a given slob_page sp.
> > + * slob_page_alloc() - Allocate a slob block within a given slob_page sp.
> > + * @sp: Page to look in.
> > + * @size: Size of the allocation.
> > + * @align: Allocation alignment.
> > + * @page_removed_from_list: Return parameter.
> > + *
> > + * Tries to find a chunk of memory at least @size bytes big within @page.
> > + *
> > + * Return: Pointer to memory if allocated, %NULL otherwise.  If the
> > + *         allocation fills up @page then the page is removed from the
> > + *         freelist, in this case @page_removed_from_list will be set to
> > + *         true (set to false otherwise).
> >   */
> > -static void *slob_page_alloc(struct page *sp, size_t size, int align)
> > +static void *slob_page_alloc(struct page *sp, size_t size, int align,
> > +			     bool *page_removed_from_list)
> 
> Hi Tobin!
> 
> Isn't it better to make slob_page_alloc() return a bool value?
> Then it's easier to ignore the returned value, no need to introduce "_unused".

We need a pointer to the memory allocated also so AFAICS its either a
return parameter for the memory pointer or a return parameter to
indicate the boolean value?  Open to any other ideas I'm missing.

In a previous crack at this I used a double pointer to the page struct
then set that to null to indicate the boolean value.  I think the
explicit boolean parameter is cleaner.

thanks,
Tobin.

