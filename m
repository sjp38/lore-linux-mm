Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5C10C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62B8E2087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:50:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62B8E2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBD3C8E0009; Mon, 25 Feb 2019 13:50:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6C218E0004; Mon, 25 Feb 2019 13:50:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE8158E0009; Mon, 25 Feb 2019 13:50:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2728E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:50:35 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id f65so3736050plb.3
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:50:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=qcjyfg1lJys5F840SIp1/Xpqy4pO4nAzr0Xj6SXU3L8=;
        b=mXgRdBmHERo3IEWmQB2MAe1k9wo7YVNUR8xedB78azpFDwL4r+n82qq/WW7ZRBZgja
         Nwr3j0y53mIlRiz+UNYaT65ln8KsBZ9sqSEteG0atGfiSuPD2KWBpE8aBY05bzZoJH7u
         5QPIUR7x/Rm5U7MnT9xF07+DhMrBYlffILnSsstvvPzaGlTLcZAndy1His2P8xDM25tw
         3SQAHK+JonS1Q3wka76wGs5lcyCca8IOU1gQ8Mnn2L6y3lo1IrtlfNloS4/djSwp3rp9
         hHpiif4exxQjpB86aeu4HaZ4VRW20vuTcwZQ3sVvscvQ3Op2Lgdz98Xuk5oQMAj+DW/d
         +UEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAub9m2qZEFi3i1QiqSDLgq5oXWDmFDFMnvZkXYqBmEqJgMgP3ohC
	yiI6JDNkPBT7Hbbep86+PRSbi3JOZXdvlILQFa4uFP6987mzz4pk6WWMa7X49wLZH1uRLoyuMlm
	S5Ao7kuaP3qaG+K94bMAmShB+RaKrlJ1z+2yL0vmC+AcH6xyVZAC9ZL1wpP6Qh99tAQ==
X-Received: by 2002:a17:902:d208:: with SMTP id t8mr29208ply.78.1551120635223;
        Mon, 25 Feb 2019 10:50:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZRI65wU1DqyELP30JmWw+v74BeW7cFTnNSA734JAn25y4YwqmF3sUH7xULHU2ihrQ6umdF
X-Received: by 2002:a17:902:d208:: with SMTP id t8mr29151ply.78.1551120634241;
        Mon, 25 Feb 2019 10:50:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551120634; cv=none;
        d=google.com; s=arc-20160816;
        b=UZ/tyRU8/aWlACf9Z6C8VRN6myieOAFDq0IAJTP7iskxEZbxVpn/W9jXrKLqRTcv85
         6z7pxgTdqWr4APKf3Pnyqp+lJULti/YaBJyBp4BkmDmWLylow6BP+ovCoKdlbx490TyU
         LQjjInMdk6ABO+/ETTStpZ/d241LHClcc/HH/TNxSZNhe5VzaT7yaKNu8T1+cDHowmbV
         fD4L/X+jCdltBq/BiRT5+5FoW7DIFj6rEE1aoBY8XleYJ7dubX5haD1EWY+80XRdfkiI
         grGxkdpem4LHl/JXM3b79RWclkfbqn4swE7UZ5uhUXWWWbO5TI/AKIxdJJUyX8yGZCC2
         tT/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=qcjyfg1lJys5F840SIp1/Xpqy4pO4nAzr0Xj6SXU3L8=;
        b=dLkFnhfeZoD/8ZHztfE512lD5uyzFarbY8JTqraK8bgbpRRnmTR+JRWlNmrbdxcX02
         vvmC66Q8wDb0pkb2SBZlxpDDiooRHlfj5qglMXnTW2ELrVQOSDbhwLktNbU9xzUhHplX
         FfSXYA1praZdoOw7fnn0m6uxXzkyG/6+xZTThumajkiJrE8IKrk/y8sc/OpRO3I0oVFG
         INsx30qFU9VoG6/Tb8sBhlNqiD8tB2QSkdgmlRdkI1hnXHTEH9sFVaS0fVaJofC6FgCx
         IUq9F31O9VuxPy9U6JXdnE1QNAdizTc1f/7aLEEC7IZLDJgpCkvYSE5qT9luVo/NPJd9
         zTiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l10si9221901pgp.25.2019.02.25.10.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 10:50:34 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PIie1p053368
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:50:33 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvkjyrahx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:50:33 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 18:50:30 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 18:50:25 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PIoOGF58130614
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 18:50:24 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2A385AE051;
	Mon, 25 Feb 2019 18:50:24 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1AEC3AE055;
	Mon, 25 Feb 2019 18:50:20 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.26])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 18:50:19 +0000 (GMT)
