Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9801CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:42:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5220C2087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:42:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5220C2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED3398E000F; Mon, 25 Feb 2019 10:42:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E827F8E000D; Mon, 25 Feb 2019 10:42:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA6048E000F; Mon, 25 Feb 2019 10:42:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9842F8E000D
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:42:07 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id g197so8035623pfb.15
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:42:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=AcE+sZK0A2LB1q0joW9FegtnHXodVSESC6wTlQL+cBE=;
        b=sh5A9+NATk82mt3R3tOD9uclzPRIFPW8PcXOdsnSZn8mKcmwTg4tBF52zySJeHoIq6
         imfOaE/+AMy20vknYrIqApb2PvLfkEZ+USoqYlnnUOzdWOZ0YHyBAZrKM2r6/MLdH/Oh
         SYrRcH5ObpQCHc4j/URFqvWtaO+fWtDdMlaY6pp8ofraWHMwpWSpHAatgXQybEgLA1+L
         HIfQG46z7ByaXl7vvzNyR2m+1aEy6sXXos1PYtk6W165e4gqOAtqyJYmiI2wdQuJjsdc
         b7F2CmiwORxgGeOciOC8R7aalPu87LcnGWz4d2iGcsSAE9xvcD96PIK2ooxZr8r3ivcK
         Nwaw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYuXdPYRRRaZ9eI/OaIazz4lbdKJ3fcc/5dUmi06WkkhsCpu+Mk
	A4S0YVjCUieBPSHQPf9lr2QHXKoAVOGg/GAu8ttX9xVVIYufvVi4uECnNEjcKrzJwWxJEzNOPS5
	vonh4ZRSpTPFwNjkaKYQpcjjCd11JvdF+YbN33mmn6rdLU2s1BhgRfaivqgdS6wD/YA==
X-Received: by 2002:a17:902:850a:: with SMTP id bj10mr20890132plb.91.1551109327294;
        Mon, 25 Feb 2019 07:42:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZjUbXEX42Jug4p8nnHCUV+b3UCevxq4PTIxypz2/eS72OgxvqAfo2w9emzhSJWa7Jg9gfi
X-Received: by 2002:a17:902:850a:: with SMTP id bj10mr20890062plb.91.1551109326240;
        Mon, 25 Feb 2019 07:42:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551109326; cv=none;
        d=google.com; s=arc-20160816;
        b=mFf8SSjs1Qr1fMV3QXTVXK53YH8wNj8iHMf0TI84ZnNzbt7LaTY1jorvrWzipUyUT1
         qHuXEriIefNCnv05/FUcVHqlb6EsF0zPs5JNTFDMhAT/opf+waCEUFtdJ1LOQjvINiMr
         2Qq9P2RQLUFlsdQe5COE9VBhWsWOsPLntRv5k1mQl14VZQxkQ55YQ+OeMxMMVAUq4CPt
         GubR4IgpqNzHkztRhRD/XRGBJcHpwKGw3KqXfpOCxTe1iP1SxioffGD9+vYhdZgYeH78
         kwarxLLqZYOM/3xO69YesCv7blruPGguUqdm6xSvNdySL4fDlh2c6wIc1gfpKMsFlJIA
         ti1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=AcE+sZK0A2LB1q0joW9FegtnHXodVSESC6wTlQL+cBE=;
        b=f2gGuw7Mvkl3Ee/ZPMYV7xm2pfp/q70pFSbzeOscDpTd8WPqjnBQjbdMkWw2gQ69sP
         A3w6zWAxB5yH27ijdDe6cXzqXHtMyksZrVpBXU9vCFtiQIVwtAhOhYigZfm4g6aQ0BbO
         +Wx1nx/e2IYJVRlyTRqQ/Dy1EdexTpeJJBnCedzPd73VAyDgCy2m7tRA42tuoDeDFL5W
         59zxz9ZHFl/ZU523oJblvvHjklR9Hr98Zrv6VcrWSUmd8vQxHC/QNjjF5n0ns/97rgZQ
         Img5G1TxKKY9EjiDrtXzgRzTFLtNTyvMujK3A9s2FXhI4drTBN646Ipo+zRMGIEbiB0A
         e5Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1si776143plv.228.2019.02.25.07.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 07:42:06 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PFZPcb134949
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:42:05 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvjbfb62g-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:42:05 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 15:42:02 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 15:41:55 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PFfspS4980780
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 15:41:54 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6BC0111C04C;
	Mon, 25 Feb 2019 15:41:54 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7A68D11C052;
	Mon, 25 Feb 2019 15:41:52 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.26])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 15:41:52 +0000 (GMT)
Date: Mon, 25 Feb 2019 17:41:50 +0200
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
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>,
        Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v2 06/26] userfaultfd: wp: add helper for writeprotect
 check
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-7-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-7-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022515-0016-0000-0000-0000025AAE04
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022515-0017-0000-0000-000032B50C16
Message-Id: <20190225154149.GA24917@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250114
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:12AM +0800, Peter Xu wrote:
> From: Shaohua Li <shli@fb.com>
> 
> add helper for writeprotect check. Will use it later.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  include/linux/userfaultfd_k.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> index 37c9eba75c98..38f748e7186e 100644
> --- a/include/linux/userfaultfd_k.h
> +++ b/include/linux/userfaultfd_k.h
> @@ -50,6 +50,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
>  	return vma->vm_flags & VM_UFFD_MISSING;
>  }
> 
> +static inline bool userfaultfd_wp(struct vm_area_struct *vma)
> +{
> +	return vma->vm_flags & VM_UFFD_WP;
> +}
> +
>  static inline bool userfaultfd_armed(struct vm_area_struct *vma)
>  {
>  	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
> @@ -94,6 +99,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
>  	return false;
>  }
> 
> +static inline bool userfaultfd_wp(struct vm_area_struct *vma)
> +{
> +	return false;
> +}
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

