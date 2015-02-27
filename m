Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id EC8CA6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 16:40:35 -0500 (EST)
Received: by qcvx3 with SMTP id x3so16155989qcv.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 13:40:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 34si5316784qgn.30.2015.02.27.13.40.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 13:40:35 -0800 (PST)
Message-ID: <54F0DA1E.9060006@redhat.com>
Date: Fri, 27 Feb 2015 15:57:02 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: set khugepaged_max_ptes_none by 1/8 of HPAGE_PMD_NR
References: <1425061608-15811-1-git-send-email-ebru.akagunduz@gmail.com> <alpine.DEB.2.10.1502271248240.2122@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502271248240.2122@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, aarcange@redhat.com

On 02/27/2015 03:53 PM, David Rientjes wrote:
> On Fri, 27 Feb 2015, Ebru Akagunduz wrote:
> 
>> Using THP, programs can access memory faster, by having the
>> kernel collapse small pages into large pages. The parameter
>> max_ptes_none specifies how many extra small pages (that are
>> not already mapped) can be allocated when collapsing a group
>> of small pages into one large page.
>>
> 
> Not exactly, khugepaged isn't "allocating" small pages to collapse into a 
> hugepage, rather it is allocating a hugepage and then remapping the 
> pageblock's mapped pages.

How would you describe the amount of extra memory
allocated, as a result of converting a partially
mapped 2MB area into a THP?

It is not physically allocating 4kB pages, but
I would like to keep the text understandable to
people who do not know the THP internals.

>> A larger value of max_ptes_none can cause the kernel
>> to collapse more incomplete areas into THPs, speeding
>> up memory access at the cost of increased memory use.
>> A smaller value of max_ptes_none will reduce memory
>> waste, at the expense of collapsing fewer areas into
>> THPs.
>>
> 
> This changelog only describes what max_ptes_none does, it doesn't state 
> why you want to change it from HPAGE_PMD_NR-1, which is 511 on x86_64 
> (largest value, more thp), to HPAGE_PMD_NR/8, which is 64 (smaller value, 
> less thp, less rss as a result of collapsing).
>
> This has particular performance implications on users who already have thp 
> enabled, so it's difficult to change the default.  This is tuanble that 
> you could easily set in an initscript, so I don't think we need to change 
> the value for everybody.

I think we do need to change the default.

Why? See this bug:

>> The problem was reported here:
>> https://bugzilla.kernel.org/show_bug.cgi?id=93111

Now, there may be a better value than HPAGE_PMD_NR/8, but
I am not sure what it would be, or why.

I do know that HPAGE_PMD_NR-1 results in undesired behaviour,
as seen in the bug above...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
