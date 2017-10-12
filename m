Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62C9D6B0253
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 16:28:41 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k31so12603115qta.22
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:28:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 128si2488805qkd.368.2017.10.12.13.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 13:28:39 -0700 (PDT)
Subject: Re: [PATCH v8 9/9] sparc64: Add support for ADI (Application Data Integrity)
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
From: Anthony Yznaga <anthony.yznaga@oracle.com>
In-Reply-To: <5edaf7dc-6bc7-c365-0b54-b78975c08894@oracle.com>
Date: Thu, 12 Oct 2017 13:27:25 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <782BD060-74C5-4D9B-B013-731249A72F87@oracle.com>
References: <cover.1506089472.git.khalid.aziz@oracle.com> <cover.1506089472.git.khalid.aziz@oracle.com> <9e3a8c90ade57d94d1ab2100c6d9508fc2d0a212.1506089472.git.khalid.aziz@oracle.com> <ABC0A87C-2B65-493D-8D7C-998616015FF7@oracle.com> <5edaf7dc-6bc7-c365-0b54-b78975c08894@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: David Miller <davem@davemloft.net>, dave.hansen@linux.intel.com, corbet@lwn.net, Bob Picco <bob.picco@oracle.com>, STEVEN_SISTARE <steven.sistare@oracle.com>, Pasha Tatashin <pasha.tatashin@oracle.com>, Mike Kravetz <mike.kravetz@oracle.com>, Rob Gardner <rob.gardner@oracle.com>, mingo@kernel.org, Nitin Gupta <nitin.m.gupta@oracle.com>, kirill.shutemov@linux.intel.com, Tom Hromatka <tom.hromatka@oracle.com>, Eric Saint Etienne <eric.saint.etienne@oracle.com>, Allen Pais <allen.pais@oracle.com>, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, pmladek@suse.com, tklauser@distanz.ch, Atish Patra <atish.patra@oracle.com>, Shannon Nelson <shannon.nelson@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, punit.agrawal@arm.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>


> On Oct 12, 2017, at 7:44 AM, Khalid Aziz <khalid.aziz@oracle.com> =
wrote:
>=20
> Hi Anthony,
>=20
> Please quote only the relevant parts of the patch with comments. That =
makes it much easier to find the comments.

Okay.

>=20
> On 10/06/2017 04:12 PM, Anthony Yznaga wrote:
>>> On Sep 25, 2017, at 9:49 AM, Khalid Aziz <khalid.aziz@oracle.com> =
wrote:
>>>=20
>>> This patch extends mprotect to enable ADI (TSTATE.mcde), =
enable/disable
>>> MCD (Memory Corruption Detection) on selected memory ranges, enable
>>> TTE.mcd in PTEs, return ADI parameters to userspace and save/restore =
ADI
>>> version tags on page swap out/in or migration. ADI is not enabled by
>> I still don't believe migration is properly supported.  Your
>> implementation is relying on a fault happening on a page while its
>> migration is in progress so that do_swap_page() will be called, but
>> I don't see how do_swap_page() will be called if a fault does not
>> happen until after the migration has completed.
>=20
> User pages are on LRU list and for the mapped pages on LRU list, =
migrate_pages() ultimately calls try_to_unmap_one and makes a migration =
swap entry for the page being migrated. This forces a page fault upon =
access on the destination node and the page is swapped back in from swap =
cache. The fault is forced by the migration swap entry, rather than =
fault being an accidental event. If page fault happens on the =
destination node while migration is in progress, do_swap_page() waits =
until migration is done. Please take a look at the code in =
__unmap_and_move().

I looked at the code again, and I now believe ADI tags are never =
restored for migrated pages.  Here's why:

A successful call to try_to_unmap() by __unmap_and_move() will have =
unmapped the page, replaced the pte with a migration pte, and saved the =
ADI tags.

If an access to the unmapped VA range is attempted while the migration =
pte is in place, handle_pte_fault() will call do_swap_page() because the =
page present flag is not set in the pte.  do_swap_page() will see that =
the pte is a migration pte and call migration_entry_wait() where it will =
block until the migration pte is removed.  do_swap_page() will then =
return so that the fault is retried.

remove_migration_pte() replaces the migration pte with a regular pte.  =
The regular pte will have the page present flag set.  Whether due to a =
retry or not, the next fault on the VA range will therefore not call =
do_swap_page() and the tags will not be restored.

