Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4389E6B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 12:24:44 -0500 (EST)
Date: Mon, 9 Nov 2009 19:21:58 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv9 0/3] vhost: a kernel-level virtio server
Message-ID: <20091109172158.GA4724@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

Ok, I think I've addressed all comments so far here, and it still seems
to work :).  Please take a look.  I basically ended up accepting all
Rusty's suggestions, except I did not get rid of avail_idx field in vq:
I don't (yet?) understand what's wrong with it, if any, and it seems
required for correct implementation of notify on empty. I tried
adding comment where it's changed to clarify the intent.

Rusty, thanks very much for the review.  I didn't split the logging code
out as you indicated that it's not necessary at this point.

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

The patches apply to both 2.6.32-rc6 and kvm.git.  I'd like them to go
into linux-next if possible.  Please comment.

Changelog from v8:
- typo in error message
- more checks for vq size (must be power of 2)

  From Rusty's review:
- don't hardcode iov size
- rename no_notify disable_notify
- rearrange loop
- convert irq trigger language to signal eventfd
- make vhost_enable_notify return status
- -1 -> -1U
- get rid of kzalloc
- better comment on vail_idx
- convert vq index to vq usage
- rename ACK->SET
- merge vring addresses into a single struct
- some comments and cosmetic changes

Changelog from v7:
- Add note on RCU usage, mirroring this in vhost/vhost.h
- Fix locking typo noted by Eric Dumazet
- Fix warnings on 32 bit

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
 drivers/vhost/net.c        |  648 +++++++++++++++++++++++++++++
 drivers/vhost/vhost.c      |  965 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h      |  159 ++++++++
 include/linux/Kbuild       |    1 +
 include/linux/if_tun.h     |   14 +
 include/linux/miscdevice.h |    1 +
 include/linux/vhost.h      |  130 ++++++
 mm/mmu_context.c           |    3 +
 14 files changed, 2027 insertions(+), 19 deletions(-)
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
