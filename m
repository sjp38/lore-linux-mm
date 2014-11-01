Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 310BA6B00A1
	for <linux-mm@kvack.org>; Sat,  1 Nov 2014 14:24:38 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so3547809wiv.8
        for <linux-mm@kvack.org>; Sat, 01 Nov 2014 11:24:37 -0700 (PDT)
Received: from sonata.ens-lyon.org (sonata.ens-lyon.org. [140.77.166.138])
        by mx.google.com with ESMTPS id ex10si2628879wic.4.2014.11.01.11.24.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Nov 2014 11:24:37 -0700 (PDT)
Date: Sat, 1 Nov 2014 19:24:30 +0100
From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: [PATCH] Merge input leds init/exit into input module init/exit
Message-ID: <20141101182430.GU2991@type.youpi.perso.aquilenet.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <543df5b4.3WRRc0wmhDhaCLQt%fengguang.wu@intel.com>
 <5431ee38.9Aay+jwGcRhCJyCA%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

Now that input/leds.c is compiled into the input.ko module in the mm
tree, its init and exit function must be called by input.ko's init and
exit functions, instead of duplicating the module init/exit hooks, which
leads to the following build error when input is built as a module:

leds.c:(.init.text+0x0): multiple definition of `init_module'
leds.c:(.exit.text+0x0): multiple definition of `cleanup_module'

This also adds a proper clean of the vt_led_work queues in the exit
function.

Signed-off-by: Samuel Thibault <samuel.thibault@ens-lyon.org>
---

This is a follow-up to the following reports:

Re: [next:master 9776/10302] leds.c:(.init.text+0x0): multiple definition of `init_module'
Re: [next:master 9391/10970] leds.c:(.exit.text+0x0): multiple definition of `cleanup_module'

and to be applied over the existing
input-route-kbd-leds-through-the-generic-leds-layer-fix-2
please.

Thanks!
Samuel

--- a/drivers/input/input.c
+++ b/drivers/input/input.c
@@ -2427,6 +2427,8 @@ static int __init input_init(void)
 		goto fail2;
 	}
 
+	input_led_init();
+
 	return 0;
 
  fail2:	input_proc_exit();
@@ -2436,6 +2438,7 @@ static int __init input_init(void)
 
 static void __exit input_exit(void)
 {
+	input_led_exit();
 	input_proc_exit();
 	unregister_chrdev_region(MKDEV(INPUT_MAJOR, 0),
 				 INPUT_MAX_CHAR_DEVICES);
--- a/drivers/input/leds.c
+++ b/drivers/input/leds.c
@@ -255,22 +255,18 @@ void input_led_disconnect(struct input_d
 	mutex_unlock(&vt_led_registered_lock);
 }
 
-static int __init input_led_init(void)
+void __init input_led_init(void)
 {
 	unsigned i;
 
 	for (i = 0; i < LED_CNT; i++)
 		INIT_WORK(&vt_led_work[i], vt_led_cb);
-
-	return 0;
 }
 
-static void __exit input_led_exit(void)
+void __exit input_led_exit(void)
 {
-}
+	unsigned i;
 
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("User LED support for input layer");
-MODULE_AUTHOR("Samuel Thibault <samuel.thibault@ens-lyon.org>");
-module_init(input_led_init);
-module_exit(input_led_exit);
+	for (i = 0; i < LED_CNT; i++)
+		cancel_work_sync(&vt_led_work[i]);
+}
--- a/include/linux/input.h
+++ b/include/linux/input.h
@@ -536,11 +536,18 @@ int input_ff_create_memless(struct input
 
 #ifdef CONFIG_INPUT_LEDS
 
+void input_led_init(void);
+void input_led_exit(void);
+
 int input_led_connect(struct input_dev *dev);
 void input_led_disconnect(struct input_dev *dev);
 
 #else
 
+static inline void input_led_init(void) { }
+
+static inline void input_led_exit(void) { }
+
 static inline int input_led_connect(struct input_dev *dev)
 {
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
