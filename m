Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5A26B0007
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 05:09:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b23so7118603wme.3
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 02:09:31 -0700 (PDT)
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id o20si3276527wro.121.2018.04.04.02.09.29
        for <linux-mm@kvack.org>;
        Wed, 04 Apr 2018 02:09:29 -0700 (PDT)
Subject: Re: [RFC] Per file OOM badness
References: <20180118170006.GG6584@dhcp22.suse.cz>
 <20180123152659.GA21817@castle.DHCP.thefacebook.com>
 <20180123153631.GR1526@dhcp22.suse.cz>
 <ccac4870-ced3-f169-17df-2ab5da468bf0@daenzer.net>
 <20180124092847.GI1526@dhcp22.suse.cz>
 <583f328e-ff46-c6a4-8548-064259995766@daenzer.net>
 <20180124110141.GA28465@dhcp22.suse.cz>
 <36b49523-792d-45f9-8617-32b6d9d77418@daenzer.net>
 <20180124115059.GC28465@dhcp22.suse.cz>
 <60e18da8-4d6e-dec9-7aef-ff003605d513@daenzer.net>
 <20180130102855.GY21609@dhcp22.suse.cz>
 <1522074988.1196.1.camel@pengutronix.de>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Message-ID: <3778a205-8b30-d147-b1f6-0a93d1de8beb@daenzer.net>
Date: Wed, 4 Apr 2018 11:09:25 +0200
MIME-Version: 1.0
In-Reply-To: <1522074988.1196.1.camel@pengutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Christian.Koenig@amd.com, linux-mm@kvack.org, amd-gfx@lists.freedesktop.org, Roman Gushchin <guro@fb.com>

On 2018-03-26 04:36 PM, Lucas Stach wrote:
> Am Dienstag, den 30.01.2018, 11:28 +0100 schrieb Michal Hocko:
>> On Tue 30-01-18 10:29:10, Michel DA?nzer wrote:
>>> On 2018-01-24 12:50 PM, Michal Hocko wrote:
>>>> On Wed 24-01-18 12:23:10, Michel DA?nzer wrote:
>>>>> On 2018-01-24 12:01 PM, Michal Hocko wrote:
>>>>>> On Wed 24-01-18 11:27:15, Michel DA?nzer wrote:
>>>>
>>>> [...]
>>>>>>> 2. If the OOM killer kills a process which is sharing BOs
>>>>>>> with another
>>>>>>> process, this should result in the other process dropping
>>>>>>> its references
>>>>>>> to the BOs as well, at which point the memory is released.
>>>>>>
>>>>>> OK. How exactly are those BOs mapped to the userspace?
>>>>>
>>>>> I'm not sure what you're asking. Userspace mostly uses a GEM
>>>>> handle to
>>>>> refer to a BO. There can also be userspace CPU mappings of the
>>>>> BO's
>>>>> memory, but userspace doesn't need CPU mappings for all BOs and
>>>>> only
>>>>> creates them as needed.
>>>>
>>>> OK, I guess you have to bear with me some more. This whole stack
>>>> is a
>>>> complete uknonwn. I am mostly after finding a boundary where you
>>>> can
>>>> charge the allocated memory to the process so that the oom killer
>>>> can
>>>> consider it. Is there anything like that? Except for the proposed
>>>> file
>>>> handle hack?
>>>
>>> How about the other way around: what APIs can we use to charge /
>>> "uncharge" memory to a process? If we have those, we can experiment
>>> with
>>> different places to call them.
>>
>> add_mm_counter() and I would add a new counter e.g. MM_KERNEL_PAGES.
> 
> So is anyone still working on this? This is hurting us bad enough that
> I don't want to keep this topic rotting for another year.
> 
> If no one is currently working on this I would volunteer to give the
> simple "just account private, non-shared buffers in process RSS" a
> spin.

Sounds good. FWIW, I think shared buffers can also be easily handled by
accounting them in each process which has a reference. But that's more
of a detail, shouldn't make a big difference overall either way.


-- 
Earthling Michel DA?nzer               |               http://www.amd.com
Libre software enthusiast             |             Mesa and X developer
