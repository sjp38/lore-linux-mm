Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1006B02C3
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 02:25:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m79so74626822pfg.13
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 23:25:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m20si9126264pli.535.2017.06.05.23.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 23:25:18 -0700 (PDT)
Date: Mon, 5 Jun 2017 23:25:06 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/5] Protectable Memory Allocator
Message-ID: <20170606062505.GA18315@infradead.org>
References: <20170605192216.21596-1-igor.stoppa@huawei.com>
 <20170605192216.21596-3-igor.stoppa@huawei.com>
 <201706060444.v564iWds024768@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706060444.v564iWds024768@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, Jun 06, 2017 at 01:44:32PM +0900, Tetsuo Handa wrote:
> Igor Stoppa wrote:
> > +int pmalloc_protect_pool(struct pmalloc_pool *pool)
> > +{
> > +	struct pmalloc_node *node;
> > +
> > +	if (!pool)
> > +		return -EINVAL;
> > +	mutex_lock(&pool->nodes_list_mutex);
> > +	hlist_for_each_entry(node, &pool->nodes_list_head, nodes_list) {
> > +		unsigned long size, pages;
> > +
> > +		size = WORD_SIZE * node->total_words + HEADER_SIZE;
> > +		pages = size / PAGE_SIZE;
> > +		set_memory_ro((unsigned long)node, pages);
> > +	}
> > +	pool->protected = true;
> > +	mutex_unlock(&pool->nodes_list_mutex);
> > +	return 0;
> > +}
> 
> As far as I know, not all CONFIG_MMU=y architectures provide
> set_memory_ro()/set_memory_rw(). You need to provide fallback for
> architectures which do not provide set_memory_ro()/set_memory_rw()
> or kernels built with CONFIG_MMU=n.

I think we'll just need to generalize CONFIG_STRICT_MODULE_RWX and/or
ARCH_HAS_STRICT_MODULE_RWX so there is a symbol to key this off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
