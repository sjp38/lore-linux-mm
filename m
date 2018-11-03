Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9D516B0007
	for <linux-mm@kvack.org>; Sat,  3 Nov 2018 12:57:38 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w10-v6so3573264plz.0
        for <linux-mm@kvack.org>; Sat, 03 Nov 2018 09:57:38 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id h2-v6si39854996plk.350.2018.11.03.09.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Nov 2018 09:57:37 -0700 (PDT)
Date: Sun, 4 Nov 2018 00:56:59 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH -next 2/3] mm: speed up mremap by 20x on large regions
 (v4)
Message-ID: <201811040056.QfAjkno6%fengguang.wu@intel.com>
References: <20181103040041.7085-3-joelaf@google.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Content-Disposition: inline
In-Reply-To: <20181103040041.7085-3-joelaf@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, kernel-team@android.com, "Kirill A . Shutemov" <kirill@shutemov.name>, akpm@linux-foundation.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, anton.ivanov@kot-begemot.co.uk, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, dancol@google.com, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, elfring@users.sourceforge.net, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, hughd@google.com, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, Julia Lawall <Julia.Lawall@lip6.fr>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, lokeshgidra@google.com, Max Filippov <jcmvbkbc@gmail.com>, Michal Hocko <mhocko@kernel.org>, minchan@kernel.org, nios2-dev@lists.rocketboards.org, pantin@google.com, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Joel,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on next-20181102]

url:    https://github.com/0day-ci/linux/commits/Joel-Fernandes/Add-support-for-fast-mremap/20181103-224908
config: openrisc-or1ksim_defconfig (attached as .config)
compiler: or1k-linux-gcc (GCC) 6.0.0 20160327 (experimental)
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=openrisc 

All errors (new ones prefixed by >>):

   mm/mremap.c: In function 'move_normal_pmd':
>> mm/mremap.c:229:2: error: implicit declaration of function 'set_pmd_at' [-Werror=implicit-function-declaration]
     set_pmd_at(mm, new_addr, new_pmd, pmd);
     ^~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/set_pmd_at +229 mm/mremap.c

   193	
   194	static bool move_normal_pmd(struct vm_area_struct *vma, unsigned long old_addr,
   195			  unsigned long new_addr, unsigned long old_end,
   196			  pmd_t *old_pmd, pmd_t *new_pmd)
   197	{
   198		spinlock_t *old_ptl, *new_ptl;
   199		struct mm_struct *mm = vma->vm_mm;
   200		pmd_t pmd;
   201	
   202		if ((old_addr & ~PMD_MASK) || (new_addr & ~PMD_MASK)
   203		    || old_end - old_addr < PMD_SIZE)
   204			return false;
   205	
   206		/*
   207		 * The destination pmd shouldn't be established, free_pgtables()
   208		 * should have release it.
   209		 */
   210		if (WARN_ON(!pmd_none(*new_pmd)))
   211			return false;
   212	
   213		/*
   214		 * We don't have to worry about the ordering of src and dst
   215		 * ptlocks because exclusive mmap_sem prevents deadlock.
   216		 */
   217		old_ptl = pmd_lock(vma->vm_mm, old_pmd);
   218		new_ptl = pmd_lockptr(mm, new_pmd);
   219		if (new_ptl != old_ptl)
   220			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
   221	
   222		/* Clear the pmd */
   223		pmd = *old_pmd;
   224		pmd_clear(old_pmd);
   225	
   226		VM_BUG_ON(!pmd_none(*new_pmd));
   227	
   228		/* Set the new pmd */
 > 229		set_pmd_at(mm, new_addr, new_pmd, pmd);
   230		flush_tlb_range(vma, old_addr, old_addr + PMD_SIZE);
   231		if (new_ptl != old_ptl)
   232			spin_unlock(new_ptl);
   233		spin_unlock(old_ptl);
   234	
   235		return true;
   236	}
   237	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--Nq2Wo0NMKNjxTN9z
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--Nq2Wo0NMKNjxTN9z--
