Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 093676B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 23:08:09 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so2459962pdi.23
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 20:08:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fl10si8038498pab.132.2014.06.19.20.08.08
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 20:08:09 -0700 (PDT)
Date: Fri, 20 Jun 2014 11:07:18 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 141/230]
 drivers/staging/iio/impedance-analyzer/ad5933.c:437:335: warning:
 comparison of distinct pointer types lacks a cast
Message-ID: <53a3a566.b2b0fo3XpXtGxiw4%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hagen Paul Pfeifer <hagen@jauu.net>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   df25ba7db0775d87018e2cd92f26b9b087093840
commit: 99c369839f847d2cc4b8e759a9c57c925592efa2 [141/230] include/linux/kernel.h: rewrite min3, max3 and clamp using min and max
config: make ARCH=i386 allyesconfig

All warnings:

   drivers/staging/iio/impedance-analyzer/ad5933.c: In function 'ad5933_store':
>> drivers/staging/iio/impedance-analyzer/ad5933.c:437:335: warning: comparison of distinct pointer types lacks a cast [enabled by default]
      val = clamp(val, (u16)0, (u16)0x7FF);
                                                                                                                                                                                                                                                                                                                                                  ^
>> drivers/staging/iio/impedance-analyzer/ad5933.c:451:331: warning: comparison of distinct pointer types lacks a cast [enabled by default]
      val = clamp(val, (u16)0, (u16)511);
                                                                                                                                                                                                                                                                                                                                              ^
--
   drivers/net/wireless/rtlwifi/rtl8723ae/dm.c: In function 'rtl92c_dm_ctrl_initgain_by_fa':
>> drivers/net/wireless/rtlwifi/rtl8723ae/dm.c:269:368: warning: comparison of distinct pointer types lacks a cast [enabled by default]
     value_igi = clamp(value_igi, (u8)DM_DIG_FA_LOWER, (u8)DM_DIG_FA_UPPER);
                                                                                                                                                                                                                                                                                                                                                                                   ^
--
   drivers/net/ethernet/intel/i40e/i40e_debugfs.c: In function 'i40e_dbg_command_write':
>> drivers/net/ethernet/intel/i40e/i40e_debugfs.c:1901:355: warning: comparison of distinct pointer types lacks a cast [enabled by default]
      bytes = clamp(bytes, (u16)1024, (u16)I40E_MAX_AQ_BUF_SIZE);
                                                                                                                                                                                                                                                                                                                                                                      ^

vim +437 drivers/staging/iio/impedance-analyzer/ad5933.c

f94aa354 Michael Hennerich 2011-08-02  431  			ret = -EINVAL;
f94aa354 Michael Hennerich 2011-08-02  432  			break;
f94aa354 Michael Hennerich 2011-08-02  433  		}
f94aa354 Michael Hennerich 2011-08-02  434  		ret = ad5933_cmd(st, 0);
f94aa354 Michael Hennerich 2011-08-02  435  		break;
f94aa354 Michael Hennerich 2011-08-02  436  	case AD5933_OUT_SETTLING_CYCLES:
e5e26dd5 Jingoo Han        2013-08-20 @437  		val = clamp(val, (u16)0, (u16)0x7FF);
f94aa354 Michael Hennerich 2011-08-02  438  		st->settling_cycles = val;
f94aa354 Michael Hennerich 2011-08-02  439  
f94aa354 Michael Hennerich 2011-08-02  440  		/* 2x, 4x handling, see datasheet */
f94aa354 Michael Hennerich 2011-08-02  441  		if (val > 511)
f94aa354 Michael Hennerich 2011-08-02  442  			val = (val >> 1) | (1 << 9);
f94aa354 Michael Hennerich 2011-08-02  443  		else if (val > 1022)
f94aa354 Michael Hennerich 2011-08-02  444  			val = (val >> 2) | (3 << 9);
f94aa354 Michael Hennerich 2011-08-02  445  
f94aa354 Michael Hennerich 2011-08-02  446  		dat = cpu_to_be16(val);
f94aa354 Michael Hennerich 2011-08-02  447  		ret = ad5933_i2c_write(st->client,
f94aa354 Michael Hennerich 2011-08-02  448  				AD5933_REG_SETTLING_CYCLES, 2, (u8 *)&dat);
f94aa354 Michael Hennerich 2011-08-02  449  		break;
f94aa354 Michael Hennerich 2011-08-02  450  	case AD5933_FREQ_POINTS:
e5e26dd5 Jingoo Han        2013-08-20 @451  		val = clamp(val, (u16)0, (u16)511);
f94aa354 Michael Hennerich 2011-08-02  452  		st->freq_points = val;
f94aa354 Michael Hennerich 2011-08-02  453  
f94aa354 Michael Hennerich 2011-08-02  454  		dat = cpu_to_be16(val);

:::::: The code at line 437 was first introduced by commit
:::::: e5e26dd5bb740c34c975e2ae059126ba3486a1ce staging: iio: replace strict_strto*() with kstrto*()

:::::: TO: Jingoo Han <jg1.han@samsung.com>
:::::: CC: Jonathan Cameron <jic23@kernel.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
