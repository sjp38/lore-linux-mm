Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A4CEC04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 03:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 249512173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 03:15:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="YqeOQlx5";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="6IekBOxa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 249512173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 823D76B0003; Mon, 20 May 2019 23:15:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AD426B0007; Mon, 20 May 2019 23:15:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 626036B0008; Mon, 20 May 2019 23:15:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCE76B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 23:15:52 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a12so14506616qkb.3
        for <linux-mm@kvack.org>; Mon, 20 May 2019 20:15:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xK51z/4F3tloMY+tzPug3rex9T46SW7cKlO10EK5SOU=;
        b=YekMvZYMOFEV/k5XkfimUEoLzuXIFQBSzy11fL/JK9yjJR0T5KnFLYqTz3u+M+C9v4
         1DcoWBsTKnPBuVzd713vZIHK/VtDi+/Bv1dMog8fIW3hv9YVfQujkn34DeIbtqhMkl+X
         6Y76qS3YXbQOv3VvglusAPSavCfqQ7T1VZiYHU6kqIFzHk2iuTt2YzjksNbU7W8eqSUu
         vqx8yEAdUlGbJpXlbW2cTaxnFFF6nk9piwp7oOlAXXAP9E4Sp+TygC/TxhaY6tbBPOpW
         wgHbBbZG9WNxJ1lkbofjqS9i9zP5H6En8s9UbrlMWsFSH1sSYRKyW0lPvHQYl+EabWaB
         r6dw==
X-Gm-Message-State: APjAAAVCkyYSzQByiZL7BH/goKJhTDNLLA8rX62Tht+nl76syM7zg9ZS
	DTQ+WpZGPOpz0s3lq/i2go73mQuzwqF7RVf/444uK2EB7RDVHF40PWcUUEeTQ6WOkSI0cXbBvh9
	ZTM9Gd/7qarxhQk4UGYVqUdQh/w9+tWe37FS7lNJZZdBf6TmOVxzT5znHH096s5GFAQ==
X-Received: by 2002:aed:2339:: with SMTP id h54mr32191005qtc.200.1558408551953;
        Mon, 20 May 2019 20:15:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynuAEEeDc/zPZcbf46GFuNk79NOO8Zvn4qBfEXz8zMQVGsLyZ6oFyOUdbA0JeP+sCqLI1M
