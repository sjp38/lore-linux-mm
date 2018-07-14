Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFD46B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 20:28:08 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j5-v6so46098800oiw.13
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 17:28:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i3-v6sor17527479oia.184.2018.07.13.17.28.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 17:28:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180713085241.GA26980@hori1.linux.bs1.fc.nec.co.jp>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153074046610.27838.329669845580014251.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180713085241.GA26980@hori1.linux.bs1.fc.nec.co.jp>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 13 Jul 2018 17:28:05 -0700
Message-ID: <CAPcyv4jpn_NyBWjvj3s67Y8pvPDu0BODtqNJZQL81ryPeewvwA@mail.gmail.com>
Subject: Re: [PATCH v5 08/11] mm, memory_failure: Teach memory_failure() about
 dev_pagemap pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jul 13, 2018 at 1:52 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> On Wed, Jul 04, 2018 at 02:41:06PM -0700, Dan Williams wrote:
>>     mce: Uncorrected hardware memory error in user-access at af34214200
>>     {1}[Hardware Error]: It has been corrected by h/w and requires no fu=
rther action
>>     mce: [Hardware Error]: Machine check events logged
>>     {1}[Hardware Error]: event severity: corrected
>>     Memory failure: 0xaf34214: reserved kernel page still referenced by =
1 users
>>     [..]
>>     Memory failure: 0xaf34214: recovery action for reserved kernel page:=
 Failed
>>     mce: Memory error not recovered
>>
>> In contrast to typical memory, dev_pagemap pages may be dax mapped. With
>> dax there is no possibility to map in another page dynamically since dax
>> establishes 1:1 physical address to file offset associations. Also
>> dev_pagemap pages associated with NVDIMM / persistent memory devices can
>> internal remap/repair addresses with poison. While memory_failure()
>> assumes that it can discard typical poisoned pages and keep them
>> unmapped indefinitely, dev_pagemap pages may be returned to service
>> after the error is cleared.
>>
>> Teach memory_failure() to detect and handle MEMORY_DEVICE_HOST
>> dev_pagemap pages that have poison consumed by userspace. Mark the
>> memory as UC instead of unmapping it completely to allow ongoing access
>> via the device driver (nd_pmem). Later, nd_pmem will grow support for
>> marking the page back to WB when the error is cleared.
>
> By the way, what happens if madvise(MADV_SOFT_OFFLINE) is called on
> a dev_pagemap page?  I'm not sure that cmci can be triggered on the
> nvdimm device, but this injection interface is open for such a case.
> Maybe simply ignoring the event is an expected behavior?

Yeah, I should explicitly block attempts to MADV_SOFT_OFFLINE a
dev_pagemap page because they are never onlined. They'll never appear
on an lru and never be available via the page allocator.

>
> A few comments/quetions below ...
>
>>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Christoph Hellwig <hch@lst.de>
>> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  include/linux/mm.h  |    1
>>  mm/memory-failure.c |  124 ++++++++++++++++++++++++++++++++++++++++++++=
++++++-
>>  2 files changed, 123 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index a0fbb9ffe380..374e5e9284f7 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2725,6 +2725,7 @@ enum mf_action_page_type {
>>       MF_MSG_TRUNCATED_LRU,
>>       MF_MSG_BUDDY,
>>       MF_MSG_BUDDY_2ND,
>> +     MF_MSG_DAX,
>>       MF_MSG_UNKNOWN,
>>  };
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 4d70753af59c..161aa1b70212 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -55,6 +55,7 @@
>>  #include <linux/hugetlb.h>
>>  #include <linux/memory_hotplug.h>
>>  #include <linux/mm_inline.h>
>> +#include <linux/memremap.h>
>>  #include <linux/kfifo.h>
>>  #include <linux/ratelimit.h>
>>  #include "internal.h"
>> @@ -263,6 +264,39 @@ void shake_page(struct page *p, int access)
>>  }
>>  EXPORT_SYMBOL_GPL(shake_page);
>>
>> +static unsigned long mapping_size(struct page *page, struct vm_area_str=
uct *vma)
>> +{
>> +     unsigned long address =3D vma_address(page, vma);
>> +     pgd_t *pgd;
>> +     p4d_t *p4d;
>> +     pud_t *pud;
>> +     pmd_t *pmd;
>> +     pte_t *pte;
>> +
>> +     pgd =3D pgd_offset(vma->vm_mm, address);
>> +     if (!pgd_present(*pgd))
>> +             return 0;
>> +     p4d =3D p4d_offset(pgd, address);
>> +     if (!p4d_present(*p4d))
>> +             return 0;
>> +     pud =3D pud_offset(p4d, address);
>> +     if (!pud_present(*pud))
>> +             return 0;
>> +     if (pud_devmap(*pud))
>> +             return PUD_SIZE;
>> +     pmd =3D pmd_offset(pud, address);
>> +     if (!pmd_present(*pmd))
>> +             return 0;
>> +     if (pmd_devmap(*pmd))
>> +             return PMD_SIZE;
>> +     pte =3D pte_offset_map(pmd, address);
>> +     if (!pte_present(*pte))
>> +             return 0;
>> +     if (pte_devmap(*pte))
>> +             return PAGE_SIZE;
>> +     return 0;
>> +}
>> +
>
> The function name looks generic, but this function seems to focus on
> devmap thing, so could you include the word 'devmap' in the name?

