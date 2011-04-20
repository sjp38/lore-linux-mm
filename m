Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BD52C8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 22:48:57 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20110420102314.4604.A69D9226@jp.fujitsu.com>
References: <1303249716.11237.26.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191657030.26867@router.home>
	 <20110420102314.4604.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Apr 2011 21:48:53 -0500
Message-ID: <1303267733.11237.42.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

On Wed, 2011-04-20 at 10:23 +0900, KOSAKI Motohiro wrote:
> > On Tue, 19 Apr 2011, James Bottomley wrote:
> > 
> > > > Which part of me telling you that you will break lots of other things in
> > > > the core kernel dont you get?
> > >
> > > I get that you tell me this ... however, the systems that, according to
> > > you, should be failing to get to boot prompt do, in fact, manage it.
> > 
> > If you dont use certain subsystems then it may work. Also do you run with
> > debuggin on.
> > 
> > The following patch is I think what would be needed to fix it.
> 
> I'm worry about this patch. A lot of mm code assume !NUMA systems 
> only have node 0. Not only SLUB.
> 
> I'm not sure why this unfortunate mismatch occur. but I think DISCONTIG
> hacks makes less sense. Can we consider parisc turn NUMA on instead?

Well, you mean a patch like this?  It won't build ... obviously we need
some more machinery

  CC      arch/parisc/kernel/asm-offsets.s
In file included from include/linux/sched.h:78,
                 from arch/parisc/kernel/asm-offsets.c:31:
include/linux/topology.h:212:2: error: #error Please define an appropriate SD_NODE_INIT in include/asm/topology.h!!!
In file included from include/linux/sched.h:78,
                 from arch/parisc/kernel/asm-offsets.c:31:
include/linux/topology.h: In function 'numa_node_id':
include/linux/topology.h:255: error: implicit declaration of function 'cpu_to_node'

James

---

diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 69ff049..ffe4058 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -261,6 +261,9 @@ config HPUX
 	bool "Support for HP-UX binaries"
 	depends on !64BIT
 
+config NUMA
+       def_bool n
+
 config NR_CPUS
 	int "Maximum number of CPUs (2-32)"
 	range 2 32
diff --git a/mm/Kconfig b/mm/Kconfig
index e9c0c61..17a1474 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -64,6 +64,7 @@ endchoice
 config DISCONTIGMEM
 	def_bool y
 	depends on (!SELECT_MEMORY_MODEL && ARCH_DISCONTIGMEM_ENABLE) || DISCONTIGMEM_MANUAL
+	select NUMA
 
 config SPARSEMEM
 	def_bool y



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
