Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A21046B000D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 14:56:17 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l17-v6so5294498edq.11
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 11:56:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e20-v6si7076eds.262.2018.07.02.11.56.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 11:56:16 -0700 (PDT)
Date: Mon, 2 Jul 2018 20:56:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: teach dump_page() to correctly output poisoned
 struct pages
Message-ID: <20180702185612.GJ19043@dhcp22.suse.cz>
References: <20180702180536.2552-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702180536.2552-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, gregkh@linuxfoundation.org

On Mon 02-07-18 14:05:36, Pavel Tatashin wrote:
[...]
>  void __dump_page(struct page *page, const char *reason)
>  {
> +	bool page_poisoned = PagePoisoned(page);
> +	int mapcount;
> +
> +	/*
> +	 * If struct page is poisoned don't access Page*() functions as that
> +	 * leads to recursive loop. Page*() check for poisoned pages, and calls
> +	 * dump_page() when detected.
> +	 */
> +	if (page_poisoned) {
> +		pr_emerg("page:%px is uninitialized and poisoned", page);
> +		goto hex_only;
> +	}

Thanks for the updated comment. Exactly what I was looking for!
-- 
Michal Hocko
SUSE Labs
