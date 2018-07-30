Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA9206B000A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 09:37:17 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r184-v6so13168892ith.0
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 06:37:17 -0700 (PDT)
Received: from us.icdsoft.com (us.icdsoft.com. [192.252.146.184])
        by mx.google.com with ESMTPS id f10-v6si6835636iob.117.2018.07.30.06.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 06:37:16 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
From: Georgi Nikolov <gnikolov@icdsoft.com>
References: <bug-200651-27@https.bugzilla.kernel.org/>
 <20180725125239.b591e4df270145f9064fe2c5@linux-foundation.org>
 <cd474b37-263f-b186-2024-507a9a4e12ae@suse.cz>
 <20180726072622.GS28386@dhcp22.suse.cz>
 <67d5e4ef-c040-6852-ad93-6f2528df0982@suse.cz>
 <20180726074219.GU28386@dhcp22.suse.cz>
 <36043c6b-4960-8001-4039-99525dcc3e05@suse.cz>
 <20180726080301.GW28386@dhcp22.suse.cz>
 <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
 <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
 <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
Message-ID: <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
Date: Mon, 30 Jul 2018 16:37:07 +0300
MIME-Version: 1.0
In-Reply-To: <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 07/26/2018 12:02 PM, Georgi Nikolov wrote:
> On 07/26/2018 11:48 AM, Vlastimil Babka wrote:
>> On 07/26/2018 10:31 AM, Vlastimil Babka wrote:
>>> On 07/26/2018 10:03 AM, Michal Hocko wrote:
>>>> On Thu 26-07-18 09:50:45, Vlastimil Babka wrote:
>>>>> On 07/26/2018 09:42 AM, Michal Hocko wrote:
>>>>>> On Thu 26-07-18 09:34:58, Vlastimil Babka wrote:
>>>>>>> On 07/26/2018 09:26 AM, Michal Hocko wrote:
>>>>>>>> On Thu 26-07-18 09:18:57, Vlastimil Babka wrote:
>>>>>>>>> On 07/25/2018 09:52 PM, Andrew Morton wrote:
>>>>>>>>>
>>>>>>>>> This is likely the kvmalloc() in xt_alloc_table_info(). Between=
 4.13 and
>>>>>>>>> 4.17 it shouldn't use __GFP_NORETRY, but looks like commit 0537=
250fdc6c
>>>>>>>>> ("netfilter: x_tables: make allocation less aggressive") was ba=
ckported
>>>>>>>>> to 4.14. Removing __GFP_NORETRY might help here, but bring back=
 other
