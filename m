Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CE2BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:06:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24474214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:06:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="v9qEBssM";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="7NOuyzjw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24474214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C15BA8E0003; Mon, 11 Mar 2019 21:06:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC4558E0002; Mon, 11 Mar 2019 21:06:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB3788E0003; Mon, 11 Mar 2019 21:06:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 815E78E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:06:21 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p5so855314qtp.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BfTF9/5XfuXj8gIHT3yfX9FHWytOy+CqJr0NmgfbW+4=;
        b=MCO5s8SyvaIyZiwIusHdAWm4fdVJW64eNBvk7DGlKmUC5tPOVbXc+9PB9KMQQL6KYA
         0zT5UwNkHbKPb/u3q9XCfyl53hZnAxkIyvAqZO42MFNTGCtBIvUU0UDB0aYmvoAFZpPt
         T0TM4ndQRUBCdpjHGOGpdHBxt0EM7xNSu0XgnzjNfS05BP+Gq+o2SOEoq8cyGAyPw02k
         0CdWPMYUyFznmQVvaOgzwxBcjhAaau6v1R6UgApAAUauOko00tU01YgeBbLEZdQTzx/l
         7yNhyhJ4HdFOSG8/xUiXj92VFfknisYCwjei8fxaRvH7WpNRnFr2DAGqvG/ME1i2yucz
         aihw==
X-Gm-Message-State: APjAAAVCGWXVPAEQ7fYK7zhMmQ4Sv6EneIAvxnjEnKXyumg31ctCwlms
	9fZpURb/k+YvYBb5VGW9avD7AUeioO3yP2xVQcXaNHbPNjUfqNhGhz2OYrfjzL5vm89YfTh4+Jc
	rQJmLM5Gf/WoMXngN5hjNn57Uo7mKNaIptciBmk87uoL2X1HFykCSN9UCiGTqX+vjhw==
X-Received: by 2002:a37:9b16:: with SMTP id d22mr26506411qke.356.1552352781268;
        Mon, 11 Mar 2019 18:06:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw42DmDSQH3My8aCxhWZRyOt6Vk6EHM0bvqJ93WYNou6ZLxb44rMq/QQ0iihf9L3c9iKDeC
X-Received: by 2002:a37:9b16:: with SMTP id d22mr26506381qke.356.1552352780644;
        Mon, 11 Mar 2019 18:06:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552352780; cv=none;
        d=google.com; s=arc-20160816;
        b=lF+Vu9l2ADHShZxvSv84VWEoRoPAcLJnABZmWGFkFtNt3Y5bGA/zjG1PQ3yb6ktKid
         S29fhN1Aza2TbZg1WAmAZLUctL3qb7z/62bYbqlYhDQa4m3avalOwWqOi7oXbf0dES1U
         A5/QlreZa1iB4Q09MqENdl8/UfdM/rZWjYMYPXIRBva3idaKIdqkv2qvg3WcKezjQlRe
         ReIW8VP4VdznUgDO8N01A7sR7ADS39IRIhYeLmd4kpj698ATNkFWdU28T7sNdM97A2P2
         pEctfTx8YV90XvTpgAFVZpGb7q9m4t5XVHNKosCJ5W4O6uqU765wQUaICuvgWRZ84sBV
         8pGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=BfTF9/5XfuXj8gIHT3yfX9FHWytOy+CqJr0NmgfbW+4=;
        b=OZoytD0YIdfu95ynQxvjDJx0ONRe+if/BYNNb/QzgMuvhtnH2mGwT1A8zHvVqo2KkH
         ZpUZimCQOtRooyMpGqg5eY65trcosVGlnYWIaQfyNFlG937Z5j2gRRvwyRQD+QvGesL5
         trtXDo4R9ZwBwuOjVhXPKCE0CgYOCEvaDd5adR4mTG5muM+07u+GsK4Av8FavmhD1ybT
         AIkk/3zKyD+oVcSoiNvX+aKXkH67vC9aX1X7DR5q9Gg9aphH8+FexrMDRCeWcOQ2eRXD
         K/P/cm4GuWrhFcRKWBRkB53MDYoxO0L47AkPLcNSoRVDQZDlgeIXhQOu/YpCiVjoVRlN
         iBvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=v9qEBssM;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=7NOuyzjw;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id 11si3698515qtu.163.2019.03.11.18.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 18:06:20 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=v9qEBssM;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=7NOuyzjw;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 3E4E6226F4;
	Mon, 11 Mar 2019 21:06:20 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 21:06:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=BfTF9/5XfuXj8gIHT3yfX9FHWyt
	Oy+CqJr0NmgfbW+4=; b=v9qEBssMxx8UjrHaKeQhZGrw3xhr3nm6bsLRV6sPDqB
	THj4osgaOer9a8BFnE4tgtFjxJDGIvVV/iCjTAGtlRodeBYxsJ+yUNZ0bn/SwS/7
	DkuzjFVJOIhBpoH+fkfJb2/P1UW/TuSjdJcxh1HLq4b6EqGP1cqAeJ9uqlu3sge/
	u9poj+DVXxgfDqqIAnT0OD8o660l0V5Jr3vZ8gWqf1nNNlEOZwcMOdgUng+gZTzg
	6QalMJRVrhDiZBaysVbOhsx+GUc9/bjgOMccnxInavUpmrbN3xPVXe851HQ1Oyix
	cYNS8/4MJO1+WqQcTAcoipOEfkb++7NZIEYqLne5yAw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=BfTF9/
	5XfuXj8gIHT3yfX9FHWytOy+CqJr0NmgfbW+4=; b=7NOuyzjwFNct8c7dj37fdO
	AwnGdyS7YZ9+u7IhlASmz7qbcJb/xZK+a9X1cQNV1uzYjhaptK2bfGtHisp0kBis
	hboaR+hfPtW9/KEurLqVF+edbbceyzsuwUtbYW+hJbjttmclQ8dIBnbt7B8qDtak
	nruwK+ZjJuAveHL3xpyLkxncqg5+MTckcfwHpBkmPT/X1UQbRvc8FNvjTR3qXUAd
	4CEXN3RZH6bqunDQfJxkX+6nVxsQBZeJPD4SDfsO/gvP4xVEbWvGAF+WThkZI7Ya
	J7cJ1cIvCht2IOBmccJbH1z2izSuq9wHiuef5+SUQEAMFDcEmhFnJibVx8SdfKjw
	==
