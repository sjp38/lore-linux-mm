Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9FCD56B005D
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 06:38:14 -0500 (EST)
Date: Thu, 5 Mar 2009 19:11:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: drop_caches ...
Message-ID: <20090305111114.GD29617@localhost>
References: <20090305004850.GA6045@localhost> <20090305090618.GB23266@ics.muni.cz> <20090305181304.6758.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <20090305181304.6758.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lukas Hejtmanek <xhejtman@ics.muni.cz>, Markus <M4rkusXXL@web.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 05, 2009 at 11:14:33AM +0200, KOSAKI Motohiro wrote:
> > Hello,
> > 
> > On Thu, Mar 05, 2009 at 08:48:50AM +0800, Wu Fengguang wrote:
> > > Markus, you may want to try this patch, it will have better chance to figure
> > > out the hidden file pages.
> > 
> > just for curiosity, would it be possible to print process name which caused
> > the file to be loaded into caches?
 
Yes the code has been there but not included in the patch I sent to you.

When enabled by the following option, the kernel will save the short name of
current process into every _newly_ allocated inode structure, which will then
be displayed in the filecache.

+config PROC_FILECACHE_EXTRAS
+       bool "track extra states"
+       default y
+       depends on PROC_FILECACHE
+       help
+         Track extra states that costs a little more time/space.

However it adds runtime overhead, and the information is not reliably usable.
So not everyone will like this idea and I'm not maintaining this feature now.

But I do have an interesting old copy that shows the process names:

#      ino       size   cached cached% refcnt state accessed   uid process         dev          file
   1221729          1        4     100      0    --       27     0 rc              08:01(sda1)	/etc/default/rcS
   1058788         32       32     100      0    --       92     0 udevd           08:01(sda1)	/sbin/modprobe
   1221859          2        4     100      0    --        2     0 rc              08:01(sda1)	/etc/init.d/module-init-tools
   1400967          2        4     100      0    --       65     0 tput            08:01(sda1)	/lib/terminfo/l/linux
    195578         90       92     100      0    --       10     0 S03udev         08:01(sda1)	/usr/bin/expr
    196704         12       12     100      0    --       60     0 S03udev         08:01(sda1)	/usr/bin/tput
   1221849          1        4     100      0    --        2     0 S18ifupdown-cle 08:01(sda1)	/etc/default/ifupdown
   1221847          2        4     100      0    --        2     0 rc              08:01(sda1)	/etc/init.d/ifupdown-clean
   1726534          1        4     100      0    --       56     0 alsa-utils      08:01(sda1)	/bin/which
   1726549          7        8     100      0    --       25     0 sh              08:01(sda1)	/bin/mountpoint
   1221998          3        4     100      0    --       30     0 sh              08:01(sda1)	/etc/fstab
   1727533        100      100     100      0    --      306     0 sh              08:01(sda1)	/bin/grep
   1221653          3        4     100      0    --        3     0 rc              08:01(sda1)	/etc/init.d/mountdevsubfs.sh
   1400773          3        4     100      0    --        9     0 sh              08:01(sda1)	/lib/init/mount-functions.sh
   1400851          8        8     100      0    --       48     0 rc              08:01(sda1)	/lib/lsb/init-functions
   1727381         19       20     100      0    --       34     0 sh              08:01(sda1)	/bin/uname
   1221672          1        4     100      0    --        3     0 sh              08:01(sda1)	/etc/default/tmpfs
   1221669          1        4     100      0    --        3     0 sh              08:01(sda1)	/etc/default/devpts
   1224261          2        4     100      1    --      975     0 rcS             08:01(sda1)	/etc/passwd
   1221725          1        4     100      0    --      492     0 rcS             08:01(sda1)	/etc/nsswitch.conf
   1221659          4        4     100      0    --        1     0 rc              08:01(sda1)	/etc/init.d/mtab.sh
   1726557         50       52     100      0    --      186     0 rc              08:01(sda1)	/bin/sed
   1222991          2        4     100      0    --       25     0 mount           08:01(sda1)	/etc/blkid.tab
   1222681          1        4     100      0    --      207     0 init            08:01(sda1)	/etc/selinux/config
   1727379         40       40     100      0    --      251     0 sh              08:01(sda1)	/bin/rm
   1564027         35       36     100      9    --      142     0 touch           08:01(sda1)	/lib/librt-2.6.so
   1727368         40       40     100      0    --       70     0 sh              08:01(sda1)	/bin/touch
   1223550         97      100     100      0    --     4479     0 init            08:01(sda1)	/etc/ld.so.cache
   1400771         10       12     100      0    --        2     0 sh              08:01(sda1)	/lib/init/readlink
   1065053          8        8     100      0    --        2     0 sh              08:01(sda1)	/sbin/logsave
   1221665         10       12     100      0    --        1     0 rc              08:01(sda1)	/etc/init.d/checkroot.sh
     12661          1        4     100      1    d-       10     0 udevd           00:0e(tmpfs)	/.udev/db/block@sr0
     12320          1        4     100      1    D-       11     0 udevd           00:0e(tmpfs)	/.udev/db/md0
     12661          1        4     100      1    d-       10     0 udevd           00:0e(tmpfs)	/.udev/db/block@sr0
     12320          1        4     100      1    D-       11     0 udevd           00:0e(tmpfs)	/.udev/db/md0
     12316          1        4     100      1    D-       11     0 udevd           00:0e(tmpfs)	/.udev/db/md2
     12289          1        4     100      1    d-       10     0 udevd           00:0e(tmpfs)	/.udev/db/class@input@input2@event2
   1726532         19       20     100      0    --       42     0 net.agent       08:01(sda1)	/bin/sleep
     11918          1        4     100      1    d-       10     0 udevd           00:0e(tmpfs)	/.udev/db/class@input@input0@event0
     11912          1        4     100      1    d-       10     0 udevd           00:0e(tmpfs)	/.udev/db/class@input@input1@event1
   1058730         60       60     100      1    --        1     0 S03udev         08:01(sda1)	/sbin/udevd
   1564011        123      124     100     16    --      220     0 mount           08:01(sda1)	/lib/libpthread-2.6.so
   1400830         70       72     100      0    --       27     0 mount           08:01(sda1)	/lib/libdevmapper.so.1.02
   1400847         11       12     100      0    --       27     0 mount           08:01(sda1)	/lib/libuuid.so.1.2
   1400881         39       40     100      0    --       27     0 mount           08:01(sda1)	/lib/libblkid.so.1.0
   1726538         87       88     100      0    --       17     0 sh              08:01(sda1)	/bin/mount
   1221817          8        8     100      0    --        4     0 rcS             08:01(sda1)	/etc/init.d/rc
   1564018         43       44     100     50    --      492     0 rcS             08:01(sda1)	/lib/libnss_files-2.6.so
   1564012         43       44     100     43    --      473     0 rcS             08:01(sda1)	/lib/libnss_nis-2.6.so
   1564010         87       88     100     47    --      513     0 rcS             08:01(sda1)	/lib/libnsl-2.6.so
   1564020         35       36     100     43    --      473     0 rcS             08:01(sda1)	/lib/libnss_compat-2.6.so
   1661561        359      360     100     13    --      384     0 rcS             08:01(sda1)	/lib/libncurses.so.5.6
   1727359        752      752     100      2    --      291     0 init            08:01(sda1)	/bin/bash
   1564016         15       16     100     52    --      801     0 init            08:01(sda1)	/lib/libdl-2.6.so
   1564015       1352     1352     100     82    --     3338     0 init            08:01(sda1)	/lib/libc-2.6.so
   1402884         91       92     100      7    --      206     0 init            08:01(sda1)	/lib/libselinux.so.1
   1401085        236      236     100      7    --      206     0 init            08:01(sda1)	/lib/libsepol.so.1
   1564007        121      124     100     82    --     3338     0 run-init        08:01(sda1)	/lib/ld-2.6.so
   1058733         40       40     100      1    --        1     0 busybox         08:01(sda1)	/sbin/init
         0  160836480      308       0      0    --        0     0 mdadm           00:02(bdev)	(08:00)
         0   32226390        4       0      0    --        0     0 mdadm           00:02(bdev)	(08:02)
         0     128489        4       0      0    --        0     0 mdadm           00:02(bdev)	(08:07)
         0  160836480      308       0      0    --        0     0 mdadm           00:02(bdev)	(08:10)
         0   32226390        4       0      0    --        0     0 mdadm           00:02(bdev)	(08:12)
         0     313236        4       0      0    --        0     0 mdadm           00:02(bdev)	(08:18)
      7976          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sda@sda4
      7970          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sda@sda8
      7964          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sdb@sdb6
      7957          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sda@sda7
      7951          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sda@sda6
      7944          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sdb@sdb8
      7938          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sdb@sdb7
      7931          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sda@sda5
      7924          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sdb@sdb5
      7918          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sda@sda3
      7911          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sdb@sdb4
      7905          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sdb@sdb3
      7898          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sda@sda2
      7892          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sda@sda1
      7885          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sdb@sdb2
      7851          1        4     100      1    D-       12     0 udevd           00:0e(tmpfs)	/.udev/db/block@sdb@sdb1
      7823          1        4     100      1    D-       32     0 udevd           00:0e(tmpfs)	/.udev/db/block@sda
      7769          1        4     100      1    D-       28     0 udevd           00:0e(tmpfs)	/.udev/db/block@sdb
      7472          1        4     100      1    D-        4     0 udevd           00:0e(tmpfs)	/.udev/db/class@input@input1@mouse0
      7068          1        4     100      1    D-        4     0 udevd           00:0e(tmpfs)	/.udev/db/class@input@mice
      2227          1        4     100      1    D-     1790     0 udevd           00:0e(tmpfs)	/.udev/uevent_seqnum
      2127          1        4     100      1    D-       11     0 init            00:0e(tmpfs)	/.initramfs/progress_state

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
