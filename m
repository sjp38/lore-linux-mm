Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 97CB76B0254
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 20:33:41 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id hb3so54532571igb.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 17:33:41 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id 138si23643863ioc.165.2016.03.02.17.33.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 17:33:40 -0800 (PST)
Received: by mail-io0-x22b.google.com with SMTP id g203so11950280iof.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 17:33:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456944849-21869-1-git-send-email-khalid.aziz@oracle.com>
References: <1456944849-21869-1-git-send-email-khalid.aziz@oracle.com>
From: Julian Calaby <julian.calaby@gmail.com>
Date: Thu, 3 Mar 2016 12:33:21 +1100
Message-ID: <CAGRGNgXH1P8Syz_08ZBfR2FZ5CQKghesHakiG56o4DD+_B+gQg@mail.gmail.com>
Subject: Re: [PATCH] sparc64: Add support for Application Data Integrity (ADI)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: "David S. Miller" <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Arnd Bergmann <arnd@arndb.de>, sparclinux <sparclinux@vger.kernel.org>, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, Konstantin Khlebnikov <koct9i@gmail.com>, oleg@redhat.com, Greg Thelen <gthelen@google.com>, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, Andy Lutomirski <luto@kernel.org>, ebiederm@xmission.com, Benjamin Segall <bsegall@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, dave@stgolabs.net, Alexey Dobriyan <adobriyan@gmail.com>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

Hi Khalid,

A couple of other comments:

On Thu, Mar 3, 2016 at 5:54 AM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>
> Enable Application Data Integrity (ADI) support in the sparc
> kernel for applications to use ADI in userspace. ADI is a new
> feature supported on sparc M7 and newer processors. ADI is supported
> for data fetches only and not instruction fetches. This patch adds
> prctl commands to enable and disable ADI (TSTATE.mcde), return ADI
> parameters to userspace, enable/disable MCD (Memory Corruption
> Detection) on selected memory ranges and enable TTE.mcd in PTEs. It
> also adds handlers for all traps related to MCD. ADI is not enabled
> by default for any task and a task must explicitly enable ADI
> (TSTATE.mcde), turn MCD on on a memory range and set version tag
> for ADI to be effective for the task. This patch adds support for
> ADI for hugepages only. Addresses passed into system calls must be
> non-ADI tagged addresses.
>
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> ---
> NOTES: ADI is a new feature added to M7 processor to allow hardware
>         to catch rogue accesses to memory. An app can enable ADI on
>         its data pages, set version tags on them and use versioned
>         addresses (bits 63-60 of the address contain a version tag)
>         to access the data pages. If a rogue app attempts to access
>         ADI enabled data pages, its access is blocked and processor
>         generates an exception. Enabling this functionality for all
>         data pages of an app requires adding infrastructure to save
>         version tags for any data pages that get swapped out and
>         restoring those tags when pages are swapped back in. In this
>         first implementation I am enabling ADI for hugepages only
>         since these pages are locked in memory and hence avoid the
>         issue of saving and restoring tags. Once this core functionality
>         is stable, ADI for other memory pages can be enabled more
>         easily.
>
>  Documentation/prctl/sparc_adi.txt     |  62 ++++++++++
>  Documentation/sparc/adi.txt           | 206 +++++++++++++++++++++++++++++++
>  arch/sparc/Kconfig                    |  12 ++
>  arch/sparc/include/asm/hugetlb.h      |  14 +++
>  arch/sparc/include/asm/hypervisor.h   |   2 +
>  arch/sparc/include/asm/mmu_64.h       |   1 +
>  arch/sparc/include/asm/pgtable_64.h   |  15 +++
>  arch/sparc/include/asm/processor_64.h |  19 +++
>  arch/sparc/include/asm/ttable.h       |  10 ++
>  arch/sparc/include/uapi/asm/asi.h     |   3 +
>  arch/sparc/include/uapi/asm/pstate.h  |  10 ++
>  arch/sparc/kernel/entry.h             |   3 +
>  arch/sparc/kernel/head_64.S           |   1 +
>  arch/sparc/kernel/mdesc.c             |  81 +++++++++++++
>  arch/sparc/kernel/process_64.c        | 221 ++++++++++++++++++++++++++++++++++
>  arch/sparc/kernel/sun4v_mcd.S         |  16 +++
>  arch/sparc/kernel/traps_64.c          |  96 ++++++++++++++-
>  arch/sparc/kernel/ttable_64.S         |   6 +-
>  include/linux/mm.h                    |   2 +
>  include/uapi/asm-generic/siginfo.h    |   5 +-
>  include/uapi/linux/prctl.h            |  16 +++
>  kernel/sys.c                          |  30 +++++
>  22 files changed, 825 insertions(+), 6 deletions(-)
>  create mode 100644 Documentation/prctl/sparc_adi.txt
>  create mode 100644 Documentation/sparc/adi.txt
>  create mode 100644 arch/sparc/kernel/sun4v_mcd.S
>
> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
> index 131d36f..cddea30 100644
> --- a/arch/sparc/include/asm/pgtable_64.h
> +++ b/arch/sparc/include/asm/pgtable_64.h
> @@ -162,6 +162,9 @@ bool kern_addr_valid(unsigned long addr);
>  #define _PAGE_E_4V       _AC(0x0000000000000800,UL) /* side-Effect          */
>  #define _PAGE_CP_4V      _AC(0x0000000000000400,UL) /* Cacheable in P-Cache */
>  #define _PAGE_CV_4V      _AC(0x0000000000000200,UL) /* Cacheable in V-Cache */
> +/* Bit 9 is used to enable MCD corruption detection instead on M7
> + */
> +#define _PAGE_MCD_4V     _AC(0x0000000000000200,UL) /* Memory Corruption    */

