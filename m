Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBDD4C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 10:29:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67F6B21874
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 10:29:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67F6B21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E08976B026D; Fri, 22 Mar 2019 06:29:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB8336B026E; Fri, 22 Mar 2019 06:29:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA7576B026F; Fri, 22 Mar 2019 06:29:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 860386B026D
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:29:48 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a72so1945809pfj.19
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:29:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=gxcA/ggt9COr1J/LAIzuWtel20cfd3JO9w9HfHTmanQ=;
        b=SsJLiXIi8Cl4UrPx+8ed9u0rN4y/UDankY4pN6KP1xeSvI/g9WzlKSOf6WJJfLtmYJ
         awuoDS9aW4hb1c0/KC+cq/W4HjmPcvS0MegsL06qwK088xnyFQD35R5qyOmCeIS5Ql7v
         hgvDBRibXtsgIniwmmLBeHLngiQNja2HB+o+2oBKEeapN1Halt7l88reFsgiMGN55yzC
         cEndsHPOx/D7WULi0diw2LheAkuYMqJlEzXSkcsDT4E0M5TSQ/c+rlerTQTUD3e0C/6I
         c37ymqLvFQ6LGw6XrPXYPtcc4D/v14r+009QJU3A9pRJ7o0yIO5hpWqymMYEXPPIillO
         PmEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWLSfp5AEGvVAAyTWkdU8/gUtMLmKZxtUDzrDqm5kaK+avfRzJe
	9oL1da7UbsZKKmCSmcYwEJa0rY1xKBQhScKA5sLmS1uBfnvMcc+2SkKur0PBTD8wb8Zv4rXrBqK
	5+WLP0iEVJaFLVMJIzY7WXgpwPc+KWPRg5jzEVUr0LwfoL3ogi4eWU1JsCwItLt5YHg==
X-Received: by 2002:a65:648f:: with SMTP id e15mr8168642pgv.249.1553250587991;
        Fri, 22 Mar 2019 03:29:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgqSXOJBlCPVw01rTSZ2a9CUh5WNjpab5lyZGU8HPWRGkDi6MG91Ss6y6MJaU+l4rErKoC
X-Received: by 2002:a65:648f:: with SMTP id e15mr8168572pgv.249.1553250586826;
        Fri, 22 Mar 2019 03:29:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553250586; cv=none;
        d=google.com; s=arc-20160816;
        b=a9MoXLDFBQqyYZD3oCNkAeth8F9O6YVJ9GlIPsEwRfBHC3xks/2iXxlPyRovmtga7E
         ifgOIWxA9Jl1Lgdl73I7VrVloVWJyCoOzo34E5HQp1eMhTCWYe/QEQgiGg16u+55711G
         qVpuJGrfYzBL8ttvSpTr6JUxxpNJCx7akHr7V6+fEscURSXLCEonpEIhV14ogYVQ/317
         XIJO+FVNklUldMpEFgEcdhceusDpAjKvutrNEbOWiV5/J36G1H8rDgAROWlhk3x4yViX
         NG9D5dir6asjYHb2UtpxmvkOd2L9MfQ3PeSL616O8zZ02qe01gN6z8A+wrvxIUVlfjKx
         /k1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=gxcA/ggt9COr1J/LAIzuWtel20cfd3JO9w9HfHTmanQ=;
        b=cDzMiYalyncwwKn4aQA0EekxeEGCjEhdbup8dIaU+VNtVwCVysnR1eDXIRv5DHY4hW
         LQJQ9bbyTG8t8GuT6cr5XnTwirGGGV7rd/vUrK0Fkd8RDJ3IAqqqHZe2OmfM2HNGh76+
         5Ok2nr28+Q1ley6B7VIuBD1T4pkM1PUFPnxLgDKUdGn2M7P3ADNURYjyuJk7hMqDYOzn
         p4AyIlmrFK0m1ioeCp03jBdNudnovroWbPPaHb/vQ5OlMjEJ4dNJF3dKo9nYEs7QESax
         FMgM+sStYsdZ3Xt1kFSvVloEK6BcPosmOOS62mzkruHdSdc1VCaZRpO9ei1j15or6GPO
         9BVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d7si6880856pls.200.2019.03.22.03.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 03:29:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2MAJL1d136418
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:29:46 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rcv3u4u17-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:29:45 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 22 Mar 2019 10:29:38 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 22 Mar 2019 10:29:31 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2MATZDp36044886
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 22 Mar 2019 10:29:35 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 47A9E4C059;
	Fri, 22 Mar 2019 10:29:35 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 821B54C052;
	Fri, 22 Mar 2019 10:29:33 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.199])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri, 22 Mar 2019 10:29:33 +0000 (GMT)
Date: Fri, 22 Mar 2019 12:29:31 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Steven Price <steven.price@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
        Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
        James Morse <james.morse@arm.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-arm-kernel@lists.infradead.org,
        "Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v5 10/19] mm: pagewalk: Add p4d_entry() and pgd_entry()
