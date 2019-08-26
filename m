Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0AD4C3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24DD72070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="c4zbl6zw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24DD72070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 741F76B0003; Mon, 26 Aug 2019 15:36:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F6256B0006; Mon, 26 Aug 2019 15:36:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EC9A6B0003; Mon, 26 Aug 2019 15:36:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id 2FBA16B0003
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:44 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D45FC181AC9AE
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:43 +0000 (UTC)
X-FDA: 75865586286.25.place55_1d8af507bec0f
X-HE-Tag: place55_1d8af507bec0f
X-Filterd-Recvd-Size: 20712
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:42 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 74F1342A6B9;
	Mon, 26 Aug 2019 12:37:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848247;
	bh=nJjh92nV0RGl6JFt88eLUBCgHIaMrYyxXIwf+0aftxI=;
	h=From:To:Cc:Subject:Date;
	b=c4zbl6zw6kXS6ELx3PQUlgiLjt1EonZoRknXf0GO+TLLnMDlFNqD29I+bjUvFr0Zb
	 B7rE7zbj81cCXUEq796J1PTmRLp/hs8fDkyQMMP0ToZumg0N5XCYg5yHe5PXgej7E8
	 OAxwbmkbPbTK6ol+LR45hOz4ML2Me6kW/lCMVBqN4WTjox+OfaDk1G2LfxvICAQVwR
	 UD2t7vOyu65fJ4Dwnxc1ymKSdexZyS9Zbf6poombAzsIVBnI8ON+03k2TAX+DAkuT1
	 6dhU0knFS+X8mkD4VarU9Hwy4KiA0hjroSEQ/E5uoR3DJbiyMZ7HfQkcO3EoQrZIjM
	 /2AoOGm3vrRlg==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 6638942A6B7;
	Mon, 26 Aug 2019 12:37:27 -0700 (PDT)
From: Edward Chron <echron@arista.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Shakeel Butt <shakeelb@google.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	colona@arista.com,
	Edward Chron <echron@arista.com>
