Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B12516005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 23:29:42 -0500 (EST)
Received: by pxi5 with SMTP id 5so11097502pxi.12
        for <linux-mm@kvack.org>; Mon, 04 Jan 2010 20:29:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100104182429.833180340@chello.nl>
	 <20100104182813.753545361@chello.nl>
	 <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 5 Jan 2010 13:29:40 +0900
Message-ID: <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Kame.

On Tue, Jan 5, 2010 at 9:25 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 04 Jan 2010 19:24:35 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
>> Generic speculative fault handler, tries to service a pagefault
>> without holding mmap_sem.
>>
>> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
>
> I'm sorry if I miss something...how does this patch series avoid
> that vma is removed while __do_fault()->vma->vm_ops->fault() is called ?
> ("vma is removed" means all other things as freeing file struct etc..)

Isn't it protected by get_file and iget?
Am I miss something?

>
> Thanks,
> -Kame
>
>
>
>
>> ---
>> =C2=A0include/linux/mm.h | =C2=A0 =C2=A02 +
>> =C2=A0mm/memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 59 +++++++++++++++=
+++++++++++++++++++++++++++++++++++++-
>> =C2=A02 files changed, 60 insertions(+), 1 deletion(-)
>>
>> Index: linux-2.6/mm/memory.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- linux-2.6.orig/mm/memory.c
>> +++ linux-2.6/mm/memory.c
>> @@ -1998,7 +1998,7 @@ again:
>> =C2=A0 =C2=A0 =C2=A0 if (!*ptep)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>>
>> - =C2=A0 =C2=A0 if (vma_is_dead(vma, seq))
>> + =C2=A0 =C2=A0 if (vma && vma_is_dead(vma, seq))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto unlock;
>>
>> =C2=A0 =C2=A0 =C2=A0 unpin_page_tables();
>> @@ -3112,6 +3112,63 @@ int handle_mm_fault(struct mm_struct *mm
>> =C2=A0 =C2=A0 =C2=A0 return handle_pte_fault(mm, vma, address, entry, pm=
d, flags, 0);
>> =C2=A0}
>>
>> +int handle_speculative_fault(struct mm_struct *mm, unsigned long addres=
s,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int flags)
>> +{
>> + =C2=A0 =C2=A0 pmd_t *pmd =3D NULL;
>> + =C2=A0 =C2=A0 pte_t *pte, entry;
>> + =C2=A0 =C2=A0 spinlock_t *ptl;
>> + =C2=A0 =C2=A0 struct vm_area_struct *vma;
>> + =C2=A0 =C2=A0 unsigned int seq;
>> + =C2=A0 =C2=A0 int ret =3D VM_FAULT_RETRY;
>> + =C2=A0 =C2=A0 int dead;
>> +
>> + =C2=A0 =C2=A0 __set_current_state(TASK_RUNNING);
>> + =C2=A0 =C2=A0 flags |=3D FAULT_FLAG_SPECULATIVE;
>> +
>> + =C2=A0 =C2=A0 count_vm_event(PGFAULT);
>> +
>> + =C2=A0 =C2=A0 rcu_read_lock();
>> + =C2=A0 =C2=A0 if (!pte_map_lock(mm, NULL, address, pmd, flags, 0, &pte=
, &ptl))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unlock;
>> +
>> + =C2=A0 =C2=A0 vma =3D find_vma(mm, address);
>> +
>> + =C2=A0 =C2=A0 if (!vma)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unmap;
>> +
>> + =C2=A0 =C2=A0 dead =3D RB_EMPTY_NODE(&vma->vm_rb);
>> + =C2=A0 =C2=A0 seq =3D vma->vm_sequence.sequence;
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* Matches both the wmb in write_seqcount_begin/end=
() and
>> + =C2=A0 =C2=A0 =C2=A0* the wmb in detach_vmas_to_be_unmapped()/__unlink=
_vma().
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 smp_rmb();
>> + =C2=A0 =C2=A0 if (dead || seq & 1)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unmap;
>> +
>> + =C2=A0 =C2=A0 if (!(vma->vm_end > address && vma->vm_start <=3D addres=
s))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unmap;
>> +
>> + =C2=A0 =C2=A0 if (read_seqcount_retry(&vma->vm_sequence, seq))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unmap;
>> +
>> + =C2=A0 =C2=A0 entry =3D *pte;
>> +
>> + =C2=A0 =C2=A0 pte_unmap_unlock(pte, ptl);
>> +
>> + =C2=A0 =C2=A0 ret =3D handle_pte_fault(mm, vma, address, entry, pmd, f=
lags, seq);
>> +
>> +out_unlock:
>> + =C2=A0 =C2=A0 rcu_read_unlock();
>> + =C2=A0 =C2=A0 return ret;
>> +
>> +out_unmap:
>> + =C2=A0 =C2=A0 pte_unmap_unlock(pte, ptl);
>> + =C2=A0 =C2=A0 goto out_unlock;
>> +}
>> +
>> +
>> =C2=A0#ifndef __PAGETABLE_PUD_FOLDED
>> =C2=A0/*
>> =C2=A0 * Allocate page upper directory.
>> Index: linux-2.6/include/linux/mm.h
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- linux-2.6.orig/include/linux/mm.h
>> +++ linux-2.6/include/linux/mm.h
>> @@ -829,6 +829,8 @@ int invalidate_inode_page(struct page *p
>> =C2=A0#ifdef CONFIG_MMU
>> =C2=A0extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_st=
ruct *vma,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 unsigned long address, unsigned int flags);
>> +extern int handle_speculative_fault(struct mm_struct *mm,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
unsigned long address, unsigned int flags);
>> =C2=A0#else
>> =C2=A0static inline int handle_mm_fault(struct mm_struct *mm,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct vm_area_struct *vma, unsigned long address,
>>
>> --
>>
>>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
