Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F78EC76194
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:09:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30A1F22AEC
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:09:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30A1F22AEC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F248C8E0005; Wed, 24 Jul 2019 10:09:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED5738E0002; Wed, 24 Jul 2019 10:09:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9E4B8E0005; Wed, 24 Jul 2019 10:09:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BACC8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:09:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so30305478ede.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:09:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3hNIS604cIlpNb5X0dW+yA2d1B9YTWRXVYiOJCJvT2I=;
        b=tdLyg0cuE1q3qufTKacEvPg0c9SrZCIsoIl+SpWXBqihauEj0Ty30k4rCPIdutzBQO
         PQzAOiv/wS5VdyMivFv9sIGH2T9EffIg0ezbGt2qMqSC7rz9+5o+lYs9jsBENFwa6JYs
         6ly70zWHUh31fnwJYYmTSU7fTX6NTr3fuwj/U63+reqUQ8ECZQOpJb6An6COB4csX0wH
         4GzpJNl1rSja9Vx4az52r8gPZvJlD25gkIQs9zkVFavdDSczvBLPHZHvrv9mzoG18S6j
         sW89Th2a6gkiDpIw0I27OjELu+d1HvXiMUzLOQQIXL4iPmCcjQPbofm/An8AvVIWlnv2
         SzFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWCejxmRCG6VUUdYA7W+xQx94Qem9D554s9nuDOg2qLVpLKWW8q
	roXc4tXG34MvUgN7ytfw/lx6khN0usQbCH/wUp2A66kh0ECAs3znE53BAJQb3pN9pGBVIgDfvXF
	ZUKmYKQTdpoLWEtHTinxRpTKMqQxlnpOCi/WAXmEBl+vrZZO1nyTqWjaUrww0Eahvig==
X-Received: by 2002:a17:906:4911:: with SMTP id b17mr61406520ejq.158.1563977354967;
        Wed, 24 Jul 2019 07:09:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyszcfJeTkpxpWn5xk2ozsU/QAYwfSKC/GrfXi4b5Y6FVBHXW4q4WBxZvpSMdEAEoLLjcLM
X-Received: by 2002:a17:906:4911:: with SMTP id b17mr61406457ejq.158.1563977354258;
        Wed, 24 Jul 2019 07:09:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563977354; cv=none;
        d=google.com; s=arc-20160816;
        b=zXlkYruWRy2j14ypJRg0bQlCJx8/LVQV3TN3QAB+d3qazB9SU7yywuFSmrhxWqI2d/
         Vzt0iwWcMd7aQARiJ+tBpCU7YaMfRAISWe540gLEtBw/B7YEmXXwPmKSG42qEvvdbQ55
         OH/jTo8qtwYQr9MHj8QPh7oPZ4sD8yMZs92ryH7JbTZPiwSZAN4kWHJ8FxsB7N808scX
         2zVQT6VXXpq9wcUQTuhRj9qtN8jhSIsogL3dMtDcpvcFLol3HFQ/mmOsX+d0fnJ6L2Lp
         AgzbaeAgm6kjA1Q01s0FPr7odLXd+IK6Ekj13/peqgljCpYdeLI2yeBd17dlagj27eaY
         302g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3hNIS604cIlpNb5X0dW+yA2d1B9YTWRXVYiOJCJvT2I=;
        b=KpH0cE7LkH9QGahA0NhjuRqF48QH7HKuMS/G3V1JgxtQOnCx3+e4wIv3ysooi1mOA+
         iIwqRDHduUFzekIBPJf7nI3UuBBzbsRYyAVNCCyZWKMQfbtVsqP4wqyVTAN1UJKg1KMb
         eMa+8kVLFVGHugP1m+mvBn5xNxKNitKFBTYpRkjmPzawwIXv6J9CKCQR1nB3gCy3fJF8
         i5pkfmttEH7t42jInYkU0+U5GkDADwfN67186V2lohIYPHpY5d+dbvmXva5Ay/qQT+7i
         /jlzK3WIsM1vK8LXLhKsAhyOQcZrl+4OIGMDIM7h3mzPCkL7Zd3rb7Ddd58lqLnpQ3fW
         BuQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g12si8274120edm.40.2019.07.24.07.09.13
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 07:09:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4428D28;
	Wed, 24 Jul 2019 07:09:13 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CB3973F71A;
	Wed, 24 Jul 2019 07:09:10 -0700 (PDT)
