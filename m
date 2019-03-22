Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E9A8C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 08:55:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BEB5218D3
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 08:55:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BEB5218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85BE86B0007; Fri, 22 Mar 2019 04:55:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80B246B0008; Fri, 22 Mar 2019 04:55:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 748BF6B000A; Fri, 22 Mar 2019 04:55:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 28C926B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:55:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w27so629184edb.13
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 01:55:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UKhjsu1GC7Hfpr6GM2R7qDy0SIfSZHfKt+EU0rqx7DE=;
        b=bmPuA9Qn9Mv9XmWiWwQWk/g/xyT5ilHRK+uHO+8BgCCZbL89YWCnHGjKa/lUzoKfgp
         HCTa+vW13vI/N3tyrYDwRdSktKG+ZiyIGVUxMvroo44Fa2pgMcNAQ++0XPWOIwUECJXs
         j/0Ub1jx0F6vepZ/AXhCUiBSJ/pldjIUt6KDfuqk9AHIKOvBFiVF4tlUVX0beBe1k0pq
         hmiA3HdSJ/4aNoYv2B2yBF3neZPUGIa2yvATpYV+TXouZ+HQtc9pNSSY5G4mSGRmyiV3
         BjfleNhdCykBnJ9TwpDqK2HaN8Acw1mB2lZ7tBlnF902DIVID/5DdwCj0tAGIc1Tmb5S
         RgFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVPEZygWIF2tjDkmyIhl14ituTttE/OJfiG+H6avSO7iHctuIBI
	v7OuH4rzaU36UDE2zKX2nTKTUGk9CImHk4yQBOMJecLzVArA4XZFUzaol38h21M9HthCb04bRHa
	2CvdFPTtQ8AONgIlaigNpF+P3+YoXZktS60gepYt38YInJVPgqlaiocHZoKG8rFsdTA==
X-Received: by 2002:a50:bacc:: with SMTP id x70mr5435283ede.211.1553244919694;
        Fri, 22 Mar 2019 01:55:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMGhDwt8SDpC54uhEbIaxkDirkpQRDVr3kKjLn7L3xsvzfSaATev7muORTHH4DMzFRFWX3
X-Received: by 2002:a50:bacc:: with SMTP id x70mr5435240ede.211.1553244918638;
        Fri, 22 Mar 2019 01:55:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553244918; cv=none;
        d=google.com; s=arc-20160816;
        b=PieBF6P3OsP2erIRgdVuTMowIOZPDSX5TiBQZmNia7rLCXs3fe3n78FVQOZACCCOqi
         48KASbJUesPDEASf+YZncfsXbLpgD1GQd9BnLZKz5Kx/WbOvHamLmkUgoxu7Ix76OJYE
         JjrkL7kctD8gnNakhvfof/8W8xOlsNNEf9hkcrK9Eepioue+DRbtkN4vvOoOy5TGERnn
         b3ROEmSnBJOYQ+APg3tXbHH4wngnzIzcXpJ+l1NJ1vCcwbvD0Rd+ku7DQSXmJiReH0I9
         8YAX2anQEKonHDhn87KBlZlk+yvk2z/t1P2AhQrupyUxEBuIDFY/e/aMUAPcMJygy/kT
         eGgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UKhjsu1GC7Hfpr6GM2R7qDy0SIfSZHfKt+EU0rqx7DE=;
        b=cklgQbD8jHw8husHoXdov1NeDFZbsV2AbU4htTT5LZJbuij2fDF3puhDIHCbR0NySb
         m+VJl362/ATLaOy7kkJjCA3k8uBUMQR/HBd9TjpRIiGjG/7NBHhmCo74rAAfFCYWWdRi
         HME/peEdI1Cpha8WtoRdxb55rQaQQxUkPcaHqu2PoPvHJUGcauJQ0CYPFmGPQ9SpOCHy
         k/fvA4HWoUXQ1x34vyoQdaP2lmdZzWv4QyCOoW/QdUVodKVcJQac8T6hOzPQj+fRSDSR
         x0B6r5qk653lBNNA48E84ZMtvF8sXxJnXY0DpYexk5aUhpmGtmNC+QQdi8Uro6ESvbc9
         7kTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id f25si1690254edt.335.2019.03.22.01.55.18
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 01:55:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 4EE60466B; Fri, 22 Mar 2019 09:55:16 +0100 (CET)
Date: Fri, 22 Mar 2019 09:55:16 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190322085509.hzerxhk5cdewodl6@d104.suse.de>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190322073902.agfaoha233vi5dhu@d104.suse.de>
 <CABXGCsPXEAfYq3y58hMnXuctUm1D3Md=BpSo=cq5dR9+3aFzOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsPXEAfYq3y58hMnXuctUm1D3Md=BpSo=cq5dR9+3aFzOg@mail.gmail.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 12:54:01PM +0500, Mikhail Gavrilov wrote:
