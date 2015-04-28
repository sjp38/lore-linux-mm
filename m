Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 55E166B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 14:38:23 -0400 (EDT)
Received: by yhcb70 with SMTP id b70so852753yhc.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 11:38:23 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id fj3si36370489vdb.81.2015.04.28.11.38.22
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 11:38:22 -0700 (PDT)
Message-ID: <553FD39C.2070503@sgi.com>
Date: Tue, 28 Apr 2015 13:38:20 -0500
From: nzimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
References: <1430231830-7702-1-git-send-email-mgorman@suse.de> <CAOJsxLG0Tr2QV8P55vJDOeUPoWw8xBextQ-qzj4E+PnOk9JBsQ@mail.gmail.com>
In-Reply-To: <CAOJsxLG0Tr2QV8P55vJDOeUPoWw8xBextQ-qzj4E+PnOk9JBsQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On an older 8 TB box with lots and lots of cpus the boot time, as 
measure from grub to login prompt, the boot time improved from 1484 
seconds to exactly 1000 seconds.

I have time on 16 TB box tonight and a 12 TB box thursday and will 
hopefully have more numbers then.



On 04/28/2015 11:06 AM, Pekka Enberg wrote:
> On Tue, Apr 28, 2015 at 5:36 PM, Mel Gorman <mgorman@suse.de> wrote:
>> Struct page initialisation had been identified as one of the reasons why
>> large machines take a long time to boot. Patches were posted a long time ago
>> to defer initialisation until they were first used.  This was rejected on
>> the grounds it should not be necessary to hurt the fast paths. This series
>> reuses much of the work from that time but defers the initialisation of
>> memory to kswapd so that one thread per node initialises memory local to
>> that node.
>>
>> After applying the series and setting the appropriate Kconfig variable I
>> see this in the boot log on a 64G machine
>>
>> [    7.383764] kswapd 0 initialised deferred memory in 188ms
>> [    7.404253] kswapd 1 initialised deferred memory in 208ms
>> [    7.411044] kswapd 3 initialised deferred memory in 216ms
>> [    7.411551] kswapd 2 initialised deferred memory in 216ms
>>
>> On a 1TB machine, I see
>>
>> [    8.406511] kswapd 3 initialised deferred memory in 1116ms
>> [    8.428518] kswapd 1 initialised deferred memory in 1140ms
>> [    8.435977] kswapd 0 initialised deferred memory in 1148ms
>> [    8.437416] kswapd 2 initialised deferred memory in 1148ms
>>
>> Once booted the machine appears to work as normal. Boot times were measured
>> from the time shutdown was called until ssh was available again.  In the
>> 64G case, the boot time savings are negligible. On the 1TB machine, the
>> savings were 16 seconds.
> FWIW,
>
> Acked-by: Pekka Enberg <penberg@kernel.org>
>
> for the whole series.
>
> - Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
