Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 1AED66B00A2
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 17:13:25 -0500 (EST)
Received: by ggni2 with SMTP id i2so12862097ggn.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 14:13:24 -0800 (PST)
Message-ID: <4F037D84.5070502@gmail.com>
Date: Tue, 03 Jan 2012 17:13:24 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 8/8] mm: add vmstat counters for tracking PCP drains
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com> <1325499859-2262-9-git-send-email-gilad@benyossef.com> <4F033F44.6020403@gmail.com> <CAOtvUMc259XZ5BdOqys3Kbv_u=Qa0matnuFyGrJhMPLtRKKkUA@mail.gmail.com>
In-Reply-To: <CAOtvUMc259XZ5BdOqys3Kbv_u=Qa0matnuFyGrJhMPLtRKKkUA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>

(1/3/12 2:00 PM), Gilad Ben-Yossef wrote:
> 2012/1/3 KOSAKI Motohiro<kosaki.motohiro@gmail.com>:
>> (1/2/12 5:24 AM), Gilad Ben-Yossef wrote:
>>> This patch introduces two new vmstat counters: pcp_global_drain
>>> that counts the number of times a per-cpu pages global drain was
>>> requested and pcp_global_ipi_saved that counts the number of times
>>> the number of CPUs with per-cpu pages in any zone were less then
>>> 1/2 of the number of online CPUs.
>>>
>>> The patch purpose is to show the usefulness of only sending an IPI
>>> asking to drain per-cpu pages to CPUs that actually have them
>>> instead of a blind global IPI. It is probably not useful by itself.
> ...
>
>               }
>>>        on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);
>>> +
>>> +     count_vm_event(PCP_GLOBAL_DRAIN);
>>> +     if (cpumask_weight(cpus_with_pcps)<    (cpumask_weight(cpu_online_mask) / 2))
>>> +             count_vm_event(PCP_GLOBAL_IPI_SAVED);
>>
>> NAK.
>>
>> PCP_GLOBAL_IPI_SAVED is only useful at development phase. I can't
>> imagine normal admins use it.
>
> As the description explains, the purpose of the patch is to show why i
> claim the previous
> patch is useful. I did not meant it to be applied to mainline. My
> apologies for not
> stating this more clearly. I agree it is not useful for an admin,
> although perhaps PCP_GLOBAL_DRAIN
> alone might - I am not sure?

Until we found a good usecase, we shouldn't append any stat. It is not
zero overhead even though nobody uses.

That's why I almost always disagree adding statistics from point of 
developers view.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
