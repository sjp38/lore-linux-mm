Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id EF4736B004D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:50:50 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 8 Apr 2013 15:50:49 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id B0F9C6E804F
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:50:38 -0400 (EDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r38Jof16270692
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 15:50:41 -0400
Received: from d01av05.pok.ibm.com (loopback [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r38Joejf022729
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 15:50:41 -0400
Message-ID: <51631F89.5090407@linux.vnet.ibm.com>
Date: Mon, 08 Apr 2013 12:50:33 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: when handling percpu_pagelist_fraction, use on_each_cpu()
 to set percpu pageset fields.
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com> <CAOtvUMdT0-oQMTsHAjFqL6K8vrLeCcXG2hX-sShxu6GGRBPxJw@mail.gmail.com> <5162FE4D.7020308@linux.vnet.ibm.com>
In-Reply-To: <5162FE4D.7020308@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/08/2013 10:28 AM, Cody P Schafer wrote:
> On 04/08/2013 05:20 AM, Gilad Ben-Yossef wrote:
>> On Fri, Apr 5, 2013 at 11:33 PM, Cody P Schafer
>> <cody@linux.vnet.ibm.com> wrote:
>>> In free_hot_cold_page(), we rely on pcp->batch remaining stable.
>>> Updating it without being on the cpu owning the percpu pageset
>>> potentially destroys this stability.
>>>
>>> Change for_each_cpu() to on_each_cpu() to fix.
>>
>> Are you referring to this? -
>
> This was the case I noticed.
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
> Potentially, yes. Note that this was simply the one case I noticed,
> rather than certainly the only case.
>
> I also wonder whether there could be unexpected interactions between
> ->high and ->batch not changing together atomically. For example, could
> adjusting this knob cause ->batch to rise enough that it is greater than
> the previous ->high? If the code above then runs with the previous
> ->high, ->count wouldn't be correct (checking this inside
> free_pcppages_bulk() might help on this one issue).
>
>> Now the batch value used is stable and you don't have to IPI every CPU
>> in the system just to change a config knob...
>
> Is this really considered an issue? I wouldn't have expected someone to
> adjust the config knob often enough (or even more than once) to cause
> problems. Of course as a "It'd be nice" thing, I completely agree.

Would using schedule_on_each_cpu() instead of on_each_cpu() be an 
improvement, in your opinion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
