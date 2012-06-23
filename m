Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 413536B02B7
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 10:58:55 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5902422pbb.14
        for <linux-mm@kvack.org>; Sat, 23 Jun 2012 07:58:54 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v4 0/6] notifier error injection
Date: Sat, 23 Jun 2012 23:58:16 +0900
Message-Id: <1340463502-15341-1-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-pm@lists.linux-foundation.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, =?UTF-8?q?Am=C3=A9rico=20Wang?= <xiyou.wangcong@gmail.com>, Michael Ellerman <michael@ellerman.id.au>

This provides kernel modules that can be used to test the error handling
of notifier call chain failures by injecting artifical errors to the
following notifier chain callbacks.

 * CPU notifier
 * PM notifier
 * memory hotplug notifier
 * powerpc pSeries reconfig notifier

Example: Inject CPU offline error (-1 == -EPERM)

	# cd /sys/kernel/debug/notifier-error-inject/cpu
	# echo -1 > actions/CPU_DOWN_PREPARE/error
	# echo 0 > /sys/devices/system/cpu/cpu1/online
	bash: echo: write error: Operation not permitted

There are also handy shell scripts to test CPU and memory hotplug notifier.
Note that these tests didn't detect error handling bugs on my machine but
I still think this feature is usefull to test the code path which is rarely
executed.

Changelog:

* v4 (It is about 11 months since v3)
- prefix all APIs with notifier_err_inject_*
- rearrange debugfs interface
  (e.g. $DEBUGFS/cpu-notifier-error-inject/CPU_DOWN_PREPARE -->
        $DEBUGFS/notifier-error-inject/cpu/actions/CPU_DOWN_PREPARE/error)
- update modules to follow new interface
- add -r option for memory-notifier.sh to specify percent of offlining
  memory blocks

* v3
- rewrite to be kernel modules instead of initializing at late_initcall()s
  (it makes the diffstat look different but most code remains unchanged)
- export err_inject_notifier_block_{init,cleanup} for modules
- export pSeries_reconfig_notifier_{,un}register symbols for a module
- notifier priority can be specified as a module parameter
- add testing scripts in tools/testing/fault-injection

* v2
- "PM: Improve error code of pm_notifier_call_chain()" is now in -next
- "debugfs: add debugfs_create_int" is dropped
- put a comment in err_inject_notifier_block_init()
- only allow valid errno to be injected (-MAX_ERRNO <= errno <= 0)
- improve Kconfig help text
- make CONFIG_PM_NOTIFIER_ERROR_INJECTION visible even if PM_DEBUG is disabled
- make CONFIG_PM_NOTIFIER_ERROR_INJECTION default if PM_DEBUG is enabled

Akinobu Mita (6):
  fault-injection: notifier error injection
  cpu: rewrite cpu-notifier-error-inject module
  PM: PM notifier error injection module
  memory: memory notifier error injection module
  powerpc: pSeries reconfig notifier error injection module
  fault-injection: add notifier error injection testing scripts

 lib/Kconfig.debug                                |   91 ++++++++++-
 lib/Makefile                                     |    5 +
 lib/cpu-notifier-error-inject.c                  |   63 +++-----
 lib/memory-notifier-error-inject.c               |   48 ++++++
 lib/notifier-error-inject.c                      |  112 ++++++++++++++
 lib/notifier-error-inject.h                      |   24 +++
 lib/pSeries-reconfig-notifier-error-inject.c     |   51 +++++++
 lib/pm-notifier-error-inject.c                   |   49 ++++++
 tools/testing/fault-injection/cpu-notifier.sh    |  169 +++++++++++++++++++++
 tools/testing/fault-injection/memory-notifier.sh |  176 ++++++++++++++++++++++
 10 files changed, 748 insertions(+), 40 deletions(-)
 create mode 100644 lib/memory-notifier-error-inject.c
 create mode 100644 lib/notifier-error-inject.c
 create mode 100644 lib/notifier-error-inject.h
 create mode 100644 lib/pSeries-reconfig-notifier-error-inject.c
 create mode 100644 lib/pm-notifier-error-inject.c
 create mode 100755 tools/testing/fault-injection/cpu-notifier.sh
 create mode 100755 tools/testing/fault-injection/memory-notifier.sh

Cc: Pavel Machek <pavel@ucw.cz>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@lists.linux-foundation.org
Cc: Greg KH <greg@kroah.com>
Cc: linux-mm@kvack.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: AmA(C)rico Wang <xiyou.wangcong@gmail.com>
Cc: Michael Ellerman <michael@ellerman.id.au>

-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
