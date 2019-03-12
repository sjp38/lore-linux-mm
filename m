Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5ACCC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:17:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E6FD20657
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:17:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="yFQTERBa";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="gaSlVRNH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E6FD20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA5548E0003; Mon, 11 Mar 2019 21:17:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E54B98E0002; Mon, 11 Mar 2019 21:17:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D445E8E0003; Mon, 11 Mar 2019 21:17:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE9D68E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:17:17 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x63so934858qka.5
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:17:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mFeJ0sVhv8hsKz3mq6pT95u7bL3p+KNXZeOuRgJHu2U=;
        b=JaG6ENz6cjim7XkuIBGCcnjdwVrPO3qFbLpCi2abFIVkaL1mPAc1KsvZ4IexsGwCx3
         vQ//zJ3vL+Wyp99eyXPQkkWmaiZl2TDLQm9OxVmbd9Zp+BwbOn+/CrDYE2PyM3Cc8i0b
         pfKN/uAU4sZjRX1uDpzkd4dpnXruCiF7GnR94f47QQousB8bVWaH1UDfmg9++DIYjSqM
         3p4NYnkiTdDk4rOnEvbXqX/x3T2d+FnitACJhPvGHjqHJrth1kSeUKXK3htLlQW2v189
         1GAz/08QmBNCGPMbkF1KVP1vddosBnhwS1LDT3wiR0WFXws7P2EAVD2VyIB2J7Y0r7ho
         U76Q==
X-Gm-Message-State: APjAAAUigc5YRgxNVrYEH+m8xuLktKEFoJO87qHjGDZUKFTh/FPuOYdD
	+Wcl/tvxDyWQnQ4RMunsuOvsbylJbWyPtu0VDYkXWD3TUXgctY3dk2Esg8u215fbvIsendBMc61
	OqezTzShnqKNIaqCcHgCGuw67eCfbFy6lXePCkhbvCaXRm3fqAcSwZdtPgId9m+3wZw==
X-Received: by 2002:ac8:1b5b:: with SMTP id p27mr28464436qtk.106.1552353437473;
        Mon, 11 Mar 2019 18:17:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz98zjFkqM1WUmYGmBvBXNsXr2BWGvVI5LaU3osuGbs9SEChxxPz2mEQATScuacFF9V55GB
X-Received: by 2002:ac8:1b5b:: with SMTP id p27mr28464406qtk.106.1552353436805;
        Mon, 11 Mar 2019 18:17:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552353436; cv=none;
        d=google.com; s=arc-20160816;
        b=IxPBryIDKx1jnwO2yt0Ph+K3qj26eVoehL3KIhaEoO4q45umIztniH1KhWEMOR7zef
         FPavtnJYo2hgfya6cdvMGDR1ePAPwRMFiSSNjDQ+z0q3PeYLKCayIt/w91oEPqCGmGQM
         8CNSh+UhpYafFQQCWqsy9koqvpmprOEIoFsfD+JRJ9fad5hZC5YRBj3hciUVKyrzaQ0m
         i9Isn5WvI1Lva1R1jkHQqhnCjl0AvSF0WLLa9HARHy3gWMGgvyzKDkO8N6fDa+mr7EJH
         0RIUZUuISPuY6RhIl5cyl8laHfKxRNgm5+Y9P3SmtTIIilV/GlxHCPZAdewRXIz0xJVv
         4j6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=mFeJ0sVhv8hsKz3mq6pT95u7bL3p+KNXZeOuRgJHu2U=;
        b=T6l644S4ThNXc1IGWgfXEVfthdDCurxAa7QdOdRcn33lnQX+Yuq4ZcYDQ5ylTn8E7h
         L8hePTffuPAUIK5wDaKtpnaE8Vs8S3tdPHGtUxgJmCldrlLKDrfsdjhXGodGR4UlOmyZ
         oKht+gpfoiP7mAl6UmUevD8nA6MC4PtLVj/1JTVQN4aWSyzJp4jnrVqPsooDy5RL2Dse
         eyThlrNlE/kVl8PdGH2owZo819jzYqyMDWNx+0Jgq7vjYAiQLOYbI8GaRxIRxye6QwPu
         8+aNQHO/mWueMi796h7GnSeuGHM8onS1J1cMQAWkhx4TU9UTXV+jcA5RzikzCTqaFu4E
         T0rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=yFQTERBa;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gaSlVRNH;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id 14si3155942qty.140.2019.03.11.18.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 18:17:16 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=yFQTERBa;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gaSlVRNH;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 8B1B721F83;
	Mon, 11 Mar 2019 21:17:16 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 21:17:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=mFeJ0sVhv8hsKz3mq6pT95u7bL3
	p+KNXZeOuRgJHu2U=; b=yFQTERBali8gZIhOwyeVFR2ETEMoMxoZ76UImjh8rN2
	Q2M0MW3u0sNaAxpMfPZHEaeW8s6euwP3220gy5tHwDyM0u1SuFWsBJfOCjAhCufa
	0DlQEreMtNRVlVWr9t7DX5PkKhcJLaqOdYvkX2byGwkdik2Sp1bPdHrf3RT06w4u
	3L/ifh1iMaaeeFajUSkSRddfDG1885EhSAsR1IAW7UGpOyBwaq9AYC2pXFBDFnfn
	L51W3rs40xuRxFiJip69JBY8xRuaufCylyOVd+7UDHY684tMpNfuCM/lUF42Dy0r
	mdggstQ1NHXllOnMcX23ykAYkCvQwiCLLxemxbr1wLw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=mFeJ0s
	Vhv8hsKz3mq6pT95u7bL3p+KNXZeOuRgJHu2U=; b=gaSlVRNH3+fb414avRhcNW
	jFoNGf2eiueImUGOCb/aB9HrVzjlrlN+W47GtTr+R+2zxX87XWnKAbm1P++EFdsD
	y5aih/kCfL3mEr/3A+QyJK6155CJt3q4N0+vu6DVy06vWc8f1s+EyaOqmI/BJDYj
	rDdGlv5yM8h0Z02v+rG+ZLIT0SifDhxHAguqRvxG3AfhhUWqcEW2yDvhWoPbT9O4
	C9+xRhfF/fXSvnLH0+4X5P7FmJGgFluA7PF6bWlLv2LTrlExXHyDr1B/87JW7lg3
	xFqOSKea/Hf9rjMoeAYSzIopMnuYGd6MAuqA55IES5gPhgTX/toBBKoEvpdRlU3Q
	==
