Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 6B4AD6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 15:27:50 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 9 Apr 2013 15:27:49 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E6FEE6E8097
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 15:27:37 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39JRdo8260260
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 15:27:39 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39JRKQR030993
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 13:27:20 -0600
Message-ID: <51646B8B.7010507@linux.vnet.ibm.com>
Date: Tue, 09 Apr 2013 12:27:07 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: when handling percpu_pagelist_fraction, use on_each_cpu()
 to set percpu pageset fields.
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com> <CAOtvUMdT0-oQMTsHAjFqL6K8vrLeCcXG2hX-sShxu6GGRBPxJw@mail.gmail.com> <5162FE4D.7020308@linux.vnet.ibm.com> <CAOtvUMcUZsfXT1km89mm4Hng=K8hbkhgsJW6tgxufNH4Kwb7sg@mail.gmail.com> <CAOtvUMc0Wzhr__U5P70Rf5yhp4zvK+vMgsAD3g0ew3a8R46Z6A@mail.gmail.com>
In-Reply-To: <CAOtvUMc0Wzhr__U5P70Rf5yhp4zvK+vMgsAD3g0ew3a8R46Z6A@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/08/2013 11:06 PM, Gilad Ben-Yossef wrote:
> On Tue, Apr 9, 2013 at 9:03 AM, Gilad Ben-Yossef <gilad@benyossef.com> wrote:
>
>>
>>> I also wonder whether there could be unexpected interactions between ->high
>>> and ->batch not changing together atomically. For example, could adjusting
>>> this knob cause ->batch to rise enough that it is greater than the previous
>>> ->high? If the code above then runs with the previous ->high, ->count
>>> wouldn't be correct (checking this inside free_pcppages_bulk() might help on
>>> this one issue).
>>
>> You are right, but that can be treated in  setup_pagelist_highmark()  e.g.:
>>
>> 3993 static void setup_pagelist_highmark(struct per_cpu_pageset *p,
>> 3994                                 unsigned long high)
>> 3995 {
>> 3996         struct per_cpu_pages *pcp;
>>                  unsigned int batch;
>> 3997
>> 3998         pcp = &p->pcp;
>>                  /* We're about to mess with PCP in an non atomic fashion.
>>                     Put an intermediate safe value of batch and make sure it
>>                     is visible before any other change */
>>                  pcp->batch = 1UL;
>>                  smb_mb();
>>
>> 3999         pcp->high = high;
>
> and i think I missed another needed barrier here:
>                    smp_mb();
>
>>
>> 4000         batch = max(1UL, high/4);
>> 4001         if ((high/4) > (PAGE_SHIFT * 8))
>> 4002                 batch = PAGE_SHIFT * 8;
>>
>>                 pcp->batch = batch;
>> 4003 }
>>
>

Yep, that appears to work, provided no additional users of ->batch and 
->high show up. It seems we'll also need some locking to prevent 
concurrent updaters, but that is relatively light weight.

I'll roll up a new patchset that uses this methodology.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