Date: Mon, 25 Feb 2019 20:50:15 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 18/26] khugepaged: skip collapse if uffd-wp detected
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-19-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-19-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022518-0020-0000-0000-0000031B173B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022518-0021-0000-0000-0000216C796A
Message-Id: <20190225185015.GK24917@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250136
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:24AM +0800, Peter Xu wrote:
> Don't collapse the huge PMD if there is any userfault write protected
> small PTEs.  The problem is that the write protection is in small page
> granularity and there's no way to keep all these write protection
> information if the small pages are going to be merged into a huge PMD.
> 
> The same thing needs to be considered for swap entries and migration
> entries.  So do the check as well disregarding khugepaged_max_ptes_swap.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  include/trace/events/huge_memory.h |  1 +
>  mm/khugepaged.c                    | 23 +++++++++++++++++++++++
>  2 files changed, 24 insertions(+)
> 
> diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
> index dd4db334bd63..2d7bad9cb976 100644
> --- a/include/trace/events/huge_memory.h
> +++ b/include/trace/events/huge_memory.h
> @@ -13,6 +13,7 @@
>  	EM( SCAN_PMD_NULL,		"pmd_null")			\
>  	EM( SCAN_EXCEED_NONE_PTE,	"exceed_none_pte")		\
>  	EM( SCAN_PTE_NON_PRESENT,	"pte_non_present")		\
> +	EM( SCAN_PTE_UFFD_WP,		"pte_uffd_wp")			\
>  	EM( SCAN_PAGE_RO,		"no_writable_page")		\
>  	EM( SCAN_LACK_REFERENCED_PAGE,	"lack_referenced_page")		\
>  	EM( SCAN_PAGE_NULL,		"page_null")			\
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 4f017339ddb2..396c7e4da83e 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -29,6 +29,7 @@ enum scan_result {
>  	SCAN_PMD_NULL,
>  	SCAN_EXCEED_NONE_PTE,
>  	SCAN_PTE_NON_PRESENT,
> +	SCAN_PTE_UFFD_WP,
>  	SCAN_PAGE_RO,
>  	SCAN_LACK_REFERENCED_PAGE,
>  	SCAN_PAGE_NULL,
> @@ -1123,6 +1124,15 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  		pte_t pteval = *_pte;
>  		if (is_swap_pte(pteval)) {
>  			if (++unmapped <= khugepaged_max_ptes_swap) {
> +				/*
> +				 * Always be strict with uffd-wp
> +				 * enabled swap entries.  Please see
> +				 * comment below for pte_uffd_wp().
> +				 */
> +				if (pte_swp_uffd_wp(pteval)) {
> +					result = SCAN_PTE_UFFD_WP;
> +					goto out_unmap;
> +				}
>  				continue;
>  			} else {
>  				result = SCAN_EXCEED_SWAP_PTE;
> @@ -1142,6 +1152,19 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  			result = SCAN_PTE_NON_PRESENT;
>  			goto out_unmap;
>  		}
> +		if (pte_uffd_wp(pteval)) {
> +			/*
> +			 * Don't collapse the page if any of the small
> +			 * PTEs are armed with uffd write protection.
> +			 * Here we can also mark the new huge pmd as
> +			 * write protected if any of the small ones is
> +			 * marked but that could bring uknown
> +			 * userfault messages that falls outside of
> +			 * the registered range.  So, just be simple.
> +			 */
> +			result = SCAN_PTE_UFFD_WP;
> +			goto out_unmap;
> +		}
>  		if (pte_write(pteval))
>  			writable = true;
> 
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

