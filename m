Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 517CEC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:54:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 163CB21743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:54:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 163CB21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8E8C6B0003; Tue, 21 May 2019 11:54:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3F2D6B0007; Tue, 21 May 2019 11:54:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E0436B0008; Tue, 21 May 2019 11:54:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6804B6B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:54:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so12596426pff.11
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:54:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=BFGuCB8WBH/xC8Q9cnfwfv1qZ9DYFBwGfjhsemsdsSY=;
        b=qVXZdRyOi3OXetPx+zoRvAcwxlbbH/EYUbLlw+zHVfN9XLxf3NwV8NgImo2IzrAzHU
         TryImTAfE99dof1UBIUFXZRD7hGo2Nm+LBqVThVX1uOuZN0DZgYZkPsyUdgi/miV7Lz/
         pERBd/xq52ubYfzXVfeaX3wXZ6CdkIOsU0x2UK6mH8fnOMnMDD1u7zbl4ByygCik76y7
         UDga6juxe5jF8Z+Tv+q10a7HlLpBNoor1GXGTh+1cNvOclBUGDop+Q/hIo26oYC6mZhH
         L0+wYYMWnsKMHmrDhUUFvjWTiI3fQeuvZliK0/mySAubQZD1CWSLBVxaUXlLrxkMJTZj
         cOZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWswUrEIgvZbD66+/yDmKwacrzerQxJ+RMhzKm/CS6gtBuQHFsy
	7I4DNRZMHDXE8EcdeYgJR6JOx4RmZ0ezGwFMtCCbFpWOLJWeMPEX8H0BUvw4715NQGunpsFWkXi
	wRZSfBWI6pxonthpQet4uwyFB6NcJIc/JY/Qe+TewP0jWtOFc3555Xqhqm6ETihn0/g==
X-Received: by 2002:a65:6402:: with SMTP id a2mr38373398pgv.438.1558454043075;
        Tue, 21 May 2019 08:54:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbV5A3ZeCyTDDSrvTu4XG0nkdjPSWvon7cmQe4ElYOx8Xu3JGbAJMCguZu+8tLvcpIhViW
X-Received: by 2002:a65:6402:: with SMTP id a2mr38373324pgv.438.1558454042265;
        Tue, 21 May 2019 08:54:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558454042; cv=none;
        d=google.com; s=arc-20160816;
        b=LmIvVm3NyrmByvHcga7P8dKcMAXmS+/wVwZeKpFJahX/OUNf8Dk3V503LfCi5RAxQy
         yMxVD6UUCAUDw69Nrrs6Vcnrtcy7Wq+2V2bKvyC7C+NT+uKmu6ZMoBu5Z+grTdMQt24i
         SPe+1Hjd6ZsN2DcPbH1pVWC8PvNwXIOR63PA257MYPO+ii1JFoEMCqq7iJNSoO3wrByr
         nakqKictVDVpoSP1+fDtOUNvNw5WqoIBNR603Lh6uIGIEoxJiWqGywPXXl/tIvYTUVaa
         x7iEJV64Vu88Tr8YDZda1eRp9rO/n0+FoYjcvuMer5vgzkGXDEsErOzhzKf1/62VfEGZ
         VfWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=BFGuCB8WBH/xC8Q9cnfwfv1qZ9DYFBwGfjhsemsdsSY=;
        b=ONAi65bVJROt78Fz4s0eNcGrFPhQuJQUmFAYBNVH/Mrc45WmyxJwO7iMKN2Gdj91mz
         bD0DM2jK/LgNs9g7G0acAs8lSE0xmdhbNQ/hVwwKOM7OyyG4kq+iiC7YGH3qK9g7B/Xk
         Mmt7SXrAyT5lafjxMHG8rz2pE8RWi37ZsMdtLIOmUK2L91wX5Qi8Ve++OfBcVhwMIhaX
         AXBh7ALyhWW2oDJ5h+OUz0SQW7SmYFh9gJyW4D5YmmVF5JMB18Lrclj+amuVYYGbVbjk
         in4CH/ZzquCc7UZ1QQPPZCXhXiV0TjA+21cv/Qg9qTnXREVdRXVDJx1wp+mUyVaCl3xD
         xTMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q20si24925211pfn.139.2019.05.21.08.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 08:54:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4LFrBVt120243
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:54:01 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2smjqjcxra-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:54:01 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 21 May 2019 16:53:59 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 21 May 2019 16:53:57 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4LFruYp53215248
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 15:53:56 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 35A4B4C052;
	Tue, 21 May 2019 15:53:56 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AB98C4C046;
	Tue, 21 May 2019 15:53:55 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.239])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 21 May 2019 15:53:55 +0000 (GMT)
Date: Tue, 21 May 2019 18:53:53 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19052115-0028-0000-0000-0000037007DF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052115-0029-0000-0000-0000242FB2C1
Message-Id: <20190521155353.GC24470@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905210099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Any comments on this?

On Tue, May 14, 2019 at 05:29:55PM +0300, Mike Rapoport wrote:
> When get_user_pages*() is called with pages = NULL, the processing of
> VM_FAULT_RETRY terminates early without actually retrying to fault-in all
> the pages.
> 
> If the pages in the requested range belong to a VMA that has userfaultfd
> registered, handle_userfault() returns VM_FAULT_RETRY *after* user space
> has populated the page, but for the gup pre-fault case there's no actual
> retry and the caller will get no pages although they are present.
> 
> This issue was uncovered when running post-copy memory restore in CRIU
> after commit d9c9ce34ed5c ("x86/fpu: Fault-in user stack if
> copy_fpstate_to_sigframe() fails").
> 
> After this change, the copying of FPU state to the sigframe switched from
> copy_to_user() variants which caused a real page fault to get_user_pages()
> with pages parameter set to NULL.
> 
> In post-copy mode of CRIU, the destination memory is managed with
> userfaultfd and lack of the retry for pre-fault case in get_user_pages()
> causes a crash of the restored process.
> 
> Making the pre-fault behavior of get_user_pages() the same as the "normal"
> one fixes the issue.
> 
> Fixes: d9c9ce34ed5c ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  mm/gup.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 91819b8..c32ae5a 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -936,10 +936,6 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>  			BUG_ON(ret >= nr_pages);
>  		}
>  
> -		if (!pages)
> -			/* If it's a prefault don't insist harder */
> -			return ret;
> -
>  		if (ret > 0) {
>  			nr_pages -= ret;
>  			pages_done += ret;
> @@ -955,8 +951,12 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>  				pages_done = ret;
>  			break;
>  		}
> -		/* VM_FAULT_RETRY triggered, so seek to the faulting offset */
> -		pages += ret;
> +		/*
> +		 * VM_FAULT_RETRY triggered, so seek to the faulting offset.
> +		 * For the prefault case (!pages) we only update counts.
> +		 */
> +		if (likely(pages))
> +			pages += ret;
>  		start += ret << PAGE_SHIFT;
>  
>  		/*
> @@ -979,7 +979,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>  		pages_done++;
>  		if (!nr_pages)
>  			break;
> -		pages++;
> +		if (likely(pages))
> +			pages++;
>  		start += PAGE_SIZE;
>  	}
>  	if (lock_dropped && *locked) {
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

