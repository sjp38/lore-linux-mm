Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D163C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 04:41:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB93E2086A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 04:41:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB93E2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 796428E00EC; Thu, 21 Feb 2019 23:41:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 745808E00EB; Thu, 21 Feb 2019 23:41:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 634A78E00EC; Thu, 21 Feb 2019 23:41:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36E0B8E00EB
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 23:41:24 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so1071935qte.10
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 20:41:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=A6oIXHz//kYOZuJmbHpBjorBwR5DrWlG/N0u8kGWRzQ=;
        b=e0pHXSdBXt2l/UkjRvlVFjKGvMfp29UHFWAUTUFzo3Xm9NmJJZq0X5ZTf0nvXIUM0N
         ZYY29G7V4SjHU6cDg3T7cYxAOTLuwYl5djXvbVvvShgrqNzWfG5qirncmlSBZU+xzJhH
         9hVskN2E2gXebI45XyH5YF3gVpr8iOnem2XaBTcCapHtN0oD78Z8cuC5zbXx2iPIO+XF
         0imHMyoWp6oyVOpH7BPu6ShuEQbKGL0xZ8qHc7W/+EDqzhIdLzSQcUF5OMlezlcNvdjt
         Xaiig0o4rzr+GtA/5gWrVVly8JFx+JhLmO4gaBGhjARIB/Xq++gmx/ZX1PnSqOfgJoZL
         QwaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaHBsXZ6dzuW0EOr9lzeiIohfkVMCophv+94zfafg856xvxOzuw
	fZegfPgroOMQRorNY2qoAH9xb5ZeBELwH58DqslLYY60Mh0hvqYiNPNsklT1ot8oqT2QewXLX/V
	aaAcz7ToofRDGNN8zEiQkCf9d7m8GHbuSJeOk7wyhPb0Y5RVkNtdUJHmQ4L0bX5dayA==
X-Received: by 2002:aed:3ef9:: with SMTP id o54mr1607439qtf.149.1550810483992;
        Thu, 21 Feb 2019 20:41:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib8O55+iDO2eysDRqvrGivGGk6i7XKCyJ1kz05KCUB8+WU9yLUtnBlFBc6KQuW2kZGm4uQk
X-Received: by 2002:aed:3ef9:: with SMTP id o54mr1607370qtf.149.1550810482409;
        Thu, 21 Feb 2019 20:41:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550810482; cv=none;
        d=google.com; s=arc-20160816;
        b=cwQJwl9pSykQdMlMeTxDCjaUOzazdNlqxPvqAEQ6eCT0JtXeb7kp6Qmnwneyz70eAW
         sIEKcZnvUj7+hzjc8EeBWzb636FVC6VOB2Y5V3qr7s1F+118Xonv3CntvA6mtZXPAw9l
         1pd1v0XBkgu/W/Ckxjrv7bhhYDjORHy6PWt7IC+pcyaCok6MIKOw21BdAtte5nEbXXOM
         MZNvv+gkLzU/jXAdBz5lwcGI9iLikPN+oiseM/2JOFj1V/HN8Jzb0WKjB1DeEnokhUxq
         yLqinfVWQT1X+Icf7KkLdmMGnG1Mx1qJ+1yxl0DpSlP99vzYdrwNzsiKj+7+3OlkL9HB
         9HaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=A6oIXHz//kYOZuJmbHpBjorBwR5DrWlG/N0u8kGWRzQ=;
        b=blSooIfrav5sJfCAoKkAfGgPeTIZxybyPzxx0dl0aXeTJdvmhatcXAOg9RxwSuggwK
         KWTLZ2zmBvF5aNbzj6yBNsGQuIYXHbxoorLx9OpZBbQSJwnjHHzZ0hOM/AV/giZHFVTh
         VQTiwWI1eCP0HaFKhKhdAm6txcsuIMc7TiMX59h06PpR6Mjzr+pMjEScNOQe1Z0QmPDv
         Yr2Zq0X8qf2WDkKQe+71RnKUqmiBfFL53ELb2q2LUFpCKOQyXR3finds3W/AmsHqq0V8
         CY7jxOAneg2uyMT0r3gXuhz+X+UgSRtec2Sw0r4nfASl5ya0n4v4JPzdq2GgfY1nmrAb
         anuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f36si263667qtk.149.2019.02.21.20.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 20:41:22 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 40FDD81F11;
	Fri, 22 Feb 2019 04:41:21 +0000 (UTC)
