Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB006B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 02:44:32 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id v137so6630713oia.21
        for <linux-mm@kvack.org>; Sat, 09 Dec 2017 23:44:32 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 29si4019438otz.363.2017.12.09.23.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Dec 2017 23:44:31 -0800 (PST)
Subject: Re: [PATCH v2] mmap.2: MAP_FIXED updated documentation
References: <20171204021411.4786-1-jhubbard@nvidia.com>
 <20171204105549.GA31332@rei>
 <efb6eae4-7f30-42c3-0efe-0ab5fbf0fdb4@nvidia.com>
 <20171205070510.aojohhvixijk3i27@dhcp22.suse.cz>
 <2cff594a-b481-269d-dd91-ff2cc2f4100a@nvidia.com>
 <20171206100118.GA13979@rei>
 <deb952d9-82bc-e737-8060-8fe7e70f44a1@nvidia.com>
 <20171207125805.GA1210@rei.lan> <20171207140221.GJ20234@dhcp22.suse.cz>
 <20171209171958.GB19862@localhost>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <8b9de658-81f4-f09b-cc7d-cef8ea0bd1ff@nvidia.com>
Date: Sat, 9 Dec 2017 23:44:29 -0800
MIME-Version: 1.0
In-Reply-To: <20171209171958.GB19862@localhost>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Michal Hocko <mhocko@kernel.org>
Cc: Cyril Hrubis <chrubis@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>

On 12/09/2017 09:19 AM, Pavel Machek wrote:
> On Thu 2017-12-07 15:02:21, Michal Hocko wrote:
>> On Thu 07-12-17 13:58:05, Cyril Hrubis wrote:
>>> Hi!
>>>>>> (It does seem unfortunate that the man page cannot help the programmer
>>>>>> actually write correct code here. He or she is forced to read the kernel
>>>>>> implementation, in order to figure out the true alignment rules. I was
>>>>>> hoping we could avoid that.)
>>>>>
>>>>> It would be nice if we had this information exported somehere so that we
>>>>> do not have to rely on per-architecture ifdefs.
>>>>>
>>>>> What about adding MapAligment or something similar to the /proc/meminfo?
>>>>>
>>>>
>>>> What's the use case you envision for that? I don't see how that would be
>>>> better than using SHMLBA, which is available at compiler time. Because 
>>>> unless someone expects to be able to run an app that was compiled for 
>>>> Arch X, on Arch Y (surely that's not requirement here?), I don't see how
>>>> the run-time check is any better.
>>>
>>> I guess that some kind of compile time constant in uapi headers will do
>>> as well, I'm really open to any solution that would expose this constant
>>> as some kind of official API.
>>
>> I am not sure this is really feasible. It is not only a simple alignment
>> thing. Look at ppc for example (slice_get_unmapped_area). Other
>> architectures might have even more complicated rules e.g. arm and its
>> cache_is_vipt_aliasing. Also this applies only on MAP_SHARED || file
>> backed mappings.
>>
>> I would really leave dogs sleeping... Trying to document all this in the
>> man page has chances to confuse more people than it has chances to help
>> those who already know all these nasty details.
> 
> You don't have to provide all the details, but warning that there's arch-
> specific magic would be nice...

Hi Pavel,

In version 4 of this patch (which oddly enough, I have trouble finding via
google, it only seems to show up in patchwork.kernel.org [1]), I phrased it 
like this:

    Don't interpret addr as a hint: place the mapping at  exactly  that
    address.   addr  must be suitably aligned: for most architectures a
    multiple of page size is sufficient;  however,  some  architectures
    may  impose additional restrictions. 

...which is basically what Cyril was asking for, in his early feedback.
Does that work for you?

(Maybe I need to repost that patch. In any case the CC's need updating,
at least.)

[1] https://patchwork.kernel.org/patch/10094905/

thanks,
-- 
John Hubbard
NVIDIA

> 								Pavel
> 
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
