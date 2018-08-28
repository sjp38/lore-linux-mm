Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3028E6B4856
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 18:13:58 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g12-v6so1232782plo.1
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 15:13:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i184-v6si1996020pfb.98.2018.08.28.15.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 15:13:57 -0700 (PDT)
Date: Tue, 28 Aug 2018 15:13:52 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
Message-ID: <20180828221352.GC11400@bombadil.infradead.org>
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535476780-5773-3-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Aug 28, 2018 at 01:19:40PM -0400, Waiman Long wrote:
> @@ -134,7 +135,7 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
>  	spin_lock(&nlru->lock);
>  	if (list_empty(item)) {
>  		l = list_lru_from_kmem(nlru, item, &memcg);
> -		list_add_tail(item, &l->list);
> +		(add_tail ? list_add_tail : list_add)(item, &l->list);
>  		/* Set shrinker bit if the first element was added */
>  		if (!l->nr_items++)
>  			memcg_set_shrinker_bit(memcg, nid,

That's not OK.  Write it out properly, ie:

		if (add_tail)
			list_add_tail(item, &l->list);
		else
			list_add(item, &l->list);