Received: from xz-x1 (ovpn-12-57.pek2.redhat.com [10.72.12.57])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4704567676;
	Fri, 22 Feb 2019 04:41:10 +0000 (UTC)
Date: Fri, 22 Feb 2019 12:41:05 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
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
Message-ID: <20190222044105.GE8904@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-6-peterx@redhat.com>
 <20190221160612.GE2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221160612.GE2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 22 Feb 2019 04:41:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 11:06:55AM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:11AM +0800, Peter Xu wrote:
> > This is the gup counterpart of the change that allows the VM_FAULT_RETRY
> > to happen for more than once.
> > 
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Thanks for the r-b, Jerome!

Though I plan to change this patch a bit because I just noticed that I
didn't touch up the hugetlbfs path for GUP.  Though it was not needed
for now because hugetlbfs is not yet supported but I think maybe I'd
better do that as well in this same patch to make follow up works
easier on hugetlb, and the patch will be more self contained.  The new
version will simply squash below change into current patch:

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e3c738bde72e..a8eace2d5296 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4257,8 +4257,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
                                fault_flags |= FAULT_FLAG_ALLOW_RETRY |
                                        FAULT_FLAG_RETRY_NOWAIT;
                        if (flags & FOLL_TRIED) {
-                               VM_WARN_ON_ONCE(fault_flags &
-                                               FAULT_FLAG_ALLOW_RETRY);
+                               /*
+                                * Note: FAULT_FLAG_ALLOW_RETRY and
+                                * FAULT_FLAG_TRIED can co-exist
+                                */
                                fault_flags |= FAULT_FLAG_TRIED;
                        }
                        ret = hugetlb_fault(mm, vma, vaddr, fault_flags);

I'd say this change is straightforward (it's the same as the
faultin_page below but just for hugetlbfs).  Please let me know if you
still want to offer the r-b with above change squashed (I'll be more
than glad to take it!), or I'll just wait for your review comment when
I post the next version.

Thanks,

> 
> > ---
> >  mm/gup.c | 17 +++++++++++++----
> >  1 file changed, 13 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/gup.c b/mm/gup.c
> > index fa75a03204c1..ba387aec0d80 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -528,7 +528,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
> >  	if (*flags & FOLL_NOWAIT)
> >  		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
> >  	if (*flags & FOLL_TRIED) {
> > -		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
> > +		/*
> > +		 * Note: FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED
> > +		 * can co-exist
> > +		 */
> >  		fault_flags |= FAULT_FLAG_TRIED;
> >  	}
> >  
> > @@ -943,17 +946,23 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
> >  		/* VM_FAULT_RETRY triggered, so seek to the faulting offset */
> >  		pages += ret;
> >  		start += ret << PAGE_SHIFT;
> > +		lock_dropped = true;
> >  
> > +retry:
> >  		/*
> >  		 * Repeat on the address that fired VM_FAULT_RETRY
> > -		 * without FAULT_FLAG_ALLOW_RETRY but with
> > +		 * with both FAULT_FLAG_ALLOW_RETRY and
> >  		 * FAULT_FLAG_TRIED.
> >  		 */
> >  		*locked = 1;
> > -		lock_dropped = true;
> >  		down_read(&mm->mmap_sem);
> >  		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
> > -				       pages, NULL, NULL);
> > +				       pages, NULL, locked);
> > +		if (!*locked) {
> > +			/* Continue to retry until we succeeded */
> > +			BUG_ON(ret != 0);
> > +			goto retry;
> > +		}
> >  		if (ret != 1) {
> >  			BUG_ON(ret > 1);
> >  			if (!pages_done)
> > -- 
> > 2.17.1
> > 

-- 
Peter Xu

