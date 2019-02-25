Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51AAFC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:20:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15B332084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 18:20:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15B332084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEEE38E000B; Mon, 25 Feb 2019 13:20:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9D7A8E0009; Mon, 25 Feb 2019 13:20:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8C548E000B; Mon, 25 Feb 2019 13:20:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 778498E0009
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:20:07 -0500 (EST)
Received: by mail-ua1-f72.google.com with SMTP id w13so2315096uaa.21
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:20:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=T6IALUrplkpdOQzDQbmAdnHUOIXzH+ng67ITmAcupqo=;
        b=U2lwHruyKGP46M4UYX34Y/VQwYSVXLjUsqgq7VmTlW+0U7Cv0b4gS0SykXqHfJSRB8
         E+9en4rje8w3MkOP00usbwrv6xrHRo77t0LYt5fR2nzKX59B/jBlTRSVx2eOi2hFeI8s
         Y+ax7+yOBfEyEPCMhksqMN3vPNwHXX2AkgVz2j0/BNVJxYm0O2lycBmxMSe3jR60NW26
         z+9My4TMrDIeBaWuN7vDSJeGfeqhiNw7eBwjhi9H/LvZovX5lXjWPft1/CyyOicB7pkd
         ZL6yK+ubpv3Z/Nppn0qUuBJ6C3cqUbs75rtDogXjB2e7eZe87Og64CHT6nIA+Jaa4VHM
         cbpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYdAoeTzQgGP25d4+ubdgiyv5dZ4qgsnPcj+isyVsVX1XtzBfoQ
	f7n2mLSQ/p3LZFV3jyiqJjUaqxbS7hIctYKakXzg76t4/M6n91PwAUSW8BUXLaF9OcDtEtE6EqE
	0r3viMtkqUk1QucN/+HdTENcyqyGGcrsmFqIngp0XiDUl7XZqcsaVJXNa2MhUGmwBHA==
X-Received: by 2002:a67:fa8e:: with SMTP id f14mr1763640vsq.126.1551118807179;
        Mon, 25 Feb 2019 10:20:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZZXkHVb3CPutdwRo35isCUZqi4eKTRt0JuvAfuaxI/EjYO5JFUel+u4ZDSXI/uq8Hix9N8
X-Received: by 2002:a67:fa8e:: with SMTP id f14mr1763575vsq.126.1551118806046;
        Mon, 25 Feb 2019 10:20:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551118806; cv=none;
        d=google.com; s=arc-20160816;
        b=oEunly4jRXU3TMILOdPdL1GT3H8BtSS89cR9N5Ss/+CCPvgC9thTor1bTao+CB7GGx
         Jvg1IoUp4bi67EIXYCcgmta5UiIToNmoEIADxYQBHsBcgd3i2BIvqWgI2fba4Xktsxz6
         hBsJE9sB/PRR+T24uutLq8U0KIMou+9yBoyUu0Aof/kDO3SWe6opb8fMVUV03raW/D/e
         TUwweEAdGddn8KAQLsPH4jDpOsdrxL0RcUSSyn5NaaMrO7H9SuMTAXKmxuubUStD5o0I
         Rs/5ubwx97I5F21aO1vWHVX0qEnI83hn4bBfkgLkUradzw96hxm9wK1B68SpAq/hXLxQ
         vg2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=T6IALUrplkpdOQzDQbmAdnHUOIXzH+ng67ITmAcupqo=;
        b=DJjPdSMiDYt/NeiVb83gCeDEAz7ZZOeNeq6ZgZ2sYK9+5xkquE7V8UR8cN/lKVPypu
         eC7PAQEUOjLJh8bgdhchuQHU/T4jnXNGoamjqEb3SSedFPyYsGCZgWxzl8d8uaLDK/42
         hmJCxNpv8iIsufBb4bqjVcDrMOeKKhWFXy6rFUSu+zEIMc8LQ5BvNnsqZhKEdVRm/sF2
         MfP7vEFbTFwUeSM5VW/z5Lr72lQ6Fl4MRAGt9dYbbr/T49Mwn9DUfL/NM6aEOFYlhtWg
         dJdIsdtyP7NHGAPuLjZVRZvIG5meNZRs5iNbAoAR4zh4wKdZJyR+z+kHxRTS83Of88UW
         zzNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q20si1675583vsm.316.2019.02.25.10.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 10:20:05 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PIBw8R114465
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:20:05 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qvjrcsrt0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:20:05 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 18:20:03 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 18:19:57 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PIJuHh31129848
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 18:19:56 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6F55D11C052;
	Mon, 25 Feb 2019 18:19:56 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 67EF411C05C;
	Mon, 25 Feb 2019 18:19:52 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.26])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 18:19:52 +0000 (GMT)
Date: Mon, 25 Feb 2019 20:19:49 +0200
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
Subject: Re: [PATCH v2 15/26] userfaultfd: wp: drop _PAGE_UFFD_WP properly
 when fork
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-16-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-16-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022518-4275-0000-0000-00000313CC8D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022518-4276-0000-0000-0000382209B5
Message-Id: <20190225181947.GG24917@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:21AM +0800, Peter Xu wrote:
> UFFD_EVENT_FORK support for uffd-wp should be already there, except
> that we should clean the uffd-wp bit if uffd fork event is not
> enabled.  Detect that to avoid _PAGE_UFFD_WP being set even if the VMA
> is not being tracked by VM_UFFD_WP.  Do this for both small PTEs and
> huge PMDs.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  mm/huge_memory.c | 8 ++++++++
>  mm/memory.c      | 8 ++++++++
>  2 files changed, 16 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 817335b443c2..fb2234cb595a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -938,6 +938,14 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	ret = -EAGAIN;
>  	pmd = *src_pmd;
> 
> +	/*
> +	 * Make sure the _PAGE_UFFD_WP bit is cleared if the new VMA
> +	 * does not have the VM_UFFD_WP, which means that the uffd
> +	 * fork event is not enabled.
> +	 */
> +	if (!(vma->vm_flags & VM_UFFD_WP))
> +		pmd = pmd_clear_uffd_wp(pmd);
> +
>  #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>  	if (unlikely(is_swap_pmd(pmd))) {
>  		swp_entry_t entry = pmd_to_swp_entry(pmd);
> diff --git a/mm/memory.c b/mm/memory.c
> index b5d67bafae35..c2035539e9fd 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -788,6 +788,14 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  		pte = pte_mkclean(pte);
>  	pte = pte_mkold(pte);
> 
> +	/*
> +	 * Make sure the _PAGE_UFFD_WP bit is cleared if the new VMA
> +	 * does not have the VM_UFFD_WP, which means that the uffd
> +	 * fork event is not enabled.
> +	 */
> +	if (!(vm_flags & VM_UFFD_WP))
> +		pte = pte_clear_uffd_wp(pte);
> +
>  	page = vm_normal_page(vma, addr, pte);
>  	if (page) {
>  		get_page(page);
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

