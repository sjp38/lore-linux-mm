Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 94FD36B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 13:23:12 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id q107so15391582qgd.8
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 10:23:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r2si28743158qcc.16.2015.02.20.10.23.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 10:23:11 -0800 (PST)
Date: Fri, 20 Feb 2015 19:02:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] mm: incorporate zero pages into transparent huge pages
Message-ID: <20150220180218.GA4285@redhat.com>
References: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com>
 <20150218153119.0bcd0bf8b4e7d30d99f00a3b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150218153119.0bcd0bf8b4e7d30d99f00a3b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com

On Wed, Feb 18, 2015 at 03:31:19PM -0800, Andrew Morton wrote:
> On Wed, 11 Feb 2015 23:03:55 +0200 Ebru Akagunduz <ebru.akagunduz@gmail.com> wrote:
> 
> > This patch improves THP collapse rates, by allowing zero pages.
> > 
> > Currently THP can collapse 4kB pages into a THP when there
> > are up to khugepaged_max_ptes_none pte_none ptes in a 2MB
> > range.  This patch counts pte none and mapped zero pages
> > with the same variable.
> 
> So if I'm understanding this correctly, with the default value of
> khugepaged_max_ptes_none (HPAGE_PMD_NR-1), if an application creates a
> 2MB area which contains 511 mappings of the zero page and one real
> page, the kernel will proceed to turn that area into a real, physical
> huge page.  So it consumes 2MB of memory which would not have
> previously been allocated?

Correct.

> 
> If so, this might be rather undesirable behaviour in some situations
> (and ditto the current behaviour for pte_none ptes)?
> 
> This can be tuned by adjusting khugepaged_max_ptes_none, but not many
> people are likely to do that because we didn't document the damn thing.

khugepaged checks !hugepage_vma_check, so those apps that don't want
it can opt out with MADV_NOHUGEPAGE. The sysctl allows to tune for the
default behavior.

>  At all.  Can we please rectify this, and update it for the is_zero_pfn
> feature?  The documentation should include an explanation telling
> people how to decide what setting to use, how to observe its effects,
> etc.

Agreed, documentation for the sysfs control would be good to have
indeed.

In the meantime I've got a more urgent issue, for which the fix is
appended below.

Thanks,
Andrea

==
