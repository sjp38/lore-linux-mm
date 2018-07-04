Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D88976B0005
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 23:58:07 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j9-v6so4086055qtn.22
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 20:58:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f36-v6si2621898qtb.43.2018.07.03.20.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 20:58:06 -0700 (PDT)
Date: Tue, 3 Jul 2018 23:58:05 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd: hugetlbfs: Fix userfaultfd_huge_must_wait
 pte access
Message-ID: <20180704035805.GA9833@redhat.com>
References: <20180626132421.78084-1-frankja@linux.ibm.com>
 <c9c5c76c-23e5-671f-1fdc-8326e42917b9@oracle.com>
 <961dc253-b071-8a72-c046-c23cae377e2c@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <961dc253-b071-8a72-c046-c23cae377e2c@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janosch Frank <frankja@linux.ibm.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Wed, Jun 27, 2018 at 10:47:44AM +0200, Janosch Frank wrote:
> On 26.06.2018 19:00, Mike Kravetz wrote:
> > On 06/26/2018 06:24 AM, Janosch Frank wrote:
> >> Use huge_ptep_get to translate huge ptes to normal ptes so we can
> >> check them with the huge_pte_* functions. Otherwise some architectures
> >> will check the wrong values and will not wait for userspace to bring
> >> in the memory.
> >>
> >> Signed-off-by: Janosch Frank <frankja@linux.ibm.com>
> >> Fixes: 369cd2121be4 ("userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges")
> > Adding linux-mm and Andrew on Cc:
> > 
> > Thanks for catching and fixing this.
> 
> Sure
> I'd be happy if we get less of these problems with time, this one was
> rather painful to debug. :)

What I thought when I read the fix is it would be more robust and we
could catch any further error like this at build time by having
huge_pte_offset return a new type "hugepte_t *" instead of the current
"pte_t *". Of course then huge_ptep_get() would take a "hugepte_t *" as
parameter. The x86 implementation would then become:

static inline pte_t huge_ptep_get(hugepte_t *ptep)
{
	return *(pte_t *)ptep;
}

I haven't tried it, perhaps it's not feasible for other reasons
because there's a significant fallout from such a change (i.e. a lot
of hugetlbfs methods needs to change input type), but you said you're
actively looking to get less of these problems this could be a way if
it can be done, so I should mention it.

The need of huge_ptep_get() of course is very apparent when reading the
fix, but it was all but apparent when reading the previous code and the
previous code was correct for x86 because of course huge_ptep_get is
implemented as *ptep on x86.

For now the current fix is certainly good, any robustness cleanup is
cleaner if done orthogonal anyway.

Thanks!
Andrea
