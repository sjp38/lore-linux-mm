Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,UNWANTED_LANGUAGE_BODY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EA8BC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:44:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4626E218E0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:44:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ETgESkeO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4626E218E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB6E08E0003; Thu, 28 Feb 2019 16:44:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C64FE8E0001; Thu, 28 Feb 2019 16:44:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B06CC8E0003; Thu, 28 Feb 2019 16:44:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4038E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:44:43 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id l11so7198468ywl.18
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:44:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=/Ts67cHhYbVtBZ+ouZr6ycKx2Tx7Wf5W6XYUebOwjOQ=;
        b=p2SWNndbOqLsTtfpIiKOS0rNEKM5HpTKjrT9atWZxibfEQSCG7ii+lHohIBov6DuBp
         +lVfy3B5ILu40vJKX8GzNSe3neKXKWwJm6mCjfwAfMBGH5LzvWyyqMWJ/nvuVeXqRtJC
         9leigB+l+kKfq3cx7Cita1IpfEg0lVrAJCdJ3rUYnAEpxQ9OYA5PE966x7xrofRaNk9R
         MSlFOatbL75FtkHrttrdXRovftoxzQI75PFKj1g7BnV+bhyo/G0oS4hDNnmfaygg+X5V
         8bRfr49zu77DWfk3VP8Y4QNhO2Xl5TY433kT4oMZPd5r01yl39jNQ8OadyaFgXaicFkV
         tb2g==
X-Gm-Message-State: APjAAAWoAJ7ZZlVGc3X/Vz5Ek6KTX2BqPMNvssCDLC2HkTYtOgD0MdjG
	N8oCnN3OZsC0IWp0qFNs1awmK4K848qfLLLULY4gETEnXSiNz2RmO9vcCZvIyzr2R8O17UYJd/3
	5jzjSfHNFlinM0JjFSRgRTyFAaBEFcxRZh8zXR5nsWwjyEc/eKthvGQ0K7NN9N2R3Aw==
X-Received: by 2002:a25:4885:: with SMTP id v127mr1438793yba.169.1551390283226;
        Thu, 28 Feb 2019 13:44:43 -0800 (PST)
X-Google-Smtp-Source: APXvYqxHT89Ih0qI/LdD7dta8LSJKm8x2BPxeNUYYvYfojO6LoPIKMQfsXzhq+QlO6BBS8zF5m1q
X-Received: by 2002:a25:4885:: with SMTP id v127mr1438751yba.169.1551390282533;
        Thu, 28 Feb 2019 13:44:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551390282; cv=none;
        d=google.com; s=arc-20160816;
        b=jLwT4qYjcFRWL8ptkqUcCM0j6hETIHojac486lzMkSszfLDVvJeKoLjPIoM97pPDIj
         sx0wZjUhXsXtPPslkAPvvHXAOWKUSdK/3YPDZ8vVsnzQGwEYxXlh0Mi1X40djrZ+NxBp
         +SWorEAyEKyhnXUaogCDN/fHgwP4AfvZwRNqb+nUJSVI/amEtLLfWJx4FQQBcTpW1nWD
         2kHBbdXO9/svWds2GJr4hF7CVYsk1rUGebeYgp8r0k47/UmgDVbIwMX+zefAuSyv0M0Y
         vwuKPz1Zd9cqSajfwBK28FNbarBFi/ZIzbQuw3gjgNNq7W2wtZvt5n9Ol+rdvtaUKcTy
         /ekg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=/Ts67cHhYbVtBZ+ouZr6ycKx2Tx7Wf5W6XYUebOwjOQ=;
        b=U0Dqf2214qkznje7fpCfomC1CkxLzTNABuQ13yxwhh9PnxHNym1O7YMYdw05aHeKfs
         l7pYJlg8qRRhpgw7QZh2gTBka/fCwqZCRorqxWVUlwr3BHFd0GGwkQS7/bJkh/Q2lyhw
         csqs/DWw7AN/6FwJ90D4+I0sqVLPKvbFZCQgyKGyij988W+S/5zU8mXYXnk2L9/05ss5
         pcuAcixZRlBmKn7h3UMQSJQ+LCLwhrVJSDlS6J7es65/NfvtVzwVSNMrhMtWjfVOd3xu
         +PDJDUzqAUlhjww5bptk6q/a7aGfRPZKK2YTcVTu/AzNUFZEnc7XzWou5VMjmjPoNJHM
         q4Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ETgESkeO;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id w193si11385202ywa.205.2019.02.28.13.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 13:44:42 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ETgESkeO;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7856480000>; Thu, 28 Feb 2019 13:44:40 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Feb 2019 13:44:41 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Feb 2019 13:44:41 -0800
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Feb
 2019 21:44:40 +0000
