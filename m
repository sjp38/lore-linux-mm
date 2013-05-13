Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D460A6B008A
	for <linux-mm@kvack.org>; Mon, 13 May 2013 16:48:24 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 13 May 2013 14:48:18 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C4A501FF0026
	for <linux-mm@kvack.org>; Mon, 13 May 2013 14:42:57 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DKlgCd072260
	for <linux-mm@kvack.org>; Mon, 13 May 2013 14:47:44 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DKoesm018342
	for <linux-mm@kvack.org>; Mon, 13 May 2013 14:50:42 -0600
Message-ID: <5191515F.8020406@linux.vnet.ibm.com>
Date: Mon, 13 May 2013 13:47:27 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND v3 00/11] mm: fixup changers of per cpu pageset's
 ->high and ->batch
References: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com> <CAOJsxLF7xCiJmNn71zuNPGx1WzSj2BKeMVGXctfzvZODqVVU-A@mail.gmail.com>
In-Reply-To: <CAOJsxLF7xCiJmNn71zuNPGx1WzSj2BKeMVGXctfzvZODqVVU-A@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/13/2013 12:20 PM, Pekka Enberg wrote:
> Hi Cody,
>
> On Mon, May 13, 2013 at 10:08 PM, Cody P Schafer
> <cody@linux.vnet.ibm.com> wrote:
>> "Problems" with the current code:
>>   1. there is a lack of synchronization in setting ->high and ->batch in
>>      percpu_pagelist_fraction_sysctl_handler()
>>   2. stop_machine() in zone_pcp_update() is unnecissary.
>>   3. zone_pcp_update() does not consider the case where percpu_pagelist_fraction is non-zero
>
> Maybe it's just me but I find the above problem description confusing.
> How does the problem manifest itself?

1. I've not reproduced this causing issues.
2. Calling zone_pcp_update() is slow.
3. Not reproduced either, but would cause percpu_pagelist_fraction (set 
via sysctl) to be ignored after a call to zone_pcp_update() (for 
example, after a memory hotplug).

> How did you find about it?

I'm writing some code that resizes zones and thus uses 
zone_pcp_update(), and fixing broken things along the way.

> Why
> do we need to fix all three problems in the same patch set?

They all affect the same bit of code and fixing all of them means 
restructuring the both of the sites where ->high and ->batch are set.

Additionally, splitting it out (if possible) would make it less clear 
what the overall goal is, and would mean a few inter-patchset 
dependencies, which are undesirable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