Subject: [PATCH 00/10] OOM Debug print selection and additional information
Date: Mon, 26 Aug 2019 12:36:28 -0700
Message-Id: <20190826193638.6638-1-echron@arista.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch series provides code that works as a debug option through
debugfs to provide additional controls to limit how much information
gets printed when an OOM event occurs and or optionally print additional
information about slab usage, vmalloc allocations, user process memory
usage, the number of processes / tasks and some summary information
about these tasks (number runable, i/o wait), system information
(#CPUs, Kernel Version and other useful state of the system),
ARP and ND Cache entry information.

Linux OOM can optionally provide a lot of information, what's missing?
----------------------------------------------------------------------
Linux provides a variety of detailed information when an OOM event occurs
but has limited options to control how much output is produced. The
system related information is produced unconditionally and limited per
user process information is produced as a default enabled option. The
per user process information may be disabled.

Slab usage information was recently added and is output only if slab
usage exceeds user memory usage.

Many OOM events are due to user application memory usage sometimes in
combination with the use of kernel resource usage that exceeds what is
expected memory usage. Detailed information about how memory was being
used when the event occurred may be required to identify the root cause
of the OOM event.

However, some environments are very large and printing all of the
information about processes, slabs and or vmalloc allocations may
not be feasible. For other environments printing as much information
about these as possible may be needed to root cause OOM events.

Extensibility using OOM debug options
-------------------------------------
What is needed is an extensible system to optionally configure
debug options as needed and to then dynamically enable and disable
them. Also for options that produce multiple lines of entry based
output, to configure which entries to print based on how much
memory they use (or optionally all the entries).

Limiting print entry output based on object size
------------------------------------------------
To limit output, a fixed size of object could be used such as:
vmallocs that use more than 1MB, slabs that are using more than
512KB, processes using 16MB or more of memory. Such an apporach
is quite reasonable.

Using OOM's memory metrics to limit printing based on entry size
----------------------------------------------------------------
However, the current implementation of OOM which has been in use for
almost a decade scores based on 1/10 % of memory. This methodology scales
well as memory sizes increase. If you limit the objects you examine to
those using 0.1% of memory you still may get a large number of objects
but avoid printing those using a relatively small amount of memory.

Further options that allow limiting output based on object size
can have the minimum size set to zero. In this case objects
that use even a small amount of memory will be printed.

Use of debugfs to allow dynamic controls
----------------------------------------
By providing a debugfs interface that allows options to be configured,
enabled and where appropriate to set a minimum size for selecting
entries to print, the output produced when an OOM event occurs can be
dynamically adjusted to produce as little or as much detail as needed
for a given system.

OOM debug options can be added to the base code as needed.

Currently we have the following OOM debug options defined:

* System State Summary
  --------------------
  One line of output that includes:
  - Uptime (days, hour, minutes, seconds)
  - Number CPUs
  - Machine Type
  - Node name
  - Domain name
  - Kernel Release
  - Kernel Version

  Example output when configured and enabled:

Jul 27 10:56:46 yoursystem kernel: System Uptime:0 days 00:17:27 CPUs:4 M=
achine:x86_64 Node:yoursystem Domain:localdomain Kernel Release:5.3.0-rc2=
+ Version: #49 SMP Mon Jul 27 10:35:32 PDT 2019

* Tasks Summary
  -------------
  One line of output that includes:
  - Number of Threads
  - Number of processes
  - Forks since boot
  - Processes that are runnable
  - Processes that are in iowait

  Example output when configured and enabled:

Jul 22 15:20:57 yoursystem kernel: Threads:530 Processes:279 forks_since_=
boot:2786 procs_runable:2 procs_iowait:0

* ARP Table and/or Neighbour Discovery Table Summary
  --------------------------------------------------
  One line of output each for ARP and ND that includes:
  - Table name
  - Table size (max # entries)
  - Key Length
  - Entry Size
  - Number of Entries
  - Last Flush (in seconds)
  - hash grows
  - entry allocations
  - entry destroys
  - Number lookups
  - Number of lookup hits
  - Resolution failures
  - Garbage Collection Forced Runs
  - Table Full
  - Proxy Queue Length

  Example output when configured and enabled (for both):

... kernel: neighbour: Table: arp_tbl size:   256 keyLen:  4 entrySize: 3=
60 entries:     9 lastFlush:  1721s hGrows:     1 allocs:     9 destroys:=
     0 lookups:   204 hits:   199 resFailed:    38 gcRuns/Forced: 111 /  =
0 tblFull:  0 proxyQlen:  0

... kernel: neighbour: Table:  nd_tbl size:   128 keyLen: 16 entrySize: 3=
68 entries:     6 lastFlush:  1720s hGrows:     0 allocs:     7 destroys:=
     1 lookups:     0 hits:     0 resFailed:     0 gcRuns/Forced: 110 /  =
0 tblFull:  0 proxyQlen:  0

* Add Select Slabs Print
  ----------------------
  Allow select slab entries (based on a minimum size) to be printed.
  Minimum size is specified as a percentage of the total RAM memory
  in tenths of a percent, consistent with existing OOM process scoring.
  Valid values are specified from 0 to 1000 where 0 prints all slab
  entries (all slabs that have at least one slab object in use) up
  to 1000 which would require a slab to use 100% of memory which can't
  happen so in that case only summary information is printed.

  The first line of output is the standard Linux output header for
  OOM printed Slab entries. This header looks like this:

Aug  6 09:37:21 egc103 yourserver: Unreclaimable slab info:

  The output is existing slab entry memory usage limited such that only
  entries equal to or larger than the minimum size are printed.
  Empty slabs (no slab entries in slabs in use) are never printed.

  Additional output consists of summary information that is printed
  at the end of the output. This summary information includes:
  - # entries examined
  - # entries selected and printed
  - minimum entry size for selection
  - Slabs total size (kB)
  - Slabs reclaimable size (kB)
  - Slabs unreclaimable size (kB)

  Example Summary output when configured and enabled:

Jul 23 23:26:34 yoursystem kernel: Summary: Slab entries examined: 123 pr=
inted: 83 minsize: 0kB

Jul 23 23:26:34 yoursystem kernel: Slabs Total: 151212kB Reclaim: 50632kB=
 Unreclaim: 100580kB

* Add Select Vmalloc allocations Print
  ------------------------------------
  Allow select vmalloc entries (based on a minimum size) to be printed.
  Minimum size is specified as a percentage of the total RAM memory
  in tenths of a percent, consistent with existing OOM process scoring.
  Valid values are specified from 0 to 1000 where 0 prints all vmalloc
  entries (all vmalloc allocations that have at least one page in use) up
  to 1000 which would require a vmalloc to use 100% of memory which can't
  happen so in that case only summary information is printed.

  The first line of output is a new Vmalloc output header for
  OOM printed Vmalloc entries. This header looks like this:

Aug 19 19:27:01 yourserver kernel: Vmalloc Info:

  The output is vmalloc entry information output limited such that only
  entries equal to or larger than the minimum size are printed.
  Unused vmallocs (no pages assigned to the vmalloc) are never printed.
  The vmalloc entry information includes:
  - Size (in bytes)
  - pages (Number pages in use)
  - Caller Information to identify the request

  A sample vmalloc entry output looks like this:

Jul 22 20:16:09 yoursystem kernel: Vmalloc size=3D2625536 pages=3D640 cal=
ler=3D__do_sys_swapon+0x78e/0x113

  Additional output consists of summary information that is printed
  at the end of the output. This summary information includes:
  - Number of Vmalloc entries examined
  - Number of Vmalloc entries printed
  - minimum entry size for selection

  A sample Vmalloc Summary output looks like this:

Aug 19 19:27:01 coronado kernel: Summary: Vmalloc entries examined: 1070 =
printed: 989 minsize: 0kB

* Add Select Process Entries Print
  --------------------------------
  Allow select process entries (based on a minimum size) to be printed.
  Minimum size is specified as a percentage totalpages (RAM + swap)
  in tenths of a percent, consistent with existing OOM process scoring.
  Note: user process memory can be swapped out when swap space present
  so that is why swap space and ram memory comprise the totalpages
  used to calculate the percentage of memory a process is using.
  Valid values are specified from 0 to 1000 where 0 prints all user
  processes (that have valid mm sections and aren't exiting) up to
  1000 which would require a user process to use 100% of memory which
  can't happen so in that case only summary information is printed.

  The first line of output is the standard Linux output headers for
  OOM printed User Processes. This header looks like this:

Aug 19 19:27:01 yourserver kernel: Tasks state (memory values in pages):
Aug 19 19:27:01 yourserver kernel: [  pid  ]   uid  tgid total_vm      rs=
s pgtables_bytes swapents oom_score_adj name

  The output is existing per user process data limited such that only
  entries equal to or larger than the minimum size are printed.

Jul 21 20:07:48 yourserver kernel: [    579]     0   579     7942     101=
0          90112        0         -1000 systemd-udevd

  Additional output consists of summary information that is printed
  at the end of the output. This summary information includes:

Aug 19 19:27:01 yourserver kernel: Summary: OOM Tasks considered:277 prin=
ted:143 minimum size:0kB totalpages:32791608kB

* Add Slab Select Always Print Enable
  -----------------------------------
  This option will enable slab entries to be printed even when slab
  memory usage does not exceed the standard Linux user memory usage
  print trigger. The Standard OOM event Slab entry print trigger is
  that slab memory usage exceeds user memory usage. This covers cases
  where the Kernel or Kernel drivers are driving slab memory usage up
  causing it to be excessive. However, OOM Events are often caused by
  user processes causing too much memory usage. In some cases where
  the user memory usage is higher the amount of slab memory consumed
  can still be an important factor in determining what caused the OOM
  event. In such cases it would be useful to have slab memory usage
  for any slab entries using a significant amount of memory.

  No changes to output format occurs, enabling the option simply
  causes what ever slabs are print eligible (from Select Slabs
  option, which this option depends on) get printed on any OOM
  event regardless of whether the memory usage by Slabs exceeds
  user memory usage or not.

* Add Enhanced Slab Print Information
  -----------------------------------
  For any slab entries that are print eligible (from Select Slabs
  option, which this option depends on) print some additional
  details about the slab that can be useful to root causing
  OOM events.

  Output information for each enhanced slab entry includes:
  - Used space (KiB)
  - Total space (KiB)
  - Active objects
  - Total Objects
  - Object size
  - Aligned object size
  - Object per Slab
  - Pages per Slab
  - Active Slabs
  - Total Slabs
  - Slab name

  The header for enhanced slab entries is revised and looks like this:

Aug 19 19:27:01 coronado kernel:   UsedKiB   TotalKiB  ActiveObj   TotalO=
bj   ObjSize AlignSize Objs/Slab Pgs/Slab ActiveSlab  TotalSlab Slab_Name

  Each enhanced slab entry is similar to the following output format:

Aug 19 19:27:01 coronado kernel:      9016       9016     384710     3847=
10        24        24       170        1       2263       2263 avtab_nod=
e


* Add Enhanced Process Print Information
  --------------------------------------
  Add OOM Debug code that prints additional detailed information about
  users processes that were considered for OOM killing for any print
  selected processes. The information is displayed for each user process
  that OOM prints in the output.

  This supplemental per user process information is very helpful for
  determing how process memory is used to allow OOM event root cause
  identifcation that might not otherwise be possible.

  Output information for enhanced user process entrys printed includes:
  - pid
  - parent pid
  - ruid
  - euid
  - tgid
  - Process State (S)
  - utime in seconds
  - stime in seconds
  - oom_score_adjust
  - task comm value (name of process)
  - Vmem KiB
  - MaxRss KiB
  - CurRss KiB
  - Pte KiB
  - Swap KiB
  - Sock KiB
  - Lib KiB
  - Text KiB
  - Heap KiB
  - Stack KiB
  - File KiB
  - Shmem KiB
  - Read Pages
  - Fault Pages
  - Lock KiB
  - Pinned KiB

  The headers for Processes changes to match the data being printed:

Aug 19 19:27:01 yourserver kernel: Tasks state (memory values in KiB):

...: [  pid  ]    ppid    ruid    euid    tgid S  utimeSec  stimeSec   Vm=
emKiB MaxRssKiB CurRssKiB    PteKiB   SwapKiB   SockKiB     LibKiB   Text=
KiB   HeapKiB  StackKiB   FileKiB  ShmemKiB     ReadPgs    FaultPgs   Loc=
kKiB PinnedKiB Adjust name

  A few entries that print formatted to match the second header:

...: [    570]       1       0       0     570 S     0.530     0.105     =
31632     12064      3864        88         0       416       9500       =
208      3608       132        36         0          60       41615      =
   0         0  -1000 systemd-udevd
...: [    759]       1       0       0     759 S     1.264     0.545     =
17196      6072       788        72         0       624       8912       =
 32       596       132         0         0           0           0      =
   0         0      0 rngd
...: [   1626]    1553   10383   10383    1626 S     9.417     2.355   33=
47904    336316    231672       924         0       416      56452       =
 16    170656       276      2116    150756           4        2309      =
   0         0      0 gnome-shell

Configuring Patches:
-------------------
OOM Debug and any options you want to use must first be configured so
the code is included in your kernel. This requires selecting kernel
config file options. You will find config options to select under:

Kernel hacking ---> Memory Debugging --->

[*] Debug OOM
    [*] Debug OOM System State
    [*] Debug OOM System Tasks Summary
    [*] Debug OOM ARP Table
    [*] Debug OOM ND Table
    [*] Debug OOM Select Slabs Print
       [*] Debug OOM Slabs Select Always Print Enable
       [*] Debug OOM Enhanced Slab Print
    [*] Debug OOM Select Vmallocs Print
    [*] Debug OOM Select Process Print
       [*] Debug OOM Enhanced Process Print

The heirarchy shown also displays the dependencies between OOM Debug for
these options. Everything depends on Debug OOM as that is where the base
code that all options require is located. Process has an Enhanced output
but requires Select Process to be enabled so you can limit the output
since you're asking for more details. The same is true with Slabs the
Enhanced output requires Select Slabs and so does Slabs Select Always
Print, to ensure you can limit your output if you need to.

Dyanmic enable/disable and setting entry minsize for Options
------------------------------------------------------------
As mentioned all options can be dynamically disabled and re-enabled.
The Select Options also allow setting minimum entry size to limit
entry printing based on the amount of memory they use, using the
OOM 0% to 100% in 1/10 % increments (1-1000). This is impelemented in
debugfs. Entries for OOM Debug are defined in the /sys/kernel/debug/oom
directory.

Arbitrary default values have been selected. The default is to enable
configured options and to set minimum entry size to 10 which is 1% of
the memory (or memory plus swap for processes). The choice was to
make sure by default you don't get a lot of data just for enabling an
option. Here is what the current defaults are set to for all the
OOM Debug options we currently have defined:

[root@yourserver ~]# grep "" /sys/kernel/debug/oom/*
/sys/kernel/debug/oom/arp_table_summary_enabled:Y
/sys/kernel/debug/oom/nd_table_summary_enabled:Y
/sys/kernel/debug/oom/process_enhanced_print_enabled:Y
/sys/kernel/debug/oom/process_select_print_enabled:Y
/sys/kernel/debug/oom/process_select_print_tenthpercent:10
/sys/kernel/debug/oom/slab_enhanced_print_enabled:Y
/sys/kernel/debug/oom/slab_select_always_print_enabled:Y
/sys/kernel/debug/oom/slab_select_print_enabled:Y
/sys/kernel/debug/oom/slab_select_print_tenthpercent:10
/sys/kernel/debug/oom/system_state_summary_enabled:Y
/sys/kernel/debug/oom/tasks_summary_enabled:Y
/sys/kernel/debug/oom/vmalloc_select_print_enabled:Y
/sys/kernel/debug/oom/vmalloc_select_print_tenthpercent:10

You can disable or re-enable options in the appropriate enable file
or adjust the minimum size value in the appropriate tenthpercent file
as needed.

---------------------------------------------------------------------

Edward Chron (10):
  mm/oom_debug: Add Debug base code
  mm/oom_debug: Add System State Summary
  mm/oom_debug: Add Tasks Summary
  mm/oom_debug: Add ARP and ND Table Summary usage
  mm/oom_debug: Add Select Slabs Print
  mm/oom_debug: Add Select Vmalloc Entries Print
  mm/oom_debug: Add Select Process Entries Print
  mm/oom_debug: Add Slab Select Always Print Enable
  mm/oom_debug: Add Enhanced Slab Print Information
  mm/oom_debug: Add Enhanced Process Print Information

 include/linux/oom.h     |   1 +
 include/linux/vmalloc.h |  12 +
 include/net/neighbour.h |  12 +
 mm/Kconfig.debug        | 228 +++++++++++++
 mm/Makefile             |   1 +
 mm/oom_kill.c           |  83 ++++-
 mm/oom_kill_debug.c     | 736 ++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill_debug.h     |  58 ++++
 mm/slab.h               |   4 +
 mm/slab_common.c        |  94 +++++
 mm/vmalloc.c            |  43 +++
 net/core/neighbour.c    |  78 +++++
 12 files changed, 1339 insertions(+), 11 deletions(-)
 create mode 100644 mm/oom_kill_debug.c
 create mode 100644 mm/oom_kill_debug.h

--=20
2.20.1


