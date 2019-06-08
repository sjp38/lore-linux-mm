Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0B16C28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:59:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70B10208C0
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:59:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oSTMOOMg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70B10208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EECD96B0279; Fri,  7 Jun 2019 23:59:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA4206B027A; Fri,  7 Jun 2019 23:59:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8BDF6B027B; Fri,  7 Jun 2019 23:59:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0DB06B0279
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 23:59:20 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id c4so2681495pgm.21
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 20:59:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=vtwv/19e9tggX3cqe5qv1DLU/M+NFvqtXR4KfTiH/nA=;
        b=ACSPpEuU23t5QXnyGwd+Xr9Ipt3hEYHZx6UWFxYprIvKaK16yPq5bu4+DakwNazbQ9
         pMz1jw4/mreIlHlj77DwUZpoeefLt28rY80fQ9+S1t36PWLe8Wsn1XAvtL+596CRUu0g
         adi14SpLw7ggq3L+Ec9XUgEKdr+dlIl0OtEY2CUohlZD+MmDD8uQ0BW+0FFpD5Ejx5EN
         7mDJgS8f0h7zqDlEY3fjabireBIceMPuhU90KZ0KgExwbOYE/N37SZjfccqe/Qd0kwnN
         Vxyb/BoZW2Ax5JD/HM4qGTIsSPAA2XtNCRJFzr1iOCwuvXjOsGEoMujjwLpEoTLAUufW
         KYaw==
X-Gm-Message-State: APjAAAXG6Brqb5gXbPsDCp78+9twb2elKj8TwOhcY27yIpi97zx61EUR
	9CkxGJdIo69TJsuzyUVr4p5mxC5gtWNUW1iFN/VaPKnzfiEdfX2+dBASqw5GCI7ZI1tDjiyyk90
	Dys23+H+tEdAAk4BcijWQpEyEG/unAChgEENI40foM/J/x2BIhDkVbKmVokVtR4WG5w==
X-Received: by 2002:a17:90a:a785:: with SMTP id f5mr9259438pjq.4.1559966360326;
        Fri, 07 Jun 2019 20:59:20 -0700 (PDT)
X-Received: by 2002:a17:90a:a785:: with SMTP id f5mr9259396pjq.4.1559966359489;
        Fri, 07 Jun 2019 20:59:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559966359; cv=none;
        d=google.com; s=arc-20160816;
        b=WHyKyvOBJdciN3AMQAGP+EU8jvUQTII63JDoDtFao7EHBCWXa7Ic/yBq5IZqBvyajd
         bzq4m5I6l1NUb2DQIbVhgL2J7NihOnEEdTfDPqB8VawUHd20RQlgpZSg/sW8PKeweRF3
         TXLAeGijbPeAgzvHlB460DrPJQGXxv9eGXmuXK6cEdL56Ez5fUUkrZRocfMtKRLsYg3b
         g6hUSwQCrzUnXtj+ADSIiu11RbrB490qmTeLrSk5FAWh3Y7QIKz40QD6rq1+YGtE1MTy
         4b8nvnZb3bpuBv6Vv856JQeQj7Xp7MITbh1cGuvOMQs58BmW05LJPDldll0v//4Klovu
         GgMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=vtwv/19e9tggX3cqe5qv1DLU/M+NFvqtXR4KfTiH/nA=;
        b=fkA3inCMHaSS5n1Ij1UWkjw2OtPy9me4dpc92+SLgy7a8JnlJ1eM8ZgXhdhRtGAvW9
         S9EkYsn88m9LJUU4f/fe5yq6EVGIC12fhzP4Zv+iu0bsnDAucgZHwyXrpuH1GNpQ7ws2
         s8PeB5QfnFLsjVczPi0BLxXAQJK7LZ+JQEfrmlCLuMGuwO7HJeEkTJLzKjWPmViguWsj
         ld5+X0ojaDoLr6dbESVZ/s3ORkDeokHHTLxn+Q0a5hI9ip5G42W+p7gt7m0nIGP4UDBE
         bdeotzkKGJv258ci8EX3l6LXMJLXV/l/pbleXsrtbwzk9WaH3YSfq7HkWhfmN6RgYsmy
         2XNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oSTMOOMg;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w5sor494111pgs.18.2019.06.07.20.59.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 20:59:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oSTMOOMg;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=vtwv/19e9tggX3cqe5qv1DLU/M+NFvqtXR4KfTiH/nA=;
        b=oSTMOOMgUDPwm9v3S0xQOC94eI7B+uLlRaPeDAiJhY7G5hwqhlqXib84eocSO4Or4Q
         s0x7m/OWbYvbr05AqgrpysSsialSnP2IO4KBRUcSw5nHDJJ9VT1JXgbFuODL+a03Z4CY
         fxnjowQ4yxOMJfuRyI+LlO2yB9we3efobS6TYwIsiOjfMo8b6WZBTJaU+YBh9SaZBOnG
         1j7mVIMwXLBa194ga11kGZm/58Txn50vJjPDmAixIt8kjjFoTSLMs5mEJ3EPCvSbcwcY
         fqcr4O0WM6f0WWVmK93XA17IO7PqzDpr6Ih0imbGmw18zRp/e/84OdJn/GrOWuqMl0mQ
         +Jgw==
