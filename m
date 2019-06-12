Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 951C7C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:45:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32165206E0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:45:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HGFLTVZM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32165206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C61C56B0010; Wed, 12 Jun 2019 14:45:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEBAB6B0266; Wed, 12 Jun 2019 14:45:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8C476B0269; Wed, 12 Jun 2019 14:45:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC5E6B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:45:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 5so12612622pff.11
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:45:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=omuFOa2tFDyvD/Kk+1R1oTq5IbQwKSGOjinwhbTkIxM=;
        b=i1SWYl1duOZ9ZnIb5OUJYj2BIcMHpkGX2L8BOf6QUqPS7Rg7FzaYGFyBHnd6kNP1PH
         AXg9/asytBjrO8pDV8jgdezi7tF9W00QS3nSjj0F+qXIF5d6zSvQymJAcCUYklQL+Xu4
         wGNlcJ2jTcE/ZNmCKI1ng32DuodV4eEEmqRZCrNmFpIZVXfmeTtdDNs5o3NOqTR15SIw
         zbW+goeGjSw03kk2ifWmCrmqpOPEXYdGdaGs/ix55Ascs8tRSM+ba5qwC9Zl+2z6zOyv
         F5GOyorRSAIwVJdCldlunlw5eNlrUPrbTQgIMltctQ0f+BBGCse33EsVPTWjXjTeVKXp
         gL5Q==
X-Gm-Message-State: APjAAAWScnklcKTuWP42R207nvtZrEL7lMutXU494dOQo/H70FWTr2fo
	EjjW37KrXOU4qhBi9wQ8tB6oqFUlYDni/Ue9/kZBJe8WQT+wFpTltjsI6nIgijodJtRdoDN3sBU
	aqrqxysKN5tUx2UHr00dz60T1u9DvF210V3Bp+NAPlCedY1nTIm5EDJvuEV61qTiWUg==
X-Received: by 2002:a65:64d6:: with SMTP id t22mr23442257pgv.406.1560365114910;
        Wed, 12 Jun 2019 11:45:14 -0700 (PDT)
X-Received: by 2002:a65:64d6:: with SMTP id t22mr23442203pgv.406.1560365114059;
        Wed, 12 Jun 2019 11:45:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560365114; cv=none;
        d=google.com; s=arc-20160816;
        b=FYK7CMmsLJh9Us6xEZeHRAOendtTdcyCd5JTI12mcyt5+iJWO3A4NrQzCB8UhhjEFO
         A8kYGQQBczLTZjECOGWfDF/g3fs5oImLAF47WytGvkcLHB0rfZdCAsOataULTW/mNeBL
         S9Cy6bhpio4Lza8cb23sFWTURWNo7+HbgU01T5lwA6v4FIAMaZaWoHYk+T2YvrGfEtaJ
         xOlFyhgvosmDK7dWxlJWlrHWyHfWaI+l3EvjvvlkGTRnQCPVUZZVQX6kVTO9SOuekDf5
         FBGxpvzLNhP6Y0LyyWWI4aCr9K14QbXOMV9oQEdp+Q9TxnqFjT831gDxK9+bMgOi39qh
         Mt0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=omuFOa2tFDyvD/Kk+1R1oTq5IbQwKSGOjinwhbTkIxM=;
        b=okaqvImpFzjI1Ov5lXoXJRw/TcKOI8xrnDDv6yb23k3IJGMKZYt+gcwMnjAQBbwNFi
         5uPAD6LQS7jQ+PI/VowONqFWG4zWSG24nrlOdU2w+5IBrqfZMmkP7XEWJpolbZrq4Q3R
         BfiLMhdtz/xpwPLQIYTAIokedobn0ZpFQmzIyPgYuY5LxfdengrCrZ111jj3GX7PNKI/
         /yTwzd//lpDVQt4Fjru9N42fiDGks73bGbt19tSKrETIH+cjqnD38F6a3c+AQMkFHuk/
         agJ0/2dUatCVkCmZGR6Wv+KvFbM9w5mHziLYVaMx6ay+ASgmtBVCJwa5BwQfSlgg1jFR
         YLeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HGFLTVZM;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e4sor428943plk.30.2019.06.12.11.45.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 11:45:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HGFLTVZM;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=omuFOa2tFDyvD/Kk+1R1oTq5IbQwKSGOjinwhbTkIxM=;
        b=HGFLTVZMj2Fv4UYi1jfmmbPBoEzDA/UVQezc0W2Bcd79cW34Pu3BbuwYPOupjYvbEX
         LQKbdb6JrU5QfS09J2UwNKfMNPLzrfuYbKSyO+k6eVh+g8iRlLN8h8u2rU8Bx10TybEp
         cBsQA/Zx7CsMDNXEKahpWcbwFw+loKIOFKzKllQm7pEYL3oZCciuOO4Rx27sbQ1tFpZD
         TtcGl78VF8GJasVUbYYq0ndgFWWSUba1B8hXNee4GB/ZFYgj3GEF6zd2eVqn9RK3IcAW
         NCiQWQgmVccoDuLas/dTLv5nhBA6sLMm9VIJs9erexVXlrnRIpo6NK4oPZvf90rYZOn6
         xWyw==
