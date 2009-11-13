Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 832516B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 10:59:58 -0500 (EST)
Received: by pzk27 with SMTP id 27so2219491pzk.12
        for <linux-mm@kvack.org>; Fri, 13 Nov 2009 07:59:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091113164134.79805c13.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091113164134.79805c13.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 14 Nov 2009 00:59:56 +0900
Message-ID: <28c262360911130759tb9ffde4n8101bd27f31b5669@mail.gmail.com>
Subject: Re: [RFC MM 4/4] speculative page fault
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 4:41 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Speculative page fault.
>
> =A0This patch tries to implement speculative page fault.
> =A0Do page fault without taking mm->semaphore and check tag mm->generatio=
n
> =A0after taking page table lock. If generation is modified, someone took
> =A0write lock on mm->semaphore and we need to take read lock.
>
> =A0Now, hugepage is not handled. And stack page is not handled because
> =A0it can change [vm_start, vm_end).
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0arch/x86/mm/fault.c | =A0 54 ++++++++++++++++++++++++++--------------
> =A0include/linux/mm.h =A0| =A0 =A02 -
> =A0mm/memory.c =A0 =A0 =A0 =A0 | =A0 70 ++++++++++++++++++++++++++++++++-=
-------------------
> =A03 files changed, 81 insertions(+), 45 deletions(-)
>
> Index: mmotm-2.6.32-Nov2/arch/x86/mm/fault.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Nov2.orig/arch/x86/mm/fault.c
> +++ mmotm-2.6.32-Nov2/arch/x86/mm/fault.c
> @@ -11,6 +11,7 @@
> =A0#include <linux/kprobes.h> =A0 =A0 =A0 =A0 =A0 =A0 /* __kprobes, ... =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0#include <linux/mmiotrace.h> =A0 =A0 =A0 =A0 =A0 /* kmmio_handler, ...=
 =A0 =A0 =A0 =A0 =A0 */
> =A0#include <linux/perf_event.h> =A0 =A0 =A0 =A0 =A0/* perf_sw_event =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +#include <linux/hugetlb.h> =A0 =A0 =A0 =A0 =A0 =A0 /* is_vm_hugetlbe_pag=
e()... =A0 =A0 */
>
> =A0#include <asm/traps.h> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* dotraplinkag=
e, ... =A0 =A0 =A0 =A0 =A0 */
> =A0#include <asm/pgalloc.h> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* pgd_*(), ... =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> @@ -952,7 +953,8 @@ do_page_fault(struct pt_regs *regs, unsi
> =A0 =A0 =A0 =A0struct mm_struct *mm;
> =A0 =A0 =A0 =A0int write;
> =A0 =A0 =A0 =A0int fault;
> - =A0 =A0 =A0 int cachehit =3D 0;
> + =A0 =A0 =A0 int cachehit;
> + =A0 =A0 =A0 unsigned int key;
>
> =A0 =A0 =A0 =A0tsk =3D current;
> =A0 =A0 =A0 =A0mm =3D tsk->mm;
> @@ -1057,6 +1059,18 @@ do_page_fault(struct pt_regs *regs, unsi
> =A0 =A0 =A0 =A0 * validate the source. If this is invalid we can skip the=
 address
> =A0 =A0 =A0 =A0 * space check, thus avoiding the deadlock:
> =A0 =A0 =A0 =A0 */
> + =A0 =A0 =A0 =A0if ((error_code & PF_USER) &&
> + =A0 =A0 =A0 =A0 =A0 =A0(mm->generation =3D=3D current->mm_generation) &=
& current->vma_cache) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma =3D current->vma_cache;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((vma->vm_start <=3D address) && (addres=
s < vma->vm_end)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 key =3D mm->generation;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachehit =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto got_vma;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +speculative_fault_retry:
> + =A0 =A0 =A0 cachehit =3D 0;
> + =A0 =A0 =A0 vma =3D NULL;
> =A0 =A0 =A0 =A0if (unlikely(!mm_reader_trylock(mm))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((error_code & PF_USER) =3D=3D 0 &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!search_exception_tables(regs->ip)=
) {
> @@ -1072,13 +1086,9 @@ do_page_fault(struct pt_regs *regs, unsi
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might_sleep();
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 if ((mm->generation =3D=3D current->mm_generation) && curre=
nt->vma_cache) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma =3D current->vma_cache;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((vma->vm_start <=3D address) && (addres=
s < vma->vm_end))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachehit =3D 1;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 if (!cachehit)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vma =3D find_vma(mm, address);
> + =A0 =A0 =A0 key =3D mm->generation;
> + =A0 =A0 =A0 vma =3D find_vma(mm, address);
> +got_vma:
> =A0 =A0 =A0 =A0if (unlikely(!vma)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bad_area(regs, error_code, address);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> @@ -1123,13 +1133,17 @@ good_area:
> =A0 =A0 =A0 =A0 * make sure we exit gracefully rather than endlessly redo
> =A0 =A0 =A0 =A0 * the fault:
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 fault =3D handle_mm_fault(mm, vma, address, write ? FAULT_F=
LAG_WRITE : 0);
> + =A0 =A0 =A0 fault =3D handle_mm_fault(mm, vma, address,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 write ? FAULT_FLAG_WRITE : 0, key);
>
> =A0 =A0 =A0 =A0if (unlikely(fault & VM_FAULT_ERROR)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mm_fault_error(regs, error_code, address, =
fault);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 if (mm->generation !=3D key)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto speculative_fault_retry;
> +

You can use match_key in here again. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
