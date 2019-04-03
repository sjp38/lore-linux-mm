Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 890BEC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:23:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D360205C9
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:23:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WcbLykPN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D360205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B8BF6B000A; Wed,  3 Apr 2019 13:23:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8401C6B000C; Wed,  3 Apr 2019 13:23:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E0D76B000D; Wed,  3 Apr 2019 13:23:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7B06B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:23:46 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w9so6380455plz.11
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:23:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zModaMrriE/hDDtVlXWrEVhoyZAp1FMyXnAmN/NXe0E=;
        b=eJvIGJTEsNTy4Uy22MUCAw2pHcydV37KgTVtHbJMWEfi6LhUKfcM18XkeH7XYHTFDV
         ui/6a2ZCRb0nNTfxi1yWbl9Zyr4QWOr9PPSnMWxMG4M6DmmCAdIXT75kDCrFBrFE/cTf
         YrWEGBjPbsZpz4nzN1ETxkhNA2hbKIdePKSR1qjx2yJzetBzyBBeH18yGlnP5kkPFJLn
         k1oPNFmG7neEd9MUjwPgIM2Ol3aW7OaAFw0LoF86UnfUh37yEb2Hfu3j+jeSXHqI3o/a
         j9PDlj7QIz1Vks9ucnGYRx1EwFu1SpQGYVxxOGW4Jm7aBXfbrQq0H0WQDCpnLQKf7Okk
         S3CQ==
X-Gm-Message-State: APjAAAXJoX63flZrfygp0WSaMteI42lXu9xWgh69nyHSqpLsgXI7DwYI
	pGVtr3W+pcUun4UhlpMrS+GKZoCTV9N6yNpHAQhVWgAJjdKJ5iDBiDSYzdRO5RCLLAvm/PXjlzJ
	HNJtY3LCIO+p5VLaEfSvC0flivskJSzc9rAmOJ6SDHIUjrhMjcJNaHR08Us9Amo95tw==
X-Received: by 2002:aa7:9116:: with SMTP id 22mr587719pfh.165.1554312225691;
        Wed, 03 Apr 2019 10:23:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuBfKFLvS7XMTfaRqKwFEWkfsn4O5/2yNyiUIGsT5bWp6Owp5A4HFffS+i4jb0IuTOhFKj
X-Received: by 2002:aa7:9116:: with SMTP id 22mr587659pfh.165.1554312224944;
        Wed, 03 Apr 2019 10:23:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554312224; cv=none;
        d=google.com; s=arc-20160816;
        b=LeP2PET1sB0Ak9TvEeveW2cEdRhKCQfvjDSX5F1hj7JzdS/9u1ni/J8PGA5vTvtFHi
         +5R/T65hRYchL27SBHFfAsbKZeLdAb7u8FkXhgnQX/4EEgPHWexhxDI/QXrdqBs5K4Tr
         hnuoJaWpYS6ikv9bMkjlSYri0wrMFX5Eqh1HVduiq8cPnwgbo0XxlGMAgymgUxNp0bvT
         yx8XiWHYGJOyZvzM6T7V8XA+UsDM1Qva/LZU1omwwv16dOugt9Ma+MiI+ajmP9Ci1fOo
         ykynfIXLTBsh0E/xWtL261Q8rqeuBQVJN9Ny10fvOG6ZtObmbZiKQT/ym0MwKX2Ehn65
         aAEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zModaMrriE/hDDtVlXWrEVhoyZAp1FMyXnAmN/NXe0E=;
        b=yD8EodMoTVInMEBq38hsBddqgkZMhyZE5sG/fWlJ1Oz/fx2qbWs9iZSpoZjRT1DJUW
         v2xB53eLZVwgigjH07npfupgLqGQClA0Ru6Owsf5JH3dozKLAfNuO3lSDL3rTWYjGgrw
         wbuMBpbFeMAYU9VifaKEU44pNumRL8ZkhYHXBF14XskC391a93w/UcVHGvNRz+UtuIji
         MM0dju38LG1KXEf3vLLI11nUuLcqgln1pwSJkDvDA3nGebb01YO8OP2xEuzi28GjyWHX
         XXYI5rj+4jyBGWIFPFXSPZoX1ctx9gMeOXhacbRUauQvAMI8EPFmxrlvCgszTArScCDW
         Otpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WcbLykPN;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j15si14325814pfi.8.2019.04.03.10.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 10:23:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WcbLykPN;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=zModaMrriE/hDDtVlXWrEVhoyZAp1FMyXnAmN/NXe0E=; b=WcbLykPNLboAU+ciI4NMLCIDe
	Z6anVMTST5BQ6g4ZKs+bxsg7dmx353AbIHO2bgVpKlNZZbXPkrk+WnujgQGLRQy8K3SRqyQiJRutv
	jkjwjTRBL4EvWM/7izzAvy3lOSaBii31BfLfeft6t9K0DhmrlT+B92H7hvxcpjrQVaqAtsF7JGi1F
	5ySylFRefcmQbe8SXpN+HPk1EGwuI6qu0XgykFmEZ7OUhIWcmSkrGdgoWqYKTFEFRIZLfW1+/OO3I
	WaTFaUxXw7a3aMmahQg5Mxahyq627ia53RCgEOHLMocouJ2HFgeSu8HXGnPkZXOA8zR6JvNKwhQpk
	WKpMFrsxQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBjbi-000465-Iu; Wed, 03 Apr 2019 17:23:26 +0000
Date: Wed, 3 Apr 2019 10:23:26 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Tobin C. Harding" <tobin@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
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
	Hugh Dickins <hughd@google.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v2 09/14] xarray: Implement migration function for
 objects
Message-ID: <20190403172326.GJ22763@bombadil.infradead.org>
References: <20190403042127.18755-1-tobin@kernel.org>
 <20190403042127.18755-10-tobin@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403042127.18755-10-tobin@kernel.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 03:21:22PM +1100, Tobin C. Harding wrote:
> +void xa_object_migrate(struct xa_node *node, int numa_node)
> +{
> +	struct xarray *xa = READ_ONCE(node->array);
> +	void __rcu **slot;
> +	struct xa_node *new_node;
> +	int i;
> +
> +	/* Freed or not yet in tree then skip */
> +	if (!xa || xa == XA_RCU_FREE)
> +		return;
> +
> +	new_node = kmem_cache_alloc_node(radix_tree_node_cachep,
> +					 GFP_KERNEL, numa_node);
> +	if (!new_node)
> +		return;
> +
> +	xa_lock_irq(xa);
> +
> +	/* Check again..... */
> +	if (xa != node->array || !list_empty(&node->private_list)) {
> +		node = new_node;
> +		goto unlock;
> +	}
> +
> +	memcpy(new_node, node, sizeof(struct xa_node));
> +
> +	/* Move pointers to new node */
> +	INIT_LIST_HEAD(&new_node->private_list);

Surely we can do something more clever, like ...

	if (xa != node->array) {
...
	if (list_empty(&node->private_list))
		INIT_LIST_HEAD(&new_node->private_list);
	else
		list_replace(&node->private_list, &new_node->private_list);


BTW, the raidx tree nodes / xa_nodes share the same slab cache; we need
to finish converting all radix tree & IDR users to the XArray before
this series can go in.

