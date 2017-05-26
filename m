Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 921446B0292
	for <linux-mm@kvack.org>; Fri, 26 May 2017 05:54:30 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j83so5447029ioi.11
        for <linux-mm@kvack.org>; Fri, 26 May 2017 02:54:30 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id h72si284610ioi.188.2017.05.26.02.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 02:54:29 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id l145so963321ita.0
        for <linux-mm@kvack.org>; Fri, 26 May 2017 02:54:29 -0700 (PDT)
From: Daniel Micay <danielmicay@gmail.com>
Subject: [PATCH v4] add the option of fortified string.h functions
Date: Fri, 26 May 2017 05:54:04 -0400
Message-Id: <20170526095404.20439-1-danielmicay@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Daniel Axtens <dja@axtens.net>, Daniel Micay <danielmicay@gmail.com>

This adds support for compiling with a rough equivalent to the glibc
_FORTIFY_SOURCE=1 feature, providing compile-time and runtime buffer
overflow checks for string.h functions when the compiler determines the
size of the source or destination buffer at compile-time. Unlike glibc,
it covers buffer reads in addition to writes.

GNU C __builtin_*_chk intrinsics are avoided because they would force a
much more complex implementation. They aren't designed to detect read
overflows and offer no real benefit when using an implementation based
on inline checks. Inline checks don't add up to much code size and allow
full use of the regular string intrinsics while avoiding the need for a
bunch of _chk functions and per-arch assembly to avoid wrapper overhead.

This detects various overflows at compile-time in various drivers and
some non-x86 core kernel code. There will likely be issues caught in
regular use at runtime too.

Future improvements left out of initial implementation for simplicity,
as it's all quite optional and can be done incrementally:

* Some of the fortified string functions (strncpy, strcat), don't yet
  place a limit on reads from the source based on __builtin_object_size of
  the source buffer.

* Extending coverage to more string functions like strlcat.

* It should be possible to optionally use __builtin_object_size(x, 1) for
  some functions (C strings) to detect intra-object overflows (like
  glibc's _FORTIFY_SOURCE=2), but for now this takes the conservative
  approach to avoid likely compatibility issues.

* The compile-time checks should be made available via a separate config
  option which can be enabled by default (or always enabled) once enough
  time has passed to get the issues it catches fixed.

Signed-off-by: Daniel Micay <danielmicay@gmail.com>
---
Changes since v3:
- Worked around conflicts with x86 string function defines, which were mostly
  legacy optimizations not relevant to current GCC. At some point these headers
  could be stripped down to drop all these hacks not needed with GCC from the
  past 6+ years.

 arch/arm64/include/asm/string.h  |   5 +
 arch/x86/boot/compressed/misc.c  |   5 +
 arch/x86/include/asm/string_32.h |   9 ++
 arch/x86/include/asm/string_64.h |   7 ++
 include/linux/string.h           | 200 +++++++++++++++++++++++++++++++++++++++
 lib/string.c                     |   6 ++
 security/Kconfig                 |   6 ++
 7 files changed, 238 insertions(+)

diff --git a/arch/arm64/include/asm/string.h b/arch/arm64/include/asm/string.h
index 2eb714c4639f..d0aa42907569 100644
--- a/arch/arm64/include/asm/string.h
+++ b/arch/arm64/include/asm/string.h
@@ -63,6 +63,11 @@ extern int memcmp(const void *, const void *, size_t);
 #define memcpy(dst, src, len) __memcpy(dst, src, len)
 #define memmove(dst, src, len) __memmove(dst, src, len)
 #define memset(s, c, n) __memset(s, c, n)
+
+#ifndef __NO_FORTIFY
+#define __NO_FORTIFY /* FORTIFY_SOURCE uses __builtin_memcpy, etc. */
+#endif
+
 #endif
 
 #endif
diff --git a/arch/x86/boot/compressed/misc.c b/arch/x86/boot/compressed/misc.c
index b3c5a5f030ce..43691238a21d 100644
--- a/arch/x86/boot/compressed/misc.c
+++ b/arch/x86/boot/compressed/misc.c
@@ -409,3 +409,8 @@ asmlinkage __visible void *extract_kernel(void *rmode, memptr heap,
 	debug_putstr("done.\nBooting the kernel.\n");
 	return output;
 }
+
+void fortify_panic(const char *name)
+{
+	error("detected buffer overflow");
+}
diff --git a/arch/x86/include/asm/string_32.h b/arch/x86/include/asm/string_32.h
index 3d3e8353ee5c..e9ee84873de5 100644
--- a/arch/x86/include/asm/string_32.h
+++ b/arch/x86/include/asm/string_32.h
@@ -142,7 +142,9 @@ static __always_inline void *__constant_memcpy(void *to, const void *from,
 }
 
 #define __HAVE_ARCH_MEMCPY
+extern void *memcpy(void *, const void *, size_t);
 
+#ifndef CONFIG_FORTIFY_SOURCE
 #ifdef CONFIG_X86_USE_3DNOW
 
 #include <asm/mmx.h>
@@ -195,11 +197,15 @@ static inline void *__memcpy3d(void *to, const void *from, size_t len)
 #endif
 
 #endif
+#endif /* !CONFIG_FORTIFY_SOURCE */
 
 #define __HAVE_ARCH_MEMMOVE
 void *memmove(void *dest, const void *src, size_t n);
 
+extern int memcmp(const void *, const void *, size_t);
+#ifndef CONFIG_FORTIFY_SOURCE
 #define memcmp __builtin_memcmp
+#endif
 
 #define __HAVE_ARCH_MEMCHR
 extern void *memchr(const void *cs, int c, size_t count);
@@ -321,6 +327,8 @@ void *__constant_c_and_count_memset(void *s, unsigned long pattern,
 	 : __memset_generic((s), (c), (count)))
 
 #define __HAVE_ARCH_MEMSET
+extern void *memset(void *, int, size_t);
+#ifndef CONFIG_FORTIFY_SOURCE
 #if (__GNUC__ >= 4)
 #define memset(s, c, count) __builtin_memset(s, c, count)
 #else
@@ -330,6 +338,7 @@ void *__constant_c_and_count_memset(void *s, unsigned long pattern,
 				 (count))				\
 	 : __memset((s), (c), (count)))
 #endif
