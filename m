Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1506A800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 06:23:16 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id m79so1060790lfm.17
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 03:23:16 -0800 (PST)
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id n6si4860ljb.72.2018.01.24.03.23.13
        for <linux-mm@kvack.org>;
        Wed, 24 Jan 2018 03:23:14 -0800 (PST)
Subject: Re: [RFC] Per file OOM badness
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz>
 <20180123152659.GA21817@castle.DHCP.thefacebook.com>
 <20180123153631.GR1526@dhcp22.suse.cz>
 <ccac4870-ced3-f169-17df-2ab5da468bf0@daenzer.net>
 <20180124092847.GI1526@dhcp22.suse.cz>
 <583f328e-ff46-c6a4-8548-064259995766@daenzer.net>
 <20180124110141.GA28465@dhcp22.suse.cz>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Message-ID: <36b49523-792d-45f9-8617-32b6d9d77418@daenzer.net>
Date: Wed, 24 Jan 2018 12:23:10 +0100
MIME-Version: 1.0
In-Reply-To: <20180124110141.GA28465@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, Christian.Koenig@amd.com, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Roman Gushchin <guro@fb.com>

On 2018-01-24 12:01 PM, Michal Hocko wrote:
> On Wed 24-01-18 11:27:15, Michel DA?nzer wrote:
>> On 2018-01-24 10:28 AM, Michal Hocko wrote:
> [...]
>>> So how exactly then helps to kill one of those processes? The memory
>>> stays pinned behind or do I still misunderstand?
>>
>> Fundamentally, the memory is only released once all references to the
>> BOs are dropped. That's true no matter how the memory is accounted for
>> between the processes referencing the BO.
>>
>>
>> In practice, this should be fine:
>>
>> 1. The amount of memory used for shared BOs is normally small compared
>> to the amount of memory used for non-shared BOs (and other things). So
>> regardless of how shared BOs are accounted for, the OOM killer should
>> first target the process which is responsible for more memory overall.
> 
> OK. So this is essentially the same as with the normal shared memory
> which is a part of the RSS in general.

Right.


>> 2. If the OOM killer kills a process which is sharing BOs with another
>> process, this should result in the other process dropping its references
>> to the BOs as well, at which point the memory is released.
> 
> OK. How exactly are those BOs mapped to the userspace?

I'm not sure what you're asking. Userspace mostly uses a GEM handle to
refer to a BO. There can also be userspace CPU mappings of the BO's
memory, but userspace doesn't need CPU mappings for all BOs and only
creates them as needed.


-- 
Earthling Michel DA?nzer               |               http://www.amd.com
Libre software enthusiast             |             Mesa and X developer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