I'm not sure that everywhere _PAGE_CV_4V is used is guarded against
setting it on M7, could someone who knows the code better than I do
please check that? It looks like the tests around it's use are
essentially "is it sun4v".

I'm probably being paranoid, but reused values like this make me worry.

>  #define _PAGE_P_4V       _AC(0x0000000000000100,UL) /* Privileged Page      */
>  #define _PAGE_EXEC_4V    _AC(0x0000000000000080,UL) /* Executable Page      */
>  #define _PAGE_W_4V       _AC(0x0000000000000040,UL) /* Writable             */
> diff --git a/arch/sparc/include/uapi/asm/pstate.h b/arch/sparc/include/uapi/asm/pstate.h
> index cf832e1..d0521db 100644
> --- a/arch/sparc/include/uapi/asm/pstate.h
> +++ b/arch/sparc/include/uapi/asm/pstate.h
> @@ -10,7 +10,12 @@
>   * -----------------------------------------------------------------------
>   *  63  12  11   10    9     8    7   6   5     4     3     2     1    0
>   */
> +/* IG on V9 conflicts with MCDE on M7. PSTATE_MCDE will only be used on
> + * processors that support ADI which do not use IG, hence there is no
> + * functional conflict
> + */
>  #define PSTATE_IG   _AC(0x0000000000000800,UL) /* Interrupt Globals.   */
> +#define PSTATE_MCDE _AC(0x0000000000000800,UL) /* MCD Enable           */

Again, I can't tell if the code that uses PSTATE_IG is guarded against
use on M7. Could someone else please check? It's used in cherrs.S
which appears to be Cheetah specific, so that's not a problem, however
it's also used in ultra.S in xcall_sync_tick which might get patched
out however I don't know the code well enough to be certain. I'm also
guessing that as this file is in include/uapi, userspace could use it
for something.

>  #define PSTATE_MG   _AC(0x0000000000000400,UL) /* MMU Globals.         */
>  #define PSTATE_CLE  _AC(0x0000000000000200,UL) /* Current Little Endian.*/
>  #define PSTATE_TLE  _AC(0x0000000000000100,UL) /* Trap Little Endian.  */
> @@ -47,7 +52,12 @@
>  #define TSTATE_ASI     _AC(0x00000000ff000000,UL) /* AddrSpace ID.     */
>  #define TSTATE_PIL     _AC(0x0000000000f00000,UL) /* %pil (Linux traps)*/
>  #define TSTATE_PSTATE  _AC(0x00000000000fff00,UL) /* PSTATE.           */
> +/* IG on V9 conflicts with MCDE on M7. TSTATE_MCDE will only be used on
> + * processors that support ADI which do not support IG, hence there is
> + * no functional conflict
> + */
>  #define TSTATE_IG      _AC(0x0000000000080000,UL) /* Interrupt Globals.*/
> +#define TSTATE_MCDE    _AC(0x0000000000080000,UL) /* MCD enable.       */

