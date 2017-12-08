Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC326B0261
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 23:14:27 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r88so7559343pfi.23
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 20:14:27 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a7si5276178pff.55.2017.12.07.20.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 20:14:25 -0800 (PST)
From: "Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: revamp vmem_altmap / dev_pagemap handling
Date: Fri, 8 Dec 2017 04:14:24 +0000
Message-ID: <1512706457.2864.1.camel@intel.com>
References: <20171207150840.28409-1-hch@lst.de>
In-Reply-To: <20171207150840.28409-1-hch@lst.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <7D2A7EE618B00A4EAAD822F4DB978251@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>
Cc: "jglisse@redhat.com" <jglisse@redhat.com>, "logang@deltatee.com" <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 2017-12-07 at 07:08 -0800, Christoph Hellwig wrote:
+AD4- Hi all,
+AD4-=20
+AD4- this series started with two patches from Logan that now are in the
+AD4- middle of the series to kill the memremap-internal pgmap structure
+AD4- and to redo the dev+AF8-memreamp+AF8-pages interface to be better sui=
table
+AD4- for future PCI P2P uses.+AKAAoA-I reviewed them and noticed that ther=
e
+AD4- isn't really any good reason to keep struct vmem+AF8-altmap either,
+AD4- and that a lot of these alternative device page map access should
+AD4- be better abstracted out instead of being sprinkled all over the
+AD4- mm code.
+AD4-=20
+AD4- Please review carefully, this has only been tested with my legacy
+AD4- e820 NVDIMM system.

I get this lockdep report booting it on my test-VM. I'll take a closer
look next week... the fsdax-vs-hole-punch-vs-dma fix is on the top of
my queue.

+AFs-    7.631431+AF0- +AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0=
APQA9AD0APQA9AD0APQA9AD0APQ-
+AFs-    7.632668+AF0- WARNING: suspicious RCU usage
+AFs-    7.633494+AF0- 4.15.0-rc2+- +ACM-942 Tainted: G           O   =20
+AFs-    7.635262+AF0- -----------------------------
+AFs-    7.636764+AF0- ./include/linux/rcupdate.h:302 Illegal context switc=
h in RCU read-side critical section+ACE-
+AFs-    7.640139+AF0-=20
+AFs-    7.640139+AF0- other info that might help us debug this:
+AFs-    7.640139+AF0-=20
+AFs-    7.643382+AF0-=20
+AFs-    7.643382+AF0- rcu+AF8-scheduler+AF8-active +AD0- 2, debug+AF8-lock=
s +AD0- 1
+AFs-    7.645814+AF0- 5 locks held by systemd-udevd/835:
+AFs-    7.647546+AF0-  +ACM-0:  (+ACY-dev-+AD4-mutex)+AHs-....+AH0-, at: +=
AFsAPA-0000000064217991+AD4AXQ- +AF8AXw-driver+AF8-attach+-0x58/0xe0
+AFs-    7.650171+AF0-  +ACM-1:  (+ACY-dev-+AD4-mutex)+AHs-....+AH0-, at: +=
AFsAPA-00000000527f6e1a+AD4AXQ- +AF8AXw-driver+AF8-attach+-0x66/0xe0
+AFs-    7.652779+AF0-  +ACM-2:  (cpu+AF8-hotplug+AF8-lock.rw+AF8-sem)+AHsA=
KwArACsAKwB9-, at: +AFsAPA-00000000a8b47692+AD4AXQ- mem+AF8-hotplug+AF8-beg=
in+-0xa/0x20
+AFs-    7.655677+AF0-  +ACM-3:  (mem+AF8-hotplug+AF8-lock.rw+AF8-sem)+AHsA=
KwArACsAKwB9-, at: +AFsAPA-000000003d83cb2a+AD4AXQ- percpu+AF8-down+AF8-wri=
te+-0x27/0x120
+AFs-    7.658649+AF0-  +ACM-4:  (rcu+AF8-read+AF8-lock)+AHs-....+AH0-, at:=
 +AFsAPA-00000000bcd32a45+AD4AXQ- vmemmap+AF8-populate+-0x0/0x373
