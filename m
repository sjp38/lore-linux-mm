Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 60B0F6B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 10:20:32 -0500 (EST)
Message-ID: <4F104A51.2000701@ah.jp.nec.com>
Date: Fri, 13 Jan 2012 10:14:25 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
References: <1326396898-5579-1-git-send-email-n-horiguchi@ah.jp.nec.com>	<1326396898-5579-3-git-send-email-n-horiguchi@ah.jp.nec.com> <CAJd=RBB6azf9nin5tjqTtHakxy896rCxr6ErK4p2KDrke_goEA@mail.gmail.com>
In-Reply-To: <CAJd=RBB6azf9nin5tjqTtHakxy896rCxr6ErK4p2KDrke_goEA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

Hi Hillf,

(1/13/2012 7:04), Hillf Danton wrote:
[...]
>> +/*
>> + * Returns 1 if a given pmd is mapping a thp and stable (not under splitting.)
>> + * Returns 0 otherwise. Note that if it returns 1, this routine returns without
>> + * unlocking page table locks. So callers must unlock them.
>> + */
>> +int pmd_trans_huge_stable(pmd_t *pmd, struct vm_area_struct *vma)
>> +{
>> +       VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
>> +
>> +       if (!pmd_trans_huge(*pmd))
>> +               return 0;
>> +
>> +       spin_lock(&vma->vm_mm->page_table_lock);
>> +       if (likely(pmd_trans_huge(*pmd))) {
>> +               if (pmd_trans_splitting(*pmd)) {
>> +                       spin_unlock(&vma->vm_mm->page_table_lock);
>> +                       wait_split_huge_page(vma->anon_vma, pmd);
>> +                       return 0;
>> +               } else {
> 
>                             spin_unlock(&vma->vm_mm->page_table_lock);     yes?

No. Unlocking is supposed to be done by the caller as commented.

Thanks,
Naoya

> 
>> +                       /* Thp mapped by 'pmd' is stable, so we can
>> +                        * handle it as it is. */
>> +                       return 1;
>> +               }
>> +       }
>> +       spin_unlock(&vma->vm_mm->page_table_lock);
>> +       return 0;
>> +}
>> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
