Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0D26B000A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:43:29 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id j13-v6so8108711wre.6
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:43:29 -0700 (PDT)
Received: from www.kot-begemot.co.uk (ivanoab6.miniserver.com. [5.153.251.140])
        by mx.google.com with ESMTPS id r9-v6si1493111wro.197.2018.10.12.09.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Oct 2018 09:43:27 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] mm: speed up mremap by 500x on large regions
From: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
References: <20181012013756.11285-1-joel@joelfernandes.org>
 <20181012013756.11285-2-joel@joelfernandes.org>
 <9ed82f9e-88c4-8e4f-8c45-3ef153469603@kot-begemot.co.uk>
 <20181012143728.t42uvr6etg7gp7fh@kshutemo-mobl1>
 <4dd52e22-5b51-9b30-7178-fde603a08f88@kot-begemot.co.uk>
Message-ID: <97cb3fe1-7bc1-12ff-d602-56c72a5496c5@kot-begemot.co.uk>
Date: Fri, 12 Oct 2018 17:42:24 +0100
MIME-Version: 1.0
In-Reply-To: <4dd52e22-5b51-9b30-7178-fde603a08f88@kot-begemot.co.uk>
Content-Type: multipart/mixed;
 boundary="------------A6D223F721C42CB9BAB1286E"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, mhocko@kernel.org, linux-mm@kvack.org, lokeshgidra@google.com, linux-riscv@lists.infradead.org, elfring@users.sourceforge.net, Jonas Bonn <jonas@southpole.se>, linux-s390@vger.kernel.org, dancol@google.com, Yoshinori Sato <ysato@users.sourceforge.jp>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, hughd@google.com, "James E.J. Bottomley" <jejb@parisc-linux.org>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-snps-arc@lists.infradead.org, kernel-team@android.com, Sam Creasey <sammy@sammy.net>, Fenghua Yu <fenghua.yu@intel.com>, Jeff Dike <jdike@addtoit.com>, linux-um@lists.infradead.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Julia Lawall <Julia.Lawall@lip6.fr>, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, nios2-dev@lists.rocketboards.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, Richard Weinberger <richard@nod.at>, linux-parisc@vger.kernel.org, pantin@google.com, Max Filippov <jcmvbkbc@gmail.com>, minchan@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-alpha@vger.kernel.org, Ley Foon Tan <lftan@altera.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

This is a multi-part message in MIME format.
--------------A6D223F721C42CB9BAB1286E
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit


