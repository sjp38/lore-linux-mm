Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D56AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 08:56:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA912218E2
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 08:56:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA912218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ED7F6B000A; Fri, 22 Mar 2019 04:56:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59A406B000C; Fri, 22 Mar 2019 04:56:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B23B6B000D; Fri, 22 Mar 2019 04:56:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBAC66B000A
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:56:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d5so641149edl.22
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 01:56:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pWOC4AsGtk6wfgJPYZed3y8AfIymm1C5nJqx4I479ds=;
        b=uFDf4mgOb3AiRUT4a4T+sHfDAP6XyTQza0oray1PxxPAEyooqDQyNit9F4uEP/Cmo9
         NyI/HQX0W3NeM+dfPu+FoWqpZSNVzOM8zNWlOphIFi1z4qQVcqsCmtLpcZbqADzfHHrz
         y5YsVUkM1TZvUhhvsUGFyPZh0ZzAaaO7DTUcnrRzQGGq6h2sErm/V94Qu4vV7TvpnNhj
         JpMjKRCxdA/Zn8L3sFZJ00jqqM+DgnWtD30/RjFcnurOS0rijWQJcPRxLlU1nFVvKN0q
         xOWz8ey9lKnkwZXTqMEdXFdKQlrQ7EGe3fiHfqkJiFrW7P55nb1sn5b/SUe/dXn4ziSs
         7ARQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVFzCTP71qvg4DJjIQMHe/fN4BnIJpwNt6fNGf5SktLlmdGIOc6
	Cdo9Ms42uPMCtqLjPnHxEk/BZRaCsN0QL5wEiu1uZ0oNaDHuupJcpzINhBrOzUE56cnWPR8ZIFY
	s3dtz2NsB3kn+W6NESIAHOUOBfB+dlkalgOwySaDahUgwL4/EYqRZ7gAFD412HgxasQ==
X-Received: by 2002:a50:978e:: with SMTP id e14mr5285974edb.234.1553244986534;
        Fri, 22 Mar 2019 01:56:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyciHtpJnd+87EeTfpSYVPnVIVxf6Z11JbVhrtChXF7Po3uW5Ju6MLybBZ1mrzlJdCOYQz
X-Received: by 2002:a50:978e:: with SMTP id e14mr5285935edb.234.1553244985560;
        Fri, 22 Mar 2019 01:56:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553244985; cv=none;
        d=google.com; s=arc-20160816;
        b=C9QJPhwjiwczWpWrlosC6w2Temv3Kq2/RclMRDpC7cxzhrSsMBV6WYbg4T7/uNhm3F
         PENvtvHFrgN8Rv7EF4znRBLLjIinZtIAITA0KGxE1KFvHKZCpJTmSqzHWK5Wp8NO73K5
         SKAo+okDn69lPd3M6t3fDiz4zQjXu7iXyMKkmCzdTB7vvHjxTzNbYM1rTd/uaZBb3xB1
         jPFrvZWD4qd7Ta/Ezi0bmcSRTZ+snB71sjmQWjc0czzgJte5lr6QDzTwLz7LnB58n1RB
         TMScVWwQnJbgztq5VqdWy1IafvAoqxaG696BHgOQ+UeE240+nP6z6Ak4zixc3ODB4w76
         UdWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pWOC4AsGtk6wfgJPYZed3y8AfIymm1C5nJqx4I479ds=;
        b=S6Rne9DDyVxvOv0XreUCxiHAozkcJ5o1wlTLDxLjPMyNDZ7GzcsoDLn96ieoGTxwwD
         LASuir5FRlE/EJTSGA0T0qTjdr/xRa+s62mHRQr8wc0iu9D/8e+dgEfrjGJOKxwp1kot
         EfvtInjMEm1ivpIy2Wv9En01zCmn0t1dmAn+9lTpkPlTLgmsigZi8MrIn+nLLzAKE4IC
         3fWMe8xJajbCjJ9fM1LxlXbZ8s+b0DJIuF/nfxD73mCUmod/XG/kpSGMEmzVU1J7H84m
         TUbgvEsjMWwMms/WTix/bvS/YPi63dx6haSLwP9eHhpduNiCesyrxQImSS8tpPiYbC26
         Ed4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id b23si3048477ede.163.2019.03.22.01.56.25
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 01:56:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id EA6F9466D; Fri, 22 Mar 2019 09:56:24 +0100 (CET)
Date: Fri, 22 Mar 2019 09:56:24 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190322085624.efa2pdu3shjkjkxh@d104.suse.de>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190322073902.agfaoha233vi5dhu@d104.suse.de>
 <CABXGCsPXEAfYq3y58hMnXuctUm1D3Md=BpSo=cq5dR9+3aFzOg@mail.gmail.com>
 <20190322085509.hzerxhk5cdewodl6@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322085509.hzerxhk5cdewodl6@d104.suse.de>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 09:55:16AM +0100, Oscar Salvador wrote:
