Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 322986B3390
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 19:04:09 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id y2so16870232plr.8
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 16:04:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v2si53832606pgn.451.2018.11.23.16.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 16:04:08 -0800 (PST)
Date: Fri, 23 Nov 2018 16:04:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/5] mm: print more information about mapping in
 __dump_page
Message-Id: <20181123160404.259413e56a8cc9a22112712a@linux-foundation.org>
In-Reply-To: <20181107101830.17405-2-mhocko@kernel.org>
References: <20181107101830.17405-1-mhocko@kernel.org>
	<20181107101830.17405-2-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed,  7 Nov 2018 11:18:26 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> __dump_page prints the mapping pointer but that is quite unhelpful
> for many reports because the pointer itself only helps to distinguish
> anon/ksm mappings from other ones (because of lowest bits
> set). Sometimes it would be much more helpful to know what kind of
> mapping that is actually and if we know this is a file mapping then also
> try to resolve the dentry name.
> 
> ...
>
> --- a/mm/debug.c
> +++ b/mm/debug.c
>
> ...
>
> @@ -70,6 +71,18 @@ void __dump_page(struct page *page, const char *reason)
>  	if (PageCompound(page))
>  		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
>  	pr_cont("\n");
> +	if (PageAnon(page))
> +		pr_emerg("anon ");
> +	else if (PageKsm(page))
> +		pr_emerg("ksm ");
> +	else if (mapping) {
> +		pr_emerg("%ps ", mapping->a_ops);
> +		if (mapping->host->i_dentry.first) {
> +			struct dentry *dentry;
> +			dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
> +			pr_emerg("name:\"%*s\" ", dentry->d_name.len, dentry->d_name.name);
> +		}
> +	}

There has to be a better way of printing the filename.  It is so often
needed.

The (poorly named and gleefully undocumented)
take_dentry_name_snapshot() looks promising.  However it's unclear that
__dump_page() is always called from contexts where
take_dentry_name_snapshot() and release_dentry_name_snapshot() can be
safely called.  Probably it's OK, but how to guarantee it?