+AFs-    7.661133+AF0-=20
+AFs-    7.661133+AF0- stack backtrace:
+AFs-    7.662650+AF0- CPU: 22 PID: 835 Comm: systemd-udevd Tainted: G     =
      O     4.15.0-rc2+- +ACM-942
+AFs-    7.665264+AF0- Hardware name: QEMU Standard PC (i440FX +- PIIX, 199=
6), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
+AFs-    7.668873+AF0- Call Trace:
+AFs-    7.668879+AF0-  dump+AF8-stack+-0x7d/0xbe
+AFs-    7.668885+AF0-  +AF8AXwBf-might+AF8-sleep+-0xe2/0x250
+AFs-    7.668890+AF0-  +AF8AXw-alloc+AF8-pages+AF8-nodemask+-0x107/0x3b0
+AFs-    7.668901+AF0-  vmemmap+AF8-alloc+AF8-block+-0x5a/0xc1
+AFs-    7.668904+AF0-  vmemmap+AF8-populate+-0x16c/0x373
+AFs-    7.668915+AF0-  sparse+AF8-mem+AF8-map+AF8-populate+-0x23/0x33
+AFs-    7.668917+AF0-  sparse+AF8-add+AF8-one+AF8-section+-0x45/0x179
+AFs-    7.668924+AF0-  +AF8AXw-add+AF8-pages+-0xc4/0x1f0
+AFs-    7.668935+AF0-  add+AF8-pages+-0x15/0x70
+AFs-    7.668939+AF0-  devm+AF8-memremap+AF8-pages+-0x293/0x440
+AFs-    7.668954+AF0-  pmem+AF8-attach+AF8-disk+-0x4f4/0x620 +AFs-nd+AF8-p=
mem+AF0-
+AFs-    7.668966+AF0-  ? nd+AF8-dax+AF8-probe+-0x105/0x140 +AFs-libnvdimm+=
AF0-
+AFs-    7.668971+AF0-  ? nd+AF8-dax+AF8-probe+-0x105/0x140 +AFs-libnvdimm+=
AF0-
+AFs-    7.668981+AF0-  nvdimm+AF8-bus+AF8-probe+-0x63/0x100 +AFs-libnvdimm=
+AF0-
+AFs-    7.668988+AF0-  driver+AF8-probe+AF8-device+-0x2a8/0x490
+AFs-    7.668993+AF0-  +AF8AXw-driver+AF8-attach+-0xde/0xe0
+AFs-    7.668997+AF0-  ? driver+AF8-probe+AF8-device+-0x490/0x490
+AFs-    7.668998+AF0-  bus+AF8-for+AF8-each+AF8-dev+-0x6a/0xb0
+AFs-    7.669002+AF0-  bus+AF8-add+AF8-driver+-0x16d/0x260
+AFs-    7.669005+AF0-  driver+AF8-register+-0x57/0xc0
+AFs-    7.669007+AF0-  ? 0xffffffffa0083000
+AFs-    7.669009+AF0-  do+AF8-one+AF8-initcall+-0x4e/0x18f
+AFs-    7.669012+AF0-  ? rcu+AF8-read+AF8-lock+AF8-sched+AF8-held+-0x3f/0x=
70
+AFs-    7.669014+AF0-  ? kmem+AF8-cache+AF8-alloc+AF8-trace+-0x2a0/0x310
+AFs-    7.669020+AF0-  do+AF8-init+AF8-module+-0x5b/0x213
+AFs-    7.669023+AF0-  load+AF8-module+-0x1873/0x1f10
+AFs-    7.669029+AF0-  ? show+AF8-coresize+-0x30/0x30
+AFs-    7.669035+AF0-  ? vfs+AF8-read+-0x131/0x150
+AFs-    7.669052+AF0-  ? SYSC+AF8-finit+AF8-module+-0xd2/0x100
+AFs-    7.669053+AF0-  SYSC+AF8-finit+AF8-module+-0xd2/0x100
+AFs-    7.669067+AF0-  do+AF8-syscall+AF8-64+-0x66/0x230
+AFs-    7.669070+AF0-  entry+AF8-SYSCALL64+AF8-slow+AF8-path+-0x25/0x25
+AFs-    7.669072+AF0- RIP: 0033:0x7fc493dd8229
+AFs-    7.669073+AF0- RSP: 002b:00007ffcaab453d8 EFLAGS: 00000246 ORIG+AF8=
-RAX: 0000000000000139
+AFs-    7.669074+AF0- RAX: ffffffffffffffda RBX: 00005643cb407bb0 RCX: 000=
07fc493dd8229
+AFs-    7.669075+AF0- RDX: 0000000000000000 RSI: 00007fc4949189c5 RDI: 000=
000000000000f
+AFs-    7.669076+AF0- RBP: 00007fc4949189c5 R08: 0000000000000000 R09: 000=
07ffcaab454f0
+AFs-    7.669076+AF0- R10: 000000000000000f R11: 0000000000000246 R12: 000=
0000000000000
+AFs-    7.669077+AF0- R13: 00005643cb408010 R14: 0000000000020000 R15: 000=
05643c97c8dec
+AFs-    7.669112+AF0- BUG: sleeping function called from invalid context a=
t mm/page+AF8-alloc.c:4174
+AFs-    7.669113+AF0- in+AF8-atomic(): 1, irqs+AF8-disabled(): 0, pid: 835=
, name: systemd-udevd
+AFs-    7.669115+AF0- 5 locks held by systemd-udevd/835:
+AFs-    7.669115+AF0-  +ACM-0:  (+ACY-dev-+AD4-mutex)+AHs-....+AH0-, at: +=
AFsAPA-0000000064217991+AD4AXQ- +AF8AXw-driver+AF8-attach+-0x58/0xe0
+AFs-    7.669120+AF0-  +ACM-1:  (+ACY-dev-+AD4-mutex)+AHs-....+AH0-, at: +=
AFsAPA-00000000527f6e1a+AD4AXQ- +AF8AXw-driver+AF8-attach+-0x66/0xe0
+AFs-    7.669123+AF0-  +ACM-2:  (cpu+AF8-hotplug+AF8-lock.rw+AF8-sem)+AHsA=
KwArACsAKwB9-, at: +AFsAPA-00000000a8b47692+AD4AXQ- mem+AF8-hotplug+AF8-beg=
in+-0xa/0x20
+AFs-    7.669126+AF0-  +ACM-3:  (mem+AF8-hotplug+AF8-lock.rw+AF8-sem)+AHsA=
KwArACsAKwB9-, at: +AFsAPA-000000003d83cb2a+AD4AXQ- percpu+AF8-down+AF8-wri=
te+-0x27/0x120
+AFs-    7.669130+AF0-  +ACM-4:  (rcu+AF8-read+AF8-lock)+AHs-....+AH0-, at:=
 +AFsAPA-00000000bcd32a45+AD4AXQ- vmemmap+AF8-populate+-0x0/0x373