>>>>>>>>> issues. Less than 4MB is not that much though, maybe find some =
"sane"
>>>>>>>>> limit and use __GFP_NORETRY only above that?
>>>>>>>> I have seen the same report via http://lkml.kernel.org/r/df6f501=
c-8546-1f55-40b1-7e3a8f54d872@icdsoft.com
>>>>>>>> and the reported confirmed that kvmalloc is not a real culprit
>>>>>>>> http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@ic=
dsoft.com
>>>>>>> Hmm but that was revert of eacd86ca3b03 ("net/netfilter/x_tables.=
c: use
>>>>>>> kvmalloc() in xt_alloc_table_info()") which was the 4.13 commit t=
hat
>>>>>>> removed __GFP_NORETRY (there's no __GFP_NORETRY under net/netfilt=
er in
>>>>>>> v4.14). I assume it was reverted on top of vanilla v4.14 as there=
 would
>>>>>>> be conflict on the stable with 0537250fdc6c backport. So what sho=
uld be
>>>>>>> tested to be sure is either vanilla v4.14 without stable backport=
s, or
>>>>>>> latest v4.14.y with revert of 0537250fdc6c.
>>>>>> But 0537250fdc6c simply restored the previous NORETRY behavior fro=
m
>>>>>> before eacd86ca3b03. So whatever causes these issues doesn't seem =
to be
>>>>>> directly related to the kvmalloc change. Or do I miss what you are=

>>>>>> saying?
>>>>> I'm saying that although it's not a regression, as you say (the
>>>>> vmalloc() there was only for a few kernel versions called without
>>>>> __GFP_NORETRY), it's still possible that removing __GFP_NORETRY wil=
l fix
>>>>> the issue and thus we will rule out other possibilities.
>>>> http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsof=
t.com
>>>> claims that reverting eacd86ca3b03 didn't really help.
>> Ah, I see, that mail thread references a different kernel bugzilla
>> #200639 which doesn't mention 4.14, but outright blames commit
>> eacd86ca3b03. Yet the alloc fail message contains __GFP_NORETRY, so I
>> still suspect the kernel also had 0537250fdc6c backport. Georgi can yo=
u
>> please clarify which exact kernel version had the alloc failures, and
>> how exactly you tested the revert (which version was the baseline for
>> revert). Thanks.
>>
>>> Of course not. eacd86ca3b03 *removed* __GFP_NORETRY, so the revert
>>> reintroduced it. I tried to explain it in the quoted part above start=
ing
>>> with "Hmm but that was revert of eacd86ca3b03 ...". What I'm saying i=
s
>>> that eacd86ca3b03 might have actually *fixed* (or rather prevented) t=
his
>>> alloc failure, if there was not 0537250fdc6c and its 4.14 stable
>>> backport (the kernel bugzilla report says 4.14, I'm assuming new enou=
gh
>>> stable to contain 0537250fdc6c as the failure message contains
>>> __GFP_NORETRY).
>>>
>>> The mail you reference also says "seems that old version is masking
>>> errors", which confirms that we are indeed looking at the right
>>> vmalloc(), because eacd86ca3b03 also removed __GFP_NOWARN there (and
>>> thus the revert reintroduced it).
>>>
>>>
>
> Hello,
> Kernel that has allocation failures is 4.14.50.
> Here is the patch applied to this version which masks errors:
>
> --- net/netfilter/x_tables.c=C2=A0=C2=A0=C2=A0 2018-06-18 14:18:21.1383=
47416 +0300
> +++ net/netfilter/x_tables.c=C2=A0=C2=A0=C2=A0 2018-07-26 11:58:01.7219=
32962 +0300
> @@ -1059,9 +1059,19 @@
> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0* than shoot all processes down before r=
ealizing there is nothing
> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0* more to reclaim.
> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0*/
> -=C2=A0=C2=A0=C2=A0 info =3D kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
> +/*=C2=A0=C2=A0=C2=A0 info =3D kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY)=
;
> =C2=A0=C2=A0=C2=A0=C2=A0 if (!info)
> =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return NULL;
> +*/
> +
> +=C2=A0=C2=A0=C2=A0 if (sz <=3D (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))=

> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 info =3D kmalloc(sz, GFP_KERNEL =
| __GFP_NOWARN | __GFP_NORETRY);
> +=C2=A0=C2=A0=C2=A0 if (!info) {
> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 info =3D __vmalloc(sz, GFP_KERNE=
L | __GFP_NOWARN | __GFP_NORETRY,
> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0PAGE_KERNEL);
> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 if (!info)
> +=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return NULL;
> +=C2=A0=C2=A0=C2=A0 }
> =C2=A0
> =C2=A0=C2=A0=C2=A0=C2=A0 memset(info, 0, sizeof(*info));
> =C2=A0=C2=A0=C2=A0=C2=A0 info->size =3D size;
>
>
> I will try to reproduce it with only
>
> info =3D kvmalloc(sz, GFP_KERNEL);
>
> Regards,
>
> --
> Georgi Nikolov
>

Hello,

Without GFP_NORETRY problem disappears.

What is correct way to fix it.
- inside xt_alloc_table_info remove GFP_NORETRY from kvmalloc or add this=
 flag only for sizes bigger than some threshold
- inside kvmalloc_node remove GFP_NORETRY from __vmalloc_node_flags_calle=
r (i don't know if it honors this flag, or the problem is elsewhere)

Regards,

--
Georgi Nikolov