>=20
>=20
>>> +#define finish_arch_post_lock_switch	=
finish_arch_post_lock_switch
>>> +static inline void finish_arch_post_lock_switch(void)
>>> +{
>>> +	/* Restore the state of MCDPER register for the new process
>>> +	 * just switched to.
>>> +	 */
>>> +	if (adi_capable()) {
>>> +		register unsigned long tmp_mcdper;
>>> +
>>> +		tmp_mcdper =3D test_thread_flag(TIF_MCDPER);
>>> +		__asm__ __volatile__(
>>> +			"mov %0, %%g1\n\t"
>>> +			".word 0x9d800001\n\t"	/* wr %g0, %g1, %mcdper" =
*/
>>> +			".word 0xaf902001\n\t"	/* wrpr %g0, 1, %pmcdper =
*/
>>> +			:
>>> +			: "ir" (tmp_mcdper)
>>> +			: "g1");
>>> +		if (current && current->mm && current->mm->context.adi) =
{
>>> +			struct pt_regs *regs;
>>> +
>>> +			regs =3D task_pt_regs(current);
>>> +			regs->tstate |=3D TSTATE_MCDE;
>> This works, but it costs additional cycles on every context switch to
>> keep setting TSTATE_MCDE.  PSTATE.mcde=3D1 only affects loads and =
stores
>> to memory mapped with TTE.mcd=3D1 so there is no impact if it is set =
and
>> no memory is mapped with TTE.mcd=3D1.  That is why I suggested just
>> setting TSTATE_MCDE once when a process thread is initialized.
>=20
> This change was suggested by David Miller. I believe there is merit to =
that suggestion.

I'm not saying it's without merit.  I just wanted to point out that the =
solution adds a bit of additional work to every context switch and that =
it's possible to avoid it.  I'm fine if David still prefers his =
solution.


>=20
>>> +	/* Tag storage has not been allocated for this vma and space
>>> +	 * is available in tag storage descriptor. Since this page is
>>> +	 * being swapped out, there is high probability subsequent pages
>>> +	 * in the VMA will be swapped out as well. Allocate pages to
>>> +	 * store tags for as many pages in this vma as possible but not
>>> +	 * more than TAG_STORAGE_PAGES. Each byte in tag space holds
>>> +	 * two ADI tags since each ADI tag is 4 bits. Each ADI tag
>>> +	 * covers adi_blksize() worth of addresses. Check if the hole is
>>> +	 * big enough to accommodate full address range for using
>>> +	 * TAG_STORAGE_PAGES number of tag pages.
>>> +	 */
>>> +	size =3D TAG_STORAGE_PAGES * PAGE_SIZE;
>>> +	end_addr =3D addr + (size*2*adi_blksize()) - 1;
>>> +	/* Check for overflow. If overflow occurs, allocate only one =
page */
>>> +	if (end_addr < addr) {
>>> +		size =3D PAGE_SIZE;
>>> +		end_addr =3D addr + (size*2*adi_blksize()) - 1;
>> end_addr could still overflow even with size =3D PAGE_SIZE.
>> Maybe you could just set end_addr to (unsigned long)-1 and =
recalculate
>> the size based on that.
>=20
> I agree at theoretical level. The number of VA bits is already limited =
by the max implemented VA bit in hardware plus with ADI in use, top 4 =
bits are not available as well either, so there is lot of unused room at =
the upper end of VA and end_addr is not going to roll over. =
Nevertheless, I can fix this as well for completeness sake.


The MMU ignores the ADI tag bits and sign extends from the actual most =
significant VA bit to get the actual VA so the hardware is capable of =
mapping a user page at 0xffffffffffffe000.  However, Linux imposes an =
upper limit on the maximum user VA.  There are theses comments in =
arch/sparc/include/asm/processor_64.h:

/*
 * User lives in his very own context, and cannot reference us. Note
 * that TASK_SIZE is a misnomer, it really gives maximum user virtual
 * address that the kernel will allocate out.
 *
 * XXX No longer using virtual page tables, kill this upper limit...
 */

Maybe this limit will remain forever, maybe not.


>=20
>>> +	}
>>> +	if (hole_end < end_addr) {
>>> +		/* Available hole is too small on the upper end of
>>> +		 * address. Can we expand the range towards the lower
>>> +		 * address and maximize use of this slot?
>>> +		 */
>>> +		unsigned long tmp_addr;
>>> +
>>> +		end_addr =3D hole_end - 1;
>>> +		tmp_addr =3D end_addr - (size*2*adi_blksize()) + 1;
>>> +		/* Check for underflow. If underflow occurs, allocate
>>> +		 * only one page for storing ADI tags
>>> +		 */
>>> +		if (tmp_addr > addr) {
>> Should compare tmp_addr to end_addr rather than addr.
>=20
> No, this is correct. If tmp_addr wraps around to the upper end, =
theoretically it can be smaller than end_addr but still be bigger than =
addr since addr < end_addr. The way it is written, this is a safer test.

If you subtract a large enough value from end_addr to cause underflow, =
the result will always be greater than end_addr.

>=20
>>> +			size =3D PAGE_SIZE;
>>> +			tmp_addr =3D addr + (size*2*adi_blksize()) - 1;
>> copy/paste error?  tmp_addr should be recalculated from end_addr and =
a
>> new size.  The new size needs to be adjusted based on end_addr to as
>> little as PAGE_SIZE.
>=20
> Good catch.
>=20
>>> diff --git a/arch/sparc/kernel/etrap_64.S =
b/arch/sparc/kernel/etrap_64.S
>>> index 1276ca2567ba..7be33bf45cff 100644
>>> --- a/arch/sparc/kernel/etrap_64.S
>>> +++ b/arch/sparc/kernel/etrap_64.S
>>> @@ -132,7 +132,33 @@ etrap_save:	save	%g2, -STACK_BIAS, %sp
>>> 		stx	%g6, [%sp + PTREGS_OFF + PT_V9_G6]
>>> 		stx	%g7, [%sp + PTREGS_OFF + PT_V9_G7]
>>> 		or	%l7, %l0, %l7
>>> -		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
>>> +661:		sethi	%hi(TSTATE_TSO | TSTATE_PEF), %l0
>>> +		/*
>>> +		 * If userspace is using ADI, it could potentially pass
>>> +		 * a pointer with version tag embedded in it. To =
maintain
>>> +		 * the ADI security, we must enable PSTATE.mcde. =
Userspace
>>> +		 * would have already set TTE.mcd in an earlier call to
>>> +		 * kernel and set the version tag for the address being
>>> +		 * dereferenced. Setting PSTATE.mcde would ensure any
>>> +		 * access to userspace data through a system call honors
>>> +		 * ADI and does not allow a rogue app to bypass ADI by
>>> +		 * using system calls. Setting PSTATE.mcde only affects
>>> +		 * accesses to virtual addresses that have TTE.mcd set.
>>> +		 * Set PMCDPER to ensure any exceptions caused by ADI
>>> +		 * version tag mismatch are exposed before system call
>>> +		 * returns to userspace. Setting PMCDPER affects only
>>> +		 * writes to virtual addresses that have TTE.mcd set and
>>> +		 * have a version tag set as well.
>>> +		 */
>>> +		.section .sun_m7_1insn_patch, "ax"
>>> +		.word	661b
>>> +		sethi	%hi(TSTATE_TSO | TSTATE_PEF | TSTATE_MCDE), %l0
>> rtrap is still missing patches to turn on TSTATE_MCDE when needed.
>>> +		.previous
>>> +661:		nop
>>> +		.section .sun_m7_1insn_patch, "ax"
>>> +		.word	661b
>>> +		.word 0xaf902001	/* wrpr %g0, 1, %pmcdper */
>> I still disagree with setting %pmcdper=3D1 on every trap into the =
kernel,
>> and now %pmcdper is also being set to 1 on every context switch.  It
>> should be sufficient to set it once for each CPU but also setting it
>> on every context switch is at least less impactful than setting it on
>> every etrap.
>=20
> We discussed this before and I believe not setting %pmcdper on trap =
into kernel can expose kernel to the possibility of running system calls =
with deferred MCD exceptions which in turn causes unreliable behavior =
from userspace point of view when MCD exception happens (userspace might =
get SIGSEGV, or system call terminates with error depending upon when =
exception is delievered). I believe it is important for system calls to =
behave consistently.

I'm not saying that %pmcdper should not be set to 1.  I'm saying that =
it's expensive and unnecessary to keep setting it to 1 on every trap =
into the kernel and now every context switch (~50-70 cycles every time =
the register is updated).  It should be sufficient to set it once when =
each CPU is configured.  If it's really necessary to mitigate the =
possibility of something in the kernel clearing %pmcdper and reseting it =
then setting it on every context switch should be sufficient and less =
onerous than every etrap.

Anthony

>=20
>=20
>>> diff --git a/arch/sparc/kernel/setup_64.c =
b/arch/sparc/kernel/setup_64.c
>>> index 150ee7d4b059..98a877715832 100644
>>> --- a/arch/sparc/kernel/setup_64.c
>>> +++ b/arch/sparc/kernel/setup_64.c
>>> @@ -293,6 +293,8 @@ static void __init sun4v_patch(void)
>>> 	case SUN4V_CHIP_SPARC_M7:
>>> 	case SUN4V_CHIP_SPARC_M8:
>>> 	case SUN4V_CHIP_SPARC_SN:
>>> +		sun4v_patch_1insn_range(&__sun_m7_1insn_patch,
>>> +					&__sun_m7_1insn_patch_end);
>>> 		sun_m7_patch_2insn_range(&__sun_m7_2insn_patch,
>>> 					 &__sun_m7_2insn_patch_end);
>> Why did you keep sun_m7_patch_2insn_range() and not replace it with
>> sun4v_m7_patch_2insn_range()?
>=20
> sun_m7_patch_2insn_range() is already in the kernel and not part of =
this patch. It can be replaced but that should be a separate patch in my =
opinion.
>=20
> Thanks,
> Khalid
> --
> To unsubscribe from this list: send the line "unsubscribe sparclinux" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