+AFs-    7.669135+AF0- CPU: 22 PID: 835 Comm: systemd-udevd Tainted: G     =
      O     4.15.0-rc2+- +ACM-942
+AFs-    7.669136+AF0- Hardware name: QEMU Standard PC (i440FX +- PIIX, 199=
6), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
+AFs-    7.669136+AF0- Call Trace:
+AFs-    7.669139+AF0-  dump+AF8-stack+-0x7d/0xbe
+AFs-    7.669142+AF0-  +AF8AXwBf-might+AF8-sleep+-0x21e/0x250
+AFs-    7.669146+AF0-  +AF8AXw-alloc+AF8-pages+AF8-nodemask+-0x107/0x3b0
+AFs-    7.669154+AF0-  vmemmap+AF8-alloc+AF8-block+-0x5a/0xc1
+AFs-    7.669157+AF0-  vmemmap+AF8-populate+-0x16c/0x373
+AFs-    7.669167+AF0-  sparse+AF8-mem+AF8-map+AF8-populate+-0x23/0x33
+AFs-    7.669170+AF0-  sparse+AF8-add+AF8-one+AF8-section+-0x45/0x179
+AFs-    7.669176+AF0-  +AF8AXw-add+AF8-pages+-0xc4/0x1f0
+AFs-    7.669187+AF0-  add+AF8-pages+-0x15/0x70
+AFs-    7.669189+AF0-  devm+AF8-memremap+AF8-pages+-0x293/0x440
+AFs-    7.669199+AF0-  pmem+AF8-attach+AF8-disk+-0x4f4/0x620 +AFs-nd+AF8-p=
mem+AF0-
+AFs-    7.669210+AF0-  ? nd+AF8-dax+AF8-probe+-0x105/0x140 +AFs-libnvdimm+=
AF0-
+AFs-    7.669215+AF0-  ? nd+AF8-dax+AF8-probe+-0x105/0x140 +AFs-libnvdimm+=
AF0-
+AFs-    7.669226+AF0-  nvdimm+AF8-bus+AF8-probe+-0x63/0x100 +AFs-libnvdimm=
+AF0-
+AFs-    7.669232+AF0-  driver+AF8-probe+AF8-device+-0x2a8/0x490
+AFs-    7.669237+AF0-  +AF8AXw-driver+AF8-attach+-0xde/0xe0
+AFs-    7.669240+AF0-  ? driver+AF8-probe+AF8-device+-0x490/0x490
+AFs-    7.669242+AF0-  bus+AF8-for+AF8-each+AF8-dev+-0x6a/0xb0
+AFs-    7.669247+AF0-  bus+AF8-add+AF8-driver+-0x16d/0x260
+AFs-    7.669251+AF0-  driver+AF8-register+-0x57/0xc0
+AFs-    7.669253+AF0-  ? 0xffffffffa0083000
+AFs-    7.669255+AF0-  do+AF8-one+AF8-initcall+-0x4e/0x18f
+AFs-    7.669257+AF0-  ? rcu+AF8-read+AF8-lock+AF8-sched+AF8-held+-0x3f/0x=
70
+AFs-    7.669259+AF0-  ? kmem+AF8-cache+AF8-alloc+AF8-trace+-0x2a0/0x310
+AFs-    7.669267+AF0-  do+AF8-init+AF8-module+-0x5b/0x213
+AFs-    7.669271+AF0-  load+AF8-module+-0x1873/0x1f10
+AFs-    7.669276+AF0-  ? show+AF8-coresize+-0x30/0x30
+AFs-    7.669283+AF0-  ? vfs+AF8-read+-0x131/0x150
+AFs-    7.669309+AF0-  ? SYSC+AF8-finit+AF8-module+-0xd2/0x100
+AFs-    7.669312+AF0-  SYSC+AF8-finit+AF8-module+-0xd2/0x100
+AFs-    7.669332+AF0-  do+AF8-syscall+AF8-64+-0x66/0x230
+AFs-    7.669336+AF0-  entry+AF8-SYSCALL64+AF8-slow+AF8-path+-0x25/0x25
+AFs-    7.669337+AF0- RIP: 0033:0x7fc493dd8229
+AFs-    7.669338+AF0- RSP: 002b:00007ffcaab453d8 EFLAGS: 00000246 ORIG+AF8=
-RAX: 0000000000000139
+AFs-    7.669340+AF0- RAX: ffffffffffffffda RBX: 00005643cb407bb0 RCX: 000=
07fc493dd8229
+AFs-    7.669341+AF0- RDX: 0000000000000000 RSI: 00007fc4949189c5 RDI: 000=
000000000000f
+AFs-    7.669342+AF0- RBP: 00007fc4949189c5 R08: 0000000000000000 R09: 000=
07ffcaab454f0
+AFs-    7.669344+AF0- R10: 000000000000000f R11: 0000000000000246 R12: 000=
0000000000000
+AFs-    7.669345+AF0- R13: 00005643cb408010 R14: 0000000000020000 R15: 000=
05643c97c8dec
+AFs-    7.680772+AF0- pmem2: detected capacity change from 0 to 3328599654=
4
+AFs-    7.834748+AF0- pmem0: detected capacity change from 0 to 4294967296=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
