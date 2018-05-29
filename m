Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 385BC6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 00:01:49 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f207-v6so6874449qke.22
        for <linux-mm@kvack.org>; Mon, 28 May 2018 21:01:49 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id w36-v6si13788030qtb.19.2018.05.28.21.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 21:01:47 -0700 (PDT)
Message-ID: <1527566501.2723.22.camel@themaw.net>
Subject: Re: [PATCH] mm-kasan-dont-vfree-nonexistent-vm_area-fix
From: Ian Kent <raven@themaw.net>
Date: Tue, 29 May 2018 12:01:41 +0800
In-Reply-To: <1527482351.2693.12.camel@themaw.net>
References: <dabee6ab-3a7a-51cd-3b86-5468718e0390@virtuozzo.com>
	 <201805261122.HdUpobQm%fengguang.wu@intel.com>
	 <20180525204804.3a655370ef4b41e0d96e03f3@linux-foundation.org>
	 <1527480795.2693.4.camel@themaw.net> <1527482351.2693.12.camel@themaw.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

On Mon, 2018-05-28 at 12:39 +0800, Ian Kent wrote:
> On Mon, 2018-05-28 at 12:13 +0800, Ian Kent wrote:
> > On Fri, 2018-05-25 at 20:48 -0700, Andrew Morton wrote:
> > > On Sat, 26 May 2018 11:31:35 +0800 kbuild test robot <lkp@intel.com>
> > > wrote:
> > > 
> > > > Hi Andrey,
> > > > 
> > > > I love your patch! Yet something to improve:
> > > > 
> > > > [auto build test ERROR on mmotm/master]
> > > > [cannot apply to v4.17-rc6]
> > > > [if your patch is applied to the wrong git tree, please drop us a note
> > > > to
> > > > help improve the system]
> > > > 
> > > > url:    https://github.com/0day-ci/linux/commits/Andrey-Ryabinin/mm-kasa
> > > > n-
> > > > do
> > > > nt-vfree-nonexistent-vm_area-fix/20180526-093255
> > > > base:   git://git.cmpxchg.org/linux-mmotm.git master
> > > > config: sparc-allyesconfig (attached as .config)
> > > > compiler: sparc64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> > > > reproduce:
> > > >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sb
> > > > in
> > > > /m
> > > > ake.cross -O ~/bin/make.cross
> > > >         chmod +x ~/bin/make.cross
> > > >         # save the attached .config to linux build tree
> > > >         make.cross ARCH=sparc 
> > > > 
> > > > All errors (new ones prefixed by >>):
> > > > 
> > > >    fs/autofs/inode.o: In function `autofs_new_ino':
> > > >    inode.c:(.text+0x220): multiple definition of `autofs_new_ino'
> > > >    fs/autofs/inode.o:inode.c:(.text+0x220): first defined here
> > > >    fs/autofs/inode.o: In function `autofs_clean_ino':
> > > >    inode.c:(.text+0x280): multiple definition of `autofs_clean_ino'
> > > >    fs/autofs/inode.o:inode.c:(.text+0x280): first defined here
> > > 
> > > There's bot breakage here - clearly that patch didn't cause this error.
> > > 
> > > Ian, this autofs glitch may still not be fixed.
> > 
> > Yes, autofs-make-autofs4-Kconfig-depend-on-AUTOFS_FS.patch should have
> > fixed that.
> > 
> > I tied a bunch of .config combinations and I was unable to find any that
> > lead to both CONFIG_AUTOFS_FS and CONFIG_AUTOFS4_FS being defined.
> 
> Oh, autofs-make-autofs4-Kconfig-depend-on-AUTOFS_FS.patch was sent as
> a follow up patch which means it's still possible to have both
> CONFIG_AUTOFS_FS and CONFIG_AUTOFS4_FS set between 
> autofs-create-autofs-Kconfig-and-Makefile.patch and the above patch.
> 
> Perhaps all that's needed is to fold the follow up patch into
> autofs-create-autofs-Kconfig-and-Makefile.patch to close that
> possibility.
> 
> I'll check that can be done without problem.

I've had a look and I can't see any reason for this other than
CONFIG_AUTOFS_FS and CONFIG_AUTOFS4_FS both being set which isn't
ok because the file system name is the same for both.

I have seen build system configs that have both of these set even
though the "autofs" module was removed years ago so that's probably
still present in some site build systems.

I see you've added the follow up patch I mentioned above as
"autofs-update-fs-autofs4-kconfig-fix.patch"
with title
"autofs - make autofs4 Kconfig depend on AUTOFS_FS"

Folding this patch into the patch
"autofs-create-autofs-kconfig-and-makefile.patch"
with title
"autofs: create autofs Kconfig and Makefile"

I'm unable to reproduce the breakage which leads me to think
the problem must be due to .config having both the CONFIG_AUTOFS*
entries defined to something other than n (which certainly does
produce the breakage if the follow up patch is not present, so
the result is not bisectable until the follow up patch is added).