> On Fri, 22 Mar 2019 at 12:39, Oscar Salvador <osalvador@suse.de> wrote:
> >
> > do you happen to have your config at hand?
> > Could you share it please?
> >
> 
> https://pastebin.com/4idrLvJQ

Thanks, could you boot up with below patch and send back the log please?

diff --git a/mm/debug.c b/mm/debug.c
index 1611cf00a137..31f71517b0fb 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -54,7 +54,12 @@ void __dump_page(struct page *page, const char *reason)
 	 * dump_page() when detected.
 	 */
 	if (page_poisoned) {
-		pr_warn("page:%px is uninitialized and poisoned", page);
+		unsigned long pfn = page_to_pfn(page);
+		unsigned long section_nr = pfn_to_section_nr(pfn);
+		bool online = online_section(__nr_to_section(section_nr));
+
+		pr_warn("page:%px (pfn: %lx section: %ld online: %d)is uninitialized and poisoned",
+								page, pfn, section_nr, online);
 		goto hex_only;
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3eb01dedfb50..a7b54c5995a6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1324,6 +1324,7 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long end_pfn = PFN_UP(end);
+	unsigned long __pfn = start_pfn;
 
 	for (; start_pfn < end_pfn; start_pfn++) {
 		if (pfn_valid(start_pfn)) {
@@ -1342,6 +1343,7 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
 			__SetPageReserved(page);
 		}
 	}
+	pr_info("%s: %lx - %lx init\n", __func__, __pfn, end_pfn - 1);
 }
 
 static void __free_pages_ok(struct page *page, unsigned int order)
@@ -1617,6 +1619,7 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
 	unsigned long nr_pages = 0;
 	struct page *page = NULL;
+	unsigned long start_pfn = pfn;
 
 	for (; pfn < end_pfn; pfn++) {
 		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
@@ -1631,6 +1634,8 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
 		__init_single_page(page, pfn, zid, nid);
 		nr_pages++;
 	}
+
+	pr_info("%s: pfn: %lx - %lx init\n", __func__, start_pfn, end_pfn - 1);
 	return (nr_pages);
 }
 
@@ -5748,10 +5753,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * function.  They do not exist on hotplugged memory.
 		 */
 		if (context == MEMMAP_EARLY) {
-			if (!early_pfn_valid(pfn))
+			if (!early_pfn_valid(pfn)) {
+				pr_info("%s: skipping: %lx\n", __func__, pfn);
 				continue;
-			if (!early_pfn_in_nid(pfn, nid))
+			}
+			if (!early_pfn_in_nid(pfn, nid)) {
+				pr_info("%s: skipping: %lx\n", __func__, pfn);
 				continue;
+			}
 			if (overlap_memmap_init(zone, &pfn))
 				continue;
 			if (defer_init(nid, pfn, end_pfn))
@@ -5780,6 +5789,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			cond_resched();
 		}
 	}
+	pr_info("%s: pfn: %lx - %lx init\n", __func__, start_pfn, end_pfn - 1);
 }
 
 #ifdef CONFIG_ZONE_DEVICE
@@ -5852,6 +5862,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 		}
 	}
 
+	pr_info("%s: %lx - %lx init\n", __func__, start_pfn, end_pfn - 1);
 	pr_info("%s initialised, %lu pages in %ums\n", dev_name(pgmap->dev),
 		size, jiffies_to_msecs(jiffies - start));
 }
@@ -6651,6 +6662,8 @@ static void __init free_area_init_core(struct pglist_data *pgdat)
 		setup_usemap(pgdat, zone, zone_start_pfn, size);
 		init_currently_empty_zone(zone, zone_start_pfn, size);
 		memmap_init(size, nid, j, zone_start_pfn);
+		pr_info("%s: zone: %s zone: %lx - %lx\n",
+			__func__, zone->name, zone_start_pfn, zone_end_pfn(zone));
 	}
 }
 
@@ -6765,6 +6778,8 @@ static u64 zero_pfn_range(unsigned long spfn, unsigned long epfn)
 		pgcnt++;
 	}
 
+	pr_info("%s: %lx - %lx zeroed\n", __func__, spfn, epfn - 1);
+
 	return pgcnt;
 }

-- 
Oscar Salvador
SUSE L3

