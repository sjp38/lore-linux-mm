Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F7E8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 08:00:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC9F82147C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 08:00:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC9F82147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FBDD8E0007; Tue, 26 Feb 2019 03:00:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AADC8E0002; Tue, 26 Feb 2019 03:00:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8743A8E0007; Tue, 26 Feb 2019 03:00:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 453648E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:00:56 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id k198so9016195pgc.20
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 00:00:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=/BT4DLkIgBGj1cjRUcjmIYFS1YR5uEvsTolKaiVQj0k=;
        b=rRMeZ4xdyS+xrDwFr3tvJhTXK/YbkkdIrDXgnZzjaORQSnqDFb9M9F0pOVh2H1z/Dx
         q/lKIR4Sw/EkjlDuFukcnUVKno0c5JSVGs/AMHeQiC5LaClwcaf4XHcEruL34Gp04rph
         M9XJ9vrajBTRKRI3/cJS71j9LMquT/46YXZej2LJ5nFEQk8690fjoKEek0iw0HFf1H1T
         gKAvmRfpEjpdii8nohLY0Z8vHUAJ6AVsQP/b7p1QIUEug2NdmFsj9Tv1nQc2DEsMcGQ1
         z1T9YEzzwvcUMVOrqMbr9r0yxkCqv8ewqgKib/BpFxC9amUGpupGmNQF0vXEKSmoNN4f
         PiNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuY2uBWqLzFnOIDKZjkX2LBOtgURktLsaf0fE8gGm9akJLyq59HL
	iA48i7OWWe1a/AvQRC9HWFLOgCeJNgqE5rac1vlwwzuGOUHDwQfPCtZ0mquXfMtdMH+wmsoPwF9
	o2MuWvRq1KTjq0dAgM8qB2dfD6Fwi1EXSv6sTzP2dLBWgN/QpWBa1IpGNjUSMYjFHqw==
X-Received: by 2002:a62:4815:: with SMTP id v21mr24264378pfa.167.1551168055901;
        Tue, 26 Feb 2019 00:00:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IamnonBjDS8vA5O9D6AArW6yKwwPwWpxYoyi5qVEzPUgIYYm4TwmzUfWBFPIBekTkQNekIa
X-Received: by 2002:a62:4815:: with SMTP id v21mr24264281pfa.167.1551168054780;
        Tue, 26 Feb 2019 00:00:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551168054; cv=none;
        d=google.com; s=arc-20160816;
        b=y5+HC0DZgfYM/48sbeGTdlGA+xW0IyvnP3eIxylnqkkmCTxwypMUyuqOfeOFs8a/R0
         bG3mwDkg1qVSkMTVsCWkC7B38Bfb4gf+ZDOnAJ6rS/nRVDFzeBp4Be9BZK/m2l2od9kg
         bI0vcwzqSuX0FsAat82ACdEu7UXkusLTNF9N3oqHTimZGorrCo8TJKgdnGl3eok98Yty
         NrzjKoB7uOXDIC6po5YALnH9Xyrexq77wqt3OmFjkySpaETkfHQMbE/0u9qrL6rmsElZ
         MKm1Z+uG5ch+3aWVpK0NmwTFANS4RqUL5Y0PeJtWiNPivU0OBnIG8H8EGP3K/SFE5+PZ
         P3qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=/BT4DLkIgBGj1cjRUcjmIYFS1YR5uEvsTolKaiVQj0k=;
        b=IylC/aUQ8r/tlUrIzWCnAW5OF/gDOh+5VNhzX9BQoFKNVDAuS13oSspu1cj6e2DCp9
         /Kv1vkOVQ/WG5dTeThvzddT9A2zupS6ycVRjGi2NaPIeRNcpFh/HZQRJy2gySMEr743v
         AWsIF6YS88Eck21JUp1l0XDKDGLus1gLlM8Xr4hHXshDYGoGExXWvB1PjPFOrABATlqL
         ZXUO29LDEcsIsNwY5Ap2l+aGe7b1uEFinLAnjeVQG9vMzkW7iwtx1+OqVhlCE6AaQHQ/
         ly/vquqAZfRsu6OpM4KNIJEDLNz+sfy3GbLqcIcyTH8ZlGyNyFRePWJiZ5Rmy8+1vEC+
         PMAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m26si12169191pfi.247.2019.02.26.00.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 00:00:54 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q7wiwQ068312
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:00:54 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qw0xchwwd-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:00:53 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 08:00:51 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 08:00:46 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q80jG758523700
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 08:00:45 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 288A542057;
	Tue, 26 Feb 2019 08:00:45 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CB3094204B;
	Tue, 26 Feb 2019 08:00:43 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 08:00:43 +0000 (GMT)
Date: Tue, 26 Feb 2019 10:00:42 +0200
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
x-cbid: 19022608-0008-0000-0000-000002C4FC95
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022608-0009-0000-0000-000022314485
Message-Id: <20190226080041.GI5873@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=851 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260061
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

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

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
> 
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