Ok.

>
>>  /*
>>   * Failure handling: if we can't find or can't kill a process there's
>>   * not much we can do.       We just print a message and ignore otherwi=
se.
>> @@ -292,7 +326,10 @@ static void add_to_kill(struct task_struct *tsk, st=
ruct page *p,
>>       }
>>       tk->addr =3D page_address_in_vma(p, vma);
>>       tk->addr_valid =3D 1;
>> -     tk->size_shift =3D compound_order(compound_head(p)) + PAGE_SHIFT;
>> +     if (is_zone_device_page(p))
>> +             tk->size_shift =3D ilog2(mapping_size(p, vma));
>> +     else
>> +             tk->size_shift =3D compound_order(compound_head(p)) + PAGE=
_SHIFT;
>>
>>       /*
>>        * In theory we don't have to kill when the page was
>> @@ -300,7 +337,7 @@ static void add_to_kill(struct task_struct *tsk, str=
uct page *p,
>>        * likely very rare kill anyways just out of paranoia, but use
>>        * a SIGKILL because the error is not contained anymore.
>>        */
>> -     if (tk->addr =3D=3D -EFAULT) {
>> +     if (tk->addr =3D=3D -EFAULT || tk->size_shift =3D=3D 0) {
>>               pr_info("Memory failure: Unable to find user space address=
 %lx in %s\n",
>>                       page_to_pfn(p), tsk->comm);
>>               tk->addr_valid =3D 0;
>> @@ -514,6 +551,7 @@ static const char * const action_page_types[] =3D {
>>       [MF_MSG_TRUNCATED_LRU]          =3D "already truncated LRU page",
>>       [MF_MSG_BUDDY]                  =3D "free buddy page",
>>       [MF_MSG_BUDDY_2ND]              =3D "free buddy page (2nd try)",
>> +     [MF_MSG_DAX]                    =3D "dax page",
>>       [MF_MSG_UNKNOWN]                =3D "unknown page",
>>  };
>>
>> @@ -1111,6 +1149,83 @@ static int memory_failure_hugetlb(unsigned long p=
fn, int flags)
>>       return res;
>>  }
>>
>> +static int memory_failure_dev_pagemap(unsigned long pfn, int flags,
>> +             struct dev_pagemap *pgmap)
>> +{
>> +     struct page *page =3D pfn_to_page(pfn);
>> +     const bool unmap_success =3D true;
>> +     unsigned long size =3D 0;
>> +     struct to_kill *tk;
>> +     LIST_HEAD(tokill);
>> +     int rc =3D -EBUSY;
>> +     loff_t start;
>> +
>> +     /*
>> +      * Prevent the inode from being freed while we are interrogating
>> +      * the address_space, typically this would be handled by
>> +      * lock_page(), but dax pages do not use the page lock. This
>> +      * also prevents changes to the mapping of this pfn until
>> +      * poison signaling is complete.
>> +      */
>> +     if (!dax_lock_mapping_entry(page))
>> +             goto out;
>> +
>> +     if (hwpoison_filter(page)) {
>> +             rc =3D 0;
>> +             goto unlock;
>> +     }
>> +
>> +     switch (pgmap->type) {
>> +     case MEMORY_DEVICE_PRIVATE:
>> +     case MEMORY_DEVICE_PUBLIC:
>> +             /*
>> +              * TODO: Handle HMM pages which may need coordination
>> +              * with device-side memory.
>> +              */
>> +             goto unlock;
>> +     default:
>> +             break;
>> +     }
>> +
>> +     /*
>> +      * Use this flag as an indication that the dax page has been
>> +      * remapped UC to prevent speculative consumption of poison.
>> +      */
>> +     SetPageHWPoison(page);
>
> The number of hwpoison pages is maintained by num_poisoned_pages,
> so you can call num_poisoned_pages_inc()?

I don't think we want these pages accounted in num_poisoned_pages().
We have the badblocks infrastructure in libnvdimm to track how many
errors and where they are located, and since they can be repaired via
driver actions I think we should track them separately.

> Related to this, I'm interested in whether/how unpoison_page() works
> on a hwpoisoned dev_pagemap page.

unpoison_page() is only triggered via freeing pages to the page
allocator, and that never happens for dev_pagemap / ZONE_DEVICE pages.
