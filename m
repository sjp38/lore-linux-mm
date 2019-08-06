Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76A2EC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:03:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30FDA20651
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:03:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30FDA20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71B246B0003; Tue,  6 Aug 2019 06:03:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CB4F6B0006; Tue,  6 Aug 2019 06:03:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 592CB6B0010; Tue,  6 Aug 2019 06:03:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 356046B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:03:02 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d9so75014643qko.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:03:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/jVT6q/FmHlbdDHPfub0az273u3608cdZZJpVxV1kVs=;
        b=ialAgfLlW13ZFeMsJNNDLHGye29KKdLvEipD7wcIljloIz+OifMNAeZj8BCQYjWwPL
         q2BBycpZJl289KWyZ5rZvtDnxvHzYDNDxvo5+Pp0teA1oKTX+uzAdMbfzny8usBl+vOT
         xDzgBHZ4ga8U5Na8YtsPs+Sdv69D+e5i9oWZHXUjogX93LHuRkfzLIEUUdp8ffUULdFj
         mMat6tIx+xJTb64ZC3YOv1RE354EcouYZx6ft7U5JVhp62Ud9NQ0mGT3H24kgbR8FM00
         CxxAGH4vU/kskSUaUD7CH1m9pdBcdjSOvJ9iNbgnlDtOod+cTDNW8VIB0IU26vQdZHoz
         sE0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVtCo0YkglzvsaaGdBrGJNxxc3mxATXvu6MQK7nLfvPeIsnPdjK
	jVHtNi3BtiJLf/okdrdAvE7F6QGTgFMKutuhC42uLu4CWHCOpZ4R0B0d5qQqvaGybDIKz3E+AE4
	idvxddgPZhPatAKGDQnz7f0+VETvZjmNqUDG6d6a5gJaoc5Ow4slssHeYFO9qEq2kFw==
X-Received: by 2002:a05:620a:1285:: with SMTP id w5mr2274663qki.302.1565085782024;
        Tue, 06 Aug 2019 03:03:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxn7mv5bVkqOd9PqNoztlCdHxxreZm1vqqSTKXwL1jZBZdEaY9O3FTTOv3UsJcv/IM23B8F
X-Received: by 2002:a05:620a:1285:: with SMTP id w5mr2274611qki.302.1565085781191;
        Tue, 06 Aug 2019 03:03:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565085781; cv=none;
        d=google.com; s=arc-20160816;
        b=XrFOw38vAnBdZGrwspG74rbS7yxXN0ncjMHuI/JkOA2RXdQLEY27L0jYWGSXFGL/L2
         cU8Ip6EuI1ixHwd7x4vuvyHYFIgCr1+zfgvXOL6NcFLxRhChwtJcPjUFdA0cpRWLgOAV
         fYGSqTd6vMGmN29vij1PBtIv+wbKi0NdwHaHzabAK2ik5DLpgeCsY0aw3ZkHev0e836H
         5EOvdW8K6WcWwpxggp+qJOz6nWuShSu5xUDy0WMsQbfLNm4d2sicFjYV2OQBtYy32vJV
         qYoz8JnRAJqw0F3DUMxGaZ7ssy6ZfwsMN3UDwAD1AHjukELFPJ/6Nk2sYUEuh3C5qmMq
         ofUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/jVT6q/FmHlbdDHPfub0az273u3608cdZZJpVxV1kVs=;
        b=arbDPJTs34mkgsNqPJW4V/rqy25QtHMeoz5xuTCZBlcz9qRakIXPcxsN5M875S4lYa
         q/0+C54F1yfyCC0tDjExipGvAtm14k+Fkalb7NE0E84gqkIIj2zxbzrkKst41UNg18yL
         wa//QNJOjXp+RhsEbonzde/QLp1GtcJ4eMWRr3J0pYtzed3vWRY+yu2XqCW2u3gwjfjL
         /3+82XvCUMjwyXWUVSGx6xYJIdsRdJJHxdHXkFBQUfPt1dNjtyzZ+W7VolftsD2RokBN
         zdoFPbwigTkMnszONGMj2sd7PqYeDlgLJZ3+U0h7RjYHbn5PZ8o8yGYnY4MOqDEJD5LP
         h10w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h71si50143674qke.354.2019.08.06.03.03.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 03:03:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2FE4230EA1B1;
	Tue,  6 Aug 2019 10:03:00 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 16ECB60610;
	Tue,  6 Aug 2019 10:02:57 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue,  6 Aug 2019 12:02:59 +0200 (CEST)
Date: Tue, 6 Aug 2019 12:02:57 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, srikar@linux.vnet.ibm.com
Subject: Re: [PATCH v4 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Message-ID: <20190806100256.GA21454@redhat.com>
References: <20190802231817.548920-1-songliubraving@fb.com>
 <20190802231817.548920-2-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802231817.548920-2-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 06 Aug 2019 10:03:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/02, Song Liu wrote:
>
> +void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long addr)
> +{
> +	unsigned long haddr = addr & HPAGE_PMD_MASK;
> +	struct vm_area_struct *vma = find_vma(mm, haddr);
> +	pmd_t *pmd = mm_find_pmd(mm, haddr);
> +	struct page *hpage = NULL;
> +	spinlock_t *ptl;
> +	int count = 0;
> +	pmd_t _pmd;
> +	int i;
> +
> +	if (!vma || !vma->vm_file || !pmd ||
> +	    vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE)
> +		return;

I still can't understand why is it safe to blindly use mm_find_pmd().

Say, what pmd_offset(pud, address) will return to this function if
pud_huge() == T? IIUC, this is possible if is_file_hugepages(vm_file).
How the code below can use this result?

I think you need something like hugepage_vma_check() or even
hugepage_vma_revalidate().

Oleg.

