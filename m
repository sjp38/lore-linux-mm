Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B02166B0055
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 12:08:16 -0400 (EDT)
Date: Thu, 27 Aug 2009 19:06:34 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv5 0/3] vhost: a kernel-level virtio server
Message-ID: <20090827160633.GA23722@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

Rusty, ok, I think I've addressed your comments so far here.
Coming next:
- TSO
- tap support
Thanks!

---

This implements vhost: a kernel-level backend for virtio,
The main motivation for this work is to reduce virtualization
overhead for virtio by removing system calls on data path,
without guest changes. For virtio-net, this removes up to
4 system calls per packet: vm exit for kick, reentry for kick,
iothread wakeup for packet, interrupt injection for packet.

This driver is as minimal as possible and does not implement almost any
virtio optional features, but it's fully functional (including migration
support interfaces), and already shows a latency improvement over
userspace.

Some more detailed description attached to the patch itself.

The patches apply to both 2.6.31-rc5 and kvm.git.  I'd like them to go
into linux-next if possible.  Please comment.

Changelog from v4:
- disable rx notification when have rx buffers
- addressed all comments from Rusty's review
- copy bugfixes from lguest commits:
	ebf9a5a99c1a464afe0b4dfa64416fc8b273bc5c
	e606490c440900e50ccf73a54f6fc6150ff40815

Changelog from v3:
- checkpatch fixes

Changelog from v2:
- Comments on RCU usage
- Compat ioctl support
- Make variable static
- Copied more idiomatic english from Rusty

Changes from v1:
- Move use_mm/unuse_mm from fs/aio.c to mm instead of copying.
- Reorder code to avoid need for forward declarations
- Kill a couple of debugging printks

Michael S. Tsirkin (3):
  mm: export use_mm/unuse_mm to modules
  mm: reduce atomic use on use_mm fast path
  vhost_net: a kernel-level virtio server

 MAINTAINERS                 |   10 +
 arch/x86/kvm/Kconfig        |    1 +
 drivers/Makefile            |    1 +
 drivers/vhost/Kconfig       |   11 +
 drivers/vhost/Makefile      |    2 +
 drivers/vhost/net.c         |  475 +++++++++++++++++++++++++++++
 drivers/vhost/vhost.c       |  688 +++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h       |  122 ++++++++
 fs/aio.c                    |   47 +---
 include/linux/Kbuild        |    1 +
 include/linux/miscdevice.h  |    1 +
 include/linux/mmu_context.h |    9 +
 include/linux/vhost.h       |  101 +++++++
 mm/Makefile                 |    2 +-
 mm/mmu_context.c            |   61 ++++
 15 files changed, 1485 insertions(+), 47 deletions(-)
 create mode 100644 drivers/vhost/Kconfig
 create mode 100644 drivers/vhost/Makefile
 create mode 100644 drivers/vhost/net.c
 create mode 100644 drivers/vhost/vhost.c
 create mode 100644 drivers/vhost/vhost.h
 create mode 100644 include/linux/mmu_context.h
 create mode 100644 include/linux/vhost.h
 create mode 100644 mm/mmu_context.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
