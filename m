Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 947146B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 23:13:50 -0400 (EDT)
Received: by gxk23 with SMTP id 23so2028461gxk.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 20:13:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110531083859.98e4ff43.kamezawa.hiroyu@jp.fujitsu.com>
References: <1306774744.4061.5.camel@localhost.localdomain>
	<20110531083859.98e4ff43.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 31 May 2011 09:13:47 +0600
Message-ID: <BANLkTinTqijGxCpZ_nRwWZHYsR-u2zojZA@mail.gmail.com>
Subject: Re: [PATCH] mm, vmstat: Use cond_resched only when !CONFIG_PREEMPT
From: Rakib Mullick <rakib.mullick@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, May 31, 2011 at 5:38 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 30 May 2011 22:59:04 +0600
> Rakib Mullick <rakib.mullick@gmail.com> wrote:
>
>> commit 468fd62ed9 (vmstats: add cond_resched() to refresh_cpu_vm_stats()=
) added cond_resched() in refresh_cpu_vm_stats. Purpose of that patch was t=
o allow other threads to run in non-preemptive case. This patch, makes sure=
 that cond_resched() gets called when !CONFIG_PREEMPT is set. In a preempti=
able kernel we don't need to call cond_resched().
>>
>> Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
>
> Hmm, what benefit do we get by adding this extra #ifdef in the code direc=
tly ?
> Other cond_resched() callers are not guilty in !CONFIG_PREEMPT ?
>
Well, in preemptible kernel this context will get preempted if
requires, so we don't need cond_resched(). If you checkout the git log
of the mentioned commit, you'll find the explanation. It says:
        "Adding a cond_resched() to allow other threads to run in the
non-preemptive
    case."

So, let cond_resched() be in non-preemptive case.

Thanks,
Rakib

> Thanks,
> -Kame
>
>> ---
>>
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index 20c18b7..72cf857 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -461,7 +461,11 @@ void refresh_cpu_vm_stats(int cpu)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->expire =
=3D 3;
>> =A0#endif
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> +#ifndef CONFIG_PREEMPT
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();
>> +#endif
>> +
>> =A0#ifdef CONFIG_NUMA
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Deal with draining the remote pageset o=
f this
>>
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
