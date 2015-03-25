Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 47A6B6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:25:26 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so24464348pad.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:25:26 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id an5si3011683pbd.208.2015.03.25.03.25.25
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 03:25:25 -0700 (PDT)
Date: Wed, 25 Mar 2015 18:25:01 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 6753/6952] drivers/hwmon/w83795.c:312:16: sparse:
 incorrect type in initializer (different modifiers)
Message-ID: <201503251859.Sj2lt6iy%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <bgolaszewski@baylibre.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   b2dfdab2f61ed5eb57317136d6efbb973f79210e
commit: f8e5b425f5eea40759a0ccc17caa7f4d660d0d4a [6753/6952] hwmon: (w83795) use find_closest_descending() in pwm_freq_to_reg()
reproduce:
  # apt-get install sparse
  git checkout f8e5b425f5eea40759a0ccc17caa7f4d660d0d4a
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/hwmon/w83795.c:312:16: sparse: incorrect type in initializer (different modifiers)
   drivers/hwmon/w83795.c:312:16:    expected unsigned short *__fc_a
   drivers/hwmon/w83795.c:312:16:    got unsigned short static const [toplevel] *<noident>

vim +312 drivers/hwmon/w83795.c

   296		unsigned long base_clock;
   297	
   298		if (reg & 0x80) {
   299			base_clock = clkin * 1000 / ((clkin == 48000) ? 384 : 256);
   300			return base_clock / ((reg & 0x7f) + 1);
   301		} else
   302			return pwm_freq_cksel0[reg & 0x0f];
   303	}
   304	
   305	static u8 pwm_freq_to_reg(unsigned long val, u16 clkin)
   306	{
   307		unsigned long base_clock;
   308		u8 reg0, reg1;
   309		unsigned long best0, best1;
   310	
   311		/* Best fit for cksel = 0 */
 > 312		reg0 = find_closest_descending(val, pwm_freq_cksel0,
   313					       ARRAY_SIZE(pwm_freq_cksel0));
   314		if (val < 375)	/* cksel = 1 can't beat this */
   315			return reg0;
   316		best0 = pwm_freq_cksel0[reg0];
   317	
   318		/* Best fit for cksel = 1 */
   319		base_clock = clkin * 1000 / ((clkin == 48000) ? 384 : 256);
   320		reg1 = clamp_val(DIV_ROUND_CLOSEST(base_clock, val), 1, 128);

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
