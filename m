Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 572F0C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 06:04:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D780020657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 06:04:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="WmDMnv+z";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="tT2jWnm6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D780020657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44E8B8E0003; Mon, 11 Mar 2019 02:04:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FD658E0002; Mon, 11 Mar 2019 02:04:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 315268E0003; Mon, 11 Mar 2019 02:04:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA2E8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 02:04:44 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id o2so3660176qkb.11
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 23:04:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=A53ynhKpBb5B67T3GkAqRrpBy8wA89nWoFI2UrtkrQ8=;
        b=j+wSy2xaEHd4Q1+r3J1VrQVex3oOcXNFClWYsaPyCRy8CLsqgrbuZYYejW/PyLo3Qk
         9wAvt7kK329olxo6Yd+kUSn0to3WMbb4TFC17MFjvhy14f3XizJdNUz70spjz6iPQTdu
         UcBBXsgCLSL4lzK6D54BmabHwR9tvPf/t7D+h0j+JrxCuV1hpGgo+oiBE/fg83CpcNsE
         qztOF+E2It56xqDfLuZT4ZdlmNTs9UZu2meaPmjikLMo/+bsO+NmVlDiE41C62rG6Ks5
         mLXga9+KgmiJFxi6oGxj0I0SHvaxwckM5me4jEjMKJ6k8EsrSWezQ/d/Yuml5D17LEaE
         adzQ==
X-Gm-Message-State: APjAAAVNWo/Kjk579XITIQtXUd16V2BabzBE3dliYGkbg/FeSw1HGuUQ
	lAI5/fVItB+wgENJiEkzhs1hX+myRTMkIhHfXblZNHD0K92zmrU+TY+pm/TZ70cfFiXUbf5Ph40
	qOj6PszRh4LUMOLCWC8dyKjy+/ikfcdme9xCcMkWYpf9mAYgRhdwk4x7XYfDZ3wiQWQ==
X-Received: by 2002:ac8:2392:: with SMTP id q18mr24220014qtq.11.1552284283832;
        Sun, 10 Mar 2019 23:04:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+Et7gZhPEUJWI/4bOfwskWuFeZKcJKeoN/eQA7+5iTf/2fZd0Xg9yevdyYU28JPWJp8U6
X-Received: by 2002:ac8:2392:: with SMTP id q18mr24219980qtq.11.1552284283047;
        Sun, 10 Mar 2019 23:04:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552284283; cv=none;
        d=google.com; s=arc-20160816;
        b=WFFoPfX+vM/lDBofQJbAk8rVLJAUB3ya0Lp+uzKz+pzGA+mTaNVBdaXBPbIc53uYRV
         ASsjwQgHpJJ7gA+KV6MoovVk2mReB9UMlxxiDTZdfu/pZC7Z7owTlvH+4/lj2/kb+bOz
         jhkR0NXTEwDMU4xEWJ6Ys62whpAmfOV5X2Iw8I/niJxtLqhIAgGZXy2lTiE+NQL/xc/j
         65fZARJEZsf3Ul4+rjNePr6N58mmm5/IIlnyu/05332vrn5Ibm6qBVwyBCw1VKIwXgg4
         U9HCvW4RoHkfch8VfFFVI1IXuqozEU817mcv14qusycXrDVdl5G4bMdjTnhzrenEi00J
         ravg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=A53ynhKpBb5B67T3GkAqRrpBy8wA89nWoFI2UrtkrQ8=;
        b=M+nGv5zhC5B7pRxoRwS1o4hOVcl7kw08I9KfKoECGyysQiTx7XiS/+2Yz+mwd+t2dD
         mRoPYaaSOjjOQaeCUkcsCcPVae1LQB8EHpidNqnkZwrIVz2XNWHK85r5Oe5txY0zytjC
         P7AzJrjMSqc76EQnw2cjhCRKvV+60o8CPDtzXg8KjsO0QWDlnYidyEnsTCLYdNVH4Bp1
         Vo2MX/mYtTRz7WzUh2+Y4QbiziSmvWK+IjNp87raC+T09xe3WybDYVRmAJzjw2dm15Vi
         jWuD/q/qAw3t7QpgeGXy/EQLoU1qsIcqDshciH01ySr8U6MzFi0l95KlAP/4wYRUtN0Q
         AHKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=WmDMnv+z;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=tT2jWnm6;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id o35si883217qto.299.2019.03.10.23.04.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 23:04:43 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=WmDMnv+z;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=tT2jWnm6;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 5F9BB21F75;
	Mon, 11 Mar 2019 02:04:42 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 02:04:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=A53ynhKpBb5B67T3GkAqRrpBy8w
	A89nWoFI2UrtkrQ8=; b=WmDMnv+zWX7XLQbLSyWQkzcNHov0AwoOZQpl6e1dgMm
	baMCoAot9dPLfD2cpq5skh9JCLevp6N2KmuVIpvonQkUf8Yn0RVntI0IUyyCUxDY
	LnOrEX/dHA2isa/gctW7ijmYOXjdANFdxk0ND0u0e/ujqItP/BIVPZKQlv7G0plu
	CgOOtqTs7Xl46ShKXEN1Y4XN5EoZH0tXTGwqj25fxSdIHlT9jjX7jehRdAp+KT2W
	FBU3ILVwxLT6n++uESgv4oAk1gjVEAhMGQmvlThHNDYITyFtOSGttvXP5BnoO508
	8PLYJG7LOwM6NXl20eBCc8cDO4INF/VHU/gJSDGf4Lw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=A53ynh
	KpBb5B67T3GkAqRrpBy8wA89nWoFI2UrtkrQ8=; b=tT2jWnm6PsjLlZfoeo3Ct1
	h7E4kmqGYts7Nmi3oR2NBL24s4QKsXq2zla45AjlPR2RBFGI1chTQNRmgbts9dJz
	TcppwWYTaMvIMXCt4mAiuikG0bWVQbdedHZpzPLf5jwkZ3zBj7y5R4sOsnuRQiG9
	z6U+IsUDrsNm3zmTrlsdCx+yMnbtqzHeti64vKMcIB69n76sISBw33tZs3VrXhKd
	IYN1uCebWYUffqL8rF6iYQe1dK2Hmcn6T+CaQVJKrvGX7RLxf1NpxL3E1g4S0nHd
	acgIKF67yADsHnrh5qEU/qZamvY5BeZ63M2mlYE8mOf8+As6CLsnA1zPkx7hzKGA
	==
