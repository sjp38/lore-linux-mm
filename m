Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88323C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 03:36:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEC6E2085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 03:36:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEC6E2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D7B98E0003; Mon, 17 Jun 2019 23:36:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 488068E0001; Mon, 17 Jun 2019 23:36:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39E138E0003; Mon, 17 Jun 2019 23:36:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 041408E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 23:36:13 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s4so9057001pgr.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:36:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1fSSe8suDKjBf1vgC8h2kWPwQn0B15jZkC7bjiGIFJk=;
        b=TcXO/Wpme/zpmS3F4XnLpmGD7RPtPucVr8niJasZAx/hCDO4fHMxVZgNnTu/BQJk0l
         4yDRNuIRKOtYwgSsKL30WQhbKkzMu3Cc6VvDQTAGyeixDwv4qChyG2eib7sIhIhazs9Y
         FQrgLRmBaYOWDL+720RazQhsTPCoih4NtxmZLWOVUe11KMsO6fwHG+ZcLxxGhrcWehYU
         Bw1BH3s/TK9zHoqNKgnedKFNYZ4TBTsOG7ORAsSMHsBX+7+Avx3BVpNL0D1WKVJdeA0r
         vd3NMUyTJx1LvRNYhFyrVcl870Bc7FetnvfxtTag65HmzPxI4ALV7yMI4zzxupZRkOpa
         1SiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWsL1uqjla2nfJG79MiMEHE5P1UY9H36mnZTITLwB726mpkH3lp
	Tl1twgd6Vqw7gwIfrM8htieCzMLNtkBs9guW9OEaSnYQstgPCdXIXYv36tG3UbjfEP+BtLlxV8l
	6sdQuGKZkOxsJ3qA119gpnJ815ClwGooRUyNRuE+g19iRuGsAOL2eBJ42N2A3Axg8Hw==
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr2742036pje.9.1560828972528;
        Mon, 17 Jun 2019 20:36:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAKcR6X9+j+tWZt1cWVQk2MA9szR85wkBcYqggN7UIIzs8JhbzzzXefwW55X56dumGwEbl
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr2741995pje.9.1560828971772;
        Mon, 17 Jun 2019 20:36:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560828971; cv=none;
        d=google.com; s=arc-20160816;
        b=D/Gx3l79hxUa9MX/jXb0Zo+Z0Pf3uYMFTvdbYbLdgSEpjDlBjjfLgpl1y3pOlyPqav
         l9+a1GCTr1rCY1dNH7bWTh+9xd1RCX1FTPhFtKqdaVoSPhXOy6av6OfA2RtWks162JDW
         FTSFFrBxAmkvkm/2q0tmmm1UPRoLrTUYq7JFhFspuWPCW2uMX5DIUbDDM6MZaRQZNINu
         B0gWl09TdW6L/PFh1X9VnzzzfKRNLEKzT3xTgjGE0y0F/cY7QCi2ti0Sjsq2+1dfoMmX
         bcZRKamBlnBQHRRfmn600EB2Iqk7g4RrmII/sAWFNI5h70aWxnolws00PXeh+IqME/9G
         9ChQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=1fSSe8suDKjBf1vgC8h2kWPwQn0B15jZkC7bjiGIFJk=;
        b=Ib8E/WqjjxjK8S3JM3NAIlCl1u/AEKQCheXffQBx7WX4blGyHsMedzAFMJ2gdUlr7L
         fAKKhHfhxspyCiMEgXmdyit/ybIHlBvKCXIKD1SmlagPEuLl/xQuAmKMX84msHzuX8zm
         4PU0SM4AztKq5GGMsqWhTzSoJXJxTi6ohpF9PhaIUjN7IlH8OO6o4DnxusmQ+ZMYA/6x
         5B1+TLkda9n5SF5AXS6NyTPHpUcLKfgupz/STB9pKkxo0YByHpFjIThzZxJMDF7odFbt
         y0H/XZaLP2Yh7rWGT8fkT/YcLuJv3/RLIgGO5uFt9o0Tb/xgqg8DKhx0Eejk6xMYsNi0
         l1pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id d132si12271292pfd.102.2019.06.17.20.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 20:36:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 20:36:10 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga001.fm.intel.com with ESMTP; 17 Jun 2019 20:36:09 -0700
Date: Tue, 18 Jun 2019 11:35:46 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	David Hildenbrand <david@redhat.com>, linux-nvdimm@lists.01.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, osalvador@suse.de
Subject: Re: [PATCH v9 06/12] mm: Kill is_dev_zone() helper
Message-ID: <20190618033546.GE18161@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977191260.2443951.15908146523735681570.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155977191260.2443951.15908146523735681570.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:58:32PM -0700, Dan Williams wrote:
>Given there are no more usages of is_dev_zone() outside of 'ifdef
>CONFIG_ZONE_DEVICE' protection, kill off the compilation helper.
>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Logan Gunthorpe <logang@deltatee.com>
>Acked-by: David Hildenbrand <david@redhat.com>
>Reviewed-by: Oscar Salvador <osalvador@suse.de>
>Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
>Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>

>---
> include/linux/mmzone.h |   12 ------------
> mm/page_alloc.c        |    2 +-
> 2 files changed, 1 insertion(+), 13 deletions(-)
>
>diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>index 6dd52d544857..49e7fb452dfd 100644
>--- a/include/linux/mmzone.h
>+++ b/include/linux/mmzone.h
>@@ -855,18 +855,6 @@ static inline int local_memory_node(int node_id) { return node_id; };
>  */
> #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
> 
>-#ifdef CONFIG_ZONE_DEVICE
>-static inline bool is_dev_zone(const struct zone *zone)
>-{
>-	return zone_idx(zone) == ZONE_DEVICE;
>-}
>-#else
>-static inline bool is_dev_zone(const struct zone *zone)
>-{
>-	return false;
>-}
>-#endif
>-
> /*
>  * Returns true if a zone has pages managed by the buddy allocator.
>  * All the reclaim decisions have to use this function rather than
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index bd773efe5b82..5dff3f49a372 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -5865,7 +5865,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
> 	unsigned long start = jiffies;
> 	int nid = pgdat->node_id;
> 
>-	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
>+	if (WARN_ON_ONCE(!pgmap || zone_idx(zone) != ZONE_DEVICE))
> 		return;
> 
> 	/*
>
>_______________________________________________
>Linux-nvdimm mailing list
>Linux-nvdimm@lists.01.org
>https://lists.01.org/mailman/listinfo/linux-nvdimm

-- 
Wei Yang
Help you, Help me

