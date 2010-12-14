Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 35AE86B0093
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 21:34:13 -0500 (EST)
Received: by iwn40 with SMTP id 40so194275iwn.14
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 18:34:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101214110711.af70b5b0.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
	<20101208170504.1750.A69D9226@jp.fujitsu.com>
	<AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com>
	<87oc8wa063.fsf@gmail.com>
	<AANLkTin642NFLMubtCQhSVUNLzfdk5ajz-RWe2zT+Lw6@mail.gmail.com>
	<20101213153105.GA2344@barrios-desktop>
	<20101214110711.af70b5b0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 14 Dec 2010 11:34:11 +0900
Message-ID: <AANLkTi=kBwNQjQ0XBo9Fu5dbUtZ4wBy11K4vU1Kfo6QK@mail.gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ben Gamari <bgamari.foss@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 11:07 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 14 Dec 2010 00:31:05 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Test Environment :
>> DRAM : 2G, CPU : Intel(R) Core(TM)2 CPU
>> Rsync backup directory size : 16G
>>
>> rsync version is 3.0.7.
>> rsync patch is Ben's fadivse.
>> stress scenario do following jobs with parallel.
>>
>> 1. make all -j4 linux, git clone linux-kernel
>> 2. git clone linux-kernel
>> 3. rsync src dst
>>
>> nrns : no-patched rsync + no stress
>> prns : patched rsync + no stress
>> nrs =A0: no-patched rsync + stress
>> prs =A0: patched rsync + stress
>>
>> pginvalidate : the number of dirty/writeback pages which is invalidated =
by fadvise
>> pgreclaim : pages moved PG_reclaim trick in inactive's tail
>>
>> In summary, my patch enhances a littie bit about elapsed time in
>> memory pressure environment and enhance reclaim effectivness(reclaim/rec=
laim)
>> with x2. It means reclaim latency is short and doesn't evict working set
>> pages due to invalidated pages.
>>
>> Look at reclaim effectivness. Patched rsync enhances x2 about reclaim
>> effectiveness and compared to mmotm-12-03, mmotm-12-03-fadvise enhances
>> 3 minute about elapsed time in stress environment.
>> I think it's due to reduce scanning, reclaim overhead.
>>
>> In no-stress enviroment, fadivse makes program little bit slow.
>> I think because there are many pgfault. I don't know why it happens.
>> Could you guess why it happens?
>>
>> Before futher work, I hope listen opinions.
>> Any comment is welcome.
>>
>
> At first, the improvement seems great. Thank you for your effort.

Thanks, Kame.

>
>> In no-stress enviroment, fadivse makes program little bit slow.
>> I think because there are many pgfault. I don't know why it happens.
>> Could you guess why it happens?
>>
>
> Are there no program which accesses a directory rsync'ed ?

Maybe. some programs might have mmaped files.
But although it happens, deactivate_page found that and it does
nothing so the page can't be reclaimed.

>
> Thanks,
> -Kame
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
