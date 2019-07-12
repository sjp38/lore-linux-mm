Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A69B3C742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:50:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 647EB20863
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:50:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cxBzmFcO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 647EB20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 121608E014D; Fri, 12 Jul 2019 09:50:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D2E68E00DB; Fri, 12 Jul 2019 09:50:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F02AF8E014D; Fri, 12 Jul 2019 09:50:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8F658E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:50:05 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so5222706pla.3
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:50:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fnnfXjFvjoDoIQnQuaRvGkZvYrw5HXbBFVcsaXovgKE=;
        b=gglEr40ppsoMLFjmbdFkkBksjABPFvsWNNFXRRGlbkxfnQ1lUzGbA1rnXe8d2q66/k
         NkT8o3bHnqxKihdrf+bSkSdVWvM+I5Siz2iKvTXYToOhS4ptyriGJkaXdWfB9YpyOXbh
         8uO+Dc5KyWgkik3LAO75VJIFIFIq3gJconFURSj5nzDq+ZiZ5XgH3mf/Bp07KN0FxXD1
         jdJaNAYYOwvU1HPCZmPDVRyOk4PGsUufJvQHBLmSxx9vM0uroAaIGIc3PhJhM+GYwzvy
         jgVHwmn+c8koiDLpdYpcgKu9oTWblevINeIQqzqAyXofdMuDzxu6CZ/Y8OiNWbZSp+1g
         TD0A==
X-Gm-Message-State: APjAAAX20iH53Iqf9/40iL0bUjnzi9GTY62gKUqbcKyuK6Y7dNKAAxsd
	ypcwWFfgHehIkC/StkNboUXEfvuUS31AA7CkmE9vRGlVCqnQfd+sqIejHFQPLaOoRnJ02sFXkV4
	1qIsigQLmosHQv0F1pMXk87DMWciGB4b4+eEKEACbk3Iw6qpeP9RWWy99KJXVdc3vSA==
X-Received: by 2002:a17:90a:2247:: with SMTP id c65mr11551541pje.24.1562939405306;
        Fri, 12 Jul 2019 06:50:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQnmwC5u7yCrqMP50qFnFoLIyPmAlhqM8+WKvibHFjhdil9RJyFyVCddVRKs7ldO6wsPlH
X-Received: by 2002:a17:90a:2247:: with SMTP id c65mr11551470pje.24.1562939404596;
        Fri, 12 Jul 2019 06:50:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562939404; cv=none;
        d=google.com; s=arc-20160816;
        b=Il95FHeuiuUcTbRvDUQF1uPOA8z5PkOI2cw8E3GLkQzl+lYA1KSgAQ6CdzTqPFm3bd
         0/JguWoFUk0Kv38Be86/DfWi/x3i6T50+5zoNBrgX4XBVJ1qeIvUqUYsTO4vIh35NG2a
         A5VK5IULWGCpfbnsMLi3KBJrJninKMPn15fPFlcWrMdzKKbK7WL3JUzmb2OB5tVTILd2
         c1B2AJS05D7t921mrDkKgVGlfn+hgnwsaXGmeAFSkefM5P/CniheMhlVP0S/aGhYmKZt
         1eVH9qR8yQrCjlWA0hvXSbueJq9dEmBQsPV0CmetU74v0hfs4NEh836CFHl+0dedzlN1
         xcEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fnnfXjFvjoDoIQnQuaRvGkZvYrw5HXbBFVcsaXovgKE=;
        b=oYgjt8uvuORi1kHeyueqqFRDtwEJ0Jdq2uquHqLWrW2/UW/6oCd16R7bvzeW9dgBJk
         KG3efQxiERqIRo5TrRnSC1O7qEDHB7BvlkRmIhql8UtvoFA/sppW2mm72Pg4tE7vJYqa
         yDIYWhCSrll38TB5DJ/u8BQwGe2ifWaQ1UH+0/TRZZKX1sr6EaDXeVd52U3vHxtRmoBm
         cs9/UlzIarM8stH/xmLrjrDyL6IA3F4fNnmcwRZ5w+QlWyHWVrx6jyQh0aTFJsbk3uCs
         XVvbK6jCrZswMHGECKY8GzBU3RlOtJwO0RiTfdfgmRE6cEnKAirrCwFcaq5ekFN9oc4I
         QjBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cxBzmFcO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q199si8453425pfq.112.2019.07.12.06.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 06:50:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cxBzmFcO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=fnnfXjFvjoDoIQnQuaRvGkZvYrw5HXbBFVcsaXovgKE=; b=cxBzmFcOfyCVzsiypcmiuOaB4
	1fMOmo+ZpbRPzJh+dTAYCbGidK6YiB8fbVv+neUEMBO1XgD5lFgobanIPl08Mxk/kB4jbRHgSXVIu
	aCrx/4k1V+9nWoRLBofxtdG0zd64VyyVgfuiwVS4CYteqh5B/2nbBOW5hf5MTuWwDcRHDCn+/Nc3s
	kYe9yq9chH57EPO3w0dPdAmX2U5O3eJJvSfg/Gh1ezFs3FNLWsIKC+otRLOEJ92WvN6OkgNGvm8zt
	FQ0G1NL4KUEWiWWE3e355AGY9P4U+l/lSbUFWthv4KVBi3Bml3xpaj7zCqeXdvrhPgklF9DUhNVjI
	jOn4gFOmA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hlvvv-0007EF-C1; Fri, 12 Jul 2019 13:49:55 +0000
