Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CFC7A6B003A
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 17:01:11 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so6348963pac.3
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:01:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id md3si22844172pdb.135.2014.09.23.14.01.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 14:01:10 -0700 (PDT)
Date: Tue, 23 Sep 2014 14:01:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 7267/7446] drivers/rtc/rtc-bq32k.c:169:3: warning:
 'setup' may be used uninitialized in this function
Message-Id: <20140923140109.d1e81b714082e562b7fb3e2c@linux-foundation.org>
In-Reply-To: <542131f8.FeDGKH/9671AZbCt%fengguang.wu@intel.com>
References: <542131f8.FeDGKH/9671AZbCt%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Tue, 23 Sep 2014 16:40:24 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   55f21306900abf9f9d2a087a127ff49c6d388ad2
> commit: 7bb72683b1708c3cf3bea0575c0e80314a2232dc [7267/7446] rtc: bq32000: add trickle charger option, with device tree binding
> config: i386-randconfig-ib0-09231629 (attached as .config)
> reproduce:
>   git checkout 7bb72683b1708c3cf3bea0575c0e80314a2232dc
>   # save the attached .config to linux build tree
>   make ARCH=i386 
> 
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> 
> All warnings:
> 
>    drivers/rtc/rtc-bq32k.c: In function 'trickle_charger_of_init':
>    drivers/rtc/rtc-bq32k.c:155:7: warning: assignment makes pointer from integer without a cast
>       reg = 0x05;
>           ^
>    drivers/rtc/rtc-bq32k.c:165:7: warning: assignment makes pointer from integer without a cast
>       reg = 0x25;
>           ^
>    drivers/rtc/rtc-bq32k.c:177:6: warning: assignment makes pointer from integer without a cast
>      reg = 0x20;
>          ^
>    drivers/rtc/rtc-bq32k.c:135:6: warning: unused variable 'plen' [-Wunused-variable]
>      int plen = 0;
>          ^
>    drivers/rtc/rtc-bq32k.c: In function 'bq32k_probe':
> >> drivers/rtc/rtc-bq32k.c:169:3: warning: 'setup' may be used uninitialized in this function [-Wmaybe-uninitialized]
>       dev_err(dev, "invalid resistor value (%d)\n", *setup);
>       ^
>    drivers/rtc/rtc-bq32k.c:136:18: note: 'setup' was declared here
>      const uint32_t *setup;

Pavel's changelog failed to tell us what warnings were being fixed
(bad!) but I expect the below will fix this.

From: Pavel Machek <pavel@ucw.cz>
Subject: drivers/rtc/rtc-bq32k.c fix warnings I introduced

Sorry about that, I somehow failed to notice rather severe warnings.

Signed-off-by: Pavel Machek <pavel@denx.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/rtc/rtc-bq32k.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -puN drivers/rtc/rtc-bq32k.c~rtc-bq32000-add-trickle-charger-option-with-device-tree-binding-fix drivers/rtc/rtc-bq32k.c
--- a/drivers/rtc/rtc-bq32k.c~rtc-bq32000-add-trickle-charger-option-with-device-tree-binding-fix
+++ a/drivers/rtc/rtc-bq32k.c
@@ -132,9 +132,7 @@ static const struct rtc_class_ops bq32k_
 
 static int trickle_charger_of_init(struct device *dev, struct device_node *node)
 {
-	int plen = 0;
-	const uint32_t *setup;
-	const uint32_t *reg;
+	unsigned char reg;
 	int error;
 	u32 ohms = 0;
 
@@ -166,7 +164,7 @@ static int trickle_charger_of_init(struc
 		break;
 
 	default:
-		dev_err(dev, "invalid resistor value (%d)\n", *setup);
+		dev_err(dev, "invalid resistor value (%d)\n", ohms);
 		return -EINVAL;
 	}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
