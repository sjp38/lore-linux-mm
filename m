Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 733D7C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:53:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1088B20823
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 15:53:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1088B20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B5898E0091; Thu, 21 Feb 2019 10:53:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78BDF8E0090; Thu, 21 Feb 2019 10:53:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67AA78E0091; Thu, 21 Feb 2019 10:53:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39E958E0090
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:53:23 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id s8so12467181qth.18
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 07:53:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KGg01+77dFjkHGjygdICs4qYzeYjC3++DNTD3glUI7Y=;
        b=lQJlmEmAzQX3rpWoQnAndJh5taQ1KS9GKWrsAZEhyvrbtcnpk9hvWjS5hqXnxmoKWA
         2BeXj6xXNF14G5kgXh+ZQ3HMCeJyf/Kj0pVLCvs6JBl3ge5228WSqtCRNM43VFPesTfH
         82VUmKXOl5IPQBMipOXHkm7XddysjlATxUbDSmysG+jU9Oi7PolgacSB1H5CVFVoBKum
         yvKaS6iAQY/WtCH/dikI065ISN1Y41aJUzsOqkhKCndjEMIs9XI/H5LQBMpRVLyRLHpb
         RRitgDiJf16idS1XVwdFPfRUQL5hMoDXHyPmxrIE/TdxfRLLOWisz+JuLvcd6dg2bpWq
         Tb1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua3Lqij9BE6GQrWGAjLwHDmigHBkaN49kOHdPqufcXo6lkoNnQ9
	TY2Pxg+Wvln11uAIa286kJ44o3ArWcoh1bt+iViXTvfWxjbQ7Q6v5f6117jgC41Ctpl2pRZ9v6t
	LuqUEgqB7kDTCh1OlHkxfkQ62DMa0u1OUm5TlqcD9V74OIO2wFZn3BwcP+Y7uPk2e9g==
X-Received: by 2002:a37:457:: with SMTP id 84mr28594682qke.303.1550764402316;
        Thu, 21 Feb 2019 07:53:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib434yD14AxSgjfiGnitGd1HtjO53jPqlY9fKypE17EE3y0YibztzfX+5sSRiueOiRt/FUh
X-Received: by 2002:a37:457:: with SMTP id 84mr28594631qke.303.1550764401286;
        Thu, 21 Feb 2019 07:53:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550764401; cv=none;
        d=google.com; s=arc-20160816;
        b=tg9CQeCnTTuPIyEPGd1/GmHysKspdqXWGtZWwPhcWO1SdBJIflRf50TQjnyA+x9G32
         dNfhSVkp0tZarWKEesJnnhpK1jdmKPoEUJtnoCu1QzLZEDY6xxgXlzkBfB552eJToPNj
         lS9g7DMW/RjwAtE0830ceiCf1b16wlPO5bF1Fi1v51qQPdSGNhBlaHmS55LeiQfVwzd6
         R7Zc5W4fJrGcF4jbZsoWohMKsKdYKwVF7NWWek/HfeXflBPOiPOZdLkltV3B8R9Ul71A
         r5ZsO04funhzpfE3vKcyVrWcIk42xOJpO74v5JIxUCOUUCR7JVG0H1+8vp3KhBP1H52w
         +/yQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KGg01+77dFjkHGjygdICs4qYzeYjC3++DNTD3glUI7Y=;
        b=c2e1e+ZK9nCl9CsQ+DL086eqZRzl3RFuAMmZ2St8Er4AzfDCQJwoEsSDxqepbAoPKm
         PHHPX8oT45xaV6aJ/loduom0WrzL7POw7+6scV/CJ0mrumKVzd5m4np7zqYomHzz978r
         X6juJjLuIk0EhO5uu8lo0blNxtMJWpwGS8HUI4OywTosf955T7miQbxecP8uOOsILuK7
         LEYjqZIijH9jc80OpSQO/9iPzc8+szfr3lCaiVHBEoOWDGepB/4ujeYmnQllcQozs5BU
         BWj9Q2ehcWwBhk/YUSzmJF+eL5a3bpk5cmN5QiY7jyow7hnsdOAblHShReNzdRbv5ZZv
         R+lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v50si1167451qtv.316.2019.02.21.07.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 07:53:21 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A8BEE3084298;
	Thu, 21 Feb 2019 15:53:19 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6EEF9226FF;
	Thu, 21 Feb 2019 15:53:13 +0000 (UTC)