+#endif /* !CONFIG_FORTIFY_SOURCE */
 
 /*
  * find the first occurrence of byte 'c', or 1 past the area if none
diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
index 733bae07fb29..309fe644569f 100644
--- a/arch/x86/include/asm/string_64.h
+++ b/arch/x86/include/asm/string_64.h
@@ -31,6 +31,7 @@ static __always_inline void *__inline_memcpy(void *to, const void *from, size_t
 extern void *memcpy(void *to, const void *from, size_t len);
 extern void *__memcpy(void *to, const void *from, size_t len);
 
+#ifndef CONFIG_FORTIFY_SOURCE
 #ifndef CONFIG_KMEMCHECK
 #if (__GNUC__ == 4 && __GNUC_MINOR__ < 3) || __GNUC__ < 4
 #define memcpy(dst, src, len)					\
@@ -51,6 +52,7 @@ extern void *__memcpy(void *to, const void *from, size_t len);
  */
 #define memcpy(dst, src, len) __inline_memcpy((dst), (src), (len))
 #endif
+#endif /* !CONFIG_FORTIFY_SOURCE */
 
 #define __HAVE_ARCH_MEMSET
 void *memset(void *s, int c, size_t n);
@@ -77,6 +79,11 @@ int strcmp(const char *cs, const char *ct);
 #define memcpy(dst, src, len) __memcpy(dst, src, len)
 #define memmove(dst, src, len) __memmove(dst, src, len)
 #define memset(s, c, n) __memset(s, c, n)
+
+#ifndef __NO_FORTIFY
+#define __NO_FORTIFY /* FORTIFY_SOURCE uses __builtin_memcpy, etc. */
+#endif
+
 #endif
 
 #define __HAVE_ARCH_MEMCPY_MCSAFE 1
diff --git a/include/linux/string.h b/include/linux/string.h
index 537918f8a98e..66dc841e4c5e 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -187,4 +187,204 @@ static inline const char *kbasename(const char *path)
 	return tail ? tail + 1 : path;
 }
 
