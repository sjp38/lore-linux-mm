Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C95DF6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 08:42:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 21so257077911pgg.4
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 05:42:13 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e39si3103252plg.21.2017.03.23.05.42.12
        for <linux-mm@kvack.org>;
        Thu, 23 Mar 2017 05:42:12 -0700 (PDT)
Date: Thu, 23 Mar 2017 12:41:54 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2] kasan: report only the first error by default
Message-ID: <20170323124154.GE9287@leverpostej>
References: <20170322160647.32032-1-aryabinin@virtuozzo.com>
 <20170323114916.29871-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170323114916.29871-1-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 23, 2017 at 02:49:16PM +0300, Andrey Ryabinin wrote:
> +	kasan_multi_shot
> +			[KNL] Enforce KASAN (Kernel Address Sanitizer) to print
> +			report on every invalid memory access. Without this
> +			parameter KASAN will print report only for the first
> +			invalid access.
> +

The option looks fine to me.

>  static int __init kmalloc_tests_init(void)
>  {
> +	/* Rise reports limit high enough to see all the following bugs */
> +	atomic_add(100, &kasan_report_count);

> +
> +	/*
> +	 * kasan is unreliable now, disable reports if
> +	 * we are in single shot mode
> +	 */
> +	atomic_sub(100, &kasan_report_count);
>  	return -EAGAIN;
>  }

... but these magic numbers look rather messy.

[...]

> +atomic_t kasan_report_count = ATOMIC_INIT(1);
> +EXPORT_SYMBOL_GPL(kasan_report_count);
> +
> +static int __init kasan_set_multi_shot(char *str)
> +{
> +	atomic_set(&kasan_report_count, 1000000000);
> +	return 1;
> +}
> +__setup("kasan_multi_shot", kasan_set_multi_shot);

... likewise.

Rather than trying to pick an arbitrarily large number, how about we use
separate flags to determine whether we're in multi-shot mode, and
whether a (oneshot) report has been made.

How about the below?

Thanks,
Mark.

---->8----
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index ceb3fe7..291d7b3 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -74,6 +74,9 @@ struct kasan_cache {
 static inline void kasan_unpoison_slab(const void *ptr) { ksize(ptr); }
 size_t kasan_metadata_size(struct kmem_cache *cache);
 
+bool kasan_save_enable_multi_shot(void);
+void kasan_restore_multi_shot(bool enabled);
+
 #else /* CONFIG_KASAN */
 
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 0b1d314..ae59dc2 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -12,6 +12,7 @@
 #define pr_fmt(fmt) "kasan test: %s " fmt, __func__
 
 #include <linux/delay.h>
+#include <linux/kasan.h>
 #include <linux/kernel.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
@@ -474,6 +475,12 @@ static noinline void __init use_after_scope_test(void)
 
 static int __init kmalloc_tests_init(void)
 {
+	/*
+	 * Temporarily enable multi-shot mode. Otherwise, we'd only get a
+	 * report for the first case.
+	 */
+	bool multishot = kasan_save_enable_multi_shot();
+
 	kmalloc_oob_right();
 	kmalloc_oob_left();
 	kmalloc_node_oob_right();
@@ -499,6 +506,9 @@ static int __init kmalloc_tests_init(void)
 	ksize_unpoisons_memory();
 	copy_user_test();
 	use_after_scope_test();
+
+	kasan_restore_multi_shot(multishot);
+
 	return -EAGAIN;
 }
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 1c260e6..dd2dea8 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -96,11 +96,6 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 		<< KASAN_SHADOW_SCALE_SHIFT);
 }
 
-static inline bool kasan_report_enabled(void)
-{
-	return !current->kasan_depth;
-}
-
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_double_free(struct kmem_cache *cache, void *object,
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index f479365..f1c5892 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -13,6 +13,7 @@
  *
  */
 
+#include <linux/bitops.h>
 #include <linux/ftrace.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
@@ -293,6 +294,40 @@ static void kasan_report_error(struct kasan_access_info *info)
 	kasan_end_report(&flags);
 }
 
+static unsigned long kasan_flags;
+
+#define KASAN_BIT_REPORTED	0
+#define KASAN_BIT_MULTI_SHOT	1
+
+bool kasan_save_enable_multi_shot(void)
+{
+	return test_and_set_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
+}
+EXPORT_SYMBOL_GPL(kasan_save_enable_multi_shot);
+
+void kasan_restore_multi_shot(bool enabled)
+{
+	if (!enabled)
+		clear_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
+}
+EXPORT_SYMBOL_GPL(kasan_restore_multi_shot);
+
+static int __init kasan_set_multi_shot(char *str)
+{
+	set_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags);
+	return 1;
+}
+__setup("kasan_multi_shot", kasan_set_multi_shot);
+
+static inline bool kasan_report_enabled(void)
+{
+	if (current->kasan_depth)
+		return false;
+	if (test_bit(KASAN_BIT_MULTI_SHOT, &kasan_flags))
+		return true;
+	return !test_and_set_bit(KASAN_BIT_REPORTED, &kasan_flags);
+}
+
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
