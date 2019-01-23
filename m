Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76F0E8E0001
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:04:16 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x67so1455094pfk.16
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 03:04:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 88sor25619039plb.63.2019.01.23.03.04.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 03:04:15 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 0/3] gcc-plugins: Introduce stackinit plugin
Date: Wed, 23 Jan 2019 03:03:46 -0800
Message-Id: <20190123110349.35882-1-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Laura Abbott <labbott@redhat.com>, Alexander Popov <alex.popov@linux.com>, xen-devel@lists.xenproject.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, dev@openvswitch.org, linux-kbuild@vger.kernel.org, linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com

This adds a new plugin "stackinit" that attempts to perform unconditional
initialization of all stack variables[1]. It has wider effects than
GCC_PLUGIN_STRUCTLEAK_BYREF_ALL=y since BYREF_ALL does not consider
non-structures. A notable weakness is that padding bytes in many cases
remain uninitialized since GCC treats these bytes as "undefined". I'm
hoping we can improve the compiler (or the plugin) to cover that too.
(It's worth noting that BYREF_ALL actually does handle the padding --
I think this is due to the different method of detecting if initialization
is needed.)

Included is a tree-wide change to move switch variables up and out of
their switch and into the top-level variable declarations.

Included is a set of test cases for evaluating stack initialization,
which checks for padding, different types, etc.

Feedback welcome! :)

-Kees

[1] https://lkml.kernel.org/r/CA+55aFykZL+cSBJjBBts7ebEFfyGPdMzTmLSxKnT_29=j942dA@mail.gmail.com

Kees Cook (3):
  treewide: Lift switch variables out of switches
  gcc-plugins: Introduce stackinit plugin
  lib: Introduce test_stackinit module

 arch/x86/xen/enlighten_pv.c                   |   7 +-
 drivers/char/pcmcia/cm4000_cs.c               |   2 +-
 drivers/char/ppdev.c                          |  20 +-
 drivers/gpu/drm/drm_edid.c                    |   4 +-
 drivers/gpu/drm/i915/intel_display.c          |   2 +-
 drivers/gpu/drm/i915/intel_pm.c               |   4 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c |   3 +-
 drivers/tty/n_tty.c                           |   3 +-
 drivers/usb/gadget/udc/net2280.c              |   5 +-
 fs/fcntl.c                                    |   3 +-
 lib/Kconfig.debug                             |   9 +
 lib/Makefile                                  |   1 +
 lib/test_stackinit.c                          | 327 ++++++++++++++++++
 mm/shmem.c                                    |   5 +-
 net/core/skbuff.c                             |   4 +-
 net/ipv6/ip6_gre.c                            |   4 +-
 net/ipv6/ip6_tunnel.c                         |   4 +-
 net/openvswitch/flow_netlink.c                |   7 +-
 scripts/Makefile.gcc-plugins                  |   6 +
 scripts/gcc-plugins/Kconfig                   |   9 +
 scripts/gcc-plugins/gcc-common.h              |  11 +-
 scripts/gcc-plugins/stackinit_plugin.c        |  79 +++++
 security/tomoyo/common.c                      |   3 +-
 security/tomoyo/condition.c                   |   7 +-
 security/tomoyo/util.c                        |   4 +-
 25 files changed, 484 insertions(+), 49 deletions(-)
 create mode 100644 lib/test_stackinit.c
 create mode 100644 scripts/gcc-plugins/stackinit_plugin.c

-- 
2.17.1
