Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60FF0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:44:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16E682075D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:44:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16E682075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A665E6B0005; Fri, 22 Mar 2019 17:44:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A147D6B0006; Fri, 22 Mar 2019 17:44:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 901C76B0007; Fri, 22 Mar 2019 17:44:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57AB36B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:44:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z14so3334360pgv.0
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:44:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=CkCj0H8W3Vi5+4r2ZHNHFzEdNYijB6HXIfxWvVkWt88=;
        b=Qr2XhZPgZuzTujFD4FxdGd04vWkzhlXMsLZQ7W0OjZ/EAzRc+cp0z+K9afOYjuiY3F
         e6bb8ckciHBW2FyxZaf18XV6apmR/0tVACiWvbkaNHUPNTTR+v5RC3VkUyOlKmEa5wYS
         DOqDVYbvOKNcTfhsCB+T7zWtaTpSYW4o3wAJu5jBw60iPQa+sKfLiLkmNtfJj8/r1adq
         +Z1ATOQWWLxgpI1V+TgR2Xkm7s7rAf7Zk+6gsoN/vxzARf8RgrjAQ9kQOz3uNs+vsIFX
         aKayXgx3muQ5dwL0rYUGH2DrvU3n/xaNRqj1mb7Dy7ZJt/sg5xh4Ed5Uwlgow1yKBd/B
         W9Ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUbSXMuH3wbcJAbRUSDvwDBhlZx4dviu3CtF0OV2guJf+onVyGs
	vSjWDNLyqXnK5kSx9prmDD57lxKP5rCfO0/ZdMGN+X8A/42R87g0b6cpS95vUqUq65ftBziabcX
	nq76m7iLLDjScSojz9qbW3kfnq0cGpKc/MWn4pFqPRxIz9OmIsZ58ayOx1Bf6/tGVJQ==
X-Received: by 2002:a63:4142:: with SMTP id o63mr10955953pga.81.1553291041996;
        Fri, 22 Mar 2019 14:44:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7bld4mbknAJ+0agljqIX49mgn+dPIxdKq1lPQSPBjDzRJbDpHPnSJEts5miUk2tAL7YGT
X-Received: by 2002:a63:4142:: with SMTP id o63mr10955913pga.81.1553291041206;
        Fri, 22 Mar 2019 14:44:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553291041; cv=none;
        d=google.com; s=arc-20160816;
        b=pTWJOqUc/xrdRPsJCXK4ifXSO4x8QsMwOan+8wUNm6RKROcJLapHW0TneP3k5DJguX
         HDfb0pDKFeVZxQT4ZFLtAiSaJurZUi7hC+EpJ3+QJWLJ2++AbroH0GP8pJsxXccFAkR4
         U0CqGITSLNSANTRG0rC6Xw+aw4xueyeGE/PmvbOs+5+qjxdKf+lpOfNWVdiqcGUhF6Is
         CphncvIuQ4uqXFXSU0SlBFx7MJULF4KhVvmRRo0/wDBL7B+8VUn6mAo+I/1BPL0vRiJG
         ERs1Ib1AIToVLvjyLU9WppRo184BEP+AJqhoFdhJKSP1mLkXyqJV27cUxgyPh8XpsQ/8
         nq4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=CkCj0H8W3Vi5+4r2ZHNHFzEdNYijB6HXIfxWvVkWt88=;
        b=JJc1dG+if2Q9KLYbAzO+QwRUmWmt/LcBcunZ19y6TF7pWAUEJfofVdn1ADRH9K65Vg
         D3w/RZrMcTZD8t8OZcK+0qJCpogjkeKfwU6ZucPaDyJE/nz1BorCHiUpy6KGdchNhNm6
         2ylKs1IMEEfCeHzZP3a41FC6iWIZTUH0uONxv45qCB7SGA3mxwIZACXKYk2hUh60Gur5
         Ox/M4CzoSK7oG2jQ+KvI9CHh9Kzzly75WFq/1BX6cfDsjheZ2Vl6ylzlbtMtZoJrSVAc
         BcV3nToL+v2fYFT+UXup4ZDr7lkhMj1LiLimJGG00Za0zg+iMvKiaaRYOE7LcaTtpgSb
         GL6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q13si7599092pll.175.2019.03.22.14.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 14:44:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2MLdRMX044170
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:44:00 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rd7dsgu1f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:44:00 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 22 Mar 2019 21:43:48 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 22 Mar 2019 21:43:42 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2MLhojT40632570
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 22 Mar 2019 21:43:51 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D5F3452050;
	Fri, 22 Mar 2019 21:43:50 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.23])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 27A275204E;
	Fri, 22 Mar 2019 21:43:49 +0000 (GMT)
Date: Fri, 22 Mar 2019 23:43:47 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 26/28] userfaultfd: wp: declare _UFFDIO_WRITEPROTECT
 conditionally
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-27-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320020642.4000-27-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032221-4275-0000-0000-0000031E3656
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032221-4276-0000-0000-0000382CC3A4
Message-Id: <20190322214346.GC9303@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=648 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903220153
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:06:40AM +0800, Peter Xu wrote:
> Only declare _UFFDIO_WRITEPROTECT if the user specified
> UFFDIO_REGISTER_MODE_WP and if all the checks passed.  Then when the
> user registers regions with shmem/hugetlbfs we won't expose the new
> ioctl to them.  Even with complete anonymous memory range, we'll only
> expose the new WP ioctl bit if the register mode has MODE_WP.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  fs/userfaultfd.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index f1f61a0278c2..7f87e9e4fb9b 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1456,14 +1456,24 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  	up_write(&mm->mmap_sem);
>  	mmput(mm);
>  	if (!ret) {
> +		__u64 ioctls_out;
> +
> +		ioctls_out = basic_ioctls ? UFFD_API_RANGE_IOCTLS_BASIC :
> +		    UFFD_API_RANGE_IOCTLS;
> +
> +		/*
> +		 * Declare the WP ioctl only if the WP mode is
> +		 * specified and all checks passed with the range
> +		 */
> +		if (!(uffdio_register.mode & UFFDIO_REGISTER_MODE_WP))
> +			ioctls_out &= ~((__u64)1 << _UFFDIO_WRITEPROTECT);
> +
>  		/*
>  		 * Now that we scanned all vmas we can already tell
>  		 * userland which ioctls methods are guaranteed to
>  		 * succeed on this range.
>  		 */
> -		if (put_user(basic_ioctls ? UFFD_API_RANGE_IOCTLS_BASIC :
> -			     UFFD_API_RANGE_IOCTLS,
> -			     &user_uffdio_register->ioctls))
> +		if (put_user(ioctls_out, &user_uffdio_register->ioctls))
>  			ret = -EFAULT;
>  	}
>  out:
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

