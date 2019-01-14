Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5574E8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 07:59:28 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s14so16473322qkl.16
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:59:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z37si951237qve.158.2019.01.14.04.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 04:59:27 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v2 0/9] mm: PG_reserved cleanups and documentation
Date: Mon, 14 Jan 2019 13:58:54 +0100
Message-Id: <20190114125903.24845-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, David Hildenbrand <david@redhat.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Albert Ou <aou@eecs.berkeley.edu>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Anthony Yznaga <anthony.yznaga@oracle.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Bhupesh Sharma <bhsharma@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, CHANDAN VN <chandan.vn@samsung.com>, Christophe Leroy <christophe.leroy@c-s.fr>, Dan Williams <dan.j.williams@intel.com>, Dave Kleikamp <dave.kleikamp@oracle.com>, David Airlie <airlied@linux.ie>, David Howells <dhowells@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Florian Fainelli <f.fainelli@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Hackmann <ghackmann@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, James Morse <james.morse@arm.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Kristina Martsenko <kristina.martsenko@arm.com>, Laura Abbott <labbott@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Marc Zyngier <marc.zyngier@arm.com>, Mark Rutland <mark.rutland@arm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matthew Wilcox <willy@infradead.org>, Matthias Brugger <mbrugger@suse.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Oleg Nesterov <oleg@redhat.com>, Palmer Dabbelt <palmer@sifive.com>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Randy Dunlap <rdunlap@infradead.org>, Souptick Joarder <jrdr.linux@gmail.com>, Stefan Agner <stefan@agner.ch>, Stephen Rothwell <sfr@canb.auug.org.au>, Tobias Klauser <tklauser@distanz.ch>, Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>

Nothing major changed since the last version. I would be happy about
additional ACKs. If there are no further comments, can this go via the
mm-tree in one chunk?

I was recently going over all users of PG_reserved. Short story: it is
difficult and sometimes not really clear if setting/checking for
PG_reserved is only a relict from the past. Easy to break things. I
guess I now have a pretty good idea wh things are like that
nowadays and how they evolved.

I had way more cleanups in this series inititally,
but some architectures take PG_reserved as a way to apply a different
caching strategy (for MMIO pages). So I decided to only include the most
obvious changes (that are less likely to break something). So the big
chunk of manual SetPageReserved users are MMIO/DMA related things on
device buffers.

Most notably, for device memory we will hopefully soon stop setting
PG_reserved. Then the documentation has to be updated.

v1 -> v2:
- Minor speeling errors in "mm: better document PG_reserved" fixed
- Added ACKs

RFC -> v1:
- Add more details to "mm: better document PG_reserved"
- Add "arm64: kdump: No need to mark crashkernel pages manually
       PG_reserved"
- Add "ia64: perfmon: Don't mark buffer pages as PG_reserved"
- Added ACKs


David Hildenbrand (9):
  agp: efficeon: no need to set PG_reserved on GATT tables
  s390/vdso: don't clear PG_reserved
  powerpc/vdso: don't clear PG_reserved
  riscv/vdso: don't clear PG_reserved
  m68k/mm: use __ClearPageReserved()
  arm64: kexec: no need to ClearPageReserved()
  arm64: kdump: No need to mark crashkernel pages manually PG_reserved
  ia64: perfmon: Don't mark buffer pages as PG_reserved
  mm: better document PG_reserved

 arch/arm64/kernel/machine_kexec.c |  3 +-
 arch/arm64/mm/init.c              | 27 --------------
 arch/ia64/kernel/perfmon.c        | 59 +++----------------------------
 arch/m68k/mm/memory.c             |  2 +-
 arch/powerpc/kernel/vdso.c        |  2 --
 arch/riscv/kernel/vdso.c          |  1 -
 arch/s390/kernel/vdso.c           |  2 --
 drivers/char/agp/efficeon-agp.c   |  2 --
 include/linux/page-flags.h        | 33 +++++++++++++++--
 9 files changed, 37 insertions(+), 94 deletions(-)

-- 
2.17.2
