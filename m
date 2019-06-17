Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D09BC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:50:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F402321855
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:50:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F402321855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76D238E0003; Mon, 17 Jun 2019 02:50:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F62B8E0001; Mon, 17 Jun 2019 02:50:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570A38E0003; Mon, 17 Jun 2019 02:50:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2008E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:50:13 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so7120884pgh.11
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:50:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=cqvAr9VASkspbEuGbxxFTsdCiPDvlZPfVuw7byQIFRU=;
        b=WfTQsw1WiMejFBoCmHdW2gYXqheLKw/N3TML/NXQMHS1+x7/TS7chedDXl6npbMln5
         YXHV0aSVkHj8p3Lezz7L97+LnTANGraxnP/RZ8QY2tBrByXTAqpi9D77J9D/YpvMMIvn
         MCQg3LUDi8eXe1mcNE08sdR6y+4rV30vBM9db/P+xtRCAo6WjnsMXs6jtvxWqofjlkIL
         l01o7PP7cY6M0//DbLqSXRXHYiAorDAPYtdXMPNbYywGGIdbvl8bOjDlKvUm/Ze2RNZp
         gPQkjZ56YiQdLxshZy9iGnzoQyha0doS0tRJnFhVmUHObrtX2eVBGrV3Z+f4xg3rpnRQ
         M0XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUJKsOFFLUQHFFBjkym62EtLOXpzNBIKm8uP8yqkT07Mhborupr
	2zO551Xh78XnF+WOXCtPeq8vNMcZXECUM6xlLlFmfJNg79+Z35xJPVh5zIoyVdfy2fcmGKj7rtN
	ePFXMkoBNGH8jPRg86b1cwdjG4IjraWKYYR8b8FwXt5bsEC28VZSuUXfBSu7NkW721g==
X-Received: by 2002:a17:902:165:: with SMTP id 92mr79707225plb.197.1560754212696;
        Sun, 16 Jun 2019 23:50:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyB5I7PR+KI8FE8lE2W8avC4Ar2+2zbQ/O/0tA4amGFjmuGBhe53esQpCRVAJY3HHP3r8yY
X-Received: by 2002:a17:902:165:: with SMTP id 92mr79707192plb.197.1560754212092;
        Sun, 16 Jun 2019 23:50:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560754212; cv=none;
        d=google.com; s=arc-20160816;
        b=GNIT/iLyH+fBUQXeq9BWQJahaHDttE4g434irYFiuK/mx+X9qxmOfEMbbXsbJHyXXO
         KK9mSgBFCYdqhjj7orUaivboAzV9T7jV9zkKdkN51vDaSMDCoXGSJYzaH3DYpVpMzad2
         TxVFDA4Jiyfyy74JOvFXugAc1fikd6PprVKKaW89FwWgsQ3eSfkqATPA9IDeMjqW41zo
         zEP9SIiMbjTlyY9XrsEvgLNeZ/LkabQk/mUDeLtICC8ZM7e1qjlRlPL05lday7W9k0PL
         +Al3QlemOVX6GpDWu6Ho3VQUJmIhk1EMtHAHFjEtb4+3WJFPeoDjvQIRQBryUtISLRVG
         Jz6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=cqvAr9VASkspbEuGbxxFTsdCiPDvlZPfVuw7byQIFRU=;
        b=YnJlelfQ1XUKG2Vv+Kdd7esXLzO8ENccJ7fGwcrsz9WCVtH1f6T0Trj9Z12qiX80HH
         jZr0+kACBzB4HrCvjZ06hxlI3VqueiDMOYyMUsVBTyK5S6P6p1aujdfyqKc7VUjRmGU0
         piBk6Ef9M0O8hWhPzwbxrCr4gtxI0ihyzr1TRHUv8V73HSuKFmc0N4OWBzfpCnX8vCCf
         81Q6+64ASO0voQ2ALjqG6HRZEC7xDwaCFb/ewP1mf348d6ncdcdAavNUB4wUjY6kFJG0
         Reya64UwfI1Rs8lgEaYfGfG/3q/cQzPygG+9PKDA+9TtPkJM9Pu1gzSFvT1xNi1XL1H1
         Sg6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r24si10032413pgv.323.2019.06.16.23.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 23:50:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H6mtYY071259
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:50:11 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2t65hjgvmb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:50:11 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 17 Jun 2019 07:50:06 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 07:50:01 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H6o0He49807480
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 06:50:00 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5514611C04C;
	Mon, 17 Jun 2019 06:50:00 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AB73F11C05E;
	Mon, 17 Jun 2019 06:49:58 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 17 Jun 2019 06:49:58 +0000 (GMT)
Date: Mon, 17 Jun 2019 09:49:57 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: "Alastair D'Silva" <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Andrew Morton <akpm@linux-foundation.org>,
        Oscar Salvador <osalvador@suse.com>,
        David Hildenbrand <david@redhat.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Juergen Gross <jgross@suse.com>,
        Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Jiri Kosina <jkosina@suse.cz>, Peter Zijlstra <peterz@infradead.org>,
        Mukesh Ojha <mojha@codeaurora.org>, Arun KS <arunks@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/5] mm: don't hide potentially null memmap pointer in
 sparse_remove_one_section
References: <20190617043635.13201-1-alastair@au1.ibm.com>
 <20190617043635.13201-3-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617043635.13201-3-alastair@au1.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19061706-0016-0000-0000-00000289B0E9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061706-0017-0000-0000-000032E6F883
Message-Id: <20190617064956.GB16810@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=906 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170063
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 02:36:28PM +1000, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> By adding offset to memmap before passing it in to clear_hwpoisoned_pages,
> is hides a potentially null memmap from the null check inside
> clear_hwpoisoned_pages.
> 
> This patch passes the offset to clear_hwpoisoned_pages instead, allowing
> memmap to successfully peform it's null check.
> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>

One nit below, otherwise

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/sparse.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 104a79fedd00..66a99da9b11b 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -746,12 +746,14 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  		kfree(usemap);
>  		__kfree_section_memmap(memmap, altmap);
>  	}
> +

The whitespace change here is not related

>  	return ret;
>  }
> 
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  #ifdef CONFIG_MEMORY_FAILURE
> -static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> +static void clear_hwpoisoned_pages(struct page *memmap,
> +		unsigned long map_offset, int nr_pages)
>  {
>  	int i;
> 
> @@ -767,7 +769,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  	if (atomic_long_read(&num_poisoned_pages) == 0)
>  		return;
> 
> -	for (i = 0; i < nr_pages; i++) {
> +	for (i = map_offset; i < nr_pages; i++) {
>  		if (PageHWPoison(&memmap[i])) {
>  			atomic_long_sub(1, &num_poisoned_pages);
>  			ClearPageHWPoison(&memmap[i]);
> @@ -775,7 +777,8 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  	}
>  }
>  #else
> -static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
> +static inline void clear_hwpoisoned_pages(struct page *memmap,
> +		unsigned long map_offset, int nr_pages)
>  {
>  }
>  #endif
> @@ -822,8 +825,7 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  		ms->pageblock_flags = NULL;
>  	}
> 
> -	clear_hwpoisoned_pages(memmap + map_offset,
> -			PAGES_PER_SECTION - map_offset);
> +	clear_hwpoisoned_pages(memmap, map_offset, PAGES_PER_SECTION);
>  	free_section_usemap(memmap, usemap, altmap);
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> -- 
> 2.21.0
> 

-- 
Sincerely yours,
Mike.

