Received: by gv-out-0910.google.com with SMTP id n8so11049gve.19
        for <linux-mm@kvack.org>; Thu, 21 Feb 2008 06:46:26 -0800 (PST)
Message-ID: <2f11576a0802210646u77409690me940717fac746315@mail.gmail.com>
Date: Thu, 21 Feb 2008 23:46:25 +0900
From: "KOSAKI Motohiro" <m-kosaki@ceres.dti.ne.jp>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller in Kconfig
In-Reply-To: <20080220185104.GA30416@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080220122338.GA4352@basil.nowhere.org>
	 <47BC2275.4060900@linux.vnet.ibm.com>
	 <18364.16552.455371.242369@stoffel.org>
	 <47BC4554.10304@linux.vnet.ibm.com>
	 <Pine.LNX.4.64.0802201647060.26109@fbirervta.pbzchgretzou.qr>
	 <20080220181911.GA4760@ucw.cz>
	 <Pine.LNX.4.64.0802201927440.26109@fbirervta.pbzchgretzou.qr>
	 <20080220185104.GA30416@elf.ucw.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Jan Engelhardt <jengelh@computergmbh.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, John Stoffel <john@stoffel.org>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

>  > >> For ordinary desktop people, memory controller is what developers
>  > >> know as MMU or sometimes even some other mysterious piece of silicon
>  > >> inside the heavy box.
>  > >
>  > >Actually I'd guess 'memory controller' == 'DRAM controller' == part of
>  > >northbridge that talks to DRAM.
>  >
>  > Yeah that must have been it when Windows says it found a new controller
>  > after changing the mainboard underneath.
>
>  Just for fun... this option really has to be renamed:

I think one reason of many people easy confusion is caused by bad menu
hierarchy.
I popose mem-cgroup move to child of cgroup and resource counter
(= obey denend on).

if you don't mind, please try to following patch.
may be, looks good than before.

---
 init/Kconfig |   52 ++++++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

Index: b/init/Kconfig
===================================================================
--- a/init/Kconfig	2008-02-17 16:44:46.000000000 +0900
+++ b/init/Kconfig	2008-02-21 23:33:51.000000000 +0900
@@ -311,6 +311,32 @@ config CPUSETS

 	  Say N if unsure.

+config PROC_PID_CPUSET
+	bool "Include legacy /proc/<pid>/cpuset file"
+	depends on CPUSETS
+	default y
+
+config CGROUP_CPUACCT
+	bool "Simple CPU accounting cgroup subsystem"
+	depends on CGROUPS
+	help
+	  Provides a simple Resource Controller for monitoring the
+	  total CPU consumed by the tasks in a cgroup
+
+config RESOURCE_COUNTERS
+	bool "Resource counters"
+	help
+	  This option enables controller independent resource accounting
+          infrastructure that works with cgroups
+	depends on CGROUPS
+
+config CGROUP_MEM_CONT
+	bool "Memory controller for cgroups"
+	depends on CGROUPS && RESOURCE_COUNTERS
+	help
+	  Provides a memory controller that manages both page cache and
+	  RSS memory.
+
 config GROUP_SCHED
 	bool "Group CPU scheduler"
 	default y
@@ -352,20 +378,6 @@ config CGROUP_SCHED

 endchoice

-config CGROUP_CPUACCT
-	bool "Simple CPU accounting cgroup subsystem"
-	depends on CGROUPS
-	help
-	  Provides a simple Resource Controller for monitoring the
-	  total CPU consumed by the tasks in a cgroup
-
-config RESOURCE_COUNTERS
-	bool "Resource counters"
-	help
-	  This option enables controller independent resource accounting
-          infrastructure that works with cgroups
-	depends on CGROUPS
-
 config SYSFS_DEPRECATED
 	bool "Create deprecated sysfs files"
 	depends on SYSFS
@@ -387,18 +399,6 @@ config SYSFS_DEPRECATED
 	  If you are using a distro that was released in 2006 or later,
 	  it should be safe to say N here.

-config CGROUP_MEM_CONT
-	bool "Memory controller for cgroups"
-	depends on CGROUPS && RESOURCE_COUNTERS
-	help
-	  Provides a memory controller that manages both page cache and
-	  RSS memory.
-
-config PROC_PID_CPUSET
-	bool "Include legacy /proc/<pid>/cpuset file"
-	depends on CPUSETS
-	default y
-
 config RELAY
 	bool "Kernel->user space relay support (formerly relayfs)"
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