Also, I don't think there is a need to update the description of
"autofs: create autofs Kconfig and Makefile"
because the patch that is folded into it adds a NOTE to the
fs/autofs4/Kconfig help that essentially re-states what is in
the description.

If this continues to happen I'll need more information about
applied patches and kernel config used to work out what's going
on.

For completeness here's the resulting patch after folding in the
follow up patch above:

autofs - create autofs Kconfig and Makefile

From: Ian Kent <raven@themaw.net>

Create Makefile and Kconfig for autofs module.

Signed-off-by: Ian Kent <raven@themaw.net>
---
 fs/Kconfig         |    1 +
 fs/Makefile        |    1 +
 fs/autofs/Kconfig  |   20 ++++++++++++++++++++
 fs/autofs/Makefile |    7 +++++++
 fs/autofs4/Kconfig |    8 ++++++++
 5 files changed, 37 insertions(+)
 create mode 100644 fs/autofs/Kconfig
 create mode 100644 fs/autofs/Makefile

diff --git a/fs/Kconfig b/fs/Kconfig
index bc821a86d965..e712e62afe59 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -108,6 +108,7 @@ source "fs/notify/Kconfig"
 
 source "fs/quota/Kconfig"
 
+source "fs/autofs/Kconfig"
 source "fs/autofs4/Kconfig"
 source "fs/fuse/Kconfig"
 source "fs/overlayfs/Kconfig"
diff --git a/fs/Makefile b/fs/Makefile
index c9375fd2c8c4..2e005525cc19 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -102,6 +102,7 @@ obj-$(CONFIG_AFFS_FS)		+= affs/
 obj-$(CONFIG_ROMFS_FS)		+= romfs/
 obj-$(CONFIG_QNX4FS_FS)		+= qnx4/
 obj-$(CONFIG_QNX6FS_FS)		+= qnx6/
+obj-$(CONFIG_AUTOFS_FS)		+= autofs/
 obj-$(CONFIG_AUTOFS4_FS)	+= autofs4/
 obj-$(CONFIG_ADFS_FS)		+= adfs/
 obj-$(CONFIG_FUSE_FS)		+= fuse/
diff --git a/fs/autofs/Kconfig b/fs/autofs/Kconfig
new file mode 100644
index 000000000000..6a2064eb3b27
--- /dev/null
+++ b/fs/autofs/Kconfig
@@ -0,0 +1,20 @@
+config AUTOFS_FS
+	tristate "Kernel automounter support (supports v3, v4 and v5)"
+	default n
+	help
+	   The automounter is a tool to automatically mount remote file systems
+	   on demand. This implementation is partially kernel-based to reduce
+	   overhead in the already-mounted case; this is unlike the BSD
+	   automounter (amd), which is a pure user space daemon.
+
+	   To use the automounter you need the user-space tools from
+	   <https://www.kernel.org/pub/linux/daemons/autofs/>; you also want
+	   to answer Y to "NFS file system support", below.
+
+	   To compile this support as a module, choose M here: the module will be
+	   called autofs.
+
+	   If you are not a part of a fairly large, distributed network or
+	   don't have a laptop which needs to dynamically reconfigure to the
+	   local network, you probably do not need an automounter, and can say
+	   N here.
diff --git a/fs/autofs/Makefile b/fs/autofs/Makefile
new file mode 100644
index 000000000000..43fedde15c26
--- /dev/null
+++ b/fs/autofs/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the linux autofs-filesystem routines.
+#
+
+obj-$(CONFIG_AUTOFS_FS) += autofs.o
+
+autofs-objs := init.o inode.o root.o symlink.o waitq.o expire.o dev-ioctl.o
diff --git a/fs/autofs4/Kconfig b/fs/autofs4/Kconfig
index 53bc592a250d..2c2fdf989f90 100644
--- a/fs/autofs4/Kconfig
+++ b/fs/autofs4/Kconfig
@@ -1,6 +1,7 @@
 config AUTOFS4_FS
 	tristate "Kernel automounter version 4 support (also supports v3 and v5)"
 	default n
+	depends on AUTOFS_FS = n
 	help
 	  The automounter is a tool to automatically mount remote file systems
 	  on demand. This implementation is partially kernel-based to reduce
@@ -30,3 +31,10 @@ config AUTOFS4_FS
 	  - any "alias autofs autofs4" will need to be removed.
 
 	  Please configure AUTOFS_FS instead of AUTOFS4_FS from now on.
+
+	  NOTE: Since the modules autofs and autofs4 use the same file system
+		type name of "autofs" only one can be built. The "depends"
+		above will result in AUTOFS4_FS not appearing in .config for
+		any setting of AUTOFS_FS other than n and AUTOFS4_FS will
+		appear under the AUTOFS_FS entry otherwise which is intended
+		to draw attention to the module rename change.
