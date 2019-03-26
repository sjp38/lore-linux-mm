Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB1ABC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:05:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C5202070D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:05:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VkC7m7yz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C5202070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F8396B000A; Tue, 26 Mar 2019 12:05:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 380B26B000C; Tue, 26 Mar 2019 12:05:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2217D6B000D; Tue, 26 Mar 2019 12:05:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CECC36B000A
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:05:45 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m17so12092164pgk.3
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:05:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Yz2RvGFb8xZomssZ7mtRK2dOFU1jnfJaOyAOB+cKBIQ=;
        b=sWWLEnd/8FJijNe3oojvFeT5dW9Doqum8/hgzCRkS2J5SyvfUp6DeNlSPHmGhDDPNz
         ZUJuZ19AZI1qZxdQK8O5HzANcL0Nn8Qvusl/U2lIe85CkDrC17sabZ3MYd0tEOEtX6Cg
         Gjn7SuVUkTzoXpOeim7vtWbE7bHd0r9hZCVu4Tpi5SxZc8jvF7cWlEXyFX+ig4jADpHp
         +ebhgDiIHNadlgYZ04Hx2iIn2/hfDjgggJYzziwY/kUM+akktyPGL8g4Kaui1WYEVHWQ
         Gv3WKLCXHJDStBoBgauQzL9XS1t+1IY82PaOOXEBQYAfHALHdUf9x6235+GKlkDrj0Qu
         rdfw==
X-Gm-Message-State: APjAAAU14biiEtx5DYTH/uTutam+6Ce/T21vuNI7UQ9ON4EY4PkVtiq1
	auRFOJA9nAEkrfyilDMhuUSpWcNdHC4q0iG8/I7jOkIICE5aqyvkdX+cz2KAv0BP0TMn8eblp43
	yS0DENZQzdl0inWR8ia/mC15ZgvTMcJnBQGqRRTgmA7XIsVNMVr9ouzofoF4XpRh7+A==
X-Received: by 2002:a63:4e10:: with SMTP id c16mr30267825pgb.302.1553616345299;
        Tue, 26 Mar 2019 09:05:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx18dkyC+qcQza6KH2L5qquVLlIxiubk9NJRvXAEp7DZKNcz8bicxGAWwv4wRWXXQGKNLdX
X-Received: by 2002:a63:4e10:: with SMTP id c16mr30267691pgb.302.1553616343940;
        Tue, 26 Mar 2019 09:05:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553616343; cv=none;
        d=google.com; s=arc-20160816;
        b=gZzcP7iUvxYMZ3IHv6Vdqs1zbs2jmUJxFAQT+fZ5TicAKVe5nNSHkLjQmIGlY/DlFQ
         4aPU5HOJX5DpIipZfPwRzzhnUohdq6jNGKby0T3ddUICxiTpz4UfQcABNg6+tIOhO3MV
         1uOo0UtpIPyWOVBdceFDSwWijrKCm6Ejba0J4FTUEv0IgiSyv1pzyslp1mn/rcBFupuf
         UoqEmXiLf7DZXMME3BzuEaJqCXD41qYuXxE6+uH+bDFRAt/4PB8IUHOUBU9/Y34ZxFgl
         amcZVihrbvPON7ENjvp1L8uP2aeAqYfM7sa/hARJdlQk2Q5Y/+fv6P9zsa30HKnwnZuB
         iaJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Yz2RvGFb8xZomssZ7mtRK2dOFU1jnfJaOyAOB+cKBIQ=;
        b=VZVoSTfziwfgyBHyhzER88YXHrbGrIxtIvMBw6derAns0C48eEH0q20Au42J0F43CA
         9YBmK5dJh75lyCJtpx+McA5Yc3bFh6QKQLztfWLHfGMqa+J/qz7VbLiGz4UzLfxI4dOp
         MAc8M4HTfP+ACJUJKn1GCXsxiMbjWRqwtPYsVLwjkDfA3eWCOOJo42spHIb5Fs8n3ip5
         +qQkGaDU74JYWYg5/Mp8aGCyBrxKXAd3of4SkjG2XFH4R5fAocNCxcf1O4H1H2A4rvVX
         0g3ydU6dC4xFImK0u195rBQoqvtildJA/4z228UVw9AQFiZZUokd1QtCD5lsWscZlZCN
         OviQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VkC7m7yz;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g12si17409708pla.52.2019.03.26.09.05.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 09:05:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VkC7m7yz;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Yz2RvGFb8xZomssZ7mtRK2dOFU1jnfJaOyAOB+cKBIQ=; b=VkC7m7yzRINQMwiNCcM2hrk5f
	+Ct1T7URpjIcWrbr0ScsN9kuCOsNZsyRTRwVJnZ0QY/ic6Ti3DY3001lLmKJbVaQ9VHyPCbcZlZjL
	ydVroQFgbIoPel1WyeZe4zc4W/A+zhSPdufqv6Iqh71FPVqEibq+mmDk9aeGpY7LWT4/IXdXHxEF0
	Ki7LZAq/eLVWcWuIrfPd2VYpRPTbE21WP+fudi4qLn3cJJ1fDpoEjImy7GIwSn4N5tGVz9LeXmdwf
	j4dP/8QAmKnXBG9qfRUXJVWa9INHMetFst4pP9jlJRY35GdXDHwNvdQyVLUU/S1YiiDTATVoyKPSw
	QsagImLOQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h8oa0-00042L-Ms; Tue, 26 Mar 2019 16:05:36 +0000