> On Fri, Mar 22, 2019 at 12:54:01PM +0500, Mikhail Gavrilov wrote:
> > On Fri, 22 Mar 2019 at 12:39, Oscar Salvador <osalvador@suse.de> wrote:
> > >
> > > do you happen to have your config at hand?
> > > Could you share it please?
> > >
> > 
> > https://pastebin.com/4idrLvJQ
> 
> Thanks, could you boot up with below patch and send back the log please?

I mean to send back the log once you trigger the issue again.

> 
> diff --git a/mm/debug.c b/mm/debug.c
> index 1611cf00a137..31f71517b0fb 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -54,7 +54,12 @@ void __dump_page(struct page *page, const char *reason)
>  	 * dump_page() when detected.
>  	 */
>  	if (page_poisoned) {
> -		pr_warn("page:%px is uninitialized and poisoned", page);
> +		unsigned long pfn = page_to_pfn(page);
> +		unsigned long section_nr = pfn_to_section_nr(pfn);
> +		bool online = online_section(__nr_to_section(section_nr));
> +
> +		pr_warn("page:%px (pfn: %lx section: %ld online: %d)is uninitialized and poisoned",
> +								page, pfn, section_nr, online);
>  		goto hex_only;
>  	}
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3eb01dedfb50..a7b54c5995a6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1324,6 +1324,7 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
>  {
>  	unsigned long start_pfn = PFN_DOWN(start);
>  	unsigned long end_pfn = PFN_UP(end);
> +	unsigned long __pfn = start_pfn;
>  
>  	for (; start_pfn < end_pfn; start_pfn++) {
>  		if (pfn_valid(start_pfn)) {
> @@ -1342,6 +1343,7 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
>  			__SetPageReserved(page);
>  		}
>  	}
> +	pr_info("%s: %lx - %lx init\n", __func__, __pfn, end_pfn - 1);
>  }
>  
>  static void __free_pages_ok(struct page *page, unsigned int order)
> @@ -1617,6 +1619,7 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
>  	unsigned long nr_pgmask = pageblock_nr_pages - 1;
>  	unsigned long nr_pages = 0;
>  	struct page *page = NULL;
> +	unsigned long start_pfn = pfn;
>  
>  	for (; pfn < end_pfn; pfn++) {
>  		if (!deferred_pfn_valid(nid, pfn, &nid_init_state)) {
> @@ -1631,6 +1634,8 @@ static unsigned long  __init deferred_init_pages(int nid, int zid,
>  		__init_single_page(page, pfn, zid, nid);
>  		nr_pages++;
>  	}
> +
> +	pr_info("%s: pfn: %lx - %lx init\n", __func__, start_pfn, end_pfn - 1);
>  	return (nr_pages);
>  }
>  
> @@ -5748,10 +5753,14 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  		 * function.  They do not exist on hotplugged memory.
>  		 */
>  		if (context == MEMMAP_EARLY) {
> -			if (!early_pfn_valid(pfn))
> +			if (!early_pfn_valid(pfn)) {
> +				pr_info("%s: skipping: %lx\n", __func__, pfn);
>  				continue;
> -			if (!early_pfn_in_nid(pfn, nid))
> +			}
> +			if (!early_pfn_in_nid(pfn, nid)) {
> +				pr_info("%s: skipping: %lx\n", __func__, pfn);
>  				continue;
> +			}
>  			if (overlap_memmap_init(zone, &pfn))
>  				continue;
>  			if (defer_init(nid, pfn, end_pfn))
> @@ -5780,6 +5789,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  			cond_resched();
>  		}
>  	}
> +	pr_info("%s: pfn: %lx - %lx init\n", __func__, start_pfn, end_pfn - 1);
>  }
>  
>  #ifdef CONFIG_ZONE_DEVICE
> @@ -5852,6 +5862,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
>  		}
>  	}
>  
> +	pr_info("%s: %lx - %lx init\n", __func__, start_pfn, end_pfn - 1);
>  	pr_info("%s initialised, %lu pages in %ums\n", dev_name(pgmap->dev),
>  		size, jiffies_to_msecs(jiffies - start));
>  }
> @@ -6651,6 +6662,8 @@ static void __init free_area_init_core(struct pglist_data *pgdat)
>  		setup_usemap(pgdat, zone, zone_start_pfn, size);
>  		init_currently_empty_zone(zone, zone_start_pfn, size);
>  		memmap_init(size, nid, j, zone_start_pfn);
> +		pr_info("%s: zone: %s zone: %lx - %lx\n",
> +			__func__, zone->name, zone_start_pfn, zone_end_pfn(zone));
>  	}
>  }
>  
> @@ -6765,6 +6778,8 @@ static u64 zero_pfn_range(unsigned long spfn, unsigned long epfn)
>  		pgcnt++;
>  	}
>  
> +	pr_info("%s: %lx - %lx zeroed\n", __func__, spfn, epfn - 1);
> +
>  	return pgcnt;
>  }
> 
> -- 
> Oscar Salvador
> SUSE L3
> 

-- 
Oscar Salvador
SUSE L3

