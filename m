Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id C53066B00A6
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:57:27 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH v2] enable all tmem backends to be built and loaded as modules.
Date: Wed, 14 Nov 2012 13:57:04 -0500
Message-Id: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com

There are also some patch I wrote up that are based on this patchset
that I will post soonish.

I hope these patches come out - I am travelling and not sure if my
git-send-email foo will make this work.

I copying here what Dan mentioned with some modifications by me:

 Since various parts of transcendent memory ("tmem") [1] were first posted in
 2009, reviewers have suggested that various tmem features should be built
 as a module and enabled by loading the module, rather than the current clunky
 method of compiling as a built-in and enabling via boot parameter.  Due
 to certain tmem initialization steps, that was not feasible at the time.
 
 [1] http://lwn.net/Articles/454795/
 
 This patchset allows each of the three merged transcendent memory
 backends (zcache, ramster, Xen tmem) to be used as modules by first
 enabling transcendent memory frontends (cleancache, frontswap) to deal
 with "lazy initialization" and, second, by adding the necessary code for
 the backends to be built and loaded as modules.
 
 The original mechanism to enable tmem backends -- namely to hardwire
 them into the kernel and select/enable one with a kernel boot
 parameter --  is retained but should be considered deprecated.  When
 backends are loaded as modules, certain knobs will now be
 properly selected via module_params rather than via undocumented
 kernel boot parameters.  Note that module UNloading is not yet
 supported as it is lower priority and will require significant
 additional work.
 
 The lazy initialization support is necessary because filesystems
 and swap devices are normally mounted early in boot and these
 activites normally trigger tmem calls to setup certain data structures;
 if the respective cleancache/frontswap ops are not yet registered
 by a back end, the tmem setup would fail for these devices and
 cleancache/frontswap would never be enabled for them which limits
 much of the value of tmem in many system configurations.  Lazy
 initialization records the necessary information in cleancache/frontswap
 data structures and "replays" it after the ops are registered
 to ensure that all filesystems and swap devices can benefit from
 the loaded tmem backend.
 
 [PATCH 1/8] mm: cleancache: lazy initialization to allow tmem
 [PATCH 2/8] mm: frontswap: lazy initialization to allow tmem

 Patches 1 and 2 are the original [2] patches to cleancache and frontswap
 proposed by Erlangen University, but rebased to 3.7-rcN plus a couple
 of bug fixes I found necessary to run properly + extra review comments.
 
 [2] http://www.spinics.net/lists/linux-mm/msg31490.html

 The other two:
 [PATCH 3/8] frontswap: Make frontswap_init use a pointer for the
 [PATCH 4/8] cleancache: Make cleancache_init use a pointer for the
 do a bit of code cleanup that can be done to make it easier to
 read and also remove some of the bools.
 
 [PATCH 5/8] staging: zcache2+ramster: enable ramster to be
 Enables module support for zcache2.  Zsmalloc support
 has not yet been merged into zcache2 but, once merged, could now
 easily be selected via a module_param.
 
 [PATCH 6/8] staging: zcache2+ramster: enable zcache2 to be
 Enables module support for ramster.  Ramster will now be
 enabled with a module_param to zcache2.
 
 [PATCH 7/8] xen: tmem: enable Xen tmem shim to be built/loaded as a
 [PATCH 8/8] xen/tmem: Remove the subsys call.
 Enables module support for the Xen tmem shim.  Xen self-ballooning and
 frontswap-selfshrinking are also "lazily"
 initialized when the Xen tmem shim is loaded as a module, unless
 explicitly disabled by module_params.


Dan Magenheimer (5):
      mm: cleancache: lazy initialization to allow tmem backends to build/run as modules
      mm: frontswap: lazy initialization to allow tmem backends to build/run as modules
      staging: zcache2+ramster: enable ramster to be built/loaded as a module
      staging: zcache2+ramster: enable zcache2 to be built/loaded as a module
      xen: tmem: enable Xen tmem shim to be built/loaded as a module

Konrad Rzeszutek Wilk (3):
      frontswap: Make frontswap_init use a pointer for the ops.
      cleancache: Make cleancache_init use a pointer for the ops
      xen/tmem: Remove the subsys call.


 drivers/staging/ramster/Kconfig                    |    6 +-
 drivers/staging/ramster/Makefile                   |   11 +-
 drivers/staging/ramster/ramster.h                  |    6 +-
 drivers/staging/ramster/ramster/nodemanager.c      |    9 +-
 drivers/staging/ramster/ramster/ramster.c          |   29 +++-
 drivers/staging/ramster/ramster/ramster.h          |    2 +-
 .../staging/ramster/ramster/ramster_nodemanager.h  |    2 +
 drivers/staging/ramster/tmem.c                     |    6 +-
 drivers/staging/ramster/tmem.h                     |    8 +-
 drivers/staging/ramster/zcache-main.c              |   63 ++++++--
 drivers/staging/ramster/zcache.h                   |    2 +-
 drivers/staging/zcache/zcache-main.c               |   16 +-
 drivers/xen/Kconfig                                |    4 +-
 drivers/xen/tmem.c                                 |   50 ++++--
 drivers/xen/xen-selfballoon.c                      |   13 +-
 include/linux/cleancache.h                         |    2 +-
 include/linux/frontswap.h                          |    2 +-
 include/xen/tmem.h                                 |    8 +
 mm/cleancache.c                                    |  167 +++++++++++++++++---
 mm/frontswap.c                                     |   78 +++++++--
 20 files changed, 371 insertions(+), 113 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
