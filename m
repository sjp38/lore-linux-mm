Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A04106B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 20:26:50 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id e15so3093885oic.1
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 17:26:50 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id v7si386286otd.233.2018.02.08.17.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 17:26:49 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB
 hugepage
Date: Fri, 9 Feb 2018 01:17:48 +0000
Message-ID: <84c6e1f7-e693-30f3-d208-c3a094d9e3b0@ah.jp.nec.com>
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
 <1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
 <20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
 <87fu6bfytm.fsf@e105922-lin.cambridge.arm.com>
In-Reply-To: <87fu6bfytm.fsf@e105922-lin.cambridge.arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F2F60818CFB5C248A8867FED819ECCCC@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 02/08/2018 09:30 PM, Punit Agrawal wrote:
> Horiguchi-san,
>=20
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
>=20
>> Hi Punit,
>>
>> On Mon, Feb 05, 2018 at 03:05:43PM +0000, Punit Agrawal wrote:
>>> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
>>>
>=20
> [...]
>=20
>>>>
>>>> You can easily reproduce this by calling madvise(MADV_HWPOISON) twice =
on
>>>> a 1GB hugepage. This happens because get_user_pages_fast() is not awar=
e
>>>> of a migration entry on pud that was created in the 1st madvise() even=
t.
>>>
>>> Maybe I'm doing something wrong but I wasn't able to reproduce the issu=
e
>>> using the test at the end. I get -
>>>
>>>     $ sudo ./hugepage
>>>
>>>     Poisoning page...once
>>>     [  121.295771] Injecting memory failure for pfn 0x8300000 at proces=
s virtual address 0x400000000000
>>>     [  121.386450] Memory failure: 0x8300000: recovery action for huge =
page: Recovered
>>>
>>>     Poisoning page...once again
>>>     madvise: Bad address
>>>
>>> What am I missing?
>>
>> The test program below is exactly what I intended, so you did right
>> testing.
>=20
> Thanks for the confirmation. And the flow outline below.=20
>=20
>> I try to guess what could happen. The related code is like below:
>>
>>   static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long =
end,
>>                            int write, struct page **pages, int *nr)
>>   {
>>           ...
>>           do {
>>                   pud_t pud =3D READ_ONCE(*pudp);
>>
>>                   next =3D pud_addr_end(addr, end);
>>                   if (pud_none(pud))
>>                           return 0;
>>                   if (unlikely(pud_huge(pud))) {
>>                           if (!gup_huge_pud(pud, pudp, addr, next, write=
,
>>                                             pages, nr))
>>                                   return 0;
>>
>> pud_none() always returns false for hwpoison entry in any arch.
>> I guess that pud_huge() could behave in undefined manner for hwpoison en=
try
>> because pud_huge() assumes that a given pud has the present bit set, whi=
ch
>> is not true for hwpoison entry.
>=20
> This is where the arm64 helpers behaves differently (though more by
> chance then design). A poisoned pud passes pud_huge() as it doesn't seem
> to be explicitly checking for the present bit.
>=20
>     int pud_huge(pud_t pud)
>     {
>             return pud_val(pud) && !(pud_val(pud) & PUD_TABLE_BIT);
>     }
>=20
>=20
> This doesn't lead to a crash as the first thing gup_huge_pud() does is
> check for pud_access_permitted() which does check for the present bit.
>=20
> I was able to crash the kernel by changing pud_huge() to check for the
> present bit.
>=20
>> As a result, pud_huge() checks an irrelevant bit used for other
>> purpose depending on non-present page table format of each arch. If
>> pud_huge() returns false for hwpoison entry, we try to go to the lower
>> level and the kernel highly likely to crash. So I guess your kernel
>> fell back the slow path and somehow ended up with returning EFAULT.
>=20
> Makes sense. Due to the difference above on arm64, it ends up falling
> back to the slow path which eventually returns -EFAULT (via
> follow_hugetlb_page) for poisoned pages.
>=20
>>
>> So I don't think that the above test result means that errors are proper=
ly
>> handled, and the proposed patch should help for arm64.
>=20
> Although, the deviation of pud_huge() avoids a kernel crash the code
> would be easier to maintain and reason about if arm64 helpers are
> consistent with expectations by core code.
>=20
> I'll look to update the arm64 helpers once this patch gets merged. But
> it would be helpful if there was a clear expression of semantics for
> pud_huge() for various cases. Is there any version that can be used as
> reference?

Sorry if I misunderstand you, but with this patch there is no non-present
pud entry, so I feel that you don't have to change pud_huge() in arm64.

When we get to have non-present pud entries (by enabling hwpoison or 1GB
hugepage migration), we need to explicitly check pud_present in every page
table walk. So I think the current semantics is like:

  if (pud_none(pud))
          /* skip this entry */
  else if (pud_huge(pud))
          /* do something for pud-hugetlb */
  else
          /* go to next (pmd) level */

and after enabling hwpoison or migartion:

  if (pud_none(pud))
          /* skip this entry */
  else if (!pud_present(pud))
          /* do what we need to handle peculiar cases */
  else if (pud_huge(pud))
          /* do something for pud-hugetlb */
  else
          /* go to next (pmd) level */

What we did for pmd can also be a reference to what we do for pud.

>=20
> Also, do you know what the plans are for re-enabling hugepage poisoning
> disabled here?

I'd like to say yes, but it's not specific one because breaking pud isn't
a easy/simple task. But 1GB hugetlb is becoming more important, so we
might have to have code for it.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
