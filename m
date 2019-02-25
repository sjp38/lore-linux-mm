Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AB5AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:09:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A43F20842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:09:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A43F20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6C9C8E0005; Mon, 25 Feb 2019 16:09:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D18558E0004; Mon, 25 Feb 2019 16:09:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B92B28E0005; Mon, 25 Feb 2019 16:09:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75FAC8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:09:52 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id f1so5103775pld.16
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:09:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=nGxED6wJ+dbK4SVY1d8AnUZ4E3mmTERlFJUt4hAkKzg=;
        b=TT24+FqMZeXPAlZo5526sgGYNQ2H8K8pXA2ATj8zt0MO9Nd4VddiuUE/P4kJocoE8U
         k1PEezl8m58C0qOpvUoERB4g4PtOKDizSfgP9BxgKTPk3Dd/tzyQee/JAGL8B8SbMspf
         SCD6oP/K4nAqi5lOVINqAI46mx/szUluTPM9LWulI6xp/dfok0RqFwIbJJHUxzwIRCPJ
         SbUCVBZ1u0vHCEYrP/a8ufRtgf0TZa3fUCP/NLjAhPfBZ4JhgLJeFtKECPWqd2Bs1Wx3
         /WIo7lhqa+Uk3oNgSmLYMv+zvxBEZxryykzixG/T/ziA73LBtqe3h9hxWqFVJo+a0woy
         FrYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubDVb1+4EMOD18q8Hczv+ZeZmXiXvdTJcHOceNBfuAHo7cbA2LL
	OOqzYAYNYpLlArian6XucE9oAfeQG7/dLm8c2GlS9lrSOD/wqXvuotWoj/5j5BbGdgJyN+2uTq1
	6PCNvVkYzxKRZIr6PKxZ5oTENhltU682iHnDG3x+YvhBsjcSIMuDoJkBoZxaSXibYsg==
X-Received: by 2002:a65:63d3:: with SMTP id n19mr17608392pgv.179.1551128992152;
        Mon, 25 Feb 2019 13:09:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLwZiveMMuWLJvy8Cf7Ib0qHEXJDi6tGeiqMIjEbf3WtTDStq2jHk/3EEPtpRJ5aLwHbTr
X-Received: by 2002:a65:63d3:: with SMTP id n19mr17608328pgv.179.1551128991293;
        Mon, 25 Feb 2019 13:09:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551128991; cv=none;
        d=google.com; s=arc-20160816;
        b=A4VbrmRl2cSk/aY1dp9EkeseJjgAX+8akAoJ6tHu5ROsfRHt1FAXw2MaA58H2a/e8i
         CMQTilJbq65WViYGj7cvL4G8F7ahFcZE9ULBlLk9Vxbh3fW/tSDxOOOwQRAgT4MzPP3/
         f5HfTlwaOCGVIW/hbfAtkjNQXR/XaGKcJX4j0nXU4x4Y02WyTyZyUc4qh4W263Bx6jud
         mmxiv/L+yZeamg4c2boEpbuT36wVLx2kRyR9Vpi+DALmNXzqZnhfnjy6ruCj/QdvbwnH
         mOuXhFc9p04D3TUlgUOqt4hfYjTnGAZPRBwT4rBnlhBISQAiD0Hc9WFwfmXtdUN2mmkN
         r8hQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=nGxED6wJ+dbK4SVY1d8AnUZ4E3mmTERlFJUt4hAkKzg=;
        b=hYQkHrWVPVU/4P+5WDe+K3Fy/qszTLa3iBwW2tgmx75dGIWQeChU+Ar0ye+vdm9r4q
         3YVXqs3Dfbco/HIfQ6jwjeMWAoz365wCW4h0Intk9mOrA46KiF6iPVe+58zMKXMMDSKZ
         M8/UfGTo2FawFxAri9mRh/gWbc4Q2AmFEO6PD0N5BqjO9FfAnJ0DfM0bExkJxVmpI630
         L0AtHpYqAilsrl2Toqoa8YuHZ85fvJXhxocC7Yh+9aRuNfBMnCX2CsBOrWZv92eytKT6
         clMf3EVo+DdzHBTqSQacpX+p0kHcm4WQ/lY4qScvvowingAjFUdTJpEVKXHvfB10f7jP
         xhXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 63si10799783pla.187.2019.02.25.13.09.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 13:09:51 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PL4ovf016082
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:09:50 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvnu560qd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:09:50 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 21:09:47 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 21:09:41 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PL9eS955574598
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 21:09:40 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C98D8AE04D;
	Mon, 25 Feb 2019 21:09:40 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DDF0AAE045;
	Mon, 25 Feb 2019 21:09:37 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.243])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 21:09:37 +0000 (GMT)
Date: Mon, 25 Feb 2019 23:09:35 +0200
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
Subject: Re: [PATCH v2 23/26] userfaultfd: wp: don't wake up when doing write
 protect
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-24-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-24-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022521-0020-0000-0000-0000031B210C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022521-0021-0000-0000-0000216C83A3
Message-Id: <20190225210934.GE10454@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=761 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250151
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:29AM +0800, Peter Xu wrote:
> It does not make sense to try to wake up any waiting thread when we're
> write-protecting a memory region.  Only wake up when resolving a write
> protected page fault.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  fs/userfaultfd.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 81962d62520c..f1f61a0278c2 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
>  	struct uffdio_writeprotect uffdio_wp;
>  	struct uffdio_writeprotect __user *user_uffdio_wp;
>  	struct userfaultfd_wake_range range;
> +	bool mode_wp, mode_dontwake;
> 
>  	if (READ_ONCE(ctx->mmap_changing))
>  		return -EAGAIN;
> @@ -1789,18 +1790,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
>  	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
>  			       UFFDIO_WRITEPROTECT_MODE_WP))
>  		return -EINVAL;
> -	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> -	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> +
> +	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
> +	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
> +
> +	if (mode_wp && mode_dontwake)
>  		return -EINVAL;

This actually means the opposite of the commit message text ;-)

Is any dependency of _WP and _DONTWAKE needed at all?
 
>  	ret = mwriteprotect_range(ctx->mm, uffdio_wp.range.start,
> -				  uffdio_wp.range.len, uffdio_wp.mode &
> -				  UFFDIO_WRITEPROTECT_MODE_WP,
> +				  uffdio_wp.range.len, mode_wp,
>  				  &ctx->mmap_changing);
>  	if (ret)
>  		return ret;
> 
> -	if (!(uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE)) {
> +	if (!mode_wp && !mode_dontwake) {
>  		range.start = uffdio_wp.range.start;
>  		range.len = uffdio_wp.range.len;
>  		wake_userfault(ctx, &range);
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