TSTATE_IG only seems to be referenced in cherrs.S which appears to be
Cheetah specific, so I'm guessing this is safe unless userspace does
something with it.

>  #define TSTATE_MG      _AC(0x0000000000040000,UL) /* MMU Globals.      */
>  #define TSTATE_CLE     _AC(0x0000000000020000,UL) /* CurrLittleEndian. */
>  #define TSTATE_TLE     _AC(0x0000000000010000,UL) /* TrapLittleEndian. */
> diff --git a/arch/sparc/kernel/process_64.c b/arch/sparc/kernel/process_64.c
> index 46a5964..33fcc85 100644
> --- a/arch/sparc/kernel/process_64.c
> +++ b/arch/sparc/kernel/process_64.c
> @@ -777,3 +779,222 @@ unsigned long get_wchan(struct task_struct *task)
>  out:
>         return ret;
>  }
> +
> +#ifdef CONFIG_SPARC_ADI
> +long get_sparc_adicaps(unsigned long val)
> +{
> +       struct adi_caps *caps;
> +
> +       if (!ADI_CAPABLE())
> +               return -EINVAL;
> +
> +       caps = get_adi_caps();
> +       if (val)

Should we return 0 before calling get_adi_caps() if val is null?

> +               if (copy_to_user((void *)val, caps, sizeof(struct adi_caps)))
> +                       return -EFAULT;
> +       return 0;
> +}
> +
> +long set_sparc_pstate_mcde(unsigned long val)
> +{
> +       unsigned long error;
> +       struct pt_regs *regs;
> +
> +       if (!ADI_CAPABLE())
> +               return -EINVAL;
> +
> +       /* We do not allow anonymous tasks to enable ADI because they
> +        * run in borrowed aadress space.
> +        */
> +       if (current->mm == NULL)
> +               return -EINVAL;
> +
> +       regs = task_pt_regs(current);
> +       if (regs->tstate & TSTATE_MCDE)
> +               error = 1;
> +       else
> +               error = 0;
> +       switch (val) {
> +       case 1:
> +               regs->tstate |= TSTATE_MCDE;
> +               current->mm->context.adi = 1;
> +               break;
> +       case 0:
> +               regs->tstate &= ~TSTATE_MCDE;
> +               current->mm->context.adi = 0;
> +               break;
> +       default:
> +               break;
> +       }
> +
> +       return error;
> +}
> +
> +long enable_sparc_adi(unsigned long addr, unsigned long len)
> +{
> +       unsigned long end, pagemask;
> +       int error;
> +       struct vm_area_struct *vma, *vma2;
> +       struct mm_struct *mm;
> +
> +       if (!ADI_CAPABLE())
> +               return -EINVAL;
> +
> +       vma = find_vma(current->mm, addr);
> +       if (unlikely(!vma) || (vma->vm_start > addr))
> +               return -EFAULT;
> +
> +       /* ADI is supported for hugepages only
> +        */
> +       if (!is_vm_hugetlb_page(vma))
> +               return -EFAULT;
> +
> +       /* Is the start address page aligned and is the length multiple
> +        * of page size?
> +        */
> +       pagemask = ~(vma_kernel_pagesize(vma) - 1);
> +       if (addr & ~pagemask)
> +               return -EINVAL;
> +       if (len & ~pagemask)
> +               return -EINVAL;
> +
> +       end = addr + len;
> +       if (end == addr)
> +               return 0;

Should we check if len == 0 before calculating the pagemask?

> +
> +       /* Verify end of the region is not out of bounds
> +        */
> +       vma2 = find_vma(current->mm, end-1);
> +       if (unlikely(!vma2) || (vma2->vm_start > end))
> +               return -EFAULT;
> +
> +       error = 0;
> +       while (1) {
> +               /* If the address space ADI is to be enabled in, does not cover
> +                * this vma in its entirety, we will need to split it.
> +                */
> +               mm = vma->vm_mm;
> +               if (addr != vma->vm_start) {
> +                       error = split_vma(mm, vma, addr, 1);
> +                       if (error)
> +                               goto out;
> +               }
> +
> +               if (end < vma->vm_end) {
> +                       error = split_vma(mm, vma, end, 0);
> +                       if (error)
> +                               goto out;
> +               }
> +
> +               /* Update the ADI info in vma and PTE
> +                */
> +               vma->vm_flags |= VM_SPARC_ADI;
> +
> +               if (end > vma->vm_end) {
> +                       change_protection(vma, addr, vma->vm_end,
> +                                         vma->vm_page_prot,
> +                                         vma_wants_writenotify(vma), 0);
> +                       addr = vma->vm_end;
> +               } else {
> +                       change_protection(vma, addr, end, vma->vm_page_prot,
> +                                       vma_wants_writenotify(vma), 0);
> +                       break;
> +               }
> +
> +               vma = find_vma(current->mm, addr);
> +               if (unlikely(!vma) || (vma->vm_start > addr))
> +                       return -EFAULT;
> +       }
> +out:
> +       if (error == -ENOMEM)
> +               error = -EAGAIN;
> +       return error;
> +}
> +
> +long disable_sparc_adi(unsigned long addr, unsigned long len)
> +{
> +       unsigned long end, pagemask;
> +       struct vm_area_struct *vma, *vma2, *prev;
> +       struct mm_struct *mm;
> +       pgoff_t pgoff;
> +
> +       if (!ADI_CAPABLE())
> +               return -EINVAL;
> +
> +       vma = find_vma(current->mm, addr);
> +       if (unlikely(!vma) || (vma->vm_start > addr))
> +               return -EFAULT;
> +
> +       /* ADI is supported for hugepages only
> +        */
> +       if (!is_vm_hugetlb_page(vma))
> +               return -EINVAL;
> +
> +       /* Is the start address page aligned and is the length multiple
> +        * of page size?
> +        */
> +       pagemask = ~(vma_kernel_pagesize(vma) - 1);
> +       if (addr & ~pagemask)
> +               return -EINVAL;
> +       if (len & ~pagemask)
> +               return -EINVAL;
> +
> +       end = addr + len;
> +       if (end == addr)
> +               return 0;
> +
> +       /* Verify end of the region is not out of bounds
> +        */
> +       vma2 = find_vma(current->mm, end-1);
> +       if (unlikely(!vma2) || (vma2->vm_start > end))
> +               return -EFAULT;
> +
> +       while (1) {
> +               mm = vma->vm_mm;
> +
> +               /* Update the ADI info in vma and check if this vma can
> +                * be merged with adjacent ones
> +                */
> +               pgoff = vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT);
> +               prev = vma_merge(mm, prev, addr, end, vma->vm_flags,
> +                                vma->anon_vma, vma->vm_file, pgoff,
> +                                vma_policy(vma), vma->vm_userfaultfd_ctx);
> +               if (prev)
> +                       vma = prev;
> +
> +               vma->vm_flags &= ~VM_SPARC_ADI;
> +               if (end > vma->vm_end) {
> +                       change_protection(vma, addr, vma->vm_end,
> +                                         vma->vm_page_prot,
> +                                         vma_wants_writenotify(vma), 0);
> +                       addr = vma->vm_end;
> +               } else {
> +                       change_protection(vma, addr, end, vma->vm_page_prot,
> +                                         vma_wants_writenotify(vma), 0);
> +                       break;
> +               }
> +
> +               vma = find_vma_prev(current->mm, addr, &prev);
> +               if (unlikely(!vma) || (vma->vm_start > addr))
> +                       return -EFAULT;
> +       }
> +       return 0;
> +}
> +
> +long get_sparc_adi_status(unsigned long addr)
> +{
> +       struct vm_area_struct *vma;
> +
> +       if (!ADI_CAPABLE())
> +               return -EINVAL;
> +
> +       vma = find_vma(current->mm, addr);
> +       if (unlikely(!vma) || (vma->vm_start > addr))
> +               return -EFAULT;
> +
> +       if (vma->vm_flags & VM_SPARC_ADI)
> +               return 1;
> +
> +       return 0;
> +}
> +#endif

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
