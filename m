Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D3BE66B004D
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 12:26:36 -0500 (EST)
Date: Tue, 3 Nov 2009 19:23:48 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv7 0/3] vhost: a kernel-level virtio server
Message-ID: <20091103172348.GA5591@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>
List-ID: <linux-mm.kvack.org>

Rusty, ok, I think I've addressed all comments so far here.  In
particular I have added write logging for live migration, indirect
buffers and virtio net header (enables gso).  I'd like this to go
into linux-next, through your tree, and hopefully 2.6.33.
What do you think?

---

This implements vhost: a kernel-level backend for virtio,
The main motivation for this work is to reduce virtualization
overhead for virtio by removing system calls on data path,
without guest changes. For virtio-net, this removes up to
4 system calls per packet: vm exit for kick, reentry for kick,
iothread wakeup for packet, interrupt injection for packet.

This driver is pretty minimal, but it's fully functional (including
migration support interfaces), and already shows performance (especially
latency) improvement over userspace.

Some more detailed description attached to the patch itself.

The patches apply to both 2.6.32-rc5 and kvm.git.  I'd like them to go
into linux-next if possible.  Please comment.

Changelog from v6:
- review comments by Daniel Walker addressed
- checkpatch cleanup
- fix build on 32 bit
- maintainers entry corrected

Changelog from v5:
- tun support
- backends with virtio net header support (enables GSO, checksum etc)
- 32 bit compat fixed
- support indirect buffers, tx exit mitigation,
  tx interrupt mitigation
- support write logging (allows migration without virtio ring code in userspace)

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
  tun: export underlying socket
  mm: export use_mm/unuse_mm to modules
  vhost_net: a kernel-level virtio server

 MAINTAINERS                |    9 +
 arch/x86/kvm/Kconfig       |    1 +
 drivers/Makefile           |    1 +
 drivers/net/tun.c          |  101 ++++-
 drivers/vhost/Kconfig      |   11 +
 drivers/vhost/Makefile     |    2 +
 drivers/vhost/net.c        |  633 +++++++++++++++++++++++++++++
 drivers/vhost/vhost.c      |  970 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h      |  158 +++++++
 include/linux/Kbuild       |    1 +
 include/linux/if_tun.h     |   14 +
 include/linux/miscdevice.h |    1 +
 include/linux/vhost.h      |  126 ++++++
 mm/mmu_context.c           |    3 +
 14 files changed, 2012 insertions(+), 19 deletions(-)
 create mode 100644 drivers/vhost/Kconfig
 create mode 100644 drivers/vhost/Makefile
 create mode 100644 drivers/vhost/net.c
 create mode 100644 drivers/vhost/vhost.c
 create mode 100644 drivers/vhost/vhost.h
 create mode 100644 include/linux/vhost.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
