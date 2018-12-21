Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C10F8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 08:24:26 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 82so4917193pfs.20
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 05:24:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h9si21714594plb.180.2018.12.21.05.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 05:24:25 -0800 (PST)
Date: Fri, 21 Dec 2018 05:24:23 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Define VM_(MAX|MIN)_READAHEAD via sizes.h constants
Message-ID: <20181221132423.GA10600@bombadil.infradead.org>
References: <20181221125314.5177-1-nborisov@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221125314.5177-1-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org, linux-fsdevel@vger.kernel.org

On Fri, Dec 21, 2018 at 02:53:14PM +0200, Nikolay Borisov wrote:
> All users of the aformentioned macros convert them to kbytes by
> multplying. Instead, directly define the macros via the aptly named
> SZ_16K/SZ_128K ones. Also remove the now redundant comments explaining
> that VM_* are defined in kbytes it's obvious. No functional changes.

Actually, all users of these constants convert them to pages!

> +	q->backing_dev_info->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
> +		sb->s_bdi->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
> +	sb->s_bdi->ra_pages	= VM_MAX_READAHEAD / PAGE_SIZE;
> +	sb->s_bdi->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;
> +	sb->s_bdi->ra_pages = VM_MAX_READAHEAD / PAGE_SIZE;

> -#define VM_MAX_READAHEAD	128	/* kbytes */
> -#define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
> +#define VM_MAX_READAHEAD	SZ_128K
> +#define VM_MIN_READAHEAD	SZ_16K	/* includes current page */

So perhaps:

#define VM_MAX_READAHEAD	(SZ_128K / PAGE_SIZE)

VM_MIN_READAHEAD isn't used, so just delete it?
