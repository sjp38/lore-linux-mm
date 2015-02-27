Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id CFE186B006E
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 16:12:56 -0500 (EST)
Received: by igbhl2 with SMTP id hl2so3454513igb.0
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 13:12:56 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id qs1si2658787igb.28.2015.02.27.13.12.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 13:12:56 -0800 (PST)
Received: by igal13 with SMTP id l13so3455243iga.1
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 13:12:56 -0800 (PST)
Date: Fri, 27 Feb 2015 13:12:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: set khugepaged_max_ptes_none by 1/8 of
 HPAGE_PMD_NR
In-Reply-To: <54F0DA1E.9060006@redhat.com>
Message-ID: <alpine.DEB.2.10.1502271300120.2122@chino.kir.corp.google.com>
References: <1425061608-15811-1-git-send-email-ebru.akagunduz@gmail.com> <alpine.DEB.2.10.1502271248240.2122@chino.kir.corp.google.com> <54F0DA1E.9060006@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, aarcange@redhat.com

On Fri, 27 Feb 2015, Rik van Riel wrote:

> >> Using THP, programs can access memory faster, by having the
> >> kernel collapse small pages into large pages. The parameter
> >> max_ptes_none specifies how many extra small pages (that are
> >> not already mapped) can be allocated when collapsing a group
> >> of small pages into one large page.
> >>
> > 
> > Not exactly, khugepaged isn't "allocating" small pages to collapse into a 
> > hugepage, rather it is allocating a hugepage and then remapping the 
> > pageblock's mapped pages.
> 
> How would you describe the amount of extra memory
> allocated, as a result of converting a partially
> mapped 2MB area into a THP?
> 
> It is not physically allocating 4kB pages, but
> I would like to keep the text understandable to
> people who do not know the THP internals.
> 

I would say it specifies how much unmapped memory can become mapped by a 
hugepage.

> I think we do need to change the default.
> 
> Why? See this bug:
> 
> >> The problem was reported here:
> >> https://bugzilla.kernel.org/show_bug.cgi?id=93111
> 
> Now, there may be a better value than HPAGE_PMD_NR/8, but
> I am not sure what it would be, or why.
> 
> I do know that HPAGE_PMD_NR-1 results in undesired behaviour,
> as seen in the bug above...
> 

I know that the value of 64 would also be undesirable for Google since we 
tightly constrain memory usage, we have used max_ptes_none == 0 since it 
was introduced.   We can get away with that because our malloc() is 
modified to try to give back large contiguous ranges of memory 
periodically back to the system, also using madvise(MADV_DONTNEED), and 
tries to avoid splitting thp memory.

The value is determined by how the system will be used: do you tightly 
constrain memory usage and not allow any unmapped memory be collapsed into 
a hugepage, or do you have an abundance of memory and really want an 
aggressive value like HPAGE_PMD_NR-1.  Depending on the properties of the 
system, you can tune this to anything you want just like we do in 
initscripts.

I'm only concerned here about changing a default that has been around for 
four years and the possibly negative implications that will have on users 
who never touch this value.  They undoubtedly get less memory backed by 
thp, and that can lead to a performance regression.  So if this patch is 
merged and we get a bug report for the 4.1 kernel, do we tell that user 
that we changed behavior out from under them and to adjust the tunable 
back to HPAGE_PMD_NR-1?

Meanwhile, the bug report you cite has a workaround that has always been 
available for thp kernels:
# echo 64 > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
