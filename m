Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 189896B004F
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 11:02:10 -0400 (EDT)
Date: Wed, 19 Aug 2009 18:00:29 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv4 0/2] vhost: a kernel-level virtio server
Message-ID: <20090819150029.GA4236@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Rusty, could you review and comment on the patches please?  Since most
of the code deals with virtio from host side, I think it will make sense
to merge them through your tree. What do you think?

One comment on placement: I put files under a separate vhost directory
to avoid confusion with virtio-net which runs in guest.  Does this sound
sane? If not let me know and I'll move them.

Thanks!

---

This implements vhost: a kernel-level backend for virtio,
The main motivation for this work is to reduce virtualization
overhead for virtio by removing system calls on data path,
without guest changes. For virtio-net, this removes up to
4 system calls per packet: vm exit for kick, reentry for kick,
iothread wakeup for packet, interrupt injection for packet.

This driver is as minimal as possible and does not implement any virtio
optional features, but it's fully functional (including migration
support), and already shows a latency improvement over userspace.

Some more detailed description attached to the patch itself.

The patches are against 2.6.31-rc4.  I'd like them to go into linux-next
and down the road 2.6.32 if possible.  Please comment.

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

Michael S. Tsirkin (2):
  mm: export use_mm/unuse_mm to modules
  vhost_net: a kernel-level virtio server

 MAINTAINERS                 |   10 +
 arch/x86/kvm/Kconfig        |    1 +
 drivers/Makefile            |    1 +
 drivers/vhost/Kconfig       |   11 +
 drivers/vhost/Makefile      |    2 +
 drivers/vhost/net.c         |  429 ++++++++++++++++++++++++++++
 drivers/vhost/vhost.c       |  664 +++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h       |  108 +++++++
 fs/aio.c                    |   47 +---
 include/linux/Kbuild        |    1 +
 include/linux/miscdevice.h  |    1 +
 include/linux/mmu_context.h |    9 +
 include/linux/vhost.h       |  100 +++++++
 mm/Makefile                 |    2 +-
 mm/mmu_context.c            |   58 ++++
 15 files changed, 1397 insertions(+), 47 deletions(-)
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
