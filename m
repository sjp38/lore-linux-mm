Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE83A6B007E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 16:25:37 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so187156160pad.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 13:25:37 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id a141si18059086pfa.80.2016.04.29.13.25.36
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 13:25:36 -0700 (PDT)
From: "Chen, Tim C" <tim.c.chen@intel.com>
Subject: RE: [RFC PATCH] swap: choose swap device according to numa node
Date: Fri, 29 Apr 2016 20:25:31 +0000
Message-ID: <045D8A5597B93E4EBEDDCBF1FC15F509359EAF8F@fmsmsx104.amr.corp.intel.com>
References: <20160429083408.GA20728@aaronlu.sh.intel.com>
In-Reply-To: <20160429083408.GA20728@aaronlu.sh.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Lu, Aaron" <aaron.lu@intel.com>, Linux MM <linux-mm@kvack.org>
Cc: "Huang, Ying" <ying.huang@intel.com>



>-----Original Message-----
>From: Lu, Aaron
>Sent: Friday, April 29, 2016 1:34 AM
>To: Linux MM
>Cc: Chen, Tim C; Huang, Ying
>Subject: [RFC PATCH] swap: choose swap device according to numa node
>
>If the system has more than one swap device and swap device has the node
>information, we can make use of this information to decide which swap devi=
ce
>to use in get_swap_page.
>
>The current code uses a priority based list, swap_avail_list, to decide wh=
ich swap
>device to use each time and if multiple swap devices share the same priori=
ty,
>they are used round robin. This patch change the previous single global
>swap_avail_list into a per-numa-node list, i.e.
>for each numa node, it sees its own priority based list of available swap =
devices.
>This will require checking a swap device's node value during swap on time =
and
>then promote its priority(more on thie below) in the swap_avail_list accor=
ding to
>which node's list it is being added to. Once this is done, there should be=
 little, if
>not none, cost in get_swap_page time.
>
>The current swap device's priority is set as: user can set a >=3D0 value, =
or the
>system will pick one by starting from -1 then downwards.
>And the priority value in the swap_avail_list is the negated value of the =
swap
>device's priority due to plist is sorted from low to high. The new policy =
doesn't
>change the semantics for priority >=3D0 cases, the previous starting from =
-1 then
>downwards now becomes starting from -2 then downwards. -1 is reserved as t=
he
>promoted value.
>
>Take an 4-node EX machine as an example, suppose 4 swap devices are
>available, each sit on a different node:
>swapA on node 0
>swapB on node 1
>swapC on node 2
>swapD on node 3
>
>After they are all swapped on in the sequence of ABCD.
>
>Current behaviour:
>their priorities will be:
>swapA: -1
>swapB: -2
>swapC: -3
>swapD: -4
>And their position in the global swap_avail_list will be:
>swapA   -> swapB   -> swapC   -> swapD
>prio:1     prio:2     prio:3     prio:4
>
>New behaviour:
>their priorities will be(note that -1 is skipped):
>swapA: -2
>swapB: -3
>swapC: -4
>swapD: -5
>And their positions in the 4 swap_avail_lists[node] will be:
>swap_avail_lists[0]: /* node 0's available swap device list */
>swapA   -> swapB   -> swapC   -> swapD
>prio:1     prio:3     prio:4     prio:5
>swap_avali_lists[1]: /* node 1's available swap device list */
>swapB   -> swapA   -> swapC   -> swapD
>prio:1     prio:2     prio:4     prio:5
>swap_avail_lists[2]: /* node 2's available swap device list */
>swapC   -> swapA   -> swapB   -> swapD
>prio:1     prio:2     prio:3     prio:5
>swap_avail_lists[3]: /* node 3's available swap device list */
>swapD   -> swapA   -> swapB   -> swapC
>prio:1     prio:2     prio:3     prio:4
>
>The test case used is:
>https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git/tree/c=
ase-
>swap-w-seq
>https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git/tree/u=
semem.c
>What the test does is: start N process, each map a region of anonymous spa=
ce
>and then write to it sequentially to trigger swap outs.
>On Haswell EP 2 node machine with 128GiB memory, two persistent memory
>devices are created, each with a size of 48GiB sitting on a different node=
 are
>used as swap devices, they are swapped on without being specified a priori=
ty
>value and the test result is:
>1 task/write size is around 95GiB
>throughput of v4.5: 1475358.0
>throughput of the patch: 1751160.0
>18% increase in throughput
>16 task/write size of each is around 6.6GiB throughput of v4.5: 2148972.4
>throughput of the patch: 5713310.0 165% increase in throughput
>
>The huge increase is partly due to the lock contention on the single
>swapper_space's radix tree lock since v4.5 will always use the higher prio=
rity
>swap device till it's full before using another one. Setting them with the=
 same
>priority could avoid this, so here are the results considering this case:
>1 task/write size is around 95GiB
>throughput of v4.5: 1475358.0
>throughput of v4.5(swap device with equal priority): 1707893.4 throughput =
of
>the patch: 1751160.0 almost the same for the latter two
>16 task/write size of each is around 6.6GiB throughput of v4.5: 2148972.4
>throughput of v4.5(swap device with equal priority): 3804688.25 throughput=
 of
>the patch: 5713310.0 increase reduced to 50%
>

Wonder if choosing the swap device by numa node is the most
effective way to spread the pages among the swap devices.
The speedup comes from spreading the swap activities among
equal priority swap devices to reduce contention on swap devices.
If the activities are mostly confined to 1 node, then we still could
have contention on a device. =20

An alternative may be we pick another swap device on each
pass of shrink_page_list  to try to swap pages.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