X-ME-Sender: <xms:mwiHXFfk9FoIq-SSgNBtRd7d7TPZs6UXRW62mSi9RdCb7TdT5nXh_Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgddvlecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculddutddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:mwiHXGbAcs5UTKbPKLCZvPXy4vL0dTQVpavxEtuczVRF4IKK12xbxw>
    <xmx:mwiHXFWl7EoHRTwcqtDII1xaWWTkX3JcO7RFNAw6vgTy8LioBPMYBw>
    <xmx:mwiHXEDgOUEfgQFkRo1B8EJO86rhYNwJ3OIYORT8ET_IUV5WY06iYg>
    <xmx:nAiHXNsmF1B7qWpn_Fj39INpzOnDlS3iYcCJjXy4NW96prreUG0UBA>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id BE7DA10310;
	Mon, 11 Mar 2019 21:17:14 -0400 (EDT)
Date: Tue, 12 Mar 2019 12:16:54 +1100
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
Subject: Re: [RFC 01/15] slub: Create sysfs field /sys/slab/<cache>/ops
Message-ID: <20190312011654.GD9362@eros.localdomain>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-2-tobin@kernel.org>
 <20190311212316.GA4581@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311212316.GA4581@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 09:23:27PM +0000, Roman Gushchin wrote:
> On Fri, Mar 08, 2019 at 03:14:12PM +1100, Tobin C. Harding wrote:
> > Create an ops field in /sys/slab/*/ops to contain all the callback
> > operations defined for a slab cache. This will be used to display
> > the additional callbacks that will be defined soon to enable movable
> > objects.
> > 
> > Display the existing ctor callback in the ops fields contents.
> > 
> > Co-developed-by: Christoph Lameter <cl@linux.com>
> > Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> 
> Hi Tobin!
> 
> > ---
> >  mm/slub.c | 13 +++++++++----
> >  1 file changed, 9 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index dc777761b6b7..69164aa7cbbf 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -5009,13 +5009,18 @@ static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
> >  }
> >  SLAB_ATTR(cpu_partial);
> >  
> > -static ssize_t ctor_show(struct kmem_cache *s, char *buf)
> > +static ssize_t ops_show(struct kmem_cache *s, char *buf)
> >  {
> > +	int x = 0;
> > +
> >  	if (!s->ctor)
> >  		return 0;
>         ^^^^^^^^^^^^^^^^^
> You can drop this part, can't you?
> 
> Also, it's not clear (without looking into following patches) why do you
> make this refactoring. So, please, add a note, or move this change into
> the patch 3.

No worries, thanks for looking at this.  Will amend the commit message
and drop the constructor check.

thanks,
Tobin

