Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 57E306B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 21:16:06 -0400 (EDT)
Received: by obfe9 with SMTP id e9so9740559obf.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:16:06 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id ec3si16903022obb.86.2015.04.28.18.16.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 18:16:05 -0700 (PDT)
Message-ID: <554030D1.8080509@hp.com>
Date: Tue, 28 Apr 2015 21:16:01 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
In-Reply-To: <1430231830-7702-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/28/2015 10:36 AM, Mel Gorman wrote:
> The bulk of the changes here are related to Andrew's feedback. Functionally
> there is almost no difference.
>
> Changelog since v3
> o Fix section-related warning
> o Comments, clarifications, checkpatch
> o Report the number of pages initialised
>
> Changelog since v2
> o Reduce overhead of topology_init
> o Remove boot-time kernel parameter to enable/disable
> o Enable on UMA
>
> Changelog since v1
> o Always initialise low zones
> o Typo corrections
> o Rename parallel mem init to parallel struct page init
> o Rebase to 4.0
>
> Struct page initialisation had been identified as one of the reasons why
> large machines take a long time to boot. Patches were posted a long time ago
> to defer initialisation until they were first used.  This was rejected on
> the grounds it should not be necessary to hurt the fast paths. This series
> reuses much of the work from that time but defers the initialisation of
> memory to kswapd so that one thread per node initialises memory local to
> that node.
>
> After applying the series and setting the appropriate Kconfig variable I
> see this in the boot log on a 64G machine
>
> [    7.383764] kswapd 0 initialised deferred memory in 188ms
> [    7.404253] kswapd 1 initialised deferred memory in 208ms
> [    7.411044] kswapd 3 initialised deferred memory in 216ms
> [    7.411551] kswapd 2 initialised deferred memory in 216ms
>
> On a 1TB machine, I see
>
> [    8.406511] kswapd 3 initialised deferred memory in 1116ms
> [    8.428518] kswapd 1 initialised deferred memory in 1140ms
> [    8.435977] kswapd 0 initialised deferred memory in 1148ms
> [    8.437416] kswapd 2 initialised deferred memory in 1148ms
>
> Once booted the machine appears to work as normal. Boot times were measured
> from the time shutdown was called until ssh was available again.  In the
> 64G case, the boot time savings are negligible. On the 1TB machine, the
> savings were 16 seconds.
>
> It would be nice if the people that have access to really large machines
> would test this series and report how much boot time is reduced.
>
>

I ran a bootup timing test on a 12-TB 16-socket IvyBridge-EX system. 
 From grub menu to ssh login, the bootup time was 453s before the patch 
and 265s after the patch - a saving of 188s (42%). I used a different OS 
environment and config file with this test and so the timing data 
weren't comparable with my previous testing data. The kswapd log entries 
were

[   45.973967] kswapd 4 initialised 197655470 pages in 4390ms
[   45.974214] kswapd 7 initialised 197655470 pages in 4390ms
[   45.976692] kswapd 15 initialised 197654299 pages in 4390ms
[   45.993284] kswapd 0 initialised 197131131 pages in 4410ms
[   46.032735] kswapd 9 initialised 197655470 pages in 4447ms
[   46.065856] kswapd 8 initialised 197655470 pages in 4481ms
[   46.066615] kswapd 1 initialised 197622702 pages in 4483ms
[   46.077995] kswapd 2 initialised 197655470 pages in 4495ms
[   46.219508] kswapd 13 initialised 197655470 pages in 4633ms
[   46.224358] kswapd 3 initialised 197655470 pages in 4641ms
[   46.228441] kswapd 11 initialised 197655470 pages in 4643ms
[   46.232258] kswapd 12 initialised 197655470 pages in 4647ms
[   46.239659] kswapd 10 initialised 197655470 pages in 4654ms
[   46.243402] kswapd 14 initialised 197655470 pages in 4657ms
[   46.250368] kswapd 5 initialised 197655470 pages in 4666ms
[   46.254659] kswapd 6 initialised 197655470 pages in 4670ms

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
