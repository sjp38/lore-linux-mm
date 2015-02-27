Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id DF41D6B006E
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 10:29:04 -0500 (EST)
Received: by wesw55 with SMTP id w55so21058041wes.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 07:29:04 -0800 (PST)
Received: from saturn.retrosnub.co.uk (saturn.retrosnub.co.uk. [178.18.118.26])
        by mx.google.com with ESMTPS id ls2si7776085wjb.132.2015.02.27.07.29.02
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 07:29:03 -0800 (PST)
In-Reply-To: <2111473.jxZaFqNM44@wuerfel>
References: <201502261516.PXhQgKP2%fengguang.wu@intel.com> <20150226124432.2220a6bfd14cc9ce154f8a62@linux-foundation.org> <2111473.jxZaFqNM44@wuerfel>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="----K9CGBQPD4XEIS52WLG1LY1SGRWIT1N"
Content-Transfer-Encoding: 8bit
Subject: Re: [mmotm:master 7/197] ak8975.c:undefined reference to `i2c_smbus_write_byte_data'
From: Jonathan Cameron <jic23@jic23.retrosnub.co.uk>
Date: Fri, 27 Feb 2015 15:28:54 +0000
Message-ID: <AF0F75E9-1E18-4788-A266-5C6386423298@jic23.retrosnub.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Cameron <jic23@kernel.org>

------K9CGBQPD4XEIS52WLG1LY1SGRWIT1N
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8

Sorry all. Been travelling (stuck in a clean room with no internet...) Should get a pull
 out sometime tomorrow.



On 26 February 2015 21:23:02 GMT+00:00, Arnd Bergmann <arnd@arndb.de> wrote:
>On Thursday 26 February 2015 12:44:32 Andrew Morton wrote:
>> On Thu, 26 Feb 2015 15:36:18 +0800 kbuild test robot
><fengguang.wu@intel.com> wrote:
>> 
>> > It's probably a bug fix that unveils the link errors.
>> > 
>> > tree:   git://git.cmpxchg.org/linux-mmotm.git master
>> > head:   87bf5bee8749a1d3c82d12a55a1e33f6a22da8ed
>> > commit: 7d789876f1a932dfa1a70ae8eeba270aa34358ad [7/197] rtc:
>ds1685: fix ds1685_rtc_alarm_irq_enable build error
>> > config: i386-randconfig-nexr0-0226 (attached as .config)
>> > reproduce:
>> >   git checkout 7d789876f1a932dfa1a70ae8eeba270aa34358ad
>> >   # save the attached .config to linux build tree
>> >   make ARCH=i386 
>> > 
>> > All error/warnings:
>> > 
>> >    drivers/built-in.o: In function `ak8975_set_mode':
>> > >> ak8975.c:(.text+0x16c108): undefined reference to
>`i2c_smbus_write_byte_data'
>> >    drivers/built-in.o: In function `ak8975_probe':
>> > >> ak8975.c:(.text+0x16c29b): undefined reference to
>`i2c_smbus_read_i2c_block_data'
>> > >> ak8975.c:(.text+0x16c348): undefined reference to
>`i2c_smbus_read_i2c_block_data'
>> >    drivers/built-in.o: In function `ak8975_read_raw':
>> > >> ak8975.c:(.text+0x16c66b): undefined reference to
>`i2c_smbus_read_byte_data'
>> > >> ak8975.c:(.text+0x16c6a2): undefined reference to
>`i2c_smbus_read_byte_data'
>> > >> ak8975.c:(.text+0x16c6c6): undefined reference to
>`i2c_smbus_read_byte_data'
>> > >> ak8975.c:(.text+0x16c751): undefined reference to
>`i2c_smbus_read_word_data'
>> >    drivers/built-in.o: In function `ak8975_driver_init':
>> > >> ak8975.c:(.init.text+0x10e35): undefined reference to
>`i2c_register_driver'
>> >    drivers/built-in.o: In function `ak8975_driver_exit':
>> > >> ak8975.c:(.exit.text+0x1841): undefined reference to
>`i2c_del_driver'
>> 
>> Yes, something seems to have gone spectacularly wrong here.  "rtc:
>> ds1685: fix ds1685_rtc_alarm_irq_enable build error" has nothing to
>do
>> with i2c or with drivers/iio/magnetometer/ak8975.c.
>> 
>> And CONFIG_AK8975 depends on CONFIG_I2C.
>
>I've also submitted a patch for this bug:
>
>From 84f1bf2e4c22183a61c04dfa2cead4a91665c920 Mon Sep 17 00:00:00 2001
>From: Arnd Bergmann <arnd@arndb.de>
>Date: Tue, 27 Jan 2015 22:08:47 +0100
>Subject: [PATCH] iio: ak8975: fix AK09911 dependencies
>
>ak8975 depends on I2C and GPIOLIB, so any symbols that selects
>ak8975 must have the same dependency, or we get build errors:
>
>drivers/iio/magnetometer/ak8975.c: In function 'ak8975_who_i_am':
>drivers/iio/magnetometer/ak8975.c:393:2: error: implicit declaration of
>function 'i2c_smbus_read_i2c_block_data'
>[-Werror=implicit-function-declaration]
>  ret = i2c_smbus_read_i2c_block_data(client, AK09912_REG_WIA1,
>  ^
>drivers/iio/magnetometer/ak8975.c: In function 'ak8975_set_mode':
>drivers/iio/magnetometer/ak8975.c:431:2: error: implicit declaration of
>function 'i2c_smbus_write_byte_data'
>[-Werror=implicit-function-declaration]
>  ret = i2c_smbus_write_byte_data(data->client,
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>Fixes: 57e73a423b1e85 ("iio: ak8975: add ak09911 and ak09912 support")
>
>diff --git a/drivers/iio/magnetometer/Kconfig
>b/drivers/iio/magnetometer/Kconfig
>index 4c7a4c52dd06..a5d6de72c523 100644
>--- a/drivers/iio/magnetometer/Kconfig
>+++ b/drivers/iio/magnetometer/Kconfig
>@@ -18,6 +18,8 @@ config AK8975
> 
> config AK09911
> 	tristate "Asahi Kasei AK09911 3-axis Compass"
>+	depends on I2C
>+	depends on GPIOLIB
> 	select AK8975
> 	help
> 	  Deprecated: AK09911 is now supported by AK8975 driver.
>
>
>http://lists.infradead.org/pipermail/linux-arm-kernel/2015-January/320527.html
>
>Randy submitted the same patch:
>https://lkml.org/lkml/2015/2/4/570
>
>Jonathan said he'd take care of it, but so far has not applied either
>version.
>
>	Arnd

-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.
------K9CGBQPD4XEIS52WLG1LY1SGRWIT1N
Content-Type: text/html;
 charset=utf-8
Content-Transfer-Encoding: 8bit

<html><head></head><body>Sorry all. Been travelling (stuck in a clean room with no internet...) Should get a pull<br>
 out sometime tomorrow.<br>
<br>
<br><br><div class="gmail_quote">On 26 February 2015 21:23:02 GMT+00:00, Arnd Bergmann &lt;arnd@arndb.de&gt; wrote:<blockquote class="gmail_quote" style="margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<pre class="k9mail">On Thursday 26 February 2015 12:44:32 Andrew Morton wrote:<br /><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #729fcf; padding-left: 1ex;"> On Thu, 26 Feb 2015 15:36:18 +0800 kbuild test robot &lt;fengguang.wu@intel.com&gt; wrote:<br /> <br /><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #ad7fa8; padding-left: 1ex;"> It's probably a bug fix that unveils the link errors.<br /> <br /> tree:   git://<a href="http://git.cmpxchg.org/linux-mmotm.git">git.cmpxchg.org/linux-mmotm.git</a> master<br /> head:   87bf5bee8749a1d3c82d12a55a1e33f6a22da8ed<br /> commit: 7d789876f1a932dfa1a70ae8eeba270aa34358ad [7/197] rtc: ds1685: fix ds1685_rtc_alarm_irq_enable build error<br /> config: i386-randconfig-nexr0-0226 (attached as .config)<br /> reproduce:<br />   git checkout 7d789876f1a932dfa1a70ae8eeba270aa34358ad<br />   # save the attached .config to linux build tree<br />   make ARCH=i386 <br
/> <br /> All error/warnings:<br /> <br />    drivers/built-in.o: In function `ak8975_set_mode':<br /><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #8ae234; padding-left: 1ex;"><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #fcaf3e; padding-left: 1ex;"> ak8975.c:(.text+0x16c108): undefined reference to `i2c_smbus_write_byte_data'<br /></blockquote></blockquote>    drivers/built-in.o: In function `ak8975_probe':<br /><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #8ae234; padding-left: 1ex;"><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #fcaf3e; padding-left: 1ex;"> ak8975.c:(.text+0x16c29b): undefined reference to `i2c_smbus_read_i2c_block_data'<br /> ak8975.c:(.text+0x16c348): undefined reference to `i2c_smbus_read_i2c_block_data'<br /></blockquote></blockquote>    drivers/built-in.o: In function
`ak8975_read_raw':<br /><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #8ae234; padding-left: 1ex;"><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #fcaf3e; padding-left: 1ex;"> ak8975.c:(.text+0x16c66b): undefined reference to `i2c_smbus_read_byte_data'<br /> ak8975.c:(.text+0x16c6a2): undefined reference to `i2c_smbus_read_byte_data'<br /> ak8975.c:(.text+0x16c6c6): undefined reference to `i2c_smbus_read_byte_data'<br /> ak8975.c:(.text+0x16c751): undefined reference to `i2c_smbus_read_word_data'<br /></blockquote></blockquote>    drivers/built-in.o: In function `ak8975_driver_init':<br /><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #8ae234; padding-left: 1ex;"><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #fcaf3e; padding-left: 1ex;"> ak8975.c:(.init.text+0x10e35): undefined reference to `i2c_register_driver'<br
/></blockquote></blockquote>    drivers/built-in.o: In function `ak8975_driver_exit':<br /><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #8ae234; padding-left: 1ex;"><blockquote class="gmail_quote" style="margin: 0pt 0pt 1ex 0.8ex; border-left: 1px solid #fcaf3e; padding-left: 1ex;"> ak8975.c:(.exit.text+0x1841): undefined reference to `i2c_del_driver'<br /></blockquote></blockquote></blockquote> <br /> Yes, something seems to have gone spectacularly wrong here.  "rtc:<br /> ds1685: fix ds1685_rtc_alarm_irq_enable build error" has nothing to do<br /> with i2c or with drivers/iio/magnetometer/ak8975.c.<br /> <br /> And CONFIG_AK8975 depends on CONFIG_I2C.<br /></blockquote><br />I've also submitted a patch for this bug:<br /><br />From 84f1bf2e4c22183a61c04dfa2cead4a91665c920 Mon Sep 17 00:00:00 2001<br />From: Arnd Bergmann &lt;arnd@arndb.de&gt;<br />Date: Tue, 27 Jan 2015 22:08:47 +0100<br />Subject: [PATCH] iio: ak8975: fix AK09911
dependencies<br /><br />ak8975 depends on I2C and GPIOLIB, so any symbols that selects<br />ak8975 must have the same dependency, or we get build errors:<br /><br />drivers/iio/magnetometer/ak8975.c: In function 'ak8975_who_i_am':<br />drivers/iio/magnetometer/ak8975.c:393:2: error: implicit declaration of function 'i2c_smbus_read_i2c_block_data' [-Werror=implicit-function-declaration]<br />  ret = i2c_smbus_read_i2c_block_data(client, AK09912_REG_WIA1,<br />  ^<br />drivers/iio/magnetometer/ak8975.c: In function 'ak8975_set_mode':<br />drivers/iio/magnetometer/ak8975.c:431:2: error: implicit declaration of function 'i2c_smbus_write_byte_data' [-Werror=implicit-function-declaration]<br />  ret = i2c_smbus_write_byte_data(data-&gt;client,<br /><br />Signed-off-by: Arnd Bergmann &lt;arnd@arndb.de&gt;<br />Fixes: 57e73a423b1e85 ("iio: ak8975: add ak09911 and ak09912 support")<br /><br />diff --git a/drivers/iio/magnetometer/Kconfig b/drivers/iio/magnetometer/Kconfig<br />index
4c7a4c52dd06..a5d6de72c523 100644<br />--- a/drivers/iio/magnetometer/Kconfig<br />+++ b/drivers/iio/magnetometer/Kconfig<br />@@ -18,6 +18,8 @@ config AK8975<br /> <br /> config AK09911<br />  tristate "Asahi Kasei AK09911 3-axis Compass"<br />+ depends on I2C<br />+ depends on GPIOLIB<br />  select AK8975<br />  help<br />    Deprecated: AK09911 is now supported by AK8975 driver.<br /><br /><br /><a href="http://lists.infradead.org/pipermail/linux-arm-kernel/2015-January/320527.html">http://lists.infradead.org/pipermail/linux-arm-kernel/2015-January/320527.html</a><br /><br />Randy submitted the same patch:<br /><a href="https://lkml.org/lkml/2015/2/4/570">https://lkml.org/lkml/2015/2/4/570</a><br /><br />Jonathan said he'd take care of it, but so far has not applied either version.<br /><br /> Arnd<br /></pre></blockquote></div><br>
-- <br>
Sent from my Android device with K-9 Mail. Please excuse my brevity.</body></html>
------K9CGBQPD4XEIS52WLG1LY1SGRWIT1N--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
