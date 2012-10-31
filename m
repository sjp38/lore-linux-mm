Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id CF2646B0070
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 11:08:03 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 0/5] enable all tmem backends to be built and loaded as modules
Date: Wed, 31 Oct 2012 08:07:49 -0700
Message-Id: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com, fschmaus@gmail.com, andor.damm@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

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

Patches 1 and 2 are the original [2] patches to cleancache and frontswap
proposed by Erlangen University, but rebased to 3.7-rcN plus a couple
of bug fixes I found necessary to run properly.  I have not attempted
any code cleanup.  I have also added defines to ensure at runtime
that backends are not loaded as modules if the frontend patches are not
yet merged; this is useful to avoid any build dependency (since the
frontends may be merged into linux-next through different trees and
at different times than some backends) and once the entire patchset
is safely merged, these defines/ifdefs can be removed.

[2] http://www.spinics.net/lists/linux-mm/msg31490.html 

Patch 3 enables module support for zcache2.  Zsmalloc support
has not yet been merged into zcache2 but, once merged, could now
easily be selected via a module_param.

Patch 4 enables module support for ramster.  Ramster will now be
enabled with a module_param to zcache2.

Patch 5 enables module support for the Xen tmem shim.  Xen
self-ballooning and frontswap-selfshrinking are also "lazily"
initialized when the Xen tmem shim is loaded as a module, unless
explicitly disabled by module_params.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

---
Diffstat:

 drivers/staging/ramster/Kconfig                    |    6 +-
 drivers/staging/ramster/Makefile                   |   11 +-
 drivers/staging/ramster/ramster.h                  |    6 +-
 drivers/staging/ramster/ramster/nodemanager.c      |    9 +-
 drivers/staging/ramster/ramster/ramster.c          |   29 +++-
 drivers/staging/ramster/ramster/ramster.h          |    2 +-
 .../staging/ramster/ramster/ramster_nodemanager.h  |    2 +
 drivers/staging/ramster/tmem.c                     |    6 +-
 drivers/staging/ramster/tmem.h                     |    8 +-
 drivers/staging/ramster/zcache-main.c              |   61 +++++++-
 drivers/staging/ramster/zcache.h                   |    2 +-
 drivers/xen/Kconfig                                |    4 +-
 drivers/xen/tmem.c                                 |   56 ++++++--
 drivers/xen/xen-selfballoon.c                      |   13 +-
 include/linux/cleancache.h                         |    1 +
 include/linux/frontswap.h                          |    1 +
 include/xen/tmem.h                                 |    8 +
 mm/cleancache.c                                    |  157 +++++++++++++++++--
 mm/frontswap.c                                     |   70 ++++++++-
 19 files changed, 379 insertions(+), 73 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
