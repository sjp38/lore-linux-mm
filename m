Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1826C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 17:12:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DAC820C01
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 17:12:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DAC820C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF87B8E0010; Mon, 25 Feb 2019 12:12:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B80418E000E; Mon, 25 Feb 2019 12:12:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A210E8E0010; Mon, 25 Feb 2019 12:12:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 266E38E000E
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:12:30 -0500 (EST)
Received: by mail-ua1-f70.google.com with SMTP id g9so2240830ual.8
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 09:12:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=tXshP6GgEDaLoJOwuV/eunafrh75iPJdSmazWkCwvIk=;
        b=DgPw5SyX875PNE9ukovHlnM/BOH14YsIQpY+YXbhj0L/iK7uvlBKXhqs7dwugvmvI8
         vS810Zw94hWr+sC02J0FR1tXi/6NXB6gPRT2DnrR9svH14MbK3ZmYFnGDTIcZYBojBCq
         VJcL/zzHgqLiSkEzuj0Ty9BrfqX8x8f7+6P0I2LffRKG8eIkYE9mKOHZr2Xf+48Wdbe8
         0MYPWZa2eMUG3D1DxMhygOHNTf9ubOs9WhRnM85yZa22UTgDOuymVQz0HBNsCvdJcC2a
         8vF3Oc8Hg6MjsXkJxCY7X0wGdCo2FbGux8jdOKpWkzjIC0S7wxO7k3oKs0qwaTRuPKXc
         hhkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaHubEzYj43EyWBng6JP7o73vkPeQgoNnW+d4Wwo0eyhJsWkU+e
	dUcBwnSMiu+pwZ8FPww5YPOBQ3nx8MolpxMAYWvP0pf5jAizmOYoV0Iny4Ti6LWyMdoBy5c4qdu
	GJr0O7gZXv5QRohwjL7xGVbWXNDpSkKQjwD1/1el+MyY1cG7LRLF3aJWTxjWnDze0zg==
X-Received: by 2002:a67:f409:: with SMTP id p9mr9717523vsn.213.1551114749785;
        Mon, 25 Feb 2019 09:12:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbobFtn5HkPwMsQWgo37CgqcZ0zMphGPHuTUv/Nivr97D4RMVjxHUV8stQfjUMZ8DX9r4PO
X-Received: by 2002:a67:f409:: with SMTP id p9mr9717488vsn.213.1551114749120;
        Mon, 25 Feb 2019 09:12:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551114749; cv=none;
        d=google.com; s=arc-20160816;
        b=0aUG+UbijJXDXk8kYtJ+fCaDSNaiBrd8fYK006aCtqwkapTaanNA1n/6e6JmvtjHZX
         Azwrjf7HZ3I+JtuBe9dGokVPOluLKodFTEVXrlE28l8DtpwA8KeG1y+MycI+ZkS05GB0
         6mTVO2KTJoSybnxPGiTm1F8y1NS7Lh9aLQWGQ3Np8lghuUfJwq5pUrvsk/7XGk91tsp3
         JMqbHDKpTt16iB3JdqnVG+HMljEZnYHdju+tqimWZr4fsmfSa3tcexVJrYY+tvlSHSOI
         WvrtGD8Xidhn85HZfjT0T5m6jEv+7C12jbfzbaTxuQczpN25mnRR2xSpsqpswIIC48ap
         UaCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=tXshP6GgEDaLoJOwuV/eunafrh75iPJdSmazWkCwvIk=;
        b=fAFzNhvbMQ88zQl8ZwOv8cRbkfoqktGXB9LSLDsVEOCXMTyZSyCgC0gOqbn3pfOYW3
         jUKPytpR52VWrZrEq0dmUar9r1S3x6ta67ZvWfR+OV5ORaX7TrHXtp21vL3ke15TWdrd
         xp5zZCPwJwubAc0ah4MUVNmibybIgw0ixMZoE4p0aVtaeU/igpNbeqUzMf4LZMFLAqov
         XL0XQskxqOaKu5IiaCNal8JQUWbM6LvWmcp4UyDA/c0b6mTPhWu/EYNGCFF/6MxU+yGI
         mTRCxXb5bIuwqy9Ll4AKtDPgmzESuGWbh7a98/Ql1qvw6KeUwqkjQCHqrDS3jAJlaLvr
         bV7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h5si1735080vso.61.2019.02.25.09.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 09:12:29 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PH9MkL180935
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:12:28 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qvjwap04b-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:12:28 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 17:12:26 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 17:12:20 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PHCJg534013366
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 17:12:19 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 41269A4055;
	Mon, 25 Feb 2019 17:12:19 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6BCCCA4040;
	Mon, 25 Feb 2019 17:12:17 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.26])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 17:12:17 +0000 (GMT)
Date: Mon, 25 Feb 2019 19:12:15 +0200
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
Subject: Re: [PATCH v2 09/26] userfaultfd: wp: userfaultfd_pte/huge_pmd_wp()
 helpers
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-10-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-10-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022517-0012-0000-0000-000002F9FF50
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022517-0013-0000-0000-00002131A072
Message-Id: <20190225171214.GE24917@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250126
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:15AM +0800, Peter Xu wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Implement helpers methods to invoke userfaultfd wp faults more
> selectively: not only when a wp fault triggers on a vma with
> vma->vm_flags VM_UFFD_WP set, but only if the _PAGE_UFFD_WP bit is set
> in the pagetable too.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  include/linux/userfaultfd_k.h | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> index 38f748e7186e..c6590c58ce28 100644
> --- a/include/linux/userfaultfd_k.h
> +++ b/include/linux/userfaultfd_k.h
> @@ -14,6 +14,8 @@
>  #include <linux/userfaultfd.h> /* linux/include/uapi/linux/userfaultfd.h */
> 
>  #include <linux/fcntl.h>
> +#include <linux/mm.h>
> +#include <asm-generic/pgtable_uffd.h>
> 
>  /*
>   * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
> @@ -55,6 +57,18 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
>  	return vma->vm_flags & VM_UFFD_WP;
>  }
> 
> +static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
> +				      pte_t pte)
> +{
> +	return userfaultfd_wp(vma) && pte_uffd_wp(pte);
> +}
> +
> +static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
> +					   pmd_t pmd)
> +{
> +	return userfaultfd_wp(vma) && pmd_uffd_wp(pmd);
> +}
> +
>  static inline bool userfaultfd_armed(struct vm_area_struct *vma)
>  {
>  	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
> @@ -104,6 +118,19 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
>  	return false;
>  }
> 
> +static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
> +				      pte_t pte)
> +{
> +	return false;
> +}
> +
> +static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
> +					   pmd_t pmd)
> +{
> +	return false;
> +}
> +
> +
>  static inline bool userfaultfd_armed(struct vm_area_struct *vma)
>  {
>  	return false;
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

