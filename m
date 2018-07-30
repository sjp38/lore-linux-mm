Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA56A6B0277
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:54:43 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g4-v6so163276itf.6
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:54:43 -0700 (PDT)
Received: from us.icdsoft.com (us.icdsoft.com. [192.252.146.184])
        by mx.google.com with ESMTPS id t134-v6si6078417itc.42.2018.07.30.08.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 08:54:42 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <cd474b37-263f-b186-2024-507a9a4e12ae@suse.cz>
 <20180726072622.GS28386@dhcp22.suse.cz>
 <67d5e4ef-c040-6852-ad93-6f2528df0982@suse.cz>
 <20180726074219.GU28386@dhcp22.suse.cz>
 <36043c6b-4960-8001-4039-99525dcc3e05@suse.cz>
 <20180726080301.GW28386@dhcp22.suse.cz>
 <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
 <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
 <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
 <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
 <20180730135744.GT24267@dhcp22.suse.cz>
From: Georgi Nikolov <gnikolov@icdsoft.com>
Message-ID: <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
Date: Mon, 30 Jul 2018 18:54:24 +0300
MIME-Version: 1.0
In-Reply-To: <20180730135744.GT24267@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 07/30/2018 04:57 PM, Michal Hocko wrote:

> On Mon 30-07-18 16:37:07, Georgi Nikolov wrote:
>> On 07/26/2018 12:02 PM, Georgi Nikolov wrote:
> [...]
>>> Here is the patch applied to this version which masks errors:
>>>
>>> --- net/netfilter/x_tables.c=C2=A0=C2=A0=C2=A0 2018-06-18 14:18:21.13=
8347416 +0300
>>> +++ net/netfilter/x_tables.c=C2=A0=C2=A0=C2=A0 2018-07-26 11:58:01.72=
1932962 +0300
>>> @@ -1059,9 +1059,19 @@
>>> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0* than shoot all processes down before=
 realizing there is nothing
>>> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0* more to reclaim.
>>> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0*/
>>> -=C2=A0=C2=A0=C2=A0 info =3D kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY)=
;
>>> +/*=C2=A0=C2=A0=C2=A0 info =3D kvmalloc(sz, GFP_KERNEL | __GFP_NORETR=
Y);
>>> =C2=A0=C2=A0=C2=A0=C2=A0 if (!info)
>>> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return NULL;
>>> +*/
>>> +
>>> +=C2=A0=C2=A0=C2=A0 if (sz <=3D (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER=
))
>>> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 info =3D kmalloc(sz, GFP_KERNE=
L | __GFP_NOWARN | __GFP_NORETRY);
>>> +=C2=A0=C2=A0=C2=A0 if (!info) {
>>> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 info =3D __vmalloc(sz, GFP_KER=
NEL | __GFP_NOWARN | __GFP_NORETRY,
>>> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0PAGE_KERNEL);
>>> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 if (!info)
>>> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return NULL;
>>> +=C2=A0=C2=A0=C2=A0 }
>>> =C2=A0
>>> =C2=A0=C2=A0=C2=A0=C2=A0 memset(info, 0, sizeof(*info));
>>> =C2=A0=C2=A0=C2=A0=C2=A0 info->size =3D size;
>>>
>>>
>>> I will try to reproduce it with only
>>>
>>> info =3D kvmalloc(sz, GFP_KERNEL);
>>>
>>> Regards,
>>>
>>> --
>>> Georgi Nikolov
>>>
>> Hello,
>>
>> Without GFP_NORETRY problem disappears.
> Hmm, there are two allocation paths which have __GFP_NORETRY here.
> I expect you have removed both of them, right?
>
> kvmalloc implicitly performs __GFP_NORETRY on kmalloc path but it
> doesn't have it for the vmalloc fallback. This would match
> kvmalloc(GFP_KERNEL). I thought you were testing this code path
> previously but there is some confusion flying around because you have
> claimed that the regressions started with eacd86ca3b036. If the
> regression is really with __GFP_NORETRY being used for the vmalloc
> fallback which would be kvmalloc(GFP_KERNEL | __GFP_NORETRY) then
> I am still confused because that would match the original code.

No i was wrong. The regression starts actually with 0537250fdc6c8.
- old code, which opencodes kvmalloc, is masking error but error is there=

- kvmalloc without GFP_NORETRY works fine, but probably can consume a
lot of memory - commit: eacd86ca3b036
- kvmalloc with GFP_NORETRY shows error - commit: 0537250fdc6c8

>> What is correct way to fix it.
>> - inside xt_alloc_table_info remove GFP_NORETRY from kvmalloc or add
>> this flag only for sizes bigger than some threshold
> This would reintroduce issue fixed by 0537250fdc6c8. Note that
> kvmalloc(GFP_KERNEL | __GFP_NORETRY) is more or less equivalent to the
> original code (well, except for __GFP_NOWARN).

So probably we should pass GFP_NORETRY only for large requests (above
some threshold).

>
>> - inside kvmalloc_node remove GFP_NORETRY from
>> __vmalloc_node_flags_caller (i don't know if it honors this flag, or
>> the problem is elsewhere)
> No, not really. This is basically equivalent to kvmalloc(GFP_KERNEL).
>
> I strongly suspect that this is not a regression in this code but rathe=
r
> a side effect of larger memory fragmentation caused by something else.
> In any case do you see this failure also without artificial test case
> with a standard workload?

Yes i can see failures with standard workload, in fact it was hard to
reproduce it.
Here is the error from production servers where allocation is smaller:
iptables: vmalloc: allocation failure, allocated 131072 of 225280 bytes,
mode:0x14010c0(GFP_KERNEL|__GFP_NORETRY), nodemask=3D(null)

I didn't understand if vmalloc honors GFP_NORETRY.

Regards,

--
Georgi Nikolov