X-Google-Smtp-Source: APXvYqxZrsK0trWabS8d1iMo9Gy4Z/Hbrd+thDvSnNr5c2e5ln1cnlGQovEnMMBxFtRUIXqBdvEDMw==
X-Received: by 2002:a63:e645:: with SMTP id p5mr5903986pgj.4.1559966358366;
        Fri, 07 Jun 2019 20:59:18 -0700 (PDT)
Received: from [100.112.83.253] ([104.133.9.109])
        by smtp.gmail.com with ESMTPSA id n2sm6068531pgp.27.2019.06.07.20.59.17
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Jun 2019 20:59:17 -0700 (PDT)
Date: Fri, 7 Jun 2019 20:58:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Yang Shi <yang.shi@linux.alibaba.com>
cc: mhocko@suse.com, vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name, 
    kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
In-Reply-To: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
Message-ID: <alpine.LSU.2.11.1906072008210.3614@eggly.anvils>
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Apr 2019, Yang Shi wrote:

> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
> vma") introduced THPeligible bit for processes' smaps. But, when checking
> the eligibility for shmem vma, __transparent_hugepage_enabled() is
> called to override the result from shmem_huge_enabled().  It may result
> in the anonymous vma's THP flag override shmem's.  For example, running a
> simple test which create THP for shmem, but with anonymous THP disabled,
> when reading the process's smaps, it may show:
> 
> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
> Size:               4096 kB
> ...
> [snip]
> ...
> ShmemPmdMapped:     4096 kB
> ...
> [snip]
> ...
> THPeligible:    0
> 
> And, /proc/meminfo does show THP allocated and PMD mapped too:
> 
> ShmemHugePages:     4096 kB
> ShmemPmdMapped:     4096 kB
> 
> This doesn't make too much sense.  The anonymous THP flag should not
> intervene shmem THP.  Calling shmem_huge_enabled() with checking
> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
> dax vma check since we already checked if the vma is shmem already.
> 
> Fixes: 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma")
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> v2: Check VM_NOHUGEPAGE per Michal Hocko
> 
>  mm/huge_memory.c | 4 ++--
>  mm/shmem.c       | 3 +++
>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 165ea46..5881e82 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -67,8 +67,8 @@ bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>  {
>  	if (vma_is_anonymous(vma))
>  		return __transparent_hugepage_enabled(vma);
> -	if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
> -		return __transparent_hugepage_enabled(vma);
> +	if (vma_is_shmem(vma))
> +		return shmem_huge_enabled(vma);
>  
>  	return false;
>  }
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 2275a0f..6f09a31 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -3873,6 +3873,9 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>  	loff_t i_size;
>  	pgoff_t off;
>  
> +	if ((vma->vm_flags & VM_NOHUGEPAGE) ||
> +	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
> +		return false;

Yes, that is correct; and correctly placed. But a little more is needed:
see how mm/memory.c's transhuge_vma_suitable() will only allow a pmd to
be used instead of a pte if the vma offset and size permit. smaps should
not report a shmem vma as THPeligible if its offset or size prevent it.

And I see that should also be fixed on anon vmas: at present smaps
reports even a 4kB anon vma as THPeligible, which is not right.
Maybe a test like transhuge_vma_suitable() can be added into
transparent_hugepage_enabled(), to handle anon and shmem together.
I say "like transhuge_vma_suitable()", because that function needs
an address, which here you don't have.

The anon offset situation is interesting: usually anon vm_pgoff is
initialized to fit with its vm_start, so the anon offset check passes;
but I wonder what happens after mremap to a different address - does
transhuge_vma_suitable() then prevent the use of pmds where they could
actually be used? Not a Number#1 priority to investigate or fix here!
but a curiosity someone might want to look into.

>  	if (shmem_huge == SHMEM_HUGE_FORCE)
>  		return true;
>  	if (shmem_huge == SHMEM_HUGE_DENY)
> -- 
> 1.8.3.1


Even with your changes
ShmemPmdMapped:     4096 kB
THPeligible:    0
will easily be seen: THPeligible reflects whether a huge page can be
allocated and mapped by pmd in that vma; but if something else already
allocated the huge page earlier, it will be mapped by pmd in this vma
if offset and size allow, whatever THPeligible says. We could change
transhuge_vma_suitable() to force ptes in that case, but it would be
a silly change, just to make what smaps shows easier to explain.

Hugh

