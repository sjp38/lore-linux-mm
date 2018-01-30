Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7076B0006
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 06:36:46 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g187so82138wmg.2
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 03:36:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w15sor619071edj.46.2018.01.30.03.36.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 03:36:44 -0800 (PST)
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
 <381a868c-78fd-d0d1-029e-a2cf4ab06d37@gmail.com>
 <20180130093145.GE25930@phenom.ffwll.local>
 <3db43c1a-59b8-af86-2b87-c783c629f512@daenzer.net>
 <3026d8c5-9313-cb8b-91ef-09c02baf27db@amd.com>
 <445628d3-677c-a9f8-171f-7d74a603c61d@daenzer.net>
 <dce6d244-36c7-7452-97f5-7437bd78cfcc@gmail.com>
 <e511ba10-7032-36cc-f22c-2f6bb05f9f6e@daenzer.net>
From: =?UTF-8?Q?Nicolai_H=c3=a4hnle?= <nhaehnle@gmail.com>
Message-ID: <82d5894f-f4ea-98cc-068a-5d470f5267df@gmail.com>
Date: Tue, 30 Jan 2018 12:36:37 +0100
MIME-Version: 1.0
In-Reply-To: <e511ba10-7032-36cc-f22c-2f6bb05f9f6e@daenzer.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>, christian.koenig@amd.com, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, amd-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org

On 30.01.2018 12:34, Michel DA?nzer wrote:
> On 2018-01-30 12:28 PM, Christian KA?nig wrote:
>> Am 30.01.2018 um 12:02 schrieb Michel DA?nzer:
>>> On 2018-01-30 11:40 AM, Christian KA?nig wrote:
>>>> Am 30.01.2018 um 10:43 schrieb Michel DA?nzer:
>>>>> [SNIP]
>>>>>> Would it be ok to hang onto potentially arbitrary mmget references
>>>>>> essentially forever? If that's ok I think we can do your process based
>>>>>> account (minus a few minor inaccuracies for shared stuff perhaps,
>>>>>> but no
>>>>>> one cares about that).
>>>>> Honestly, I think you and Christian are overthinking this. Let's try
>>>>> charging the memory to every process which shares a buffer, and go from
>>>>> there.
>>>> My problem is that this needs to be bullet prove.
>>>>
>>>> For example imagine an application which allocates a lot of BOs, then
>>>> calls fork() and let the parent process die. The file descriptor lives
>>>> on in the child process, but the memory is not accounted against the
>>>> child.
>>> What exactly are you referring to by "the file descriptor" here?
>>
>> The file descriptor used to identify the connection to the driver. In
>> other words our drm_file structure in the kernel.
>>
>>> What happens to BO handles in general in this case? If both parent and
>>> child process keep the same handle for the same BO, one of them
>>> destroying the handle will result in the other one not being able to use
>>> it anymore either, won't it?
>> Correct.
>>
>> That usage is actually not useful at all, but we already had
>> applications which did exactly that by accident.
>>
>> Not to mention that somebody could do it on purpose.
> 
> Can we just prevent child processes from using their parent's DRM file
> descriptors altogether? Allowing it seems like a bad idea all around.

Existing protocols pass DRM fds between processes though, don't they?

Not child processes perhaps, but special-casing that seems like awful 
design.

Cheers,
Nicolai
-- 
Lerne, wie die Welt wirklich ist,
Aber vergiss niemals, wie sie sein sollte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