X-ME-Sender: <xms:CgaHXPy18bevCJZaVvD4E2hMf2whqgQ950KYFAYYXJ7VZtXWWV8ABQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgddviecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdeftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:CgaHXI7rg91R3vuz4n-POghIUOAhPxJD-h7wuW7Tyl-igrD_M1Ehlw>
    <xmx:CgaHXNbEdogCkmNboxXNCVCuZa2Z4z5E6VpMzWsM_gD8OaZd_nr6mA>
    <xmx:CgaHXP-5w56EjfhStOdjnadP9xKSayTk919MNx4gg1vzGOz7uVqIug>
    <xmx:DAaHXINCaELhtCEs2hH3NLMsxINiXJA4GpShyndbtsD_O20v3oPHUw>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id AFE8C1030F;
	Mon, 11 Mar 2019 21:06:16 -0400 (EDT)
Date: Tue, 12 Mar 2019 12:05:54 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Matthew Wilcox <willy@infradead.org>
Cc: Roman Gushchin <guro@fb.com>, "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/4] mm: Use slab_list list_head instead of lru
Message-ID: <20190312010554.GA9362@eros.localdomain>
References: <20190311010744.5862-1-tobin@kernel.org>
 <20190311204919.GA20002@tower.DHCP.thefacebook.com>
 <20190311231633.GF19508@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311231633.GF19508@bombadil.infradead.org>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 04:16:33PM -0700, Matthew Wilcox wrote:
> On Mon, Mar 11, 2019 at 08:49:23PM +0000, Roman Gushchin wrote:
> > The patchset looks good to me, however I'd add some clarifications
> > why switching from lru to slab_list is safe.
> > 
> > My understanding is that the slab_list fields isn't currently in use,
> > but it's not that obvious that putting slab_list and next/pages/pobjects
> > fields into a union is safe (for the slub case).
> 
> It's already in a union.
> 
> struct page {
>         union {
>                 struct {        /* Page cache and anonymous pages */
>                         struct list_head lru;
> ...
>                 struct {        /* slab, slob and slub */
>                         union {
>                                 struct list_head slab_list;     /* uses lru */
>                                 struct {        /* Partial pages */
>                                         struct page *next;
> 
> slab_list and lru are in the same bits.  Once this patch set is in,
> we can remove the enigmatic 'uses lru' comment that I added.

Funny you should say this, I came to me today while daydreaming that I
should have removed that comment :)

I'll remove it in v2.

thanks,
Tobin.

