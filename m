Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id CCF346B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 08:48:09 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [GIT PULL] ACPI and power management fixes for v3.12-rc1
Date: Thu, 12 Sep 2013 14:59:12 +0200
Message-ID: <1694280.WDu46WrZNJ@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>, linux-mm@kvack.org

Hi Linus,

Please pull from the git repository at

  git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm.git pm+acpi-fixes-3.12-rc1

to receive ACPI and power management fixes for v3.12 with top-most commit
f1728fd1599112239ed5cebc7be9810264db6792

  Merge branch 'pm-cpufreq'

on top of commit a9238741987386bb549d61572973c7e62b2a4145

  Merge tag 'pci-v3.12-changes' of git://git.kernel.org/pub/scm/linux/kernel/git/helgaa
s/pci

All of these commits are fixes that have emerged recently and some of them
fix bugs introduced during this merge window.

Specifics:

 1) ACPI-based PCI hotplug (ACPIPHP) fixes related to spurious events

  After the recent ACPIPHP changes we've seen some interesting breakage
  on a system that triggers device check notifications during boot for
  non-existing devices.  Although those notifications are really
  spurious, we should be able to deal with them nevertheless and that
  shouldn't introduce too much overhead.  Four commits to make that
  work properly.

 2) Memory hotplug and hibernation mutual exclusion rework

  This was maent to be a cleanup, but it happens to fix a classical
  ABBA deadlock between system suspend/hibernation and ACPI memory
  hotplug which is possible if they are started roughly at the same
  time.  Three commits rework memory hotplug so that it doesn't
  acquire pm_mutex and make hibernation use device_hotplug_lock
  which prevents it from racing with memory hotplug.

 3) ACPI Intel LPSS (Low-Power Subsystem) driver crash fix

  The ACPI LPSS driver crashes during boot on Apple Macbook Air with
  Haswell that has slightly unusual BIOS configuration in which one
  of the LPSS device's _CRS method doesn't return all of the information
  expected by the driver.  Fix from Mika Westerberg, for stable.

 4) ACPICA fix related to Store->ArgX operation

  AML interpreter fix for obscure breakage that causes AML to be
  executed incorrectly on some machines (observed in practice).  From
  Bob Moore.

 5) ACPI core fix for PCI ACPI device objects lookup

  There still are cases in which there is more than one ACPI device
  object matching a given PCI device and we don't choose the one that
  the BIOS expects us to choose, so this makes the lookup take more
  criteria into account in those cases.

 6) Fix to prevent cpuidle from crashing in some rare cases

  If the result of cpuidle_get_driver() is NULL, which can happen on
  some systems, cpuidle_driver_ref() will crash trying to use that
  pointer and the Daniel Fu's fix prevents that from happening.

 7) cpufreq fixes related to CPU hotplug

  Stephen Boyd reported a number of concurrency problems with cpufreq
  related to CPU hotplug which are addressed by a series of fixes
  from Srivatsa S Bhat and Viresh Kumar.

 8) cpufreq fix for time conversion in time_in_state attribute

  Time conversion carried out by cpufreq when user space attempts to
  read /sys/devices/system/cpu/cpu*/cpufreq/stats/time_in_state won't
  work correcty if cputime_t doesn't map directly to jiffies.  Fix
  from Andreas Schwab.

 9) Revert of a troublesome cpufreq commit

  Commit 7c30ed5 (cpufreq: make sure frequency transitions are
  serialized) was intended to address some known concurrency problems
  in cpufreq related to the ordering of transitions, but unfortunately
  it introduced several problems of its own, so I decided to revert it
  now and address the original problems later in a more robust way.

10) Intel Haswell CPU models for intel_pstate from Nell Hardcastle.

11) cpufreq fixes related to system suspend/resume

  The recent cpufreq changes that made it preserve CPU sysfs attributes
  over suspend/resume cycles introduced a possible NULL pointer
  dereference that caused it to crash during the second attempt to
  suspend.  Three commits from Srivatsa S Bhat fix that problem and a
  couple of related issues.

12) cpufreq locking fix

  cpufreq_policy_restore() should acquire the lock for reading, but
  it acquires it for writing.  Fix from Lan Tianyu.

Thanks!


---------------

Andreas Schwab (1):
      cpufreq: Fix wrong time unit conversion

Bob Moore (1):
      ACPICA: Fix for a Store->ArgX when ArgX contains a reference to a field.

Daniel Fu (1):
      cpuidle: Check the result of cpuidle_get_driver() against NULL

Lan Tianyu (1):
      cpufreq: Acquire the lock in cpufreq_policy_restore() for reading

Mika Westerberg (1):
      ACPI / LPSS: don't crash if a device has no MMIO resources

Nell Hardcastle (1):
      intel_pstate: Add Haswell CPU models

Rafael J. Wysocki (9):
      ACPI / scan: Change ordering of locks for device hotplug
      PM / hibernate: Create memory bitmaps after freezing user space
      PM / hibernate / memory hotplug: Rework mutual exclusion
      ACPI / hotplug / PCI: Don't trim devices before scanning the namespace
      ACPI / hotplug / PCI: Avoid doing too much for spurious notifies
      ACPI / hotplug / PCI: Use _OST to notify firmware about notify status
      ACPI / hotplug / PCI: Avoid parent bus rescans on spurious device checks
      ACPI / bind: Prefer device objects with _STA to those without it
      Revert "cpufreq: make sure frequency transitions are serialized"

Srivatsa S. Bhat (8):
      cpufreq: Split __cpufreq_remove_dev() into two parts
      cpufreq: Invoke __cpufreq_remove_dev_finish() after releasing cpu_hotplug.lock
      cpufreq: Synchronize the cpufreq store_*() routines with CPU hotplug
      cpufreq: Remove temporary fix for race between CPU hotplug and sysfs-writes
      cpufreq: Use signed type for 'ret' variable, to store negative error values
      cpufreq: Fix crash in cpufreq-stats during suspend/resume
      cpufreq: Restructure if/else block to avoid unintended behavior
      cpufreq: Prevent problems in update_policy_cpu() if last_cpu == new_cpu

Viresh Kumar (2):
      cpufreq: don't allow governor limits to be changed when it is disabled
      cpufreq: serialize calls to __cpufreq_governor()

---------------

 drivers/acpi/acpi_lpss.c           |    3 +-
 drivers/acpi/acpica/exstore.c      |  166 ++++++++++++++++++++++--------------
 drivers/acpi/glue.c                |   35 +++++---
 drivers/acpi/scan.c                |   15 ++--
 drivers/cpufreq/cpufreq.c          |  152 ++++++++++++++++++++++-----------
 drivers/cpufreq/cpufreq_stats.c    |    2 +-
 drivers/cpufreq/intel_pstate.c     |    5 ++
 drivers/cpuidle/driver.c           |    3 +-
 drivers/pci/hotplug/acpiphp_glue.c |   61 ++++++++++---
 include/linux/cpufreq.h            |    1 -
 kernel/power/hibernate.c           |   45 +++++-----
 kernel/power/user.c                |   24 +++---
 mm/memory_hotplug.c                |    4 -
 13 files changed, 328 insertions(+), 188 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