Date: Tue, 26 Mar 2019 09:05:36 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, mhocko@kernel.org,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] kmemleaak: survive in a low-memory situation
Message-ID: <20190326160536.GO10344@bombadil.infradead.org>
References: <20190326154338.20594-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326154338.20594-1-cai@lca.pw>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 11:43:38AM -0400, Qian Cai wrote:
> Unless there is a brave soul to reimplement the kmemleak to embed it's
> metadata into the tracked memory itself in a foreseeable future, this
> provides a good balance between enabling kmemleak in a low-memory
> situation and not introducing too much hackiness into the existing
> code for now.

I don't understand kmemleak.  Kirill pointed me at this a few days ago:

https://gist.github.com/kiryl/3225e235fea390aa2e49bf625bbe83ec

It's caused by the XArray allocating memory using GFP_NOWAIT | __GFP_NOWARN.
kmemleak then decides it needs to allocate memory to track this memory.
So it calls kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));

#define gfp_kmemleak_mask(gfp)  (((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
                                 __GFP_NORETRY | __GFP_NOMEMALLOC | \
                                 __GFP_NOWARN | __GFP_NOFAIL)

then the page allocator gets to see GFP_NOFAIL | GFP_NOWAIT and gets angry.

But I don't understand why kmemleak needs to mess with the GFP flags at
all.  Just allocate using the same flags as the caller, and fail the original
allocation if the kmemleak allocation fails.  Like this:

+++ b/mm/slab.h
@@ -435,12 +435,22 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
        for (i = 0; i < size; i++) {
                p[i] = kasan_slab_alloc(s, p[i], flags);
                /* As p[i] might get tagged, call kmemleak hook after KASAN. */
-               kmemleak_alloc_recursive(p[i], s->object_size, 1,
-                                        s->flags, flags);
+               if (kmemleak_alloc_recursive(p[i], s->object_size, 1,
+                                        s->flags, flags))
+                       goto fail;
        }
 
        if (memcg_kmem_enabled())
                memcg_kmem_put_cache(s);
+       return;
+
+fail:
+       while (i > 0) {
+               kasan_blah(...);
+               kmemleak_blah();
+               i--;
+       }
+	free_blah(p);
+       *p = NULL;
 }
 
 #ifndef CONFIG_SLOB


and if we had something like this, we wouldn't need kmemleak to have this
self-disabling or must-succeed property.