X-Google-Smtp-Source: APXvYqyIHxzrp9wTkBh/Z0Wezdft3T2dBv3Ff7o00sYtjg56R9Q392wcAQJKkhAxczOYIvNrKXebGA==
X-Received: by 2002:a17:902:e011:: with SMTP id ca17mr15951482plb.328.1560365112972;
        Wed, 12 Jun 2019 11:45:12 -0700 (PDT)
Received: from [100.112.83.253] ([104.133.9.109])
        by smtp.gmail.com with ESMTPSA id m96sm210388pjb.1.2019.06.12.11.45.11
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Jun 2019 11:45:12 -0700 (PDT)
Date: Wed, 12 Jun 2019 11:44:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Yang Shi <yang.shi@linux.alibaba.com>
cc: Hugh Dickins <hughd@google.com>, mhocko@suse.com, vbabka@suse.cz, 
    rientjes@google.com, kirill@shutemov.name, kirill.shutemov@linux.intel.com, 
    akpm@linux-foundation.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
In-Reply-To: <578b7903-40ef-e616-d700-473713f438c0@linux.alibaba.com>
Message-ID: <alpine.LSU.2.11.1906121120240.1107@eggly.anvils>
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com> <alpine.LSU.2.11.1906072008210.3614@eggly.anvils> <578b7903-40ef-e616-d700-473713f438c0@linux.alibaba.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Jun 2019, Yang Shi wrote:
> On 6/7/19 8:58 PM, Hugh Dickins wrote:
> > Yes, that is correct; and correctly placed. But a little more is needed:
> > see how mm/memory.c's transhuge_vma_suitable() will only allow a pmd to
> > be used instead of a pte if the vma offset and size permit. smaps should
> > not report a shmem vma as THPeligible if its offset or size prevent it.
> > 
> > And I see that should also be fixed on anon vmas: at present smaps
> > reports even a 4kB anon vma as THPeligible, which is not right.
> > Maybe a test like transhuge_vma_suitable() can be added into
> > transparent_hugepage_enabled(), to handle anon and shmem together.
> > I say "like transhuge_vma_suitable()", because that function needs
> > an address, which here you don't have.
> 
> Thanks for the remind. Since we don't have an address I'm supposed we just
> need check if the vma's size is big enough or not other than other alignment
> check.
> 
> And, I'm wondering whether we could reuse transhuge_vma_suitable() by passing
> in an impossible address, i.e. -1 since it is not a valid userspace address.
> It can be used as and indicator that this call is from THPeligible context.

Perhaps, but sounds like it will abuse and uglify transhuge_vma_suitable()
just for smaps. Would passing transhuge_vma_suitable() the address
    ((vma->vm_end & HPAGE_PMD_MASK) - HPAGE_PMD_SIZE)
give the the correct answer in all cases?

> > 
> > The anon offset situation is interesting: usually anon vm_pgoff is
> > initialized to fit with its vm_start, so the anon offset check passes;
> > but I wonder what happens after mremap to a different address - does
> > transhuge_vma_suitable() then prevent the use of pmds where they could
> > actually be used? Not a Number#1 priority to investigate or fix here!
> > but a curiosity someone might want to look into.
> 
> Will mark on my TODO list.
> 
> > Even with your changes
> > ShmemPmdMapped:     4096 kB
> > THPeligible:    0
> > will easily be seen: THPeligible reflects whether a huge page can be
> > allocated and mapped by pmd in that vma; but if something else already
> > allocated the huge page earlier, it will be mapped by pmd in this vma
> > if offset and size allow, whatever THPeligible says. We could change
> > transhuge_vma_suitable() to force ptes in that case, but it would be
> > a silly change, just to make what smaps shows easier to explain.
> 
> Where did this come from? From the commit log? If so it is the example for
> the wrong smap output. If that case really happens, I think we could document
> it since THPeligible should just show the current status.

Please read again what I explained there: it's not necessarily an example
of wrong smaps output, it's reasonable smaps output for a reasonable case.

Yes, maybe Documentation/filesystems/proc.txt should explain "THPeligble"
a little better - "eligible for allocating THP pages" rather than just
"eligible for THP pages" would be good enough? we don't want to write
a book about the various cases.

Oh, and the "THPeligible" output lines up very nicely there in proc.txt:
could the actual alignment of that 0 or 1 be fixed in smaps itself too?

Thanks,
Hugh

