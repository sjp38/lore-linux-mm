Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6FEDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:15:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DA9E218D4
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:15:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DA9E218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3142F6B0003; Thu, 21 Mar 2019 17:15:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C4316B0006; Thu, 21 Mar 2019 17:15:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B4C56B0007; Thu, 21 Mar 2019 17:15:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D19FE6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:15:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b11so128365pfo.15
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=7h7FqmlJBTKBKAjwDIvKHhQQdiu2A7AvuMuSR3flwCk=;
        b=ed6oPpOtYWm0e3zF1ntzoz7cVhjk6QZ23cM8RGB3q63OEhDTmczYGXA97jFPg1OpfJ
         yY4Lb5iSBQFU3zaw0APUrZVn1nlHchSZ9slrD/z1KrPtAz9wQIzkqCnXR3BTlvO0ICWt
         RPrhVtLdCp4XOmLf3Ssb58WRhxwsb4GyVwxPHiZWDb3cC/K6/uRoC2SP20eBAlSSyng1
         /fg3bTXcO9KrYUBcRd5xzLWByKB8TdxQR10YvsqNnd4bn7RWUECt7tcMdkW5AjeAyGzL
         zg5HjYsM7mchLYX1W5QxHbNaY2WPqu1jT+4pxmdTq6+pXfoW3d+lWjTFr2h7uY3eHXNj
         BEdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUsbLexcIeT8D3KTf4792cfR2cHbmAqPYORJ0WnMfvS7y1cdoi/
	/4ratnXMJq6nO0SPtufcktbUaJRZ1CJJ2QkXw1gNfKdJyAGNYLA4dy/YoOLCu1BpPg/F8cqX7yQ
	43TZWgp9xEy5xCHN0nA9UtGP2XZtYQ66Kp6lB41HU+syEQV8tzZQ0GGlzk0KuXDtfMw==
X-Received: by 2002:a65:41ca:: with SMTP id b10mr5399284pgq.146.1553202925438;
        Thu, 21 Mar 2019 14:15:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1QB/eJwxkWg9woahgEZed71wqeiOU2w8ft3MCXUtB9wueEmzyS3nkDJUnp/hUK/Kyolqa
X-Received: by 2002:a65:41ca:: with SMTP id b10mr5399215pgq.146.1553202924558;
        Thu, 21 Mar 2019 14:15:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553202924; cv=none;
        d=google.com; s=arc-20160816;
        b=lF6fSl3HCWM6unMIt26b6QfprhuUlX919+ncNtTIS6YgXkXIJTvyuq+FSwmtowB4OO
         ECP3hmxQldB3X3hPYdKfRUcw8Gfc9fOTY0xKX2h9ORVZ6sivffCRshmdq4f18Y2vfLWo
         LwIE64TbMaeGhGBAiz0jlY5GWdBOsPCVKF9vhyHe2uny+IRX4KBQfvOZ6cErFOdBruSy
         adqyWk8kaKI/j5fFxbdSc7kISkT49i5fQdQmkT2+h+gS5TVudX/wpqivrNecI9AfMv7i
         vLcUYWpr5WAtDOq1qeJsezNSJggjrnblDZfT5qHzFigxGt/4BVTJUFl04rii1qbbfA+C
         Wekg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=7h7FqmlJBTKBKAjwDIvKHhQQdiu2A7AvuMuSR3flwCk=;
        b=1LIMY0cafRh5ojlVcYdHdy2vxeCDzBRno4J7qhLvXYx0oP3z+1mVQgym6srDOhB3PY
         vORbyPAifTA2J3pqqUPXH+VDz6SHVMvSh2Q8CwXO6RvZS6wv5j8O2EFsRWUQF6gNX/5F
         IoPvleOvVrei1sVIqeqTTfiFUh39xtoI9hb8XaiWnJiNGD2eUxPx3Rml0Ov9Y/EsxxY3
         a0di88mPK4UMT3vtI+V9X/ZWXZM5ntRTREmYy8C8JAyn5NuaBhYOImh9CbSax1+kGe6Q
         lZvgfAu5RvLObxa3ilk5OJolLx3O5+F2qEYzjyd8TzyoQGQDnpW2VX2rLqzXGqcUMsiE
         RH6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g24si5190594pfd.212.2019.03.21.14.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 14:15:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2LLE7E1009643
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:15:24 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rcj7vga4s-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:15:23 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 21 Mar 2019 21:15:19 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 21 Mar 2019 21:15:14 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2LLFEwk15663334
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Mar 2019 21:15:14 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6EC2052050;
	Thu, 21 Mar 2019 21:15:14 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.163])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id A164852054;
	Thu, 21 Mar 2019 21:15:12 +0000 (GMT)
