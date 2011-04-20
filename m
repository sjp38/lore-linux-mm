Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6548D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:40:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 415273EE0AE
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 17:40:27 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2983645DE94
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 17:40:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0798445DE92
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 17:40:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EF569E38001
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 17:40:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9AF7E08001
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 17:40:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards
In-Reply-To: <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
References: <20110420161615.462D.A69D9226@jp.fujitsu.com> <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
Message-Id: <20110420174027.4631.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Apr 2011 17:40:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

> > btw, x86 don't have an issue. Probably it's a reason why this issue was=
 neglected
> > long time.
> >
> > arch/x86/Kconfig
> > -------------------------------------
> > config ARCH_DISCONTIGMEM_ENABLE
> > =A0 =A0 =A0 =A0def_bool y
> > =A0 =A0 =A0 =A0depends on NUMA && X86_32
>=20
> That part makes me think the best option is to make parisc do
> CONFIG_NUMA as well regardless of the historical intent was.
>=20
>                         Pekka

This?

compile test only.

---
 arch/parisc/Kconfig            |    7 +++++++
 include/asm-generic/topology.h |    4 ----
 include/linux/topology.h       |    2 +-
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 69ff049..0bf9ae8 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -229,6 +229,12 @@ config HOTPLUG_CPU
 	default y if SMP
 	select HOTPLUG
=20
+config NUMA
+	bool "NUMA support"
+	help
+	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
+	  Access).
+
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
 	depends on 64BIT
@@ -236,6 +242,7 @@ config ARCH_SELECT_MEMORY_MODEL
 config ARCH_DISCONTIGMEM_ENABLE
 	def_bool y
 	depends on 64BIT
+	depends on NUMA
=20
 config ARCH_FLATMEM_ENABLE
 	def_bool y
diff --git a/include/asm-generic/topology.h b/include/asm-generic/topology.=
h
index fc824e2..932567b 100644
--- a/include/asm-generic/topology.h
+++ b/include/asm-generic/topology.h
@@ -27,8 +27,6 @@
 #ifndef _ASM_GENERIC_TOPOLOGY_H
 #define _ASM_GENERIC_TOPOLOGY_H
=20
-#ifndef	CONFIG_NUMA
-
 /* Other architectures wishing to use this simple topology API should fill
    in the below functions as appropriate in their own <asm/topology.h> fil=
e. */
 #ifndef cpu_to_node
@@ -60,8 +58,6 @@
 				 cpumask_of_node(pcibus_to_node(bus)))
 #endif
=20
-#endif	/* CONFIG_NUMA */
-
 #if !defined(CONFIG_NUMA) || !defined(CONFIG_HAVE_MEMORYLESS_NODES)
=20
 #ifndef set_numa_mem
diff --git a/include/linux/topology.h b/include/linux/topology.h
index b91a40e..e1e535b 100644
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -209,7 +209,7 @@ int arch_update_cpu_topology(void);
=20
 #ifdef CONFIG_NUMA
 #ifndef SD_NODE_INIT
-#error Please define an appropriate SD_NODE_INIT in include/asm/topology.h=
!!!
+#define SD_NODE_INIT SD_ALLNODES_INIT
 #endif
=20
 #endif /* CONFIG_NUMA */
--=20
1.7.3.1




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
