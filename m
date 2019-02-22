Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 282A8C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:13:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E232E20657
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:13:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E232E20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B17EF8E0110; Fri, 22 Feb 2019 10:13:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEC248E0109; Fri, 22 Feb 2019 10:13:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B6198E0110; Fri, 22 Feb 2019 10:13:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D71B8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:13:32 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k1so2343016qta.2
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:13:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=86GNuUi5MmL/QA1x+urEpcsAgX5gpfVoujKfw1+RC/Q=;
        b=T40yJUOzkJ1x+UYeoniGGFNuelCwc4ihdTqyrK47Fwus3o903oE02J54LFT7OqgJKT
         3E+ogzWfXAUK88eX/Mr37dmACdY+WH5bx7LSOKG1rhAPWCugfrYYkkwKffUC5cn8MZi7
         syiAoMJl65bk2NaOytWxmy4uO2mlT56bJNMyi28xDWg8wAXa7WTWQmw4vT5kwcm4zsW6
         Gy1AqoQAdkzgCFditZZZ2qUlnCA4B0GtHvJaDiAz6EgOUR0Z8HQLX3KMvQ1L9ZEd3eE7
         0grMfjez1cfR5LdfFomTpbsCCb9It4yjNm4gKcNeyTE6xPo0YLkeshVVaXFMbcnIiEqr
         P3bg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZVw1b/g08zXmgSNmYYCwJbteC/ZPLvHzN/MtOt7LMB6SATPYRk
	GY7T70d6+vZcI3M3XgvYNBMyRASQWICtbib+txRG6UNSpmvAiZn3SinwfiIkMB9nvQnKNIr5DzX
	JsIyXYrN9Qbj/vx4ScBKKcWj1dKbhv6EP8vFSVEALcJtF7xhuY6WrasxmbBbuEy/OGw==
X-Received: by 2002:a37:4d52:: with SMTP id a79mr3301578qkb.75.1550848412221;
        Fri, 22 Feb 2019 07:13:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ8Ger1Z90l7uQEqeeymCxvZ58NF3L+lNuaWk/52inveFQxTol7jTzHEyKi/WQaH0LBj8GJ
X-Received: by 2002:a37:4d52:: with SMTP id a79mr3301516qkb.75.1550848411368;
        Fri, 22 Feb 2019 07:13:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550848411; cv=none;
        d=google.com; s=arc-20160816;
        b=gyo5z5/nb5kQS8ttR8Cs9gOvRqYLiDcL37vCDYGFBI7M0YXcU/H3GWHGoX1fRUOx64
         SzYsOzeuu5y9KVSH48NiL/cmyThn+VUKEkGDTFzSgQHRdsDiR6im/u/UQTYm86ykVQCU
         OQRQu0fSDCIkw+/pB+3AkAve82ZCUWYNgpcmvTWUFk1W9TTX5MgrnX9XZ6pEVseHs/I1
         h6K8oNn885bT4eWaQ/Li1e75M2gW7nZGnh3a9WQ9SCRw/PjBIVl6qW/NR0Q2nuDgSW6I
         oFEyzUDrNaRe1q/VHoY0EVfFsYk4y3cFvD6IlgWNjTT1uibiPJjUPhv4/XDzalKRpnp8
         tWCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=86GNuUi5MmL/QA1x+urEpcsAgX5gpfVoujKfw1+RC/Q=;
        b=vHnA07pXwP3uBg6d9QyuSnFjl1p0UNQ5fzlchQ6ST+EwzSMV7QaxefdLU6Y2ukdyLd
         Sv6Adh0GnT4NbJvCi3JtWrydArI7oT3ZzIbw2OhVQmTYqhjBu+SJK245165mmHMgXo7a
         qXq6qmapnXPAS6tEkE4W5FyatfWNbluVuYp0px3rvNd5WvWpUVV+MOvgqL/Z5b2DyYcX
         SYM/mtm9u91Yviouy7pkUBdReIZzTgr/lZHN/05PrkaQtlzFteysBMsVPironsod/9lz
         xiGM/v9dx8EMvxEK7YcNNVDR9mB1hz0luTyzUDcQx8YbMZABfPoHz5vB/Yj19r2NXUtE
         jZWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 17si534677qvo.189.2019.02.22.07.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 07:13:31 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 427E43097088;
	Fri, 22 Feb 2019 15:13:30 +0000 (UTC)
Received: from redhat.com (ovpn-126-14.rdu2.redhat.com [10.10.126.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id F20E4600CD;
	Fri, 22 Feb 2019 15:13:23 +0000 (UTC)
Date: Fri, 22 Feb 2019 10:13:22 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 05/26] mm: gup: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190222151321.GB7783@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-6-peterx@redhat.com>
 <20190221160612.GE2813@redhat.com>
 <20190222044105.GE8904@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190222044105.GE8904@xz-x1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 22 Feb 2019 15:13:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 12:41:05PM +0800, Peter Xu wrote:
> On Thu, Feb 21, 2019 at 11:06:55AM -0500, Jerome Glisse wrote:
> > On Tue, Feb 12, 2019 at 10:56:11AM +0800, Peter Xu wrote:
> > > This is the gup counterpart of the change that allows the VM_FAULT_RETRY
> > > to happen for more than once.
> > > 
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > 
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> Thanks for the r-b, Jerome!
> 
> Though I plan to change this patch a bit because I just noticed that I
> didn't touch up the hugetlbfs path for GUP.  Though it was not needed
> for now because hugetlbfs is not yet supported but I think maybe I'd
> better do that as well in this same patch to make follow up works
> easier on hugetlb, and the patch will be more self contained.  The new
> version will simply squash below change into current patch:
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e3c738bde72e..a8eace2d5296 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4257,8 +4257,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>                                 fault_flags |= FAULT_FLAG_ALLOW_RETRY |
>                                         FAULT_FLAG_RETRY_NOWAIT;
>                         if (flags & FOLL_TRIED) {
> -                               VM_WARN_ON_ONCE(fault_flags &
> -                                               FAULT_FLAG_ALLOW_RETRY);
> +                               /*
> +                                * Note: FAULT_FLAG_ALLOW_RETRY and
> +                                * FAULT_FLAG_TRIED can co-exist
> +                                */
>                                 fault_flags |= FAULT_FLAG_TRIED;
>                         }
>                         ret = hugetlb_fault(mm, vma, vaddr, fault_flags);
> 
> I'd say this change is straightforward (it's the same as the
> faultin_page below but just for hugetlbfs).  Please let me know if you
> still want to offer the r-b with above change squashed (I'll be more
> than glad to take it!), or I'll just wait for your review comment when
> I post the next version.

Looks good i should have thought of hugetlbfs. You can keep my r-b.

Cheers,
Jérôme