X-ME-Sender: <xms:efqFXOGRGBcXaeLhosYuQcR90W-qyTSj3a-Ar9ydcy-bRWutKbx4oA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeehgdeltdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdeftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddukedrvdduuddrudelvddrieeinecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:efqFXHydtcoUcjr73VnsbOVFVUKNSSWGhJ7k3qbpV7JSvLjAJQyFUA>
    <xmx:efqFXInlDhWYrwJeIkO1NfDl__f2WrmQX9QscN8wYRtF8fxdUwYcYg>
    <xmx:efqFXImgUii6jT6e6H2ZKDJAWYQo01SuNUOBtlHj2efxPdV_6-7K6Q>
    <xmx:evqFXBZf0Y4mpFb9wRTFq0GS7uCS8dyvRy02h-EPJnqv_Uule5BFXg>
Received: from localhost (ppp118-211-192-66.bras1.syd2.internode.on.net [118.211.192.66])
	by mail.messagingengine.com (Postfix) with ESMTPA id D47CC1030F;
	Mon, 11 Mar 2019 02:04:40 -0400 (EDT)
Date: Mon, 11 Mar 2019 17:04:18 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Tycho Andersen <tycho@tycho.ws>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC 07/15] slub: Add defrag_used_ratio field and sysfs support
Message-ID: <20190311060418.GA22772@eros.localdomain>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-8-tobin@kernel.org>
 <20190308160151.GC373@cisco>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308160151.GC373@cisco>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 09:01:51AM -0700, Tycho Andersen wrote:
> On Fri, Mar 08, 2019 at 03:14:18PM +1100, Tobin C. Harding wrote:
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3642,6 +3642,7 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
> >  
> >  	set_cpu_partial(s);
> >  
> > +	s->defrag_used_ratio = 30;
> >  #ifdef CONFIG_NUMA
> >  	s->remote_node_defrag_ratio = 1000;
> >  #endif
> > @@ -5261,6 +5262,28 @@ static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
> >  }
> >  SLAB_ATTR_RO(destroy_by_rcu);
> >  
> > +static ssize_t defrag_used_ratio_show(struct kmem_cache *s, char *buf)
> > +{
> > +	return sprintf(buf, "%d\n", s->defrag_used_ratio);
> > +}
> > +
> > +static ssize_t defrag_used_ratio_store(struct kmem_cache *s,
> > +				       const char *buf, size_t length)
> > +{
> > +	unsigned long ratio;
> > +	int err;
> > +
> > +	err = kstrtoul(buf, 10, &ratio);
> > +	if (err)
> > +		return err;
> > +
> > +	if (ratio <= 100)
> > +		s->defrag_used_ratio = ratio;
>     else
>         return -EINVAL;

Nice, thanks.  I moulded your suggestion into

	if (ratio > 100)
		return -EINVAL;

	s->defrag_used_ratio = ratio;
	return length;


thanks,
Tobin.