+#define __FORTIFY_INLINE extern __always_inline __attribute__((gnu_inline))
+#define __RENAME(x) __asm__(#x)
+
+void fortify_panic(const char *name) __noreturn __cold;
+void __read_overflow(void) __compiletime_error("detected read beyond size of object passed as 1st parameter");
+void __read_overflow2(void) __compiletime_error("detected read beyond size of object passed as 2nd parameter");
+void __write_overflow(void) __compiletime_error("detected write beyond size of object passed as 1st parameter");
+
+#if !defined(__NO_FORTIFY) && defined(__OPTIMIZE__) && defined(CONFIG_FORTIFY_SOURCE)
+__FORTIFY_INLINE char *strcpy(char *p, const char *q)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	size_t q_size = __builtin_object_size(q, 0);
+	if (p_size == (size_t)-1 && q_size == (size_t)-1)
+		return __builtin_strcpy(p, q);
+	if (strscpy(p, q, p_size < q_size ? p_size : q_size) < 0)
+		fortify_panic(__func__);
+	return p;
+}
+
+__FORTIFY_INLINE char *strncpy(char *p, const char *q, __kernel_size_t size)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	if (__builtin_constant_p(size) && p_size < size)
+		__write_overflow();
+	if (p_size < size)
+		fortify_panic(__func__);
+	return __builtin_strncpy(p, q, size);
+}
+
+__FORTIFY_INLINE char *strcat(char *p, const char *q)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	if (p_size == (size_t)-1)
+		return __builtin_strcat(p, q);
+	if (strlcat(p, q, p_size) >= p_size)
+		fortify_panic(__func__);
+	return p;
+}
+
+__FORTIFY_INLINE __kernel_size_t strlen(const char *p)
+{
+	__kernel_size_t ret;
+	size_t p_size = __builtin_object_size(p, 0);
+	if (p_size == (size_t)-1)
+		return __builtin_strlen(p);
+	ret = strnlen(p, p_size);
+	if (p_size <= ret)
+		fortify_panic(__func__);
+	return ret;
+}
+
+extern __kernel_size_t __real_strnlen(const char *, __kernel_size_t) __RENAME(strnlen);
+__FORTIFY_INLINE __kernel_size_t strnlen(const char *p, __kernel_size_t maxlen)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	__kernel_size_t ret = __real_strnlen(p, maxlen < p_size ? maxlen : p_size);
+	if (p_size <= ret)
+		fortify_panic(__func__);
+	return ret;
+}
+
+/* defined after fortified strlen to reuse it */
+extern size_t __real_strlcpy(char *, const char *, size_t) __RENAME(strlcpy);
+__FORTIFY_INLINE size_t strlcpy(char *p, const char *q, size_t size)
+{
+	size_t ret;
+	size_t p_size = __builtin_object_size(p, 0);
+	size_t q_size = __builtin_object_size(q, 0);
+	if (p_size == (size_t)-1 && q_size == (size_t)-1)
+		return __real_strlcpy(p, q, size);
+	ret = strlen(q);
+	if (size) {
+		size_t len = (ret >= size) ? size - 1 : ret;
+		if (__builtin_constant_p(len) && len >= p_size)
+			__write_overflow();
+		if (len >= p_size)
+			fortify_panic(__func__);
+		__builtin_memcpy(p, q, len);
+		p[len] = '\0';
+	}
+	return ret;
+}
+
+/* defined after fortified strlen and strnlen to reuse them */
+__FORTIFY_INLINE char *strncat(char *p, const char *q, __kernel_size_t count)
+{
+	size_t p_len, copy_len;
+	size_t p_size = __builtin_object_size(p, 0);
+	size_t q_size = __builtin_object_size(q, 0);
+	if (p_size == (size_t)-1 && q_size == (size_t)-1)
+		return __builtin_strncat(p, q, count);
+	p_len = strlen(p);
+	copy_len = strnlen(q, count);
+	if (p_size < p_len + copy_len + 1)
+		fortify_panic(__func__);
+	__builtin_memcpy(p + p_len, q, copy_len);
+	p[p_len + copy_len] = '\0';
+	return p;
+}
+
+__FORTIFY_INLINE void *memset(void *p, int c, __kernel_size_t size)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	if (__builtin_constant_p(size) && p_size < size)
+		__write_overflow();
+	if (p_size < size)
+		fortify_panic(__func__);
+	return __builtin_memset(p, c, size);
+}
+
+__FORTIFY_INLINE void *memcpy(void *p, const void *q, __kernel_size_t size)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	size_t q_size = __builtin_object_size(q, 0);
+	if (__builtin_constant_p(size)) {
+		if (p_size < size)
+			__write_overflow();
+		if (q_size < size)
+			__read_overflow2();
+	}
+	if (p_size < size || q_size < size)
+		fortify_panic(__func__);
+	return __builtin_memcpy(p, q, size);
+}
+
+__FORTIFY_INLINE void *memmove(void *p, const void *q, __kernel_size_t size)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	size_t q_size = __builtin_object_size(q, 0);
+	if (__builtin_constant_p(size)) {
+		if (p_size < size)
+			__write_overflow();
+		if (q_size < size)
+			__read_overflow2();
+	}
+	if (p_size < size || q_size < size)
+		fortify_panic(__func__);
+	return __builtin_memmove(p, q, size);
+}
+
+extern void *__real_memscan(void *, int, __kernel_size_t) __RENAME(memscan);
+__FORTIFY_INLINE void *memscan(void *p, int c, __kernel_size_t size)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	if (__builtin_constant_p(size) && p_size < size)
+		__read_overflow();
+	if (p_size < size)
+		fortify_panic(__func__);
+	return __real_memscan(p, c, size);
+}
+
+__FORTIFY_INLINE int memcmp(const void *p, const void *q, __kernel_size_t size)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	size_t q_size = __builtin_object_size(q, 0);
+	if (__builtin_constant_p(size)) {
+		if (p_size < size)
+			__read_overflow();
+		if (q_size < size)
+			__read_overflow2();
+	}
+	if (p_size < size || q_size < size)
+		fortify_panic(__func__);
+	return __builtin_memcmp(p, q, size);
+}
+
+__FORTIFY_INLINE void *memchr(const void *p, int c, __kernel_size_t size)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	if (__builtin_constant_p(size) && p_size < size)
+		__read_overflow();
+	if (p_size < size)
+		fortify_panic(__func__);
+	return __builtin_memchr(p, c, size);
+}
+
+void *__real_memchr_inv(const void *s, int c, size_t n) __RENAME(memchr_inv);
+__FORTIFY_INLINE void *memchr_inv(const void *p, int c, size_t size)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	if (__builtin_constant_p(size) && p_size < size)
+		__read_overflow();
+	if (p_size < size)
+		fortify_panic(__func__);
+	return __real_memchr_inv(p, c, size);
+}
+
+extern void *__real_kmemdup(const void *src, size_t len, gfp_t gfp) __RENAME(kmemdup);
+__FORTIFY_INLINE void *kmemdup(const void *p, size_t size, gfp_t gfp)
+{
+	size_t p_size = __builtin_object_size(p, 0);
+	if (__builtin_constant_p(size) && p_size < size)
+		__read_overflow();
+	if (p_size < size)
+		fortify_panic(__func__);
+	return __real_kmemdup(p, size, gfp);
+}
+#endif
+
 #endif /* _LINUX_STRING_H_ */
diff --git a/lib/string.c b/lib/string.c
index 1c1fc9187b05..a6ee1955a701 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -978,3 +978,9 @@ char *strreplace(char *s, char old, char new)
 	return s;
 }
 EXPORT_SYMBOL(strreplace);
+
+void fortify_panic(const char *name)
+{
+	panic("detected buffer overflow in %s", name);
+}
+EXPORT_SYMBOL(fortify_panic);
diff --git a/security/Kconfig b/security/Kconfig
index 93027fdf47d1..0e5035d720ce 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -154,6 +154,12 @@ config HARDENED_USERCOPY_PAGESPAN
 	  been removed. This config is intended to be used only while
 	  trying to find such users.
 
+config FORTIFY_SOURCE
+	bool "Harden common functions against buffer overflows"
+	help
+	  Detect overflows of buffers in common functions where the compiler
+	  can determine the buffer size.
+
 config STATIC_USERMODEHELPER
 	bool "Force all usermode helper calls through a single binary"
 	help
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
