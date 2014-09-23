Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3761E6B0037
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 21:29:31 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so3675165pde.22
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 18:29:30 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ig2si17828844pbb.232.2014.09.22.18.29.29
        for <linux-mm@kvack.org>;
        Mon, 22 Sep 2014 18:29:29 -0700 (PDT)
Date: Tue, 23 Sep 2014 09:28:46 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 262/385] drivers/rtc/rtc-bq32k.c:155:7: warning:
 assignment makes pointer from integer without a cast
Message-ID: <5420ccce.rDfDnUkASFVCOUUB%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   eb076320e4dbdf99513732811ed8730812b34b2f
commit: b44e93cb89b6c5b32fd625f30341bcf14991322d [262/385] rtc: bq32000: add trickle charger option, with device tree binding
config: i386-allyesconfig
reproduce:
  git checkout b44e93cb89b6c5b32fd625f30341bcf14991322d
  make ARCH=i386  allyesconfig
  make ARCH=i386 

All warnings:

   drivers/rtc/rtc-bq32k.c: In function 'trickle_charger_of_init':
>> drivers/rtc/rtc-bq32k.c:155:7: warning: assignment makes pointer from integer without a cast
      reg = 0x05;
          ^
>> drivers/rtc/rtc-bq32k.c:165:7: warning: assignment makes pointer from integer without a cast
      reg = 0x25;
          ^
>> drivers/rtc/rtc-bq32k.c:177:6: warning: assignment makes pointer from integer without a cast
     reg = 0x20;
         ^
>> drivers/rtc/rtc-bq32k.c:135:6: warning: unused variable 'plen' [-Wunused-variable]
     int plen = 0;
         ^

vim +155 drivers/rtc/rtc-bq32k.c

   129		.read_time	= bq32k_rtc_read_time,
   130		.set_time	= bq32k_rtc_set_time,
   131	};
   132	
   133	static int trickle_charger_of_init(struct device *dev, struct device_node *node)
   134	{
   135		int plen = 0;
   136		const uint32_t *setup;
   137		const uint32_t *reg;
   138		int error;
   139		u32 ohms = 0;
   140	
   141		if (of_property_read_u32(node, "trickle-resistor-ohms" , &ohms))
   142			return 0;
   143	
   144		switch (ohms) {
   145		case 180+940:
   146			/*
   147			 * TCHE[3:0] == 0x05, TCH2 == 1, TCFE == 0 (charging
   148			 * over diode and 940ohm resistor)
   149			 */
   150	
   151			if (of_property_read_bool(node, "trickle-diode-disable")) {
   152				dev_err(dev, "diode and resistor mismatch\n");
   153				return -EINVAL;
   154			}
   155			reg = 0x05;
   156			break;
   157	
   158		case 180+20000:
   159			/* diode disabled */
   160	
   161			if (!of_property_read_bool(node, "trickle-diode-disable")) {
   162				dev_err(dev, "bq32k: diode and resistor mismatch\n");
   163				return -EINVAL;
   164			}
   165			reg = 0x25;
   166			break;
   167	
   168		default:
   169			dev_err(dev, "invalid resistor value (%d)\n", *setup);
   170			return -EINVAL;
   171		}
   172	
   173		error = bq32k_write(dev, &reg, BQ32K_CFG2, 1);
   174		if (error)
   175			return error;
   176	
   177		reg = 0x20;
   178		error = bq32k_write(dev, &reg, BQ32K_TCH2, 1);
   179		if (error)
   180			return error;

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
