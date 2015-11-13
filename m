Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7CE6B0257
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 06:54:20 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so98384399pac.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 03:54:20 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id iw10si27027786pac.40.2015.11.13.03.54.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 03:54:20 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so98384255pac.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 03:54:19 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <5645BFAA.1070004@suse.cz>
Date: Fri, 13 Nov 2015 19:54:11 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com>
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com> <20151112092923.19ee53dd@gandalf.local.home> <5645BFAA.1070004@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> On Nov 13, 2015, at 18:47, Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
> On 11/12/2015 03:29 PM, Steven Rostedt wrote:
>> On Thu, 12 Nov 2015 16:21:02 +0800
>> yalin wang <yalin.wang2010@gmail.com> wrote:
>>=20
>>> This crash is caused by NULL pointer deference, in page_to_pfn() =
marco,
>>> when page =3D=3D NULL :
>>>=20
>>> [  182.639154 ] Unable to handle kernel NULL pointer dereference at =
virtual address 00000000
>>=20
>>=20
>>> add the trace point with TP_CONDITION(page),
>>=20
>> I wonder if we still want to trace even if page is NULL?
>=20
> I'd say we want to. There's even a "SCAN_PAGE_NULL" result defined for =
that case, and otherwise we would only have to guess why collapsing =
failed, which is the thing that the tracepoint should help us find out =
in the first place :)
>=20
>>> avoid trace NULL page.
>>>=20
>>> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
>>> ---
>>>  include/trace/events/huge_memory.h | 20 ++++++++++++--------
>>>  mm/huge_memory.c                   |  6 +++---
>>>  2 files changed, 15 insertions(+), 11 deletions(-)
>>>=20
>>> diff --git a/include/trace/events/huge_memory.h =
b/include/trace/events/huge_memory.h
>>> index 11c59ca..727647b 100644
>>> --- a/include/trace/events/huge_memory.h
>>> +++ b/include/trace/events/huge_memory.h
>>> @@ -45,12 +45,14 @@ SCAN_STATUS
>>>  #define EM(a, b)	{a, b},
>>>  #define EMe(a, b)	{a, b}
>>>=20
>>> -TRACE_EVENT(mm_khugepaged_scan_pmd,
>>> +TRACE_EVENT_CONDITION(mm_khugepaged_scan_pmd,
>>>=20
>>> -	TP_PROTO(struct mm_struct *mm, unsigned long pfn, bool writable,
>>> +	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
>>>  		 bool referenced, int none_or_zero, int status, int =
unmapped),
>>>=20
>>> -	TP_ARGS(mm, pfn, writable, referenced, none_or_zero, status, =
unmapped),
>>> +	TP_ARGS(mm, page, writable, referenced, none_or_zero, status, =
unmapped),
>>> +
>>> +	TP_CONDITION(page),
>>>=20
>>>  	TP_STRUCT__entry(
>>>  		__field(struct mm_struct *, mm)
>>> @@ -64,7 +66,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
>>>=20
>>>  	TP_fast_assign(
>>>  		__entry->mm =3D mm;
>>> -		__entry->pfn =3D pfn;
>>> +		__entry->pfn =3D page_to_pfn(page);
>>=20
>> Instead of the condition, we could have:
>>=20
>> 	__entry->pfn =3D page ? page_to_pfn(page) : -1;
>=20
> I agree. Please do it like this.
ok ,  i will send V5 patch .=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
