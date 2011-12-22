Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id C31656B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 11:04:11 -0500 (EST)
Message-ID: <4EF35477.8090007@ah.jp.nec.com>
Date: Thu, 22 Dec 2011 11:01:59 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] thp: optimize away unnecessary page table locking
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com>	<1324506228-18327-3-git-send-email-n-horiguchi@ah.jp.nec.com> <CAJd=RBDxZbsk8RxFpHUJtsc=fq+=WWGeWvJGJX_SFFGj4AvuHg@mail.gmail.com>
In-Reply-To: <CAJd=RBDxZbsk8RxFpHUJtsc=fq+=WWGeWvJGJX_SFFGj4AvuHg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

(12/22/2011 8:04), Hillf Danton wrote:
> On Thu, Dec 22, 2011 at 6:23 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
>> Currently when we check if we can handle thp as it is or we need to
>> split it into regular sized pages, we hold page table lock prior to
>> check whether a given pmd is mapping thp or not. Because of this,
>> when it's not "huge pmd" we suffer from unnecessary lock/unlock overhead.
>> To remove it, this patch introduces a optimized check function and
>> replace several similar logics with it.
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: David Rientjes <rientjes@google.com>
>> ---
>>  fs/proc/task_mmu.c      |   74 ++++++++++------------------
>>  include/linux/huge_mm.h |    7 +++
>>  mm/huge_memory.c        |  124 ++++++++++++++++++++++------------------------
>>  mm/mremap.c             |    3 +-
>>  4 files changed, 93 insertions(+), 115 deletions(-)
>>
> 
> [...]
> 
>>
>> +/*
>> + * Returns 1 if a given pmd is mapping a thp and stable (not under splitting.)
>> + * Returns 0 otherwise. Note that if it returns 1, this routine returns without
>> + * unlocking page table locks. So callers must unlock them.
>> + */
>> +int check_and_wait_split_huge_pmd(pmd_t *pmd, struct vm_area_struct *vma)
>> +{
>> +       if (!pmd_trans_huge(*pmd))
>> +               return 0;
>> +
>> +       spin_lock(&vma->vm_mm->page_table_lock);
>> +       if (likely(pmd_trans_huge(*pmd))) {
>> +               if (pmd_trans_splitting(*pmd)) {
>> +                       spin_unlock(&vma->vm_mm->page_table_lock);
>> +                       wait_split_huge_page(vma->anon_vma, pmd);
> 
>                             return 0;   yes?

Oops. You are right.
Thank you.
 
>> +               } else {
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
