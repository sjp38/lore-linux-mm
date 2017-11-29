Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB5D26B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 04:51:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i83so1165814wma.4
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:51:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w35si475161edm.121.2017.11.29.01.51.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 01:51:08 -0800 (PST)
Date: Wed, 29 Nov 2017 10:51:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 2/2] mm, hugetlb: do not rely on overcommit limit
 during migration
Message-ID: <20171129095106.q6pvltcouq567tz7@dhcp22.suse.cz>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128141211.11117-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 28-11-17 15:12:11, Michal Hocko wrote:
[...]
> +/*
> + * Internal hugetlb specific page flag. Do not use outside of the hugetlb
> + * code
> + */
> +static inline bool PageHugeTemporary(struct page *page)
> +{
> +	if (!PageHuge(page))
> +		return false;
> +
> +	return page[2].flags == -1U;
> +}
> +
> +static inline void SetPageHugeTemporary(struct page *page)
> +{
> +	page[2].flags = -1U;
> +}
> +
> +static inline void ClearPageHugeTemporary(struct page *page)
> +{
> +	page[2].flags = 0;
> +}

Ups, this is obviously not OK. I was just lucky to not hit BUG_ONs
because I am clearly overwriting node/zone data in flags. I will have to
find something else to abuse. I will go with my favorite mapping pointer
which is not used at all.
---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1be43563e226..db7544a0b7b6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1259,17 +1259,17 @@ static inline bool PageHugeTemporary(struct page *page)
 	if (!PageHuge(page))
 		return false;
 
-	return page[2].flags == -1U;
+	return page[2].mapping == -1U;
 }
 
 static inline void SetPageHugeTemporary(struct page *page)
 {
-	page[2].flags = -1U;
+	page[2].mapping = -1U;
 }
 
 static inline void ClearPageHugeTemporary(struct page *page)
 {
-	page[2].flags = 0;
+	page[2].mapping = NULL;
 }
 
 void free_huge_page(struct page *page)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