Date: Thu, 21 Feb 2019 10:53:11 -0500
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
Subject: Re: [PATCH v2.1 04/26] mm: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190221155311.GD2813@redhat.com>
References: <20190212025632.28946-5-peterx@redhat.com>
 <20190221085656.18529-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221085656.18529-1-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Thu, 21 Feb 2019 15:53:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 04:56:56PM +0800, Peter Xu wrote:
> The idea comes from a discussion between Linus and Andrea [1].
> 
> Before this patch we only allow a page fault to retry once.  We
> achieved this by clearing the FAULT_FLAG_ALLOW_RETRY flag when doing
> handle_mm_fault() the second time.  This was majorly used to avoid
> unexpected starvation of the system by looping over forever to handle
> the page fault on a single page.  However that should hardly happen,
> and after all for each code path to return a VM_FAULT_RETRY we'll
> first wait for a condition (during which time we should possibly yield
> the cpu) to happen before VM_FAULT_RETRY is really returned.
> 
> This patch removes the restriction by keeping the
> FAULT_FLAG_ALLOW_RETRY flag when we receive VM_FAULT_RETRY.  It means
> that the page fault handler now can retry the page fault for multiple
> times if necessary without the need to generate another page fault
> event.  Meanwhile we still keep the FAULT_FLAG_TRIED flag so page
> fault handler can still identify whether a page fault is the first
> attempt or not.
> 
> Then we'll have these combinations of fault flags (only considering
> ALLOW_RETRY flag and TRIED flag):
> 
>   - ALLOW_RETRY and !TRIED:  this means the page fault allows to
>                              retry, and this is the first try
> 
>   - ALLOW_RETRY and TRIED:   this means the page fault allows to
>                              retry, and this is not the first try
> 
>   - !ALLOW_RETRY and !TRIED: this means the page fault does not allow
>                              to retry at all
> 
>   - !ALLOW_RETRY and TRIED:  this is forbidden and should never be used
> 
> In existing code we have multiple places that has taken special care
> of the first condition above by checking against (fault_flags &
> FAULT_FLAG_ALLOW_RETRY).  This patch introduces a simple helper to
> detect the first retry of a page fault by checking against
> both (fault_flags & FAULT_FLAG_ALLOW_RETRY) and !(fault_flag &
> FAULT_FLAG_TRIED) because now even the 2nd try will have the
> ALLOW_RETRY set, then use that helper in all existing special paths.
> One example is in __lock_page_or_retry(), now we'll drop the mmap_sem
> only in the first attempt of page fault and we'll keep it in follow up
> retries, so old locking behavior will be retained.
> 
> This will be a nice enhancement for current code [2] at the same time
> a supporting material for the future userfaultfd-writeprotect work,
> since in that work there will always be an explicit userfault
> writeprotect retry for protected pages, and if that cannot resolve the
> page fault (e.g., when userfaultfd-writeprotect is used in conjunction
> with swapped pages) then we'll possibly need a 3rd retry of the page
> fault.  It might also benefit other potential users who will have
> similar requirement like userfault write-protection.
> 
> GUP code is not touched yet and will be covered in follow up patch.
> 
> Please read the thread below for more information.
> 
> [1] https://lkml.org/lkml/2017/11/2/833
> [2] https://lkml.org/lkml/2018/12/30/64

I have few comments on this one. See below.


> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
> 
>  arch/alpha/mm/fault.c           |  2 +-
>  arch/arc/mm/fault.c             |  1 -
>  arch/arm/mm/fault.c             |  3 ---
>  arch/arm64/mm/fault.c           |  5 -----
>  arch/hexagon/mm/vm_fault.c      |  1 -
>  arch/ia64/mm/fault.c            |  1 -
>  arch/m68k/mm/fault.c            |  3 ---
>  arch/microblaze/mm/fault.c      |  1 -
>  arch/mips/mm/fault.c            |  1 -
>  arch/nds32/mm/fault.c           |  1 -
>  arch/nios2/mm/fault.c           |  3 ---
>  arch/openrisc/mm/fault.c        |  1 -
>  arch/parisc/mm/fault.c          |  2 --
>  arch/powerpc/mm/fault.c         |  6 ------
>  arch/riscv/mm/fault.c           |  5 -----
>  arch/s390/mm/fault.c            |  5 +----
>  arch/sh/mm/fault.c              |  1 -
>  arch/sparc/mm/fault_32.c        |  1 -
>  arch/sparc/mm/fault_64.c        |  1 -
>  arch/um/kernel/trap.c           |  1 -
>  arch/unicore32/mm/fault.c       |  6 +-----
>  arch/x86/mm/fault.c             |  2 --
>  arch/xtensa/mm/fault.c          |  1 -
>  drivers/gpu/drm/ttm/ttm_bo_vm.c | 12 +++++++++---
>  include/linux/mm.h              | 12 +++++++++++-
>  mm/filemap.c                    |  2 +-
>  mm/shmem.c                      |  2 +-
>  27 files changed, 25 insertions(+), 57 deletions(-)
> 

[...]

> diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
> index 29422eec329d..7d3e96a9a7ab 100644
> --- a/arch/parisc/mm/fault.c
> +++ b/arch/parisc/mm/fault.c
> @@ -327,8 +327,6 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
>  		else
>  			current->min_flt++;
>  		if (fault & VM_FAULT_RETRY) {
> -			flags &= ~FAULT_FLAG_ALLOW_RETRY;

Don't you need to also add:
     flags |= FAULT_FLAG_TRIED;

Like other arch.


[...]

> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 248ff0a28ecd..d842c3e02a50 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1483,9 +1483,7 @@ void do_user_addr_fault(struct pt_regs *regs,
>  	if (unlikely(fault & VM_FAULT_RETRY)) {
>  		bool is_user = flags & FAULT_FLAG_USER;
>  
> -		/* Retry at most once */
>  		if (flags & FAULT_FLAG_ALLOW_RETRY) {
> -			flags &= ~FAULT_FLAG_ALLOW_RETRY;
>  			flags |= FAULT_FLAG_TRIED;
>  			if (is_user && signal_pending(tsk))
>  				return;

So here you have a change in behavior, it can retry indefinitly for as
long as they are no signal. Don't you want so test for FAULT_FLAG_TRIED ?

[...]

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb6408fe73..4e11c9639f1b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -341,11 +341,21 @@ extern pgprot_t protection_map[16];
>  #define FAULT_FLAG_ALLOW_RETRY	0x04	/* Retry fault if blocking */
>  #define FAULT_FLAG_RETRY_NOWAIT	0x08	/* Don't drop mmap_sem and wait when retrying */
>  #define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
> -#define FAULT_FLAG_TRIED	0x20	/* Second try */
> +#define FAULT_FLAG_TRIED	0x20	/* We've tried once */
>  #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
>  #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>  #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
>  
> +/*
> + * Returns true if the page fault allows retry and this is the first
> + * attempt of the fault handling; false otherwise.
> + */

You should add why it returns false if it is not the first try ie to
avoid starvation.

> +static inline bool fault_flag_allow_retry_first(unsigned int flags)
> +{
> +	return (flags & FAULT_FLAG_ALLOW_RETRY) &&
> +	    (!(flags & FAULT_FLAG_TRIED));
> +}
> +
>  #define FAULT_FLAG_TRACE \
>  	{ FAULT_FLAG_WRITE,		"WRITE" }, \
>  	{ FAULT_FLAG_MKWRITE,		"MKWRITE" }, \

[...]

