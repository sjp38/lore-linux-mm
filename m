Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB292C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:18:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62FD6214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:18:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62FD6214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 084048E0038; Wed, 31 Jul 2019 11:18:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 034578E0035; Wed, 31 Jul 2019 11:18:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3E1B8E0038; Wed, 31 Jul 2019 11:18:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1A9C8E0035
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:18:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t124so58457322qkh.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:18:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4ojGJG/svvYGC/WDCO3AK5k4bNUNKbhtcQdjb7jNstU=;
        b=r5d9jqizXixqUotITbLOEBHjH+qIBKQX7hn0NeBr/6/cfFqOzCms3GYc0C2x4o4Xsf
         m6qBDH+/ZfaxbxROjM8gWuVeG38DWcN6obTsrxwzsunFvHyJKrYn7WFeGfbPyBaSEIa8
         x2aW4cp/Z/lwTTyesrzVV95Hq7w/7jsASadD7NkL/85IGl9M/l7dp7mqmVcOc0T4PvWc
         vJgy9XILfcvPAqlPy7ZG/hwiOLF1IJzRWm5OgIbs8rmcdS0o0lB/fnrczHTJN0R++3KQ
         AmrDR00m+TzQmOZtNWhNRR674/4z5vMOb+c8klx6spONu5ERy9C6jV+3Z14hwa6YTFqV
         PP0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU2zMY5JzBOrL6WwCmdLT6udkko6w48yi8vHR5mPV5onvQq7OCk
	8WXxOP+faZVwMn94y9zivNQNH7awXpETP9GHNiuWs1GHAuo5aRPvuC1gfDMJbD1sVTtpHkJBO8v
	EUzRHMUWr0M7lEf0soGpuW+XVorKi+8Zz0zNyhsgthYpPRMmbY8Pa7lx7jLcf/AIkFA==
X-Received: by 2002:ad4:4423:: with SMTP id e3mr75157749qvt.145.1564586327569;
        Wed, 31 Jul 2019 08:18:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWeoY1yJio5xIfVWlYYUAt937KU4VUvVSCkDgGQHvewVdHliJ/UDd+pqNUmM7ent+PyYko
X-Received: by 2002:ad4:4423:: with SMTP id e3mr75157694qvt.145.1564586326867;
        Wed, 31 Jul 2019 08:18:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586326; cv=none;
        d=google.com; s=arc-20160816;
        b=QZa0PDJVB8z9hJsLGdCAbglQFQaQCkbi0IOOHINKuYtB0eOsgeYZjgg7JlDs5YgpFj
         7jsX33zXsdyuFJfhyeJz34ZWohZh1lJTv63u50kLsWYSevgXjug6HBc3N6iKPrio4+N3
         6BBTKSwhJextycuyqTLBiTSud3DKJgHYlkrIcUdDD0mZycav7t261pwUFThS7CyQXDr0
         dwvQPIzEaAWdenhVmaFgc7rceRkEd+5/mrGX66DtZGmBM1yt2IbRUAofVpGQ98Dx1aG+
         TtkkUrHzqKqhoHaWsvRmbt/FHukY30ZW2NeOlz05t4FFMdc2HWxMhiEZ4Zcd2cMODGJJ
         3mcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4ojGJG/svvYGC/WDCO3AK5k4bNUNKbhtcQdjb7jNstU=;
        b=OxGo/f/pKv1g/eoX69l/HK4m7CZpOiZ7MlQbqsx3e9wC/ZkzV4p20DTJG+dCMtqjqj
         W9mb3ezrPnXEnNzh13T52GtP9COMwFwt9eLJOW7Q4jcyJ0f69Q81Hj+V+zrjnV1+CSOi
         EBLsx3ACAWFdAkWjZLB2tKEBi4gphIyo0ltbSe2LjFyH+3G+JAX1yNNF0UpgcOoUE2dx
         v/kHSqy9hPaoTElz295IHRgT3J5WAdWfaou/EmhuAgYQHsneoIgjhsZsnQMtjIYbFjL5
         neq1U2tnxjcUm5NpiBwasxOYOx/lCEjduzSP1zoREWojHcVECwRN9BE11y+vUiHP75Dt
         3w1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q39si42625032qtk.284.2019.07.31.08.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:18:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 02BE2300D20F;
	Wed, 31 Jul 2019 15:18:46 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 275AF196EC;
	Wed, 31 Jul 2019 15:18:43 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 31 Jul 2019 17:18:45 +0200 (CEST)