Date: Fri, 12 Jul 2019 06:49:55 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Pengfei Li <lpf.vector@gmail.com>
Cc: akpm@linux-foundation.org, urezki@gmail.com, rpenyaev@suse.de,
	peterz@infradead.org, guro@fb.com, rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com, aryabinin@virtuozzo.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4 2/2] mm/vmalloc.c: Modify struct vmap_area to reduce
 its size
Message-ID: <20190712134955.GV32320@bombadil.infradead.org>
References: <20190712120213.2825-1-lpf.vector@gmail.com>
 <20190712120213.2825-3-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190712120213.2825-3-lpf.vector@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 08:02:13PM +0800, Pengfei Li wrote:
> +++ b/include/linux/vmalloc.h
> @@ -51,15 +51,37 @@ struct vmap_area {
>  	unsigned long va_start;
>  	unsigned long va_end;
>  
> -	/*
> -	 * Largest available free size in subtree.
> -	 */
> -	unsigned long subtree_max_size;
> -	unsigned long flags;
> -	struct rb_node rb_node;         /* address sorted rbtree */
> -	struct list_head list;          /* address sorted list */
> -	struct llist_node purge_list;    /* "lazy purge" list */
> -	struct vm_struct *vm;
> +	union {
> +		/* In rbtree and list sorted by address */
> +		struct {
> +			union {
> +				/*
> +				 * In "busy" rbtree and list.
> +				 * rbtree root:	vmap_area_root
> +				 * list head:	vmap_area_list
> +				 */
> +				struct vm_struct *vm;
> +
> +				/*
> +				 * In "free" rbtree and list.
> +				 * rbtree root:	free_vmap_area_root
> +				 * list head:	free_vmap_area_list
> +				 */
> +				unsigned long subtree_max_size;
> +			};
> +
> +			struct rb_node rb_node;
> +			struct list_head list;
> +		};
> +
> +		/*
> +		 * In "lazy purge" list.
> +		 * llist head: vmap_purge_list
> +		 */
> +		struct {
> +			struct llist_node purge_list;
> +		};

I don't think you need struct union struct union.  Because llist_node
is just a pointer, you can get the same savings with just:

	union {
		struct llist_node purge_list;
		struct vm_struct *vm;
		unsigned long subtree_max_size;
	};

