Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C4E1A6B00B6
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:55:19 -0400 (EDT)
Received: by qyk34 with SMTP id 34so297921qyk.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 18:55:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikVueTjihngtC2rsoeqkUb5Wg-zeEFH1HKgcuuo@mail.gmail.com>
References: <20101016043331.GA3177@darkstar>
	<20101018164647.bc928c78.akpm@linux-foundation.org>
	<AANLkTikVueTjihngtC2rsoeqkUb5Wg-zeEFH1HKgcuuo@mail.gmail.com>
Date: Tue, 19 Oct 2010 09:55:17 +0800
Message-ID: <AANLkTi=t2U5wa_7pqcb1pAq6p_x7VqYKbfMDZ10q+Geq@mail.gmail.com>
Subject: Re: [PATCH 1/2] Add vzalloc shortcut
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 9:27 AM, Dave Young <hidave.darkstar@gmail.com> wro=
te:
> On Tue, Oct 19, 2010 at 7:46 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Sat, 16 Oct 2010 12:33:31 +0800
>> Dave Young <hidave.darkstar@gmail.com> wrote:
>>
>>> Add vzalloc for convinience of vmalloc-then-memset-zero case
>>>
>>> Use __GFP_ZERO in vzalloc to zero fill the allocated memory.
>>>
>>> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
>>> ---
>>> =C2=A0include/linux/vmalloc.h | =C2=A0 =C2=A01 +
>>> =C2=A0mm/vmalloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 13=
 +++++++++++++
>>> =C2=A02 files changed, 14 insertions(+)
>>>
>>> --- linux-2.6.orig/include/linux/vmalloc.h =C2=A0 =C2=A02010-08-22 15:3=
1:38.000000000 +0800
>>> +++ linux-2.6/include/linux/vmalloc.h 2010-10-16 10:50:54.739996121 +08=
00
>>> @@ -53,6 +53,7 @@ static inline void vmalloc_init(void)
>>> =C2=A0#endif
>>>
>>> =C2=A0extern void *vmalloc(unsigned long size);
>>> +extern void *vzalloc(unsigned long size);
>>> =C2=A0extern void *vmalloc_user(unsigned long size);
>>> =C2=A0extern void *vmalloc_node(unsigned long size, int node);
>>> =C2=A0extern void *vmalloc_exec(unsigned long size);
>>> --- linux-2.6.orig/mm/vmalloc.c =C2=A0 =C2=A0 =C2=A0 2010-08-22 15:31:3=
9.000000000 +0800
>>> +++ linux-2.6/mm/vmalloc.c =C2=A0 =C2=A02010-10-16 10:51:57.126665918 +=
0800
>>> @@ -1604,6 +1604,19 @@ void *vmalloc(unsigned long size)
>>> =C2=A0EXPORT_SYMBOL(vmalloc);
>>>
>>> =C2=A0/**
>>> + * =C2=A0 vzalloc =C2=A0- =C2=A0allocate virtually contiguous memory w=
ith zero filled
>>
>> s/filled/fill/
>
> Thanks, Will fix
>
>>
>>> + * =C2=A0 @size: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0allocation size
>>> + * =C2=A0 Allocate enough pages to cover @size from the page level
>>> + * =C2=A0 allocator and map them into contiguous kernel virtual space.
>>> + */
>>> +void *vzalloc(unsigned long size)
>>> +{
>>> + =C2=A0 =C2=A0 return __vmalloc_node(size, 1, GFP_KERNEL | __GFP_HIGHM=
EM | __GFP_ZERO,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PAGE_KERNEL, -1, __builtin_return_address(0));
>>> +}
>>> +EXPORT_SYMBOL(vzalloc);
>>
>> We'd need to add the same interface to nommu, please.
>
> Ok, will do
>
> Minchan kim, thanks as well. I missed your comments about nommu before.
>
>>
>> Also, a slightly better implementation would be
>>
>> static inline void *__vmalloc_node_flags(unsigned long size, gfp_t flags=
)
>> {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return __vmalloc_node(size, 1, flags, PAGE_KE=
RNEL, -1,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__builtin_return_address(0));
>> }

Is this better? might __vmalloc_node_flags would be used by other than vmal=
loc?

static inline void *__vmalloc_node_flags(unsigned long size, int node,
gfp_t flags)

>>
>> void *vzalloc(unsigned long size)
>> {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return __vmalloc_node_flags(size,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0GFP_KERNEL | __GFP_HIGHMEM | __GFP=
_ZERO);
>> }
>>
>> void *vmalloc(unsigned long size)
>> {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return __vmalloc_node_flags(size, GFP_KERNEL =
| __GFP_HIGHMEM);
>> }
>>
>> just to avoid code duplication (and possible later errors derived from i=
t).
>>
>> Perhaps it should be always_inline, so the __builtin_return_address()
>> can't get broken.
>>
>> Or just leave it the way you had it :)
>
> Andrew, your suggestion is cleaner and better. I will do as yours.
>
> --
> Regards
> dave
>



--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
