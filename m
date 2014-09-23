Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 652716B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 02:27:45 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so4064447pde.8
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 23:27:45 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id jd9si18791089pbd.114.2014.09.22.23.27.43
        for <linux-mm@kvack.org>;
        Mon, 22 Sep 2014 23:27:44 -0700 (PDT)
Date: Tue, 23 Sep 2014 14:26:40 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 262/385] drivers/rtc/rtc-bq32k.c:155:21: sparse:
 incorrect type in assignment (different base types)
Message-ID: <542112a0.F1EaJC3N9jNPLjHw%fengguang.wu@intel.com>
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
reproduce:
  # apt-get install sparse
  git checkout b44e93cb89b6c5b32fd625f30341bcf14991322d
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   drivers/rtc/rtc-bq32k.c:76:28: sparse: Variable length array is used.
>> drivers/rtc/rtc-bq32k.c:155:21: sparse: incorrect type in assignment (different base types)
   drivers/rtc/rtc-bq32k.c:155:21:    expected unsigned int const [usertype] *reg
   drivers/rtc/rtc-bq32k.c:155:21:    got int
>> drivers/rtc/rtc-bq32k.c:165:21: sparse: incorrect type in assignment (different base types)
   drivers/rtc/rtc-bq32k.c:165:21:    expected unsigned int const [usertype] *reg
   drivers/rtc/rtc-bq32k.c:165:21:    got int
>> drivers/rtc/rtc-bq32k.c:177:13: sparse: incorrect type in assignment (different base types)
   drivers/rtc/rtc-bq32k.c:177:13:    expected unsigned int const [usertype] *[addressable] reg
   drivers/rtc/rtc-bq32k.c:177:13:    got int
   drivers/rtc/rtc-bq32k.c: In function 'trickle_charger_of_init':
   drivers/rtc/rtc-bq32k.c:155:7: warning: assignment makes pointer from integer without a cast
      reg = 0x05;
          ^
   drivers/rtc/rtc-bq32k.c:165:7: warning: assignment makes pointer from integer without a cast
      reg = 0x25;
          ^
   drivers/rtc/rtc-bq32k.c:177:6: warning: assignment makes pointer from integer without a cast
     reg = 0x20;
         ^
   drivers/rtc/rtc-bq32k.c:135:6: warning: unused variable 'plen' [-Wunused-variable]
     int plen = 0;
         ^

vim +155 drivers/rtc/rtc-bq32k.c

    70		return -EIO;
    71	}
    72	
    73	static int bq32k_write(struct device *dev, void *data, uint8_t off, uint8_t len)
    74	{
    75		struct i2c_client *client = to_i2c_client(dev);
    76		uint8_t buffer[len + 1];
    77	
    78		buffer[0] = off;
    79		memcpy(&buffer[1], data, len);
    80	
    81		if (i2c_master_send(client, buffer, len + 1) == len + 1)
    82			return 0;
    83	
    84		return -EIO;
    85	}
    86	
    87	static int bq32k_rtc_read_time(struct device *dev, struct rtc_time *tm)
    88	{
    89		struct bq32k_regs regs;
    90		int error;
    91	
    92		error = bq32k_read(dev, &regs, 0, sizeof(regs));
    93		if (error)
    94			return error;
    95	
    96		tm->tm_sec = bcd2bin(regs.seconds & BQ32K_SECONDS_MASK);
    97		tm->tm_min = bcd2bin(regs.minutes & BQ32K_SECONDS_MASK);
    98		tm->tm_hour = bcd2bin(regs.cent_hours & BQ32K_HOURS_MASK);
    99		tm->tm_mday = bcd2bin(regs.date);
   100		tm->tm_wday = bcd2bin(regs.day) - 1;
   101		tm->tm_mon = bcd2bin(regs.month) - 1;
   102		tm->tm_year = bcd2bin(regs.years) +
   103					((regs.cent_hours & BQ32K_CENT) ? 100 : 0);
   104	
   105		return rtc_valid_tm(tm);
   106	}
   107	
   108	static int bq32k_rtc_set_time(struct device *dev, struct rtc_time *tm)
   109	{
   110		struct bq32k_regs regs;
   111	
   112		regs.seconds = bin2bcd(tm->tm_sec);
   113		regs.minutes = bin2bcd(tm->tm_min);
   114		regs.cent_hours = bin2bcd(tm->tm_hour) | BQ32K_CENT_EN;
   115		regs.day = bin2bcd(tm->tm_wday + 1);
   116		regs.date = bin2bcd(tm->tm_mday);
   117		regs.month = bin2bcd(tm->tm_mon + 1);
   118	
   119		if (tm->tm_year >= 100) {
   120			regs.cent_hours |= BQ32K_CENT;
   121			regs.years = bin2bcd(tm->tm_year - 100);
   122		} else
   123			regs.years = bin2bcd(tm->tm_year);
   124	
   125		return bq32k_write(dev, &regs, 0, sizeof(regs));
   126	}
   127	
   128	static const struct rtc_class_ops bq32k_rtc_ops = {
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
