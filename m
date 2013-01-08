Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 15F0E6B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 03:25:28 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F21153EE0BC
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 17:25:25 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D732545DE57
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 17:25:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2FF145DE4F
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 17:25:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A54431DB8045
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 17:25:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ABB41DB803E
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 17:25:25 +0900 (JST)
Message-ID: <50EBD7C0.4010100@jp.fujitsu.com>
Date: Tue, 08 Jan 2013 17:24:32 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Add mempressure cgroup
References: <20130104082751.GA22227@lizard.gateway.2wire.net> <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org> <50EA8CA2.7020608@jp.fujitsu.com> <20130108072935.GA15431@lizard.gateway.2wire.net>
In-Reply-To: <20130108072935.GA15431@lizard.gateway.2wire.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

(2013/01/08 16:29), Anton Vorontsov wrote:
> On Mon, Jan 07, 2013 at 05:51:46PM +0900, Kamezawa Hiroyuki wrote:
> [...]
>> I'm just curious..
>
> Thanks for taking a look! :)
>
> [...]
>>> +/*
>>> + * The window size is the number of scanned pages before we try to analyze
>>> + * the scanned/reclaimed ratio (or difference).
>>> + *
>>> + * It is used as a rate-limit tunable for the "low" level notification,
>>> + * and for averaging medium/oom levels. Using small window sizes can cause
>>> + * lot of false positives, but too big window size will delay the
>>> + * notifications.
>>> + */
>>> +static const uint vmpressure_win = SWAP_CLUSTER_MAX * 16;
>>> +static const uint vmpressure_level_med = 60;
>>> +static const uint vmpressure_level_oom = 99;
>>> +static const uint vmpressure_level_oom_prio = 4;
>>> +
>>
>> Hmm... isn't this window size too small ?
>> If vmscan cannot find a reclaimable page while scanning 2M of pages in a zone,
>> oom notify will be returned. Right ?
>
> Yup, you are right, if we were not able to find anything within the window
> size (which is 2M, but see below), then it is effectively the "OOM level".
> The thing is, the vmpressure reports... the pressure. :) Or, the
> allocation cost, and if the cost becomes high, it is no good.
>
> The 2M is, of course, not ideal. And the "ideal" depends on many factors,
> alike to vmstat. And, actually I dream about deriving the window size from
> zone->stat_threshold, which would make the window automatically adjustable
> for different "machine sizes" (as we do in calculate_normal_threshold(),
> in vmstat.c).
>
> But again, this is all "implementation details"; tunable stuff that we can
> either adjust ourselves as needed, or try to be smart, i.e. apply some
> heuristics, again, as in vmstat.
>

Hmm, I like automatic adjustment for things like this (but may be need to be tunable by
user). My concern is, for example, that if a qemu-kvm with pci-passthrough running on
a node using the most of memory on it, the interface will say "Hey it's near to OOM"
to users. We may need a complicated heuristics ;)

Anyway, your approach seems interesting to me but it seems peaky to usual users.
Uses should know what they should check (vmstat, zoneinfo, malloc latency ??) when they
get notify before rising real alarm. (not explained in the doc.)
For example, if the user takes care of usage of swap, he should check it.

I'm glad if you explain in Doc that this interface just makes a hint and notify status
of _recent_ vmscans of some amount of window. That means latency of recent memory allocations.
Users should confirm the real status and make the final judge by themselves.
The point is that this notify is important because it's quick and related to ongoing memory
allocation latency. But kernel is not sure there are long-standing heavy vm pressure.

I'm sorry if I misundestand the concept.

Thank you,
-Kame



  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