Date: Wed, 31 Jul 2019 17:18:43 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: lkml <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v10 3/4] mm, thp: introduce FOLL_SPLIT_PMD
Message-ID: <20190731151842.GB25078@redhat.com>
References: <20190730052305.3672336-1-songliubraving@fb.com>
 <20190730052305.3672336-4-songliubraving@fb.com>
 <20190730161113.GC18501@redhat.com>
 <1E2B5653-BA85-4A05-9B41-57CF9E48F14A@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1E2B5653-BA85-4A05-9B41-57CF9E48F14A@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 31 Jul 2019 15:18:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/30, Song Liu wrote:
>
>
> > On Jul 30, 2019, at 9:11 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > So after the next patch we have a single user of FOLL_SPLIT_PMD (uprobes)
> > and a single user of FOLL_SPLIT: arch/s390/mm/gmap.c:thp_split_mm().
> >
> > Hmm.
>
> I think this is what we want. :)

We? I don't ;)

> FOLL_SPLIT is the fallback solution for users who cannot handle THP.

and again, we have a single user: thp_split_mm(). I do not know if it
can use FOLL_SPLIT_PMD or not, may be you can take a look...

> With
> more THP aware code, there will be fewer users of FOLL_SPLIT.

Fewer than 1? Good ;)

> >> @@ -399,7 +399,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
> >> 		spin_unlock(ptl);
> >> 		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
> >> 	}
> >> -	if (flags & FOLL_SPLIT) {
> >> +	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
> >> 		int ret;
> >> 		page = pmd_page(*pmd);
> >> 		if (is_huge_zero_page(page)) {
> >> @@ -408,7 +408,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
> >> 			split_huge_pmd(vma, pmd, address);
> >> 			if (pmd_trans_unstable(pmd))
> >> 				ret = -EBUSY;
> >> -		} else {
> >> +		} else if (flags & FOLL_SPLIT) {
> >> 			if (unlikely(!try_get_page(page))) {
> >> 				spin_unlock(ptl);
> >> 				return ERR_PTR(-ENOMEM);
> >> @@ -420,6 +420,10 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
> >> 			put_page(page);
> >> 			if (pmd_none(*pmd))
> >> 				return no_page_table(vma, flags);
> >> +		} else {  /* flags & FOLL_SPLIT_PMD */
> >> +			spin_unlock(ptl);
> >> +			split_huge_pmd(vma, pmd, address);
> >> +			ret = pte_alloc(mm, pmd);
> >
> > I fail to understand why this differs from the is_huge_zero_page() case above.
>
> split_huge_pmd() handles is_huge_zero_page() differently. In this case, we
> cannot use the pmd_trans_unstable() check.

Please correct me, but iiuc the problem is not that split_huge_pmd() handles
is_huge_zero_page() differently, the problem is that __split_huge_pmd_locked()
handles the !vma_is_anonymous(vma) differently and returns with pmd_none() = T
after pmdp_huge_clear_flush_notify(). This means that pmd_trans_unstable() will
fail.

Now, I don't understand why do we need pmd_trans_unstable() after
split_huge_pmd(huge-zero-pmd), but whatever reason we have, why can't we
unify both cases?

IOW, could you explain why the path below is wrong?

Oleg.


--- x/mm/gup.c
+++ x/mm/gup.c
@@ -399,14 +399,16 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 		spin_unlock(ptl);
 		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
 	}
-	if (flags & FOLL_SPLIT) {
+	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
 		int ret;
 		page = pmd_page(*pmd);
-		if (is_huge_zero_page(page)) {
+		if ((flags & FOLL_SPLIT_PMD) || is_huge_zero_page(page)) {
 			spin_unlock(ptl);
-			ret = 0;
 			split_huge_pmd(vma, pmd, address);
-			if (pmd_trans_unstable(pmd))
+			ret = 0;
+			if (pte_alloc(mm, pmd))
+				ret = -ENOMEM;
+			else if (pmd_trans_unstable(pmd))
 				ret = -EBUSY;
 		} else {
 			if (unlikely(!try_get_page(page))) {

