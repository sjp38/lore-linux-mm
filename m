Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id A701C6B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 01:41:35 -0500 (EST)
Received: by pfbo64 with SMTP id o64so40563807pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 22:41:35 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id fi15si1203040pac.191.2015.12.14.22.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 22:41:34 -0800 (PST)
Received: by pabur14 with SMTP id ur14so117845711pab.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 22:41:34 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [RFC] mm: change find_vma() function
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151214211132.GA7390@node.shutemov.name>
Date: Tue, 15 Dec 2015 14:41:21 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <5603C6DF-DDA5-4B57-9608-63335282B966@gmail.com>
References: <1450090945-4020-1-git-send-email-yalin.wang2010@gmail.com> <20151214121107.GB4201@node.shutemov.name> <20151214175509.GA25681@redhat.com> <20151214211132.GA7390@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Oleg Nesterov <oleg@redhat.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, gang.chen.5i5j@gmail.com, mhocko@suse.com, kwapulinski.piotr@gmail.com, aarcange@redhat.com, dcashman@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Dec 15, 2015, at 05:11, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>=20
> On Mon, Dec 14, 2015 at 06:55:09PM +0100, Oleg Nesterov wrote:
>> On 12/14, Kirill A. Shutemov wrote:
>>>=20
>>> On Mon, Dec 14, 2015 at 07:02:25PM +0800, yalin wang wrote:
>>>> change find_vma() to break ealier when found the adderss
>>>> is not in any vma, don't need loop to search all vma.
>>>>=20
>>>> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
>>>> ---
>>>> mm/mmap.c | 3 +++
>>>> 1 file changed, 3 insertions(+)
>>>>=20
>>>> diff --git a/mm/mmap.c b/mm/mmap.c
>>>> index b513f20..8294c9b 100644
>>>> --- a/mm/mmap.c
>>>> +++ b/mm/mmap.c
>>>> @@ -2064,6 +2064,9 @@ struct vm_area_struct *find_vma(struct =
mm_struct *mm, unsigned long addr)
>>>> 			vma =3D tmp;
>>>> 			if (tmp->vm_start <=3D addr)
>>>> 				break;
>>>> +			if (!tmp->vm_prev || tmp->vm_prev->vm_end <=3D =
addr)
>>>> +				break;
>>>> +
>>>=20
>>> This 'break' would return 'tmp' as found vma.
>>=20
>> But this would be right?
>=20
> Hm. Right. Sorry for my tone.
>=20
> I think the right condition is 'tmp->vm_prev->vm_end < addr', not '<=3D'=
 as
> vm_end is the first byte after the vma. But it's equivalent in =
practice
> here.
>=20
this should be <=3D here,
because vma=E2=80=99s effect address space doesn=E2=80=99t include =
vm_end add,
so if an address vm_end <=3D add , this means this addr don=E2=80=99t =
belong to this vma,

> Anyway, I don't think it's possible to gain anything measurable from =
this
> optimization.
>=20
the advantage is that if addr don=E2=80=99t belong to any vma, we =
don=E2=80=99t need loop all vma,
we can break earlier if we found the most closest vma which vma->end_add =
> addr,
>>=20
>> Not that I think this optimization makes sense, I simply do not know,
>> but to me this change looks technically correct at first glance...
>>=20
>> But the changelog is wrong or I missed something. This change can =
stop
>> the main loop earlier; if "tmp" is the first vma,
>=20
> For the first vma, we don't get anything comparing to what we have =
now:
> check for !rb_node on the next iteration would have the same trade off =
and
> effect as the proposed check.
Yes
>=20
>> or if the previous one is below the address.
>=20
> Yes, but would it compensate additional check on each 'tmp->vm_end > =
addr'
> iteration to the point? That's not obvious.
>=20
>> Or perhaps I just misread that "not in any vma" note in the =
changelog.
>>=20
>> No?
>>=20
>> Oleg.
>>=20

i have test it, it works fine. :)
Thanks




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
