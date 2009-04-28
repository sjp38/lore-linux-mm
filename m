Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E3EB36B005A
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 00:25:06 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3S4PPPr010838
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 28 Apr 2009 13:25:26 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 71B3D45DE58
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:25:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 36F2E45DE51
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:25:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 133521DB804B
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:25:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B213B1DB803C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:25:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: meminfo Committed_AS underflows
In-Reply-To: <20090427202707.9d36ce8a.akpm@linux-foundation.org>
References: <20090428092400.EBB6.A69D9226@jp.fujitsu.com> <20090427202707.9d36ce8a.akpm@linux-foundation.org>
Message-Id: <20090428130035.EBB9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 28 Apr 2009 13:25:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ebmunson@us.ibm.com, mel@linux.vnet.ibm.com, cl@linux-foundation.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

> > > > > > >  	committed = atomic_long_read(&vm_committed_space);
> > > > > > > +	if (committed < 0)
> > > > > > > +		committed = 0;
> > > > > > 
> > > 
> > > Is there a reason why we can't use a boring old percpu_counter for
> > > vm_committed_space?  That way the meminfo code can just use
> > > percpu_counter_read_positive().
> > > 
> > > Or perhaps just percpu_counter_read().  The percpu_counter code does a
> > > better job of handling large cpu counts than the
> > > mysteriously-duplicative open-coded stuff we have there.
> > 
> > At that time, I thought smallest patch is better because it can send -stable
> > tree easily.
> > but maybe I was wrong. it made bikeshed discussion :(
> 
> Yes, I know what you mean.  But otoh it's a good idea to keep -stable
> in sync with mainline - it means that -stable can merge things which
> have had a suitable amount of testing.

Agreed.


> > Reported-by: Dave Hansen <dave@linux.vnet.ibm.com>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Eric B Munson <ebmunson@us.ibm.com>
> > ---
> >  fs/proc/meminfo.c    |    2 +-
> >  include/linux/mman.h |    9 +++------
> >  mm/mmap.c            |   12 ++++++------
> >  mm/nommu.c           |   13 +++++++------
> >  mm/swap.c            |   46 ----------------------------------------------
> >  5 files changed, 17 insertions(+), 65 deletions(-)
> 
> Well that was nice.
> 
> There's potential here for weird performance regressions, so I think
> that if we do this in mainline, we should wait a while (a few weeks?)
> before backporting it.
> 
> Do we know how long this bug has existed for?  Quite a while, I expect?

ACCT_THRESHOLD was introduced bit-keeper age.
powerpc default NR_CPUS is still less 128.

% grep NR_CPUS *
cell_defconfig:CONFIG_NR_CPUS=4
celleb_defconfig:CONFIG_NR_CPUS=4
chrp32_defconfig:CONFIG_NR_CPUS=4
g5_defconfig:CONFIG_NR_CPUS=4
iseries_defconfig:CONFIG_NR_CPUS=32
maple_defconfig:CONFIG_NR_CPUS=4
mpc86xx_defconfig:CONFIG_NR_CPUS=2
pasemi_defconfig:CONFIG_NR_CPUS=2
ppc64_defconfig:CONFIG_NR_CPUS=32
ps3_defconfig:CONFIG_NR_CPUS=2
pseries_defconfig:CONFIG_NR_CPUS=128

powerpc maximum NR_CPUS was increased following commit.
I'm not sure about one year is short or long.

==========================================================
commit 90035fe378c7459ba19c43c63d5f878284224ce4
Author: Tony Breeds <tony@bakeyournoodle.com>
Date:   Thu Apr 24 13:43:49 2008 +1000

    [POWERPC] Raise the upper limit of NR_CPUS and move the pacas into the BSS

    This adds the required functionality to fill in all pacas at runtime.

    With NR_CPUS=1024
    text    data     bss     dec     hex filename
     137 1704032       0 1704169  1a00e9 arch/powerpc/kernel/paca.o :Before
     121 1179744  524288 1704153  1a00d9 arch/powerpc/kernel/paca.o :After

    Also remove unneeded #includes from arch/powerpc/kernel/paca.c

    Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
    Signed-off-by: Paul Mackerras <paulus@samba.org>

diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 5fc7fac..f7efaa9 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -220,8 +220,8 @@ config SMP
          If you don't know what to do here, say N.

 config NR_CPUS
-       int "Maximum number of CPUs (2-128)"
-       range 2 128
+       int "Maximum number of CPUs (2-1024)"
+       range 2 1024
        depends on SMP
        default "32" if PPC64
        default "4"



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
