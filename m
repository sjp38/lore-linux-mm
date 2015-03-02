Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C18D86B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 09:00:38 -0500 (EST)
Received: by wibbs8 with SMTP id bs8so15031365wib.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 06:00:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2si22294140wjy.199.2015.03.02.06.00.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 06:00:36 -0800 (PST)
Message-ID: <54F46D01.1030105@suse.cz>
Date: Mon, 02 Mar 2015 15:00:33 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: set khugepaged_max_ptes_none by 1/8 of HPAGE_PMD_NR
References: <1425061608-15811-1-git-send-email-ebru.akagunduz@gmail.com> <alpine.DEB.2.10.1502271248240.2122@chino.kir.corp.google.com> <54F0DA1E.9060006@redhat.com> <alpine.DEB.2.10.1502271300120.2122@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502271300120.2122@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, aarcange@redhat.com

On 02/27/2015 10:12 PM, David Rientjes wrote:
> On Fri, 27 Feb 2015, Rik van Riel wrote:
>
>> I think we do need to change the default.
>>
>> Why? See this bug:
>>
>>>> The problem was reported here:
>>>> https://bugzilla.kernel.org/show_bug.cgi?id=93111
>>
>> Now, there may be a better value than HPAGE_PMD_NR/8, but
>> I am not sure what it would be, or why.
>>
>> I do know that HPAGE_PMD_NR-1 results in undesired behaviour,
>> as seen in the bug above...
>>
>
> I know that the value of 64 would also be undesirable for Google since we
> tightly constrain memory usage, we have used max_ptes_none == 0 since it
> was introduced.   We can get away with that because our malloc() is
> modified to try to give back large contiguous ranges of memory
> periodically back to the system, also using madvise(MADV_DONTNEED), and
> tries to avoid splitting thp memory.
>
> The value is determined by how the system will be used: do you tightly
> constrain memory usage and not allow any unmapped memory be collapsed into
> a hugepage, or do you have an abundance of memory and really want an
> aggressive value like HPAGE_PMD_NR-1.  Depending on the properties of the
> system, you can tune this to anything you want just like we do in
> initscripts.
>
> I'm only concerned here about changing a default that has been around for
> four years and the possibly negative implications that will have on users
> who never touch this value.  They undoubtedly get less memory backed by
> thp, and that can lead to a performance regression.  So if this patch is
> merged and we get a bug report for the 4.1 kernel, do we tell that user
> that we changed behavior out from under them and to adjust the tunable
> back to HPAGE_PMD_NR-1?

Note that the new default has no effect on THP page faults which will 
still effectively act like max_ptes_none == 511. That means anyone who 
would notice this change of default has been relying on khugepaged, 
which is in its default settings quite slow, and (before other Ebru's 
patches) wouldn't collapse pmd's with zero pages or swapcache pages. So 
I think the chances of bug report due to the new default are lower than 
the bug 93111.

> Meanwhile, the bug report you cite has a workaround that has always been
> available for thp kernels:
> # echo 64 > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