Subject: Re: [PATCH v2 2/4] mm: remove zone_lru_lock() function access
 ->lru_lock directly
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton
	<akpm@linux-foundation.org>
CC: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman
	<mgorman@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-2-aryabinin@virtuozzo.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <44ffadb4-4235-76c9-332f-680dda5da521@nvidia.com>
Date: Thu, 28 Feb 2019 13:44:40 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190228083329.31892-2-aryabinin@virtuozzo.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551390281; bh=/Ts67cHhYbVtBZ+ouZr6ycKx2Tx7Wf5W6XYUebOwjOQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ETgESkeOLXCBUzBcNfOUO2yf+ijNCGe+fZc6VGzbXmaEJMlKUxLOKLvNYV5/8cz1j
	 dYxenWULRy+AssayFNv3D//xaKCOnR2vzfzXVEihgonFCN036ihbMkZllx837L2Chn
	 EEB8/qCmpJ5vb9oLVdNJrzdntYZ0nkxxIkfN+IxlGycz7Mv66tyRTZqJPJmUpRH0T0
	 PISjgmTE9DXqSEgI0XkdQjmdJcM3G8oZsPHv+TccevKPMvh5/nAA28pOLyBMB1JcKi
	 8C9xvzhZlU9OrJ5Ufe7Hf4bwOK6LZ8nX5lp26h99tC/qUaI5fbJlXXWY4RwM8zFiF+
	 Rf1UOK82I4Mrg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 12:33 AM, Andrey Ryabinin wrote:
> We have common pattern to access lru_lock from a page pointer:
> 	zone_lru_lock(page_zone(page))
> 
> Which is silly, because it unfolds to this:
> 	&NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)]->zone_pgdat->lru_lock
> while we can simply do
> 	&NODE_DATA(page_to_nid(page))->lru_lock
> 

Hi Andrey,

Nice. I like it so much that I immediately want to tweak it. :)


> Remove zone_lru_lock() function, since it's only complicate things.
> Use 'page_pgdat(page)->lru_lock' pattern instead.

Here, I think the zone_lru_lock() is actually a nice way to add
a touch of clarity at the call sites. How about, see below:

[snip]

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 2fd4247262e9..22423763c0bd 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -788,10 +788,6 @@ typedef struct pglist_data {
>  
>  #define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
>  #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
> -static inline spinlock_t *zone_lru_lock(struct zone *zone)
> -{
> -	return &zone->zone_pgdat->lru_lock;
> -}
>  

Instead of removing that function, let's change it, and add another
(since you have two cases: either a page* or a pgdat* is available),
and move it to where it can compile, like this:


diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..cea3437f5d68 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1167,6 +1167,16 @@ static inline pg_data_t *page_pgdat(const struct page *page)
        return NODE_DATA(page_to_nid(page));
 }
 
+static inline spinlock_t *zone_lru_lock(pg_data_t *pgdat)
+{
+       return &pgdat->lru_lock;
+}
+
+static inline spinlock_t *zone_lru_lock_from_page(struct page *page)
+{
+       return zone_lru_lock(page_pgdat(page));
+}
+
 #ifdef SECTION_IN_PAGE_FLAGS
 static inline void set_page_section(struct page *page, unsigned long section)
 {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 842f9189537b..e03042fe1d88 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -728,11 +728,6 @@ typedef struct pglist_data {
 
 #define node_start_pfn(nid)    (NODE_DATA(nid)->node_start_pfn)
 #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
-static inline spinlock_t *zone_lru_lock(struct zone *zone)
-{
-       return &zone->zone_pgdat->lru_lock;
-}
-
 static inline struct lruvec *node_lruvec(struct pglist_data *pgdat)
 {
        return &pgdat->lruvec;



Like it?

thanks,
-- 
John Hubbard
NVIDIA

