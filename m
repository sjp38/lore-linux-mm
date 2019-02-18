Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E651C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:51:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09CFF2173C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:51:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09CFF2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8BFD8E0003; Mon, 18 Feb 2019 12:51:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3AEC8E0002; Mon, 18 Feb 2019 12:51:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADBD78E0003; Mon, 18 Feb 2019 12:51:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD4B8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:51:15 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id q193so15202110qke.12
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:51:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=O1K2rmTkRkPvorn2KTFNNBW8ayzzov6KnyOQ+EOWIBE=;
        b=G1sNAFvW7KPHloB6uaWOXoZp113ak126HshGiYjiUjEPVyJ2RiX3Rdw2z/Gt7qwFDR
         0h9PR5FO1wEHHM3eaq3IfTRW5QUyONhfSAHDezx4y8cCjilxIu9bBcsl2NRY/kvsknYA
         W3e9ysKAnmghu/rDwcrLa5x/SERNcj9VBvNctkrlQAuVeko8wCjrEo/EEWZhb2dlcstz
         Z9RFmxQ54nnAMjceGA+Dj1QKdi2mGvLIwbT+sMyJpzGL8pPYxSm7S1ncHlX3cSmDAKsW
         9vKNaREVvOWw2u7Zx0/KSeNSWxPlAgICLQryP4kazu6aliJvjMDCbBhbf6l3863ZshCA
         ZnaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYzEL33zWMwvGMDiukX/2RoVDgVF7BsygOgmhaNTgApWWweUSsS
	yQ4VHBUx8eqRzRiDZk9DGxcmpit9TtuMf88Iouhw2XtmpnVZnY00aD4apFCMmhVLyV0aPFT2hiy
	XoDXNnPopiwIGv2jya7cWmkAgPP6+ZwBm44gSIeOyjLFsLxm/UOUQbkDAdfZ7nCEwMQ==
X-Received: by 2002:ac8:2709:: with SMTP id g9mr18730292qtg.287.1550512275238;
        Mon, 18 Feb 2019 09:51:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia8Pr1k+xQXZ6iI0Ga2R9X6iIid2NLeqttHTrE+US/b3iEFuAvJVt4z4Buv0YJCYS0EUCyr
X-Received: by 2002:ac8:2709:: with SMTP id g9mr18730259qtg.287.1550512274547;
        Mon, 18 Feb 2019 09:51:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550512274; cv=none;
        d=google.com; s=arc-20160816;
        b=LnkYzPSPEWFhpFHapfhhS22KuZ13xeS7iKZNjvHFvKmVBAk0HG713Oy0ox82+XuCqb
         ONwO4nwpPDiSCStGxWp8+nGpZzOhQ7JP3ftb6uWk0qSL4RzGyKj5k0l2a2s7pdi0z84/
         +mo67BCJN/J2BkvRt7RFCUpjCst0tcBSRMfioDnvU6TmhvwI2nvkT/2Ep+/8NwXcHCLq
         s2n0A+NZKlXUOO42H82UIAHTyn8VBUFx8d6s5MbJpumDDuls1ZCY/ceUfg4yNqkJrsM3
         kRLA7xmpy0ihR/MnXNG0jiCP6Rw9hWB1Aqday50+p6Y8q/ModkZJGPXis9PayMb5LuE6
         TyGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=O1K2rmTkRkPvorn2KTFNNBW8ayzzov6KnyOQ+EOWIBE=;
        b=dCX56gJ+LFA2A6KQ3IxEeHV2ZO+4efUCAATkAvxvb+xCK2GfGdwe543mNxMujwE4p/
         e8wXEjja8fyym5qxGbIOex7GB0QczJP/DaRpMRkxC5uqYRd7/HsA5t+PhJVF0cBg8SOJ
         s1/Z6KdcwG7eve5pbTsXeOhBcHfVkk3lsqv/1LGiQNj8p/StoBfw03dBvxA3iaITpKIo
         awb4pjeTf+dqIgkEJqMrtNGIoh31080elZUBzV7nuOS8VBDyPs2v5OXuNqpEvN91CE+U
         wsXc7JL/lxmA1YFleycr7REnUtHe/V0MfbFVLf707P8nWgcmklGw+mBqdeM0tAuVb8Ef
         epQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w12si4787056qka.209.2019.02.18.09.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 09:51:14 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1IHp5JW129005
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:51:14 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qqxrf0u3h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:51:10 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 18 Feb 2019 17:48:38 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 18 Feb 2019 17:48:34 -0000
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1IHmX9R24838356
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 18 Feb 2019 17:48:33 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9FF9E42042;
	Mon, 18 Feb 2019 17:48:33 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D0F0C42047;
	Mon, 18 Feb 2019 17:48:31 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.239])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 18 Feb 2019 17:48:31 +0000 (GMT)
