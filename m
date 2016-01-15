Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 61439828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 07:54:09 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id w75so103350954oie.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 04:54:09 -0800 (PST)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id m133si13298163oia.143.2016.01.15.04.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 04:54:08 -0800 (PST)
Received: by mail-oi0-x242.google.com with SMTP id j3so8378545oig.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 04:54:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160113081611.GA29313@hori1.linux.bs1.fc.nec.co.jp>
References: <1452138758-30031-1-git-send-email-liangchen.linux@gmail.com>
	<20160113081611.GA29313@hori1.linux.bs1.fc.nec.co.jp>
Date: Fri, 15 Jan 2016 20:54:08 +0800
Message-ID: <CAKhg4tLTYeBusZojA3ebmBw+_6PaXnS0Dcrgx=LCGpFJBTpRAw@mail.gmail.com>
Subject: Re: [PATCH V2] mm: mempolicy: skip non-migratable VMAs when setting MPOL_MF_LAZY
From: Liang Chen <liangchen.linux@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "riel@redhat.com" <riel@redhat.com>, "mgorman@suse.de" <mgorman@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Gavin Guo <gavin.guo@canonical.com>

Hi Naoya,

Yeah. Thanks for the reminding=EF=BC=81

vma_policy_mof doesn't need to be checked because with MPOL_MF_LAZY
do_mbind always sets the MPOL_F_MOF flag.
VM_HUGETLB and VM_MIXEDMAP vma should be excluded to avoid compound
pages being marked for migration and unexpected COWs when handling
hugetlb fault.

I will send a patch to add these check soon.

Thanks,
Liang

On Wed, Jan 13, 2016 at 4:16 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> Hello Liang,
>
> On Thu, Jan 07, 2016 at 11:52:38AM +0800, Liang Chen wrote:
>> MPOL_MF_LAZY is not visible from userspace since 'commit a720094ded8c
>> ("mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now"=
)'
>> , but it should still skip non-migratable VMAs such as VM_IO, VM_PFNMAP,
>> and VM_HUGETLB VMAs, and avoid useless overhead of minor faults.
>>
>> Signed-off-by: Liang Chen <liangchen.linux@gmail.com>
>> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
>> ---
>> Changes since v2:
>> - Add more description into the changelog
>>
>> We have been evaluating the enablement of MPOL_MF_LAZY again, and found
>> this issue. And we decided to push this patch upstream no matter if we
>> finally determine to propose re-enablement of MPOL_MF_LAZY or not. Since
>> it can be a potential problem even if MPOL_MF_LAZY is not enabled this
>> time.
>> ---
>>  mm/mempolicy.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 87a1779..436ff411 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -610,7 +610,8 @@ static int queue_pages_test_walk(unsigned long start=
, unsigned long end,
>>
>>       if (flags & MPOL_MF_LAZY) {
>>               /* Similar to task_numa_work, skip inaccessible VMAs */
>> -             if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
>> +             if (vma_migratable(vma) &&
>> +                     vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
>>                       change_prot_numa(vma, start, endvma);
>>               return 1;
>>       }
>
> task_numa_work() does more vma checks before entering change_prot_numa() =
like
> vma_policy_mof(), is_vm_hugetlb_page(), and (vma->vm_flags & VM_MIXEDMAP)=
.
> So is it better to use the same check set to limit the target vmas to aut=
o-numa
> enabled ones?
>
> Thanks,
> Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