X-Received: by 2002:aed:2339:: with SMTP id h54mr32190979qtc.200.1558408551284;
        Mon, 20 May 2019 20:15:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558408551; cv=none;
        d=google.com; s=arc-20160816;
        b=lcgvZTrZuuYfuB6JfMT9PoaxPp8hUaL1GogtSG2uBubSlGYSvw380gMzp+LJOQMVgO
         acvF49OJ+x0RrolEv2QrgtMJKahZV//5qZggSo+sWs1+1Zqn2NZsyHzEmFumQaJuzFCB
         OaelX4fkIAcz6SRmO+9TTdEfY7kwX1tSiWpwnOXDWNeCXFav7lySXqmOq7gouNDmgX3R
         bh1TInbipGKg2QZw0q02GLRFcqil8dMA64apf9YP9L6NvUJ61UlA+Z3e0nbfku0SgRsJ
         b/LnOMBnTL8fS/xCl782dWMDc7+YSy11GyOCyoffOsl2/ab39TnhA8uiS6EoqjDKxezM
         jSPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=xK51z/4F3tloMY+tzPug3rex9T46SW7cKlO10EK5SOU=;
        b=KSKNn8OVi74l4/BSurcdJoAGkGCrLucCOhRagScOZ0t9Cmyj241noHOLF6ezpxl6gi
         NpQuOljIlHhhzeUMx+d5JE/aflLqN/CTWxLp+AM6AQ/L3I4I2Usc0IRMIGM2TweuHNvb
         5+nLc96B0j0I1mwRPUSWwCEEC6ai3z1Un+RZePfv28zdvmbQVJstybvrkZJVAKrnZAg2
         VTECqLeicVnoNPn6Q5Tf1sEezZAiAWz/7ynjMMfdNNGRIgprUI0Dzxc/z4cJcxN6+lv9
         jY4Kf8XogKbUbmSXj19A0qe6E60+AuS8ZF6KYYd3B3epAqAG79VSLfj0k1WMUqGg813e
         q7VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=YqeOQlx5;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=6IekBOxa;
       spf=neutral (google.com: 66.111.4.224 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from new2-smtp.messagingengine.com (new2-smtp.messagingengine.com. [66.111.4.224])
        by mx.google.com with ESMTPS id z45si12686158qvg.102.2019.05.20.20.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 20:15:51 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.224 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.224;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm3 header.b=YqeOQlx5;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=6IekBOxa;
       spf=neutral (google.com: 66.111.4.224 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailnew.nyi.internal (Postfix) with ESMTP id B9681E3BC;
	Mon, 20 May 2019 23:15:50 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 20 May 2019 23:15:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=xK51z/4F3tloMY+tzPug3rex9T4
	6SW7cKlO10EK5SOU=; b=YqeOQlx5ShquIqkxOAUmbnJsp8m/qja6Z41Yjq+YdPF
	VUpy3QyeomaB393THjyzAfuZlrXUwO8Krn2pJ24Ahxh5Bv9bLY9rmnOrTShDoVrZ
	0yjuCDs1mZbQs5I1ciWEUqDdCXqe3i75xs7avcDFkb8uFHr9HQdloN28XH6TPgOd
	EPYiYg/Gj3UAr5GM4Vw7rG1EqKXfQ+N6dDbyKkFOua9jm5DDr55YrhjMvbmnYOdr
	kaOli+q7ca3InzmMZ3tGYMe9bROdzeUQXDV4WdJFNKkQwdWJKMyin4jdaEpvF/w1
	9O861pvSU6K3IUsdGwKxvxA9MJ61cNoA9OGavASYN+w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=xK51z/
	4F3tloMY+tzPug3rex9T46SW7cKlO10EK5SOU=; b=6IekBOxajm2IVukVZgys4+
	VFDH9sDnFB1A8ggg85ndJ9idlwUvvxh/S+1eYgLmJiVfb0vPp3A+SlHon4r/w17v
	XLdimeduBfCBkasf8KT4RyD9V2tSW32SYzG2NCJOCAYeFiyLxztbHRYYfgcwmedj
	hLtueQRXoOudV4iCDoy+Uh4PFw8JH3jdwxqXzvny0APBpEXaPk2+I+Eay9OegJ5Q
	wiWApBBiFbKT9wh2mYYCkskz00jhYZMzzCp7MMHr73Gm+/3jJxBX42059bNExVaO
	e47CPN+QULGa6FZgUU+WTO4Ab7fA2y2LzsiG6UDRwGFFP1alUc4pHMPiV6hTumyQ
	==
X-ME-Sender: <xms:ZG3jXF1p4HYxa2LaaW9d1VPD3E0cdYN1ULFc9jETDLokYHIzlbhU4Q>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtledgieejucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    gfrhhlucfvnfffucdlfedtmdenucfjughrpeffhffvuffkfhggtggujgfofgesthdtredt
    ofervdenucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtoh
    gsihhnrdgttgeqnecukfhppeduvdegrdduieelrdduheeirddvtdefnecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:ZG3jXGGI23jma_u4tPvE-79o_Ify65-SmXl_a9fDSvsx0oXuPoa53g>
    <xmx:ZG3jXMjFqrHjaBbgvErqbhS495QD0n443l2a0nBcc44p05o43_74tQ>
    <xmx:ZG3jXBDkf7juigVj-jf56R0rsFRD5t93EweudCkglm2D49K8arvjmQ>
    <xmx:Zm3jXLlxqiGTgLnufQRjCpfoGRFxTM7UVI3q8oCm_4q_7I_8GG0iTg>
Received: from localhost (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id 21E9380059;
	Mon, 20 May 2019 23:15:47 -0400 (EDT)
Date: Tue, 21 May 2019 13:15:08 +1000
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH v5 16/16] dcache: Add CONFIG_DCACHE_SMO
Message-ID: <20190521031508.GA31794@eros.localdomain>
References: <20190520054017.32299-1-tobin@kernel.org>
 <20190520054017.32299-17-tobin@kernel.org>
 <20190521005740.GA9552@tower.DHCP.thefacebook.com>
 <20190521013118.GB25898@eros.localdomain>
 <20190521020530.GA18287@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521020530.GA18287@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 02:05:38AM +0000, Roman Gushchin wrote:
> On Tue, May 21, 2019 at 11:31:18AM +1000, Tobin C. Harding wrote:
> > On Tue, May 21, 2019 at 12:57:47AM +0000, Roman Gushchin wrote:
> > > On Mon, May 20, 2019 at 03:40:17PM +1000, Tobin C. Harding wrote:
> > > > In an attempt to make the SMO patchset as non-invasive as possible add a
> > > > config option CONFIG_DCACHE_SMO (under "Memory Management options") for
> > > > enabling SMO for the DCACHE.  Whithout this option dcache constructor is
> > > > used but no other code is built in, with this option enabled slab
> > > > mobility is enabled and the isolate/migrate functions are built in.
> > > > 
> > > > Add CONFIG_DCACHE_SMO to guard the partial shrinking of the dcache via
> > > > Slab Movable Objects infrastructure.
> > > 
> > > Hm, isn't it better to make it a static branch? Or basically anything
> > > that allows switching on the fly?
> > 
> > If that is wanted, turning SMO on and off per cache, we can probably do
> > this in the SMO code in SLUB.
> 
> Not necessarily per cache, but without recompiling the kernel.
> > 
> > > It seems that the cost of just building it in shouldn't be that high.
> > > And the question if the defragmentation worth the trouble is so much
> > > easier to answer if it's possible to turn it on and off without rebooting.
> > 
> > If the question is 'is defragmentation worth the trouble for the
> > dcache', I'm not sure having SMO turned off helps answer that question.
> > If one doesn't shrink the dentry cache there should be very little
> > overhead in having SMO enabled.  So if one wants to explore this
> > question then they can turn on the config option.  Please correct me if
> > I'm wrong.
> 
> The problem with a config option is that it's hard to switch over.
> 
> So just to test your changes in production a new kernel should be built,
> tested and rolled out to a representative set of machines (which can be
> measured in thousands of machines). Then if results are questionable,
> it should be rolled back.
> 
> What you're actually guarding is the kmem_cache_setup_mobility() call,
> which can be perfectly avoided using a boot option, for example. Turning
> it on and off completely dynamic isn't that hard too.
> 
> Of course, it's up to you, it's just probably easier to find new users
> of a new feature, when it's easy to test it.

Ok, cool - I like it.  Will add for next version.

thanks,
Tobin.