On 10/12/18 3:48 PM, Anton Ivanov wrote:
> On 12/10/2018 15:37, Kirill A. Shutemov wrote:
>> On Fri, Oct 12, 2018 at 03:09:49PM +0100, Anton Ivanov wrote:
>>> On 10/12/18 2:37 AM, Joel Fernandes (Google) wrote:
>>>> Android needs to mremap large regions of memory during memory 
>>>> management
>>>> related operations. The mremap system call can be really slow if 
>>>> THP is
>>>> not enabled. The bottleneck is move_page_tables, which is copying each
>>>> pte at a time, and can be really slow across a large map. Turning 
>>>> on THP
>>>> may not be a viable option, and is not for us. This patch speeds up 
>>>> the
>>>> performance for non-THP system by copying at the PMD level when 
>>>> possible.
>>>>
>>>> The speed up is three orders of magnitude. On a 1GB mremap, the mremap
>>>> completion times drops from 160-250 millesconds to 380-400 
>>>> microseconds.
>>>>
>>>> Before:
>>>> Total mremap time for 1GB data: 242321014 nanoseconds.
>>>> Total mremap time for 1GB data: 196842467 nanoseconds.
>>>> Total mremap time for 1GB data: 167051162 nanoseconds.
>>>>
>>>> After:
>>>> Total mremap time for 1GB data: 385781 nanoseconds.
>>>> Total mremap time for 1GB data: 388959 nanoseconds.
>>>> Total mremap time for 1GB data: 402813 nanoseconds.
>>>>
>>>> Incase THP is enabled, the optimization is skipped. I also flush the
>>>> tlb every time we do this optimization since I couldn't find a way to
>>>> determine if the low-level PTEs are dirty. It is seen that the cost of
>>>> doing so is not much compared the improvement, on both x86-64 and 
>>>> arm64.
>>>>
>>>> Cc: minchan@kernel.org
>>>> Cc: pantin@google.com
>>>> Cc: hughd@google.com
>>>> Cc: lokeshgidra@google.com
>>>> Cc: dancol@google.com
>>>> Cc: mhocko@kernel.org
>>>> Cc: kirill@shutemov.name
>>>> Cc: akpm@linux-foundation.org
>>>> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
>>>> ---
>>>> A A  mm/mremap.c | 62 
>>>> +++++++++++++++++++++++++++++++++++++++++++++++++++++
>>>> A A  1 file changed, 62 insertions(+)
>>>>
>>>> diff --git a/mm/mremap.c b/mm/mremap.c
>>>> index 9e68a02a52b1..d82c485822ef 100644
>>>> --- a/mm/mremap.c
>>>> +++ b/mm/mremap.c
>>>> @@ -191,6 +191,54 @@ static void move_ptes(struct vm_area_struct 
>>>> *vma, pmd_t *old_pmd,
>>>> A A A A A A A A A A  drop_rmap_locks(vma);
>>>> A A  }
>>>> +static bool move_normal_pmd(struct vm_area_struct *vma, unsigned 
>>>> long old_addr,
>>>> +A A A A A A A A A  unsigned long new_addr, unsigned long old_end,
>>>> +A A A A A A A A A  pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
>>>> +{
>>>> +A A A  spinlock_t *old_ptl, *new_ptl;
>>>> +A A A  struct mm_struct *mm = vma->vm_mm;
>>>> +
>>>> +A A A  if ((old_addr & ~PMD_MASK) || (new_addr & ~PMD_MASK)
>>>> +A A A A A A A  || old_end - old_addr < PMD_SIZE)
>>>> +A A A A A A A  return false;
>>>> +
>>>> +A A A  /*
>>>> +A A A A  * The destination pmd shouldn't be established, free_pgtables()
>>>> +A A A A  * should have release it.
>>>> +A A A A  */
>>>> +A A A  if (WARN_ON(!pmd_none(*new_pmd)))
>>>> +A A A A A A A  return false;
>>>> +
>>>> +A A A  /*
>>>> +A A A A  * We don't have to worry about the ordering of src and dst
>>>> +A A A A  * ptlocks because exclusive mmap_sem prevents deadlock.
>>>> +A A A A  */
>>>> +A A A  old_ptl = pmd_lock(vma->vm_mm, old_pmd);
>>>> +A A A  if (old_ptl) {
>>>> +A A A A A A A  pmd_t pmd;
>>>> +
>>>> +A A A A A A A  new_ptl = pmd_lockptr(mm, new_pmd);
>>>> +A A A A A A A  if (new_ptl != old_ptl)
>>>> +A A A A A A A A A A A  spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
>>>> +
>>>> +A A A A A A A  /* Clear the pmd */
>>>> +A A A A A A A  pmd = *old_pmd;
>>>> +A A A A A A A  pmd_clear(old_pmd);
>>>> +
>>>> +A A A A A A A  VM_BUG_ON(!pmd_none(*new_pmd));
>>>> +
>>>> +A A A A A A A  /* Set the new pmd */
>>>> +A A A A A A A  set_pmd_at(mm, new_addr, new_pmd, pmd);
>>> UML does not have set_pmd_at at all
>> Every architecture does. :)
>
> I tried to build it patching vs 4.19-rc before I made this statement 
> and ran into that.
>
> Presently it does not.
>
> https://elixir.bootlin.com/linux/v4.19-rc7/ident/set_pmd_at - UML is 
> not on the list.

Once this problem as well as the omissions in the include changes for 
UML in patch one have been fixed it appears to be working.

What it needs is attached.


>
>>
>> But it may come not from the arch code.
>
> There is no generic definition as far as I can see. All 12 defines in 
> 4.19 are in arch specific code. Unless i am missing something...
>
>>
>>> If I read the code right, MIPS completely ignores the address 
>>> argument so
>>> set_pmd_at there may not have the effect which this patch is trying to
>>> achieve.
>> Ignoring address is fine. Most architectures do that..
>> The ideas is to move page table to the new pmd slot. It's nothing to do
>> with the address passed to set_pmd_at().
>
> If that is it's only function, then I am going to appropriate the code 
> out of the MIPS tree for further uml testing. It does exactly that - 
> just move the pmd the new slot.
>
>>
> A.


A.


--------------A6D223F721C42CB9BAB1286E
Content-Type: text/x-patch;
 name="0001-Incremental-fixes-to-the-mmremap-patch.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-Incremental-fixes-to-the-mmremap-patch.patch"


--------------A6D223F721C42CB9BAB1286E--
