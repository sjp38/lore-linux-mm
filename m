Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 699FC6B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 02:35:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 184so3922734wmy.11
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 23:35:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h132si1579365wma.82.2017.04.10.23.35.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 23:35:04 -0700 (PDT)
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
 <84B5E286-4E2A-4DE0-8351-806D2102C399@cs.rutgers.edu>
 <20170410172056.shyx6qzcjglbt5nd@techsingularity.net>
 <8A6309F4-DB76-48FA-BE7F-BF9536A4C4E5@cs.rutgers.edu>
 <20170410180714.7yfnxl7qin72jcob@techsingularity.net>
 <20170410150903.f931ceb5475d2d3d8945bb71@linux-foundation.org>
 <789A2322-A5B6-4AC8-8668-D7057A56A140@cs.rutgers.edu>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6336c469-c946-c300-7392-87052c990266@suse.cz>
Date: Tue, 11 Apr 2017 08:35:02 +0200
MIME-Version: 1.0
In-Reply-To: <789A2322-A5B6-4AC8-8668-D7057A56A140@cs.rutgers.edu>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/11/2017 12:28 AM, Zi Yan wrote:
> On 10 Apr 2017, at 17:09, Andrew Morton wrote:
> 
>> On Mon, 10 Apr 2017 19:07:14 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
>>
>>> On Mon, Apr 10, 2017 at 12:49:40PM -0500, Zi Yan wrote:
>>>> On 10 Apr 2017, at 12:20, Mel Gorman wrote:
>>>>
>>>>> On Mon, Apr 10, 2017 at 11:45:08AM -0500, Zi Yan wrote:
>>>>>>> While this could be fixed with heavy locking, it's only necessary to
>>>>>>> make a copy of the PMD on the stack during change_pmd_range and avoid
>>>>>>> races. A new helper is created for this as the check if quite subtle and the
>>>>>>> existing similar helpful is not suitable. This passed 154 hours of testing
>>>>>>> (usually triggers between 20 minutes and 24 hours) without detecting bad
>>>>>>> PMDs or corruption. A basic test of an autonuma-intensive workload showed
>>>>>>> no significant change in behaviour.
>>>>>>>
>>>>>>> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
>>>>>>> Cc: stable@vger.kernel.org
>>>>>>
>>>>>> Does this patch fix the same problem fixed by Kirill's patch here?
>>>>>> https://lkml.org/lkml/2017/3/2/347
>>>>>>
>>>>>
>>>>> I don't think so. The race I'm concerned with is due to locks not being
>>>>> held and is in a different path.
>>>>
>>>> I do not agree. Kirill's patch is fixing the same race problem but in
>>>> zap_pmd_range().
>>>>
>>>> The original autoNUMA code first clears PMD then sets it to protnone entry.
>>>> pmd_trans_huge() does not return TRUE because it saw cleared PMD, but
>>>> pmd_none_or_clear_bad() later saw the protnone entry and reported it as bad.
>>>> Is this the problem you are trying solve?
>>>>
>>>> Kirill's patch will pmdp_invalidate() the PMD entry, which keeps _PAGE_PSE bit,
>>>> so pmd_trans_huge() will return TRUE. In this case, it also fixes
>>>> your race problem in change_pmd_range().
>>>>
>>>> Let me know if I miss anything.
>>>>
>>>
>>> Ok, now I see. I think you're correct and I withdraw the patch.
>>
>> I have Kirrill's
>>
>> thp-reduce-indentation-level-in-change_huge_pmd.patch
>> thp-fix-madv_dontneed-vs-numa-balancing-race.patch
>> mm-drop-unused-pmdp_huge_get_and_clear_notify.patch
>> thp-fix-madv_dontneed-vs-madv_free-race.patch
>> thp-fix-madv_dontneed-vs-madv_free-race-fix.patch
>> thp-fix-madv_dontneed-vs-clear-soft-dirty-race.patch
>>
>> scheduled for 4.12-rc1.  It sounds like
>> thp-fix-madv_dontneed-vs-madv_free-race.patch and
>> thp-fix-madv_dontneed-vs-madv_free-race.patch need to be boosted to
>> 4.11 and stable?
> 
> thp-fix-madv_dontneed-vs-numa-balancing-race.patch is the fix for
> numa balancing problem reported in this thread.
> 
> mm-drop-unused-pmdp_huge_get_and_clear_notify.patch,
> thp-fix-madv_dontneed-vs-madv_free-race.patch,
> thp-fix-madv_dontneed-vs-madv_free-race-fix.patch, and
> thp-fix-madv_dontneed-vs-clear-soft-dirty-race.patch
> 
> are the fixes for other potential race problems similar to this one.
> 
> I think it is better to have all these patches applied.

Yeah we should get all such fixes to stable IMHO (after review :). It's
not the first time that a fix for MADV_DONTNEED turned out to also fix a
race that involved "normal operation" with THP, without such syscalls.

> --
> Best Regards
> Yan Zi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
