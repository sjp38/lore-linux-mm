Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 545796B0073
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:01:13 -0500 (EST)
Received: by wesx3 with SMTP id x3so858874wes.1
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:01:12 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fv10si13650915wjb.157.2015.03.05.09.01.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 09:01:11 -0800 (PST)
Message-ID: <54F88BD4.3090006@suse.cz>
Date: Thu, 05 Mar 2015 18:01:08 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC 0/6] the big khugepaged redesign
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz> <1424731603.6539.51.camel@stgolabs.net> <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org> <54EC533E.8040805@suse.cz> <54F88498.2000902@suse.cz> <20150305165230.GQ30405@awork2.anarazel.de>
In-Reply-To: <20150305165230.GQ30405@awork2.anarazel.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>

On 03/05/2015 05:52 PM, Andres Freund wrote:
> Hi,
> 
> On 2015-03-05 17:30:16 +0100, Vlastimil Babka wrote:
>> That however means the workload is based on hugetlbfs and shouldn't trigger THP
>> page fault activity, which is the aim of this patchset. Some more googling made
>> me recall that last LSF/MM, postgresql people mentioned THP issues and pointed
>> at compaction. See http://lwn.net/Articles/591723/ That's exactly where this
>> patchset should help, but I obviously won't be able to measure this before LSF/MM...
>> 
>> I'm CCing the psql guys from last year LSF/MM - do you have any insight about
>> psql performance with THPs enabled/disabled on recent kernels, where e.g.
>> compaction is no longer synchronous for THP page faults?
> 
> What exactly counts as "recent" in this context? Most of the bigger
> installations where we found THP to be absolutely prohibitive (slowdowns
> on the order of a magnitude, huge latency spikes) unfortunately run
> quite old kernels...  I guess 3.11 does *not* count :/? That'd be a

Yeah that's too old :/ 3.17 has patches to make compaction less aggressive on
THP page faults, and 3.18 prevents khugepaged from holding mmap_sem during
compaction, which could be also relevant.

> bigger machine where I could relatively quickly reenable THP to check
> whether it's still bad. I might be able to trigger it to be rebooted
> onto a newer kernel, will ask.

Thanks, that would be great, if you could do that.
I also noticed that you now support hugetlbfs. That could be also interesting
data point, if the hugetlbfs usage helped because THP code wouldn't trigger.

Vlastimil

> Greetings,
> 
> Andres Freund
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
