Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 80A358D0039
	for <linux-mm@kvack.org>; Sat, 19 Mar 2011 12:05:03 -0400 (EDT)
Message-ID: <4D84D3F2.4010200@fiec.espol.edu.ec>
Date: Sat, 19 Mar 2011 11:04:02 -0500
From: =?ISO-8859-15?Q?Alex_Villac=ED=ADs_Lasso?=
 <avillaci@fiec.espol.edu.ec>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
References: <bug-31142-10286@https.bugzilla.kernel.org/> <20110315135334.36e29414.akpm@linux-foundation.org> <4D7FEDDC.3020607@fiec.espol.edu.ec> <20110315161926.595bdb65.akpm@linux-foundation.org> <4D80D65C.5040504@fiec.espol.edu.ec> <20110316150208.7407c375.akpm@linux-foundation.org> <4D827CC1.4090807@fiec.espol.edu.ec> <20110317144727.87a461f9.akpm@linux-foundation.org> <20110318111300.GF707@csn.ul.ie> <4D839EDB.9080703@fiec.espol.edu.ec> <20110319134628.GG707@csn.ul.ie>
In-Reply-To: <20110319134628.GG707@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

El 19/03/11 08:46, Mel Gorman escribio:
> On Fri, Mar 18, 2011 at 01:05:15PM -0500, Alex Villac??s Lasso wrote:
>> El 18/03/11 06:13, Mel Gorman escribio:
>>> \o/ ... no wait, it's the other one - :(
>>>
>>> If you look at the stack traces though, all of them had called
>>> do_huge_pmd_anonymous_page() so while it looks similar to 12309, the trigger
>>> is new because it's THP triggering compaction that is causing the stalls
>>> rather than page reclaim doing direct writeback which was the culprit in
>>> the past.
>>>
>>> To confirm if this is the case, I'd be very interested in hearing if this
>>> problem persists in the following cases
>>>
>>> 1. 2.6.38-rc8 with defrag disabled by
>>>     echo never>/sys/kernel/mm/transparent_hugepage/defrag
>>>     (this will stop THP allocations calling into compaction)
>>> 2. 2.6.38-rc8 with THP disabled by
>>>     echo never>
>>> /sys/kernel/mm/transparent_hugepage/enabled
>>>     (if the problem still persists, then page reclaim is still a problem
>>>      but we should still stop THP doing sync writes)
>>> 3. 2.6.37 vanilla
>>>     (in case this is a new regression introduced since then)
>>>
>>> Migration can do sync writes on dirty pages which is why it looks so similar
>>> to page reclaim but this can be controlled by the value of sync_migration
>>> passed into try_to_compact_pages(). If we find that option 1 above makes
>>> the regression go away or at least helps a lot, then a reasonable fix may
>>> be to never set sync_migration if __GFP_NO_KSWAPD which is always set for
>>> THP allocations. I've added Andrea to the cc to see what he thinks.
>>>
>>> Thanks for the report.
>>>
>> I have just done tests 1 and 2 on 2.6.38 (final, not -rc8), and I
>> have verified that echoing "never" on either
>> /sys/kernel/mm/transparent_hugepage/defrag or
>> /sys/kernel/mm/transparent_hugepage/enabled does allow the file copy
>> to USB to proceed smoothly (copying 4GB of data). Just to verify, I
>> later wrote "always" to both files, and sure enough, some
>> applications stalled when I repeated the same file copy. So I have
>> at least a workaround for the issue. Given this evidence, will the
>> patch at comment #14 fix the issue for good?
>>
> Thanks for testing and reporting, it's very helpful. Based on that that
> report the patch should help. Can you test it to be absolutly sure please?
>
>
The patch did not help. I have attached a sysrq-w trace with the patch applied in the bug report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
