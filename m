Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E19EE6B0027
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 02:03:04 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id x11so6510115lbi.1
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 23:03:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5162FE4D.7020308@linux.vnet.ibm.com>
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
	<1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com>
	<CAOtvUMdT0-oQMTsHAjFqL6K8vrLeCcXG2hX-sShxu6GGRBPxJw@mail.gmail.com>
	<5162FE4D.7020308@linux.vnet.ibm.com>
Date: Tue, 9 Apr 2013 09:03:02 +0300
Message-ID: <CAOtvUMcUZsfXT1km89mm4Hng=K8hbkhgsJW6tgxufNH4Kwb7sg@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: when handling percpu_pagelist_fraction, use
 on_each_cpu() to set percpu pageset fields.
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 8, 2013 at 8:28 PM, Cody P Schafer <cody@linux.vnet.ibm.com> wrote:
> On 04/08/2013 05:20 AM, Gilad Ben-Yossef wrote:
>>
>> On Fri, Apr 5, 2013 at 11:33 PM, Cody P Schafer <cody@linux.vnet.ibm.com>
>> wrote:
>>>
>>> In free_hot_cold_page(), we rely on pcp->batch remaining stable.
>>> Updating it without being on the cpu owning the percpu pageset
>>> potentially destroys this stability.
>>>
>>> Change for_each_cpu() to on_each_cpu() to fix.
>>
>>
>> Are you referring to this? -
>
>
> This was the case I noticed.
>
>
>>
>> 1329         if (pcp->count >= pcp->high) {
>> 1330                 free_pcppages_bulk(zone, pcp->batch, pcp);
>> 1331                 pcp->count -= pcp->batch;
>> 1332         }
>>
>> I'm probably missing the obvious but won't it be simpler to do this in
>>   free_hot_cold_page() -
>>
>> 1329         if (pcp->count >= pcp->high) {
>> 1330                  unsigned int batch = ACCESS_ONCE(pcp->batch);
>> 1331                 free_pcppages_bulk(zone, batch, pcp);
>> 1332                 pcp->count -= batch;
>> 1333         }
>>
>
> Potentially, yes. Note that this was simply the one case I noticed, rather
> than certainly the only case.

OK, so perhaps the right thing to do is to understand what are (some of) the
other cases so that we may choose the right solution.

> I also wonder whether there could be unexpected interactions between ->high
> and ->batch not changing together atomically. For example, could adjusting
> this knob cause ->batch to rise enough that it is greater than the previous
> ->high? If the code above then runs with the previous ->high, ->count
> wouldn't be correct (checking this inside free_pcppages_bulk() might help on
> this one issue).

You are right, but that can be treated in  setup_pagelist_highmark()  e.g.:

3993 static void setup_pagelist_highmark(struct per_cpu_pageset *p,
3994                                 unsigned long high)
3995 {
3996         struct per_cpu_pages *pcp;
                unsigned int batch;
3997
3998         pcp = &p->pcp;
                /* We're about to mess with PCP in an non atomic fashion.
                   Put an intermediate safe value of batch and make sure it
                   is visible before any other change */
                pcp->batch = 1UL;
                smb_mb();

3999         pcp->high = high;

4000         batch = max(1UL, high/4);
4001         if ((high/4) > (PAGE_SHIFT * 8))
4002                 batch = PAGE_SHIFT * 8;

               pcp->batch = batch;
4003 }

Or we could use an RCU here, but that might be an overkill.

>
>
>> Now the batch value used is stable and you don't have to IPI every CPU
>> in the system just to change a config knob...
>
>
> Is this really considered an issue? I wouldn't have expected someone to
> adjust the config knob often enough (or even more than once) to cause
> problems. Of course as a "It'd be nice" thing, I completely agree.

Well, interfering unconditionally with other CPUs either via IPIs or
scheduling work
on them is a major headache for people that run work on machines with 4k CPUs,
especially the HPC or RT or combos from the finance and networking
users.

If this was the only little knob or trigger that does this, then maybe
it wont be so bad,
but the problem is there is a list of these little knobs and items
that potentially cause
cross machine interference, and the poor sys admin has to keep them
all in his or her
head: "Now, is it ok to pull this knob now, or will it cause an IPI s**t storm?"

We can never get rid of them all, but I'd really prefer to keep them
down to a minimum
if at all possible. Here, it looks to me that it is possible and that
the price is not great -
that is, the resulting code is not too hairy or none maintainable. At
least, that is how
it looks to me.

Thanks,
Gilad

-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
 -- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
