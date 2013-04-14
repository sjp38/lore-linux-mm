Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 61D856B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 19:57:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Apr 2013 09:54:57 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 5C1CA2BB0051
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 09:57:04 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3ENuvQl2359784
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 09:56:58 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3ENv2sH023160
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 09:57:03 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH] staging: ramster: add how-to for ramster
Date: Mon, 15 Apr 2013 07:56:56 +0800
Message-Id: <1365983816-30204-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

From: Dan Magenheimer <dan.magenheimer@oracle.com>

Add how-to for ramster.

Singed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/ramster/HOWTO.txt |  249 ++++++++++++++++++++++++++++++
 1 file changed, 249 insertions(+)
 create mode 100644 drivers/staging/zcache/ramster/HOWTO.txt

diff --git a/drivers/staging/zcache/ramster/HOWTO.txt b/drivers/staging/zcache/ramster/HOWTO.txt
new file mode 100644
index 0000000..e6387e8
--- /dev/null
+++ b/drivers/staging/zcache/ramster/HOWTO.txt
@@ -0,0 +1,249 @@
+Version: 130309
+ Dan Magenheimer <dan.magenheimer@oracle.com>
+
+This is a how-to document for RAMster.  It applies to the March 9, 2013
+version of RAMster, re-merged with the new zcache codebase, built and tested
+on the 3.9 tree and submitted for the staging tree for 3.9.
+
+Note that this document was created from notes taken earlier.  I would
+appreciate any feedback from anyone who follows the process as described
+to confirm that it works and to clarify any possible misunderstandings,
+or to report problems.
+
+A. PRELIMINARY
+
+1) Install two or more Linux systems that are known to work when upgraded
+   to a recent upstream Linux kernel version (e.g. v3.9).  I used Oracle
+   Linux 6 ("OL6") on two Dell Optiplex 790s.  Note that it should be possible
+   to use ocfs2 as a filesystem on your systems but this hasn't been
+   tested thoroughly, so if you do use ocfs2 and run into problems, please
+   report them.  Up to eight nodes should work, but not much testing has
+   been done with more than three nodes.
+
+On each system:
+
+2) Configure, build and install then boot Linux (e.g. 3.9), just to ensure it
+   can be done with an unmodified upstream kernel.  Confirm you booted
+   the upstream kernel with "uname -a".
+
+3) Install ramster-tools.  The src.rpm and an OL6 rpm are available
+   in this directory.  I'm not very good at userspace stuff and
+   would welcome any help in turning ramster-tools into more
+   distributable rpms/debs for a wider range of distros.
+
+B. BUILDING RAMSTER INTO THE KERNEL
+
+Do the following on each system:
+
+1) Ensure you have the new codebase for drivers/staging/zcache in your source.
+
+2) Change your .config to have:
+
+	CONFIG_CLEANCACHE=y
+	CONFIG_FRONTSWAP=y
+	CONFIG_STAGING=y
+	CONFIG_ZCACHE=y
+	CONFIG_RAMSTER=y
+
+   You may have to reconfigure your kernel multiple times to ensure
+   all of these are set properly.  I use:
+
+	# yes "" | make oldconfig
+
+   and then manually check the .config file to ensure my selections
+   have "taken".
+
+   Do not bother to build the kernel until you are certain all of
+   the above config selections will stick for the build.
+
+3) Build this kernel and "make install" so that you have a new kernel
+   in /etc/grub.conf
+
+4) Add "ramster" to the kernel boot line in /etc/grub.conf.
+
+5) Reboot and check dmesg to ensure there are some messages from ramster
+   and that "ramster_enabled=1" appears.
+
+	# dmesg | grep ramster
+
+   You should also see a lot of files in:
+
+	# ls /sys/kernel/debug/zcache
+	# ls /sys/kernel/debug/ramster
+
+   and a few files in:
+
+	# ls /sys/kernel/mm/ramster
+
+   RAMster now will act as a single-system zcache but doesn't yet
+   know anything about the cluster so can't do anything remotely.
+
+C. BUILDING THE RAMSTER CLUSTER
+
+This is the error prone part unless you are a clustering expert.  We need
+to describe the cluster in /etc/ramster.conf file and the init scripts
+that parse it are extremely picky about the syntax.
+
+1) Create the /etc/ramster.conf file and ensure it is identical
+   on both systems.  There is a good amount of similar documentation
+   for ocfs2 /etc/cluster.conf that can be googled for this, but I use:
+
+	cluster:
+		name = ramster
+		node_count = 2
+	node:
+		name = system1
+		cluster = ramster
+		number = 0
+		ip_address = my.ip.ad.r1
+		ip_port = 7777
+	node:
+		name = system2
+		cluster = ramster
+		number = 0
+		ip_address = my.ip.ad.r2
+		ip_port = 7777
+
+   You must ensure that the "name" field in the file exactly matches
+   the output of "hostname" on each system.  The following assumes
+   you use "ramster" as the name of your cluster.
+
+2) Enable the ramster service and configure it:
+
+	# chkconfig --add ramster
+	# service ramster configure
+
+   Set "load on boot" to "y", cluster to start is "ramster" (or whatever
+   name you chose in ramster.conf), heartbeat dead threshold as "500",
+   network idle timeout as "1000000".  Leave the others as default.
+
+4) Reboot.  After reboot, try:
+
+	# service ramster status
+
+   You should see "Checking ramster cluster ramster: Online".  If you do
+   not, something is wrong and RAMster will not work.  Note that you
+   should also see that the driver for "configfs" is loaded and mounted,
+   the driver for ocfs2_dlmfs is not loaded, and some numbers for network
+   parameters.  You will also see "Checking ramster heartbeat: Not active".
+   That's all OK.
+
+5) Now you need to start the cluster heartbeat; the cluster is not "up"
+   until all nodes detect a heartbeat.  Normally this is done via
+   a cluster filesystem, but you don't have one.  Some hack-y
+   code in RAMster can start it for you though if you tell it what
+   nodes are "up".  To enable it for nodes 0 and 1, do:
+
+	# echo 0 > /sys/kernel/mm/ramster/manual_node_up
+	# echo 1 > /sys/kernel/mm/ramster/manual_node_up
+
+   This must be done on ALL nodes.  I usually put these lines
+   in /etc/rc.local as otherwise I forget.  To confirm that
+   the cluster is now up, on both systems do:
+
+	# dmesg | grep ramster
+
+   You should see "Accepted connection" messages in dmesg after this.
+
+6) You must tell each node the node to which it should "remotify" pages.
+   For example if you have a three-node cluster and you want nodes
+   1 and 2 to be "clients" and node 0 to be the "memory server", then
+   on nodes 1 and 2, you do:
+
+	# echo 0 > /sys/kernel/mm/ramster/remote_target_nodenum
+
+   You should see "ramster: node N set as remotification target"
+   in dmesg.  Again, /etc/rc.local is a good place to put this
+   so you don't forget to do it at each boot.
+
+7) One more step:  By default, the RAMster code does not "remotify" any
+   pages; this is primarily for testing purposes, but sometimes it is
+   useful.  This may change in the future, but for now, you must:
+
+	# echo 1 > /sys/kernel/mm/ramster/pers_remotify_enable
+	# echo 1 > /sys/kernel/mm/ramster/eph_remotify_enable
+
+   The first enables remotifying swap (persistent, aka frontswap) pages,
+   the second enables remotifying of page cache (ephemeral, cleancache)
+   pages.
+
+   These lines can also be put in /etc/rc.local (AFTER the node_up
+   lines), or I often just put them at the beginning of my script that
+   runs a workload.
+
+8) Most testing has been done with both/all machines booted roughly
+   simultaneously.  Ideally, you should do this too unless you are
+   trying to break RAMster rather than just use it. ;-)
+
+D. TESTING RAMSTER
+
+1) Note that RAMster has no value unless pages get "remotified".  For
+   swap/frontswap/persistent pages, this doesn't happen unless/until
+   the workload would cause swapping to occur, at which point pages
+   are put into frontswap/zcache, and the remotification thread starts
+   working.  To get to the point where the system swaps, you either
+   need a workload for which the working set exceeds the RAM in the
+   system; or you need to somehow reduce the amount of RAM one of
+   the system sees.  This latter is easy when testing in a VM, but
+   harder on physical systems.  In some cases, "mem=xxxM" on the
+   kernel command line restricts memory, but for some values of xxx
+   my kernel fails to boot.  I may also try creating a fixed RAMdisk,
+   doing nothing with it, but ensuring that it eats up a fixed
+   amount of RAM.
+2) To see if RAMster is working, on the remote system, I do:
+
+	# watch -d 'cat /sys/kernel/debug/ramster/foreign_*'
+
+   to monitor the number (and max) ephemeral and persistent pages
+   that RAMster has sent.  If these stay at 0, RAMster is not working
+   either because the workload isn't creating enough memory pressure
+   or because "remotifying" isn't working.  On the system with the
+   workload, you can watch lots of useful information also, but beware
+   that you may be affecting the workload and performance.  I use
+	# watch ./watchme
+   where the watchme file contains:
+
+	for i in /sys/kernel/debug/zcache/evicted_buddied_pages \
+		/sys/kernel/debug/zcache/evicted_raw_pages \
+		/sys/kernel/debug/zcache/evicted_unbuddied_pages \
+		/sys/kernel/debug/zcache/zbud_curr_raw_pages \
+		/sys/kernel/debug/zcache/zbud_curr_zbytes \
+		/sys/kernel/debug/zcache/zbud_curr_zpages \
+		/sys/kernel/debug/ramster/eph_pages_remoted \
+		/sys/kernel/debug/ramster/remote_eph_pages_succ_get \
+		/sys/kernel/debug/ramster/remote_pers_pages_succ_get \
+		/sys/kernel/debug/frontswap/succ_puts
+	do
+		echo $i ": " $(cat $i)
+	done
+   And if you have debugfs mounted (as /sys/kernel/debug), you can
+   add to the watchme script some interesting counters in
+   /sys/kernel/debug/cleancache/* and /sys/kernel/debug/frontswap/*
+
+3) In v4, there are known issues in counting certain values.  As a result
+   you may see periodic warnings from the kernel.  Almost always you
+   will see "ramster: bad accounting for XXX".  There are also "WARN_ONCE"
+   messages.  If you see kernel warnings with a tombstone, please report
+   them.  They are harmless but reflect bugs that need to be eventually fixed.
+
+AUTOMATIC SWAP REPATRIATION
+
+You may notice that while the systems are idle, the foreign persistent
+page count on the remote machine slowly decreases.  This is because
+RAMster implements "frontswap selfshrinking":  When possible, swap
+pages that have been remotified are slowly repatriated to the local
+machine.  This is so that local RAM can be used when possible and
+so that, in case of remote machine crash, the probability of loss
+of data is reduced.
+
+REBOOTING / POWEROFF
+
+If a system is shut down while some of its swap pages still reside
+on a remote system, the system may lock up partially through the shutdown
+sequence.  This is because the network is shut down before the
+swap mechansim is shut down.  To avoid this annoying problem, simply
+shut off the swap subsystem before starting the shutdown sequence, e.g.:
+
+	# swapoff -a
+	# reboot
+
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