Date: Wed, 24 Jul 2019 15:09:08 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Steven Price <steven.price@arm.com>
Cc: x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v9 11/21] mm: pagewalk: Add p4d_entry() and pgd_entry()
Message-ID: <20190724140908.GE2624@lakrids.cambridge.arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-12-steven.price@arm.com>
 <20190723101432.GC8085@lakrids.cambridge.arm.com>
 <60ee20ef-62a3-5df1-6e24-24973b69be70@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <60ee20ef-62a3-5df1-6e24-24973b69be70@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 02:53:04PM +0100, Steven Price wrote:
> On 23/07/2019 11:14, Mark Rutland wrote:
> > On Mon, Jul 22, 2019 at 04:42:00PM +0100, Steven Price wrote:
> >> pgd_entry() and pud_entry() were removed by commit 0b1fbfe50006c410
> >> ("mm/pagewalk: remove pgd_entry() and pud_entry()") because there were
> >> no users. We're about to add users so reintroduce them, along with
> >> p4d_entry() as we now have 5 levels of tables.
> >>
> >> Note that commit a00cc7d9dd93d66a ("mm, x86: add support for
> >> PUD-sized transparent hugepages") already re-added pud_entry() but with
> >> different semantics to the other callbacks. Since there have never
> >> been upstream users of this, revert the semantics back to match the
> >> other callbacks. This means pud_entry() is called for all entries, not
> >> just transparent huge pages.
> >>
> >> Signed-off-by: Steven Price <steven.price@arm.com>
> >> ---
> >>  include/linux/mm.h | 15 +++++++++------
> >>  mm/pagewalk.c      | 27 ++++++++++++++++-----------
> >>  2 files changed, 25 insertions(+), 17 deletions(-)
> >>
> >> diff --git a/include/linux/mm.h b/include/linux/mm.h
> >> index 0334ca97c584..b22799129128 100644
> >> --- a/include/linux/mm.h
> >> +++ b/include/linux/mm.h
> >> @@ -1432,15 +1432,14 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
> >>  
> >>  /**
> >>   * mm_walk - callbacks for walk_page_range
> >> - * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
> >> - *	       this handler should only handle pud_trans_huge() puds.
> >> - *	       the pmd_entry or pte_entry callbacks will be used for
> >> - *	       regular PUDs.
> >> - * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
> >> + * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
> >> + * @p4d_entry: if set, called for each non-empty P4D entry
> >> + * @pud_entry: if set, called for each non-empty PUD entry
> >> + * @pmd_entry: if set, called for each non-empty PMD entry
> > 
> > How are these expected to work with folding?
> > 
> > For example, on arm64 with 64K pages and 42-bit VA, you can have 2-level
> > tables where the PGD is P4D, PUD, and PMD. IIUC we'd invoke the
> > callbacks for each of those levels where we found an entry in the pgd.
> > 
> > Either the callee handle that, or we should inhibit the callbacks when
> > levels are folded, and I think that needs to be explcitly stated either
> > way.
> > 
> > IIRC on x86 the p4d folding is dynamic depending on whether the HW
> > supports 5-level page tables. Maybe that implies the callee has to
> > handle that.
> 
> Yes, my assumption is that it has to be up to the callee to handle that
> because folding can be dynamic. I believe this also was how these
> callbacks work before they were removed. However I'll add a comment
> explaining that here as it's probably non-obvious.

That sounds good to me.

Thanks,
Mark.

