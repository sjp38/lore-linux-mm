Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA456B01F2
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:49:23 -0400 (EDT)
Date: Wed, 18 Aug 2010 15:46:59 +0100
From: Chris Webb <chris@arachsys.com>
Subject: Re: Over-eager swapping
Message-ID: <20100818144655.GX2370@arachsys.com>
References: <AANLkTinjmZOOaq7FgwJOZ=UNGS8x8KtQWZg6nv7fqJMe@mail.gmail.com>
 <20100803042835.GA17377@localhost>
 <20100803214945.GA2326@arachsys.com>
 <20100804022148.GA5922@localhost>
 <AANLkTi=wRPXY9BTuoCe_sDCwhnRjmmwtAf_bjDKG3kXQ@mail.gmail.com>
 <20100804032400.GA14141@localhost>
 <20100804095811.GC2326@arachsys.com>
 <20100804114933.GA13527@localhost>
 <20100804120430.GB23551@arachsys.com>
 <20100818143801.GA9086@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100818143801.GA9086@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> writes:

> Did you enable any NUMA policy? That could start swapping even if
> there are lots of free pages in some nodes.

Hi. Thanks for the follow-up. We haven't done any configuration or tuning of
NUMA behaviour, but NUMA support is definitely compiled into the kernel:

  # zgrep NUMA /proc/config.gz 
  CONFIG_NUMA_IRQ_DESC=y
  CONFIG_NUMA=y
  CONFIG_K8_NUMA=y
  CONFIG_X86_64_ACPI_NUMA=y
  # CONFIG_NUMA_EMU is not set
  CONFIG_ACPI_NUMA=y
  # grep -i numa /var/log/dmesg.boot 
  NUMe: Allocated memnodemap from b000 - 1b540
  NUMA: Using 20 for the hash shift.

> Are your free pages equally distributed over the nodes? Or limited to
> some of the nodes? Try this command:
> 
>         grep MemFree /sys/devices/system/node/node*/meminfo

My worst-case machines current have swap completely turned off to make them
usable for clients, but I have one machine which is about 3GB into swap with
8GB of buffers and 3GB free. This shows

  # grep MemFree /sys/devices/system/node/node*/meminfo
  /sys/devices/system/node/node0/meminfo:Node 0 MemFree:          954500 kB
  /sys/devices/system/node/node1/meminfo:Node 1 MemFree:         2374528 kB

I could definitely imagine that one of the nodes could have dipped down to
zero in the past. I'll try enabling swap on one of our machines with the bad
problem late tonight and repeat the experiment. The node meminfo on this box
currently looks like

  # grep MemFree /sys/devices/system/node/node*/meminfo
  /sys/devices/system/node/node0/meminfo:Node 0 MemFree:           82732 kB
  /sys/devices/system/node/node1/meminfo:Node 1 MemFree:         1723896 kB

Best wishes,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