Date: Mon, 18 Feb 2019 19:48:29 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rong Chen <rong.a.chen@intel.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        linux-kernel@vger.kernel.org,
        Linux Memory Management List <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>, LKP <lkp@01.org>,
        Oscar Salvador <osalvador@suse.de>
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
References: <20190218052823.GH29177@shao2-debian>
 <20190218070844.GC4525@dhcp22.suse.cz>
 <20190218085510.GC7251@dhcp22.suse.cz>
 <4c75d424-2c51-0d7d-5c28-78c15600e93c@intel.com>
 <20190218103013.GK4525@dhcp22.suse.cz>
 <20190218140515.GF25446@rapoport-lnx>
 <20190218152050.GS4525@dhcp22.suse.cz>
 <20190218152213.GT4525@dhcp22.suse.cz>
 <20190218164813.GG25446@rapoport-lnx>
 <20190218170558.GV4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218170558.GV4525@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021817-0028-0000-0000-00000349FEEB
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021817-0029-0000-0000-0000240837F9
Message-Id: <20190218174828.GH25446@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902180132
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 06:05:58PM +0100, Michal Hocko wrote:
> On Mon 18-02-19 18:48:14, Mike Rapoport wrote:
> > On Mon, Feb 18, 2019 at 04:22:13PM +0100, Michal Hocko wrote:
> [...]
> > > Thinking about it some more, is it possible that we are overflowing by 1
> > > here?
> > 
> > Looks like that, the end_pfn is actually the first pfn in the next section.
> 
> Thanks for the confirmation. I guess it also exaplains why nobody has
> noticed this off-by-one. Most people seem to use VMEMMAP SPARSE model
> and we are safe there.
> 
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > index 124e794867c5..6618b9d3e53a 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > > @@ -1234,10 +1234,10 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
> > >  {
> > >  	struct page *page = pfn_to_page(start_pfn);
> > >  	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> > > -	struct page *end_page = pfn_to_page(end_pfn);
> > > +	struct page *end_page = pfn_to_page(end_pfn - 1);
> > >  
> > >  	/* Check the starting page of each pageblock within the range */
> > > -	for (; page < end_page; page = next_active_pageblock(page)) {
> > > +	for (; page <= end_page; page = next_active_pageblock(page)) {
> > >  		if (!is_pageblock_removable_nolock(page))
> > >  			return false;
> > >  		cond_resched();
> > 
> > Works with your fix, but I think mine is more intuitive ;-)
> 
> I would rather go and rework this to pfns. What about this instead.
> Slightly larger but arguably cleared code?

Yeah, this is clearer.
 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 124e794867c5..a799a0bdbf34 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1188,11 +1188,13 @@ static inline int pageblock_free(struct page *page)
>  	return PageBuddy(page) && page_order(page) >= pageblock_order;
>  }
>  
> -/* Return the start of the next active pageblock after a given page */
> -static struct page *next_active_pageblock(struct page *page)
> +/* Return the pfn of the start of the next active pageblock after a given pfn */
> +static unsigned long next_active_pageblock(unsigned long pfn)
>  {
> +	struct page *page = pfn_to_page(pfn);
> +
>  	/* Ensure the starting page is pageblock-aligned */
> -	BUG_ON(page_to_pfn(page) & (pageblock_nr_pages - 1));
> +	BUG_ON(pfn & (pageblock_nr_pages - 1));
>  
>  	/* If the entire pageblock is free, move to the end of free page */
>  	if (pageblock_free(page)) {
> @@ -1200,16 +1202,16 @@ static struct page *next_active_pageblock(struct page *page)
>  		/* be careful. we don't have locks, page_order can be changed.*/
>  		order = page_order(page);
>  		if ((order < MAX_ORDER) && (order >= pageblock_order))
> -			return page + (1 << order);
> +			return pfn + (1 << order);
>  	}
>  
> -	return page + pageblock_nr_pages;
> +	return pfn + pageblock_nr_pages;
>  }
>  
> -static bool is_pageblock_removable_nolock(struct page *page)
> +static bool is_pageblock_removable_nolock(unsigned long pfn)
>  {
> +	struct page *page = pfn_to_page(pfn);
>  	struct zone *zone;
> -	unsigned long pfn;
>  
>  	/*
>  	 * We have to be careful here because we are iterating over memory
> @@ -1232,13 +1234,14 @@ static bool is_pageblock_removable_nolock(struct page *page)
>  /* Checks if this range of memory is likely to be hot-removable. */
>  bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>  {
> -	struct page *page = pfn_to_page(start_pfn);
> -	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> -	struct page *end_page = pfn_to_page(end_pfn);
> +	unsigned long end_pfn;
> +
> +	end_pfn = min(start_pfn + nr_pages,
> +			zone_end_pfn(page_zone(pfn_to_page(start_pfn))));
>  
>  	/* Check the starting page of each pageblock within the range */
> -	for (; page < end_page; page = next_active_pageblock(page)) {
> -		if (!is_pageblock_removable_nolock(page))
> +	for (; start_pfn < end_pfn; start_pfn = next_active_pageblock(start_pfn)) {
> +		if (!is_pageblock_removable_nolock(start_pfn))
>  			return false;
>  		cond_resched();
>  	}

With this on top the loop even fits into 80-chars ;-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9cc42f3..9981ca7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1234,13 +1234,13 @@ static bool is_pageblock_removable_nolock(unsigned long pfn)
 /* Checks if this range of memory is likely to be hot-removable. */
 bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
-	unsigned long end_pfn;
+	unsigned long end_pfn, pfn;
 
 	end_pfn = min(start_pfn + nr_pages,
 			zone_end_pfn(page_zone(pfn_to_page(start_pfn))));
 
 	/* Check the starting page of each pageblock within the range */
-	for (; start_pfn < end_pfn; start_pfn = next_active_pageblock(start_pfn)) {
+	for (pfn = start_pfn; pfn < end_pfn; pfn = next_active_pageblock(pfn)) {
 		if (!is_pageblock_removable_nolock(start_pfn))
 			return false;
 		cond_resched();

-- 
Sincerely yours,
Mike.

