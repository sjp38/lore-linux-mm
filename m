Date: Tue, 8 May 2007 20:14:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] change zonelist order v5 [0/3]
Message-Id: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Lee.Schermerhorn@hp.com, Christoph Lameter <clameter@sgi.com>, AKPM <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, jbarnes@virtuousgeek.org, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, this is zonelist-order-fix patch version 5.
against 2.6.21-mm1. works well in my ia64/NUMA environment.


ChangeLog V4 -> V5
- separated 'doc' patch and rewrote it.
- more clean ups.
- sysctl/boot option params are simplified.

ChangeLog V2 -> V4
- automatic configuration is added.
- automatic configuration is now default.
- relaxed_zone_order is renamed to be numa_zonelist_order
  you can specify value "default" , "zone" , "numa"
- clean-up from Lee Schermerhorn
- patch is speareted to "base" and "autoconfiguration algorithm"

Changelog from V1 -> V2
- sysctl name is changed to be relaxed_zone_order
- NORMAL->NORMAL->....->DMA->DMA->DMA order (new ordering) is now default.
  NORMAL->DMA->NORMAL->DMA order (old ordering) is optional.
- addes boot opttion to set relaxed_zone_order. ia64 is supported now.
- Added documentation

Thanks to Lee Schermerhon for his great help. please ack or
give your sign-off if O.K.

[patch set]
[1/3] ---- add zonelist selection logic.
[2/3] ---- add automatic configration of zonelist order
[3/3] ---- add documentaion.

Any comments are welcome.

[Description]
This patch modifies zonelist order in NUMA. This patch offers two zonelist
order.
(TypeA) zone is ordered by node locality, then zone type
(TypeB) zone is ordered by zone type, then node locality

(TypeA) is called as "Node Order", (TypeB) is called as "Zone Order"
Default zonelist order is determined by the kernel automatically.


Assume 2 Node NUMA, Node(0) has ZONE_DMA/ZONE_NORMAL and Node(1) has ZONE_NORMAL.
In this case, zonelist for GFP_KERNEL in Node(0) will be

In "Node Order",  Node(0)NORMAL -> Node(0)DMA -> Node(1)NORMAL
In "Zone Order",  Node(0)NORMAL -> Node(1)NORMAL -> Node(0) DMA

"Node Order" will guarantee "better locality" but  "Zone Order" places
ZONE_DMA at the tail of zonelist. This will offer robust zonelist agatist OOM on ZONE_DMA, which is tend to be small.

"Which is better ?" 
It depends on a system's environment and memory usage, I think.

[Case Study]
On my (and other) ia64 NUMA box, only Node(0) has 2Gbytes of ZONE_DMA.
Assume a machine with following configuration.

Node 0:   12GB of memory   10GB NORMAL 2GB DMA
Node 1:   12GB of memory   12GB NORMAL
Node 2:   12GB of memory   12GB NORMAL

Start a process which uses 12GB of memory on Node(0), then memory usage
will be
Node 0:   0/12 GB of memory is available, NORMAL: empty DMA: empty
Node 1:  12/12 GB of memory is available. NORMAL: 12G
Node 2:  12/12 GB of memory is available. NORMAL: 12G

An interesting matter is "ZONE_DMA is exhausted before ZONE_NORMAL".
This is current kernel's behavior. This can cause OOM very easily if the
system has a device which uses GFP_DMA. 

This patch fixes this kind of situation as following. (by using "Zone Order")
Node 0:   2/12 GB of memory is available, NORMAL: empty DMA: 2G
Node 1:  10/12 GB of memory is available. NORMAL: 10G
Node 2:  12/12 GB of memory is available. NORMAL  12G

A user can say "Good bye OOM-Killer" but 2GB of memory is allocated from
off-node memory. it's trade-off.

-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
