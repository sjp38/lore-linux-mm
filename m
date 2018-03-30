Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 953916B0280
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 04:08:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k18so851985wri.9
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 01:08:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m7sor4086883eda.51.2018.03.30.01.08.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Mar 2018 01:08:13 -0700 (PDT)
Date: Fri, 30 Mar 2018 11:07:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 06/14] mm/page_alloc: Propagate encryption KeyID
 through page allocator
Message-ID: <20180330080735.cvajv6dbzbi2in7b@node.shutemov.name>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-7-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180328165540.648-7-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 28, 2018 at 07:55:32PM +0300, Kirill A. Shutemov wrote:
> diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
> index 4432f31e8479..99580091830b 100644
> --- a/arch/tile/mm/homecache.c
> +++ b/arch/tile/mm/homecache.c
> @@ -398,7 +398,7 @@ struct page *homecache_alloc_pages_node(int nid, gfp_t gfp_mask,
>  {
>  	struct page *page;
>  	BUG_ON(gfp_mask & __GFP_HIGHMEM);   /* must be lowmem */
> -	page = alloc_pages_node(nid, gfp_mask, order);
> +	page = alloc_pages_node(rch/x86/events/intel/pt.cnid, gfp_mask, order, 0);
>  	if (page)
>  		homecache_change_page_home(page, order, home);
>  	return page;

Ouch. Fixup:

diff --git a/arch/tile/mm/homecache.c b/arch/tile/mm/homecache.c
index 99580091830b..9eb14da556a8 100644
--- a/arch/tile/mm/homecache.c
+++ b/arch/tile/mm/homecache.c
@@ -398,7 +398,7 @@ struct page *homecache_alloc_pages_node(int nid, gfp_t gfp_mask,
 {
 	struct page *page;
 	BUG_ON(gfp_mask & __GFP_HIGHMEM);   /* must be lowmem */
-	page = alloc_pages_node(rch/x86/events/intel/pt.cnid, gfp_mask, order, 0);
+	page = alloc_pages_node(nid, gfp_mask, order, 0);
 	if (page)
 		homecache_change_page_home(page, order, home);
 	return page;
-- 
 Kirill A. Shutemov
