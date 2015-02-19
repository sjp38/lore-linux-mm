Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA096B00C1
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 03:25:25 -0500 (EST)
Received: by wesp10 with SMTP id p10so5833460wes.2
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 00:25:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id el4si39727133wjd.189.2015.02.19.00.25.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 00:25:23 -0800 (PST)
Message-ID: <54E59DEF.2020807@suse.cz>
Date: Thu, 19 Feb 2015 09:25:19 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: incorporate zero pages into transparent huge pages
References: <1423688635-4306-1-git-send-email-ebru.akagunduz@gmail.com> <20150218153119.0bcd0bf8b4e7d30d99f00a3b@linux-foundation.org> <54E5296C.5040806@redhat.com>
In-Reply-To: <54E5296C.5040806@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, aarcange@redhat.com

On 02/19/2015 01:08 AM, Rik van Riel wrote:
> On 02/18/2015 06:31 PM, Andrew Morton wrote:
>> On Wed, 11 Feb 2015 23:03:55 +0200 Ebru Akagunduz
>> <ebru.akagunduz@gmail.com> wrote:
> 
>>> This patch improves THP collapse rates, by allowing zero pages.
>>> 
>>> Currently THP can collapse 4kB pages into a THP when there are up
>>> to khugepaged_max_ptes_none pte_none ptes in a 2MB range.  This
>>> patch counts pte none and mapped zero pages with the same
>>> variable.
> 
>> So if I'm understanding this correctly, with the default value of 
>> khugepaged_max_ptes_none (HPAGE_PMD_NR-1), if an application
>> creates a 2MB area which contains 511 mappings of the zero page and
>> one real page, the kernel will proceed to turn that area into a
>> real, physical huge page.  So it consumes 2MB of memory which would
>> not have previously been allocated?
> 
> This is equivalent to an application doing a write fault
> to a 2MB area that was previously untouched, going into
> do_huge_pmd_anonymous_page() and receiving a 2MB page.
> 
>> If so, this might be rather undesirable behaviour in some
>> situations (and ditto the current behaviour for pte_none ptes)?
> 
>> This can be tuned by adjusting khugepaged_max_ptes_none,
> 
> The example of directly going into do_huge_pmd_anonymous_page()
> is not influenced by the tunable.
> 
> It may indeed be undesirable in some situations, but I am
> not sure how to detect those...

Well, yeah. We seem to lack a setting to restrict page fault THP allocations to
e.g. madvise, while still letting khugepaged to collapse them later, taking
khugepaged_max_ptes_none into account.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
