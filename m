Date: Thu, 03 Jul 2008 17:46:42 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm] build failure on x86_64 pci-calgary_64.c
In-Reply-To: <20080703161028.D6CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <486C74B1.3000007@cn.fujitsu.com> <20080703161028.D6CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080703174027.D6D7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>
Cc: kosaki.motohiro@jp.fujitsu.com, Li Zefan <lizf@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik Van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > Seems the problematic patch is :
> > mmap-handle-mlocked-pages-during-map-remap-unmap.patch
> > 
> > I'm using mmotm uploaded yesterday by Andrew, so I guess this bug
> > has not been fixed ?
> > 
> > BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
> > in_atomic():1, irqs_disabled():0
> 
> sorry for that.
> I started investigate this problem.

Hi Andrew,

on ia64, I can't reproduce this problem.
on x86_64, I can't build kernel because following error happned.
           (end_pfn doesn't exist, but used)


-----------------------------------------------------
% LANG=C make -j 20
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHK     include/linux/compile.h
  CC      arch/x86/kernel/pci-calgary_64.o
arch/x86/kernel/pci-calgary_64.c: In function 'detect_calgary':
arch/x86/kernel/pci-calgary_64.c:1413: error: 'end_pfn' undeclared (first use in this function)
arch/x86/kernel/pci-calgary_64.c:1413: error: (Each undeclared identifier is reported only once
arch/x86/kernel/pci-calgary_64.c:1413: error: for each function it appears in.)
make[1]: *** [arch/x86/kernel/pci-calgary_64.o] Error 1
make: *** [arch/x86/kernel] Error 2
make: *** Waiting for unfinished jobs....
make: *** wait: No child processes.  Stop.

-----------------------------------------------------


I guess below commit or related commit is doubtfully.

:commit 1b1b18f0bf62ec808784002382f2b5833701afda
:Author: Yinghai Lu <yhlu.kernel@gmail.com>
:Date:   Tue Jun 24 22:14:09 2008 -0700
:
:    x86: remove end_pfn in 64bit
:
:    and use max_pfn directly.
:
:    Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>
:    Signed-off-by: Ingo Molnar <mingo@elte.hu>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