Date: Thu, 21 Mar 2019 23:15:10 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Will Deacon <will.deacon@arm.com>, x86@kernel.org,
        "H. Peter Anvin" <hpa@zytor.com>, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, Mark Rutland <Mark.Rutland@arm.com>,
        "Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v5 10/19] mm: pagewalk: Add p4d_entry() and pgd_entry()
References: <20190321141953.31960-1-steven.price@arm.com>
 <20190321141953.31960-11-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190321141953.31960-11-steven.price@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032121-0028-0000-0000-00000356D2E0
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032121-0029-0000-0000-000024157AD0
Message-Id: <20190321211510.GA27213@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-21_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903210149
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 02:19:44PM +0000, Steven Price wrote:
> pgd_entry() and pud_entry() were removed by commit 0b1fbfe50006c410
> ("mm/pagewalk: remove pgd_entry() and pud_entry()") because there were
> no users. We're about to add users so reintroduce them, along with
> p4d_entry() as we now have 5 levels of tables.
> 
> Note that commit a00cc7d9dd93d66a ("mm, x86: add support for
> PUD-sized transparent hugepages") already re-added pud_entry() but with
> different semantics to the other callbacks. Since there have never
> been upstream users of this, revert the semantics back to match the
> other callbacks. This means pud_entry() is called for all entries, not
> just transparent huge pages.
> 
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  include/linux/mm.h |  9 ++++++---
>  mm/pagewalk.c      | 27 ++++++++++++++++-----------
>  2 files changed, 22 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 76769749b5a5..2983f2396a72 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1367,10 +1367,9 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
> 
>  /**
>   * mm_walk - callbacks for walk_page_range
> + * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
> + * @p4d_entry: if set, called for each non-empty P4D (1st-level) entry

IMHO, p4d implies the 4th level :)

I think it would make more sense to start counting from PTE rather than
from PGD. Then it would be consistent across architectures with fewer
levels.

>   * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
> - *	       this handler should only handle pud_trans_huge() puds.
> - *	       the pmd_entry or pte_entry callbacks will be used for
> - *	       regular PUDs.
>   * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
>   *	       this handler is required to be able to handle
>   *	       pmd_trans_huge() pmds.  They may simply choose to
> @@ -1390,6 +1389,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>   * (see the comment on walk_page_range() for more details)
>   */
>  struct mm_walk {
> +	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
> +	int (*p4d_entry)(p4d_t *p4d, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
>  	int (*pud_entry)(pud_t *pud, unsigned long addr,
>  			 unsigned long next, struct mm_walk *walk);
>  	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index c3084ff2569d..98373a9f88b8 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -90,15 +90,9 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>  		}
> 
>  		if (walk->pud_entry) {
> -			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
> -
> -			if (ptl) {
> -				err = walk->pud_entry(pud, addr, next, walk);
> -				spin_unlock(ptl);
> -				if (err)
> -					break;
> -				continue;
> -			}
> +			err = walk->pud_entry(pud, addr, next, walk);
> +			if (err)
> +				break;
>  		}
> 
>  		split_huge_pud(walk->vma, pud, addr);
> @@ -131,7 +125,12 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
>  				break;
>  			continue;
>  		}
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (walk->p4d_entry) {
> +			err = walk->p4d_entry(p4d, addr, next, walk);
> +			if (err)
> +				break;
> +		}
> +		if (walk->pud_entry || walk->pmd_entry || walk->pte_entry)
>  			err = walk_pud_range(p4d, addr, next, walk);
>  		if (err)
>  			break;
> @@ -157,7 +156,13 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
>  				break;
>  			continue;
>  		}
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (walk->pgd_entry) {
> +			err = walk->pgd_entry(pgd, addr, next, walk);
> +			if (err)
> +				break;
> +		}
> +		if (walk->p4d_entry || walk->pud_entry || walk->pmd_entry ||
> +				walk->pte_entry)
>  			err = walk_p4d_range(pgd, addr, next, walk);
>  		if (err)
>  			break;
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

