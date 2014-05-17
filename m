Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2C46B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 22:34:46 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so3254383pab.24
        for <linux-mm@kvack.org>; Fri, 16 May 2014 19:34:45 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id ug2si11165716pab.212.2014.05.16.19.34.44
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 19:34:45 -0700 (PDT)
Date: Sat, 17 May 2014 10:34:09 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 446/499] drivers/firewire/core-device.c:756:1:
 warning: missing braces around initializer
Message-ID: <5376caa1.H9Vy3NRlMf2qjx6e%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   ff35dad6205c66d96feda494502753e5ed1b10f1
commit: 67039d034b422b074af336ebf8101346b6b5d441 [446/499] rwsem: Support optimistic spinning
config: make ARCH=arm allmodconfig

All warnings:

>> drivers/firewire/core-device.c:756:1: warning: missing braces around initializer [-Wmissing-braces]
>> drivers/firewire/core-device.c:756:1: warning: (near initialization for 'fw_device_rwsem.dep_map') [-Wmissing-braces]
--
>> fs/ocfs2/dlm/dlmdomain.c:2281:8: warning: missing braces around initializer [-Wmissing-braces]
>> fs/ocfs2/dlm/dlmdomain.c:2281:8: warning: (near initialization for 'dlm_callback_sem.dep_map') [-Wmissing-braces]
--
>> drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c:105:8: warning: missing braces around initializer [-Wmissing-braces]
>> drivers/staging/lustre/lustre/libcfs/kernel_user_comm.c:105:8: warning: (near initialization for 'kg_sem.dep_map') [-Wmissing-braces]
--
   In file included from drivers/staging/media/sn9c102/sn9c102_core.c:42:0:
>> drivers/staging/media/sn9c102/sn9c102.h:99:8: warning: missing braces around initializer [-Wmissing-braces]
>> drivers/staging/media/sn9c102/sn9c102.h:99:8: warning: (near initialization for 'sn9c102_dev_lock.dep_map') [-Wmissing-braces]
--
>> drivers/staging/lustre/lustre/llite/file.c:3138:2: warning: missing braces around initializer [-Wmissing-braces]
>> drivers/staging/lustre/lustre/llite/file.c:3138:2: warning: (near initialization for 'llioc.ioc_sem.dep_map') [-Wmissing-braces]
--
>> drivers/i2c/i2c-boardinfo.c:32:1: warning: missing braces around initializer [-Wmissing-braces]
>> drivers/i2c/i2c-boardinfo.c:32:1: warning: (near initialization for '__i2c_board_lock.dep_map') [-Wmissing-braces]
--
>> net/netlink/genetlink.c:24:8: warning: missing braces around initializer [-Wmissing-braces]
>> net/netlink/genetlink.c:24:8: warning: (near initialization for 'cb_lock.dep_map') [-Wmissing-braces]
--
>> fs/fscache/cache.c:18:1: warning: missing braces around initializer [-Wmissing-braces]
>> fs/fscache/cache.c:18:1: warning: (near initialization for 'fscache_addremove_sem.dep_map') [-Wmissing-braces]
--
>> drivers/pci/search.c:16:1: warning: missing braces around initializer [-Wmissing-braces]
>> drivers/pci/search.c:16:1: warning: (near initialization for 'pci_bus_sem.dep_map') [-Wmissing-braces]
--
>> fs/configfs/dir.c:38:1: warning: missing braces around initializer [-Wmissing-braces]
>> fs/configfs/dir.c:38:1: warning: (near initialization for 'configfs_rename_sem.dep_map') [-Wmissing-braces]
--
>> drivers/video/fbdev/core/fb_notify.c:17:8: warning: missing braces around initializer [-Wmissing-braces]
>> drivers/video/fbdev/core/fb_notify.c:17:8: warning: (near initialization for 'fb_notifier_list.rwsem.dep_map') [-Wmissing-braces]
..

vim +756 drivers/firewire/core-device.c

19a15b93 drivers/firewire/fw-device.c Kristian Hogsberg 2006-12-19  740  	}
19a15b93 drivers/firewire/fw-device.c Kristian Hogsberg 2006-12-19  741  }
19a15b93 drivers/firewire/fw-device.c Kristian Hogsberg 2006-12-19  742  
19a15b93 drivers/firewire/fw-device.c Kristian Hogsberg 2006-12-19  743  static int shutdown_unit(struct device *device, void *data)
19a15b93 drivers/firewire/fw-device.c Kristian Hogsberg 2006-12-19  744  {
21351dbe drivers/firewire/fw-device.c Kristian Hogsberg 2007-03-20  745  	device_unregister(device);
19a15b93 drivers/firewire/fw-device.c Kristian Hogsberg 2006-12-19  746  
19a15b93 drivers/firewire/fw-device.c Kristian Hogsberg 2006-12-19  747  	return 0;
19a15b93 drivers/firewire/fw-device.c Kristian Hogsberg 2006-12-19  748  }
19a15b93 drivers/firewire/fw-device.c Kristian Hogsberg 2006-12-19  749  
c9755e14 drivers/firewire/fw-device.c Stefan Richter    2008-03-24  750  /*
c9755e14 drivers/firewire/fw-device.c Stefan Richter    2008-03-24  751   * fw_device_rwsem acts as dual purpose mutex:
c9755e14 drivers/firewire/fw-device.c Stefan Richter    2008-03-24  752   *   - serializes accesses to fw_device_idr,
c9755e14 drivers/firewire/fw-device.c Stefan Richter    2008-03-24  753   *   - serializes accesses to fw_device.config_rom/.config_rom_length and
c9755e14 drivers/firewire/fw-device.c Stefan Richter    2008-03-24  754   *     fw_unit.directory, unless those accesses happen at safe occasions
c9755e14 drivers/firewire/fw-device.c Stefan Richter    2008-03-24  755   */
c9755e14 drivers/firewire/fw-device.c Stefan Richter    2008-03-24 @756  DECLARE_RWSEM(fw_device_rwsem);
c9755e14 drivers/firewire/fw-device.c Stefan Richter    2008-03-24  757  
d6053e08 drivers/firewire/fw-device.c Stefan Richter    2008-11-24  758  DEFINE_IDR(fw_device_idr);
a3aca3da drivers/firewire/fw-device.c Kristian Hogsberg 2007-03-07  759  int fw_cdev_major;
a3aca3da drivers/firewire/fw-device.c Kristian Hogsberg 2007-03-07  760  
96b19062 drivers/firewire/fw-device.c Stefan Richter    2008-02-02  761  struct fw_device *fw_device_get_by_devt(dev_t devt)
a3aca3da drivers/firewire/fw-device.c Kristian Hogsberg 2007-03-07  762  {
a3aca3da drivers/firewire/fw-device.c Kristian Hogsberg 2007-03-07  763  	struct fw_device *device;
a3aca3da drivers/firewire/fw-device.c Kristian Hogsberg 2007-03-07  764  

:::::: The code at line 756 was first introduced by commit
:::::: c9755e14a01987ada4063e8b4c50c2b6738d879e firewire: reread config ROM when device reset the bus

:::::: TO: Stefan Richter <stefanr@s5r6.in-berlin.de>
:::::: CC: Stefan Richter <stefanr@s5r6.in-berlin.de>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