References: <20190321141953.31960-1-steven.price@arm.com>
 <20190321141953.31960-11-steven.price@arm.com>
 <20190321211510.GA27213@rapoport-lnx>
 <03f5ad0f-2450-c53f-b1e6-d2c0f2d4879c@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <03f5ad0f-2450-c53f-b1e6-d2c0f2d4879c@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032210-0012-0000-0000-00000305DFC0
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032210-0013-0000-0000-0000213CFB32
Message-Id: <20190322102930.GA24367@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903220078
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 10:11:59AM +0000, Steven Price wrote:
> On 21/03/2019 21:15, Mike Rapoport wrote:
> > On Thu, Mar 21, 2019 at 02:19:44PM +0000, Steven Price wrote:
> >> pgd_entry() and pud_entry() were removed by commit 0b1fbfe50006c410
> >> ("mm/pagewalk: remove pgd_entry() and pud_entry()") because there were
> >> no users. We're about to add users so reintroduce them, along with
> >> p4d_entry() as we now have 5 levels of tables.
> >>
> >> Note that commit a00cc7d9dd93d66a ("mm, x86: add support for
> >> PUD-sized transparent hugepages") already re-added pud_entry() but with
> >> different semantics to the other callbacks. Since there have never
> >> been upstream users of this, revert the semantics back to match the
> >> other callbacks. This means pud_entry() is called for all entries, not
> >> just transparent huge pages.
> >>
> >> Signed-off-by: Steven Price <steven.price@arm.com>
> >> ---
> >>  include/linux/mm.h |  9 ++++++---
> >>  mm/pagewalk.c      | 27 ++++++++++++++++-----------
> >>  2 files changed, 22 insertions(+), 14 deletions(-)
> >>
> >> diff --git a/include/linux/mm.h b/include/linux/mm.h
> >> index 76769749b5a5..2983f2396a72 100644
> >> --- a/include/linux/mm.h
> >> +++ b/include/linux/mm.h
> >> @@ -1367,10 +1367,9 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
> >>
> >>  /**
> >>   * mm_walk - callbacks for walk_page_range
> >> + * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
> >> + * @p4d_entry: if set, called for each non-empty P4D (1st-level) entry
> > 
> > IMHO, p4d implies the 4th level :)
> 
> You have a good point there... I was simply working back from the
> existing definitions (below) of PTE:4th, PMD:3rd, PUD:2nd. But it's
> already somewhat broken by PGD:0th and my cop-out was calling it "top".
> 
> > I think it would make more sense to start counting from PTE rather than
> > from PGD. Then it would be consistent across architectures with fewer
> > levels.
> 
> It would also be the opposite way round to architectures such as Arm
> which number their levels, for example [1] refers to levels 0-3 (with 3
> being PTE in Linux terms).

By consistent I meant that for architectures with fewer levels we won't be
describing PTE as level 4 when the architecture only has 2 levels.
 
> [1]
> https://developer.arm.com/docs/100940/latest/translation-tables-in-armv8-a
> 
> Probably the least confusing thing is to drop the level numbers in
> brackets since I don't believe they directly match any architecture, and
> hopefully any user of the page walking code is already familiar with the
> P?D terms used by the kernel.

That's a fair assumption :)
Still, maybe we keep your (top-level) for PGD and use (lowest level) for
PTE and drop those in the middle?

> Steve
> 
> >>   * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
> >> - *	       this handler should only handle pud_trans_huge() puds.
> >> - *	       the pmd_entry or pte_entry callbacks will be used for
> >> - *	       regular PUDs.
> >>   * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
> >>   *	       this handler is required to be able to handle
> >>   *	       pmd_trans_huge() pmds.  They may simply choose to
> >> @@ -1390,6 +1389,10 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
> >>   * (see the comment on walk_page_range() for more details)
> >>   */
> >>  struct mm_walk {
> >> +	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
> >> +			 unsigned long next, struct mm_walk *walk);
> >> +	int (*p4d_entry)(p4d_t *p4d, unsigned long addr,
> >> +			 unsigned long next, struct mm_walk *walk);
> >>  	int (*pud_entry)(pud_t *pud, unsigned long addr,
> >>  			 unsigned long next, struct mm_walk *walk);
> >>  	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
> >> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> >> index c3084ff2569d..98373a9f88b8 100644
> >> --- a/mm/pagewalk.c
> >> +++ b/mm/pagewalk.c
> >> @@ -90,15 +90,9 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
> >>  		}
> >>
> >>  		if (walk->pud_entry) {
> >> -			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
> >> -
> >> -			if (ptl) {
> >> -				err = walk->pud_entry(pud, addr, next, walk);
> >> -				spin_unlock(ptl);
> >> -				if (err)
> >> -					break;
> >> -				continue;
> >> -			}
> >> +			err = walk->pud_entry(pud, addr, next, walk);
> >> +			if (err)
> >> +				break;
> >>  		}
> >>
> >>  		split_huge_pud(walk->vma, pud, addr);
> >> @@ -131,7 +125,12 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
> >>  				break;
> >>  			continue;
> >>  		}
> >> -		if (walk->pmd_entry || walk->pte_entry)
> >> +		if (walk->p4d_entry) {
> >> +			err = walk->p4d_entry(p4d, addr, next, walk);
> >> +			if (err)
> >> +				break;
> >> +		}
> >> +		if (walk->pud_entry || walk->pmd_entry || walk->pte_entry)
> >>  			err = walk_pud_range(p4d, addr, next, walk);
> >>  		if (err)
> >>  			break;
> >> @@ -157,7 +156,13 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
> >>  				break;
> >>  			continue;
> >>  		}
> >> -		if (walk->pmd_entry || walk->pte_entry)
> >> +		if (walk->pgd_entry) {
> >> +			err = walk->pgd_entry(pgd, addr, next, walk);
> >> +			if (err)
> >> +				break;
> >> +		}
> >> +		if (walk->p4d_entry || walk->pud_entry || walk->pmd_entry ||
> >> +				walk->pte_entry)
> >>  			err = walk_p4d_range(pgd, addr, next, walk);
> >>  		if (err)
> >>  			break;
> >> -- 
> >> 2.20.1
> >>
> > 
> 

-- 
Sincerely yours,
Mike.

