Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 66C3A6B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 16:58:27 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f19-v6so11182081plr.23
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 13:58:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 9si2537401pgg.286.2018.04.03.13.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 13:58:26 -0700 (PDT)
Date: Tue, 3 Apr 2018 13:58:22 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] kfree_rcu() should use kfree_bulk() interface
Message-ID: <20180403205822.GB30145@bombadil.infradead.org>
References: <1522776173-7190-1-git-send-email-rao.shoaib@oracle.com>
 <1522776173-7190-3-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522776173-7190-3-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rao.shoaib@oracle.com
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, joe@perches.com, brouer@redhat.com, linux-mm@kvack.org

On Tue, Apr 03, 2018 at 10:22:53AM -0700, rao.shoaib@oracle.com wrote:
> +++ b/mm/slab.h
> @@ -80,6 +80,29 @@ extern const struct kmalloc_info_struct {
>  	unsigned long size;
>  } kmalloc_info[];
>  
> +#define	RCU_MAX_ACCUMULATE_SIZE	25
> +
> +struct rcu_bulk_free_container {
> +	struct	rcu_head rbfc_rcu;
> +	int	rbfc_entries;
> +	void	*rbfc_data[RCU_MAX_ACCUMULATE_SIZE];
> +	struct	rcu_bulk_free *rbfc_rbf;
> +};
> +
> +struct rcu_bulk_free {
> +	struct	rcu_head rbf_rcu; /* used to schedule monitor process */
> +	spinlock_t	rbf_lock;
> +	struct		rcu_bulk_free_container *rbf_container;
> +	struct		rcu_bulk_free_container *rbf_cached_container;
> +	struct		rcu_head *rbf_list_head;
> +	int		rbf_list_size;
> +	int		rbf_cpu;
> +	int		rbf_empty;
> +	int		rbf_polled;
> +	bool		rbf_init;
> +	bool		rbf_monitor;
> +};

I think you might be better off with an IDR.  The IDR can always
contain one entry, so there's no need for this 'rbf_list_head' or
__rcu_bulk_schedule_list.  The IDR contains its first 64 entries in
an array (if that array can be allocated), so it's compatible with the
kfree_bulk() interface.
