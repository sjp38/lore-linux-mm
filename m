Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB8F6B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:50:53 -0400 (EDT)
Received: by widdi4 with SMTP id di4so211776236wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:50:53 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id m1si8701633wjy.52.2015.05.06.10.50.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 10:50:49 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 6 May 2015 18:50:48 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id A439517D805F
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:51:30 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46HojDe33095780
	for <linux-mm@kvack.org>; Wed, 6 May 2015 17:50:45 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46Hoiuk027496
	for <linux-mm@kvack.org>; Wed, 6 May 2015 11:50:45 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH RFC 03/15] uaccess: clarify that uaccess may only sleep if pagefaults are enabled
Date: Wed,  6 May 2015 19:50:27 +0200
Message-Id: <1430934639-2131-4-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: dahi@linux.vnet.ibm.com, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

In general, non-atomic variants of user access functions must not sleep
if pagefaults are disabled.

Let's update all relevant comments in uaccess code. This also reflects
the might_sleep() checks in might_fault().

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/avr32/include/asm/uaccess.h      | 12 ++++++----
 arch/hexagon/include/asm/uaccess.h    |  3 ++-
 arch/m32r/include/asm/uaccess.h       | 30 +++++++++++++++--------
 arch/microblaze/include/asm/uaccess.h |  6 +++--
 arch/mips/include/asm/uaccess.h       | 45 +++++++++++++++++++++++------------
 arch/s390/include/asm/uaccess.h       | 15 ++++++++----
 arch/score/include/asm/uaccess.h      | 15 ++++++++----
 arch/tile/include/asm/uaccess.h       | 18 +++++++++-----
 arch/x86/include/asm/uaccess.h        | 15 ++++++++----
 arch/x86/include/asm/uaccess_32.h     |  6 +++--
 arch/x86/lib/usercopy_32.c            |  6 +++--
 lib/strnlen_user.c                    |  6 +++--
 12 files changed, 118 insertions(+), 59 deletions(-)

diff --git a/arch/avr32/include/asm/uaccess.h b/arch/avr32/include/asm/uaccess.h
index a46f7cf..68cf638 100644
--- a/arch/avr32/include/asm/uaccess.h
+++ b/arch/avr32/include/asm/uaccess.h
@@ -97,7 +97,8 @@ static inline __kernel_size_t __copy_from_user(void *to,
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -116,7 +117,8 @@ static inline __kernel_size_t __copy_from_user(void *to,
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -136,7 +138,8 @@ static inline __kernel_size_t __copy_from_user(void *to,
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -158,7 +161,8 @@ static inline __kernel_size_t __copy_from_user(void *to,
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
diff --git a/arch/hexagon/include/asm/uaccess.h b/arch/hexagon/include/asm/uaccess.h
index e4127e4..f000a38 100644
--- a/arch/hexagon/include/asm/uaccess.h
+++ b/arch/hexagon/include/asm/uaccess.h
@@ -36,7 +36,8 @@
  * @addr: User space pointer to start of block to check
  * @size: Size of block to check
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Checks if a pointer to a block of memory in user space is valid.
  *
diff --git a/arch/m32r/include/asm/uaccess.h b/arch/m32r/include/asm/uaccess.h
index 71adff2..cac7014 100644
--- a/arch/m32r/include/asm/uaccess.h
+++ b/arch/m32r/include/asm/uaccess.h
@@ -91,7 +91,8 @@ static inline void set_fs(mm_segment_t s)
  * @addr: User space pointer to start of block to check
  * @size: Size of block to check
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Checks if a pointer to a block of memory in user space is valid.
  *
@@ -155,7 +156,8 @@ extern int fixup_exception(struct pt_regs *regs);
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -175,7 +177,8 @@ extern int fixup_exception(struct pt_regs *regs);
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -194,7 +197,8 @@ extern int fixup_exception(struct pt_regs *regs);
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -274,7 +278,8 @@ do {									\
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -568,7 +573,8 @@ unsigned long __generic_copy_from_user(void *, const void __user *, unsigned lon
  * @from: Source address, in kernel space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from kernel space to user space.  Caller must check
  * the specified block with access_ok() before calling this function.
@@ -588,7 +594,8 @@ unsigned long __generic_copy_from_user(void *, const void __user *, unsigned lon
  * @from: Source address, in kernel space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from kernel space to user space.
  *
@@ -606,7 +613,8 @@ unsigned long __generic_copy_from_user(void *, const void __user *, unsigned lon
  * @from: Source address, in user space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to kernel space.  Caller must check
  * the specified block with access_ok() before calling this function.
@@ -626,7 +634,8 @@ unsigned long __generic_copy_from_user(void *, const void __user *, unsigned lon
  * @from: Source address, in user space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to kernel space.
  *
@@ -677,7 +686,8 @@ unsigned long clear_user(void __user *mem, unsigned long len);
  * strlen_user: - Get the size of a string in user space.
  * @str: The string to measure.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Get the size of a NUL-terminated string in user space.
  *
diff --git a/arch/microblaze/include/asm/uaccess.h b/arch/microblaze/include/asm/uaccess.h
index 62942fd..331b0d3 100644
--- a/arch/microblaze/include/asm/uaccess.h
+++ b/arch/microblaze/include/asm/uaccess.h
@@ -178,7 +178,8 @@ extern long __user_bad(void);
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -290,7 +291,8 @@ extern long __user_bad(void);
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
diff --git a/arch/mips/include/asm/uaccess.h b/arch/mips/include/asm/uaccess.h
index bf8b324..9722357 100644
--- a/arch/mips/include/asm/uaccess.h
+++ b/arch/mips/include/asm/uaccess.h
@@ -103,7 +103,8 @@ extern u64 __ua_limit;
  * @addr: User space pointer to start of block to check
  * @size: Size of block to check
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Checks if a pointer to a block of memory in user space is valid.
  *
@@ -138,7 +139,8 @@ extern u64 __ua_limit;
  * @x:	 Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -157,7 +159,8 @@ extern u64 __ua_limit;
  * @x:	 Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -177,7 +180,8 @@ extern u64 __ua_limit;
  * @x:	 Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -199,7 +203,8 @@ extern u64 __ua_limit;
  * @x:	 Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -498,7 +503,8 @@ extern void __put_user_unknown(void);
  * @x:	 Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -517,7 +523,8 @@ extern void __put_user_unknown(void);
  * @x:	 Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -537,7 +544,8 @@ extern void __put_user_unknown(void);
  * @x:	 Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -559,7 +567,8 @@ extern void __put_user_unknown(void);
  * @x:	 Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -815,7 +824,8 @@ extern size_t __copy_user(void *__to, const void *__from, size_t __n);
  * @from: Source address, in kernel space.
  * @n:	  Number of bytes to copy.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from kernel space to user space.  Caller must check
  * the specified block with access_ok() before calling this function.
@@ -888,7 +898,8 @@ extern size_t __copy_user_inatomic(void *__to, const void *__from, size_t __n);
  * @from: Source address, in kernel space.
  * @n:	  Number of bytes to copy.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from kernel space to user space.
  *
@@ -1075,7 +1086,8 @@ extern size_t __copy_in_user_eva(void *__to, const void *__from, size_t __n);
  * @from: Source address, in user space.
  * @n:	  Number of bytes to copy.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to kernel space.  Caller must check
  * the specified block with access_ok() before calling this function.
@@ -1107,7 +1119,8 @@ extern size_t __copy_in_user_eva(void *__to, const void *__from, size_t __n);
  * @from: Source address, in user space.
  * @n:	  Number of bytes to copy.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to kernel space.
  *
@@ -1329,7 +1342,8 @@ strncpy_from_user(char *__to, const char __user *__from, long __len)
  * strlen_user: - Get the size of a string in user space.
  * @str: The string to measure.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Get the size of a NUL-terminated string in user space.
  *
@@ -1398,7 +1412,8 @@ static inline long __strnlen_user(const char __user *s, long n)
  * strnlen_user: - Get the size of a string in user space.
  * @str: The string to measure.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Get the size of a NUL-terminated string in user space.
  *
diff --git a/arch/s390/include/asm/uaccess.h b/arch/s390/include/asm/uaccess.h
index d64a7a6..9dd4cc4 100644
--- a/arch/s390/include/asm/uaccess.h
+++ b/arch/s390/include/asm/uaccess.h
@@ -98,7 +98,8 @@ static inline unsigned long extable_fixup(const struct exception_table_entry *x)
  * @from: Source address, in user space.
  * @n:	  Number of bytes to copy.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to kernel space.  Caller must check
  * the specified block with access_ok() before calling this function.
@@ -118,7 +119,8 @@ unsigned long __must_check __copy_from_user(void *to, const void __user *from,
  * @from: Source address, in kernel space.
  * @n:	  Number of bytes to copy.
  *
- * Context: User context only.	This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from kernel space to user space.  Caller must check
  * the specified block with access_ok() before calling this function.
@@ -264,7 +266,8 @@ int __get_user_bad(void) __attribute__((noreturn));
  * @from: Source address, in kernel space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from kernel space to user space.
  *
@@ -290,7 +293,8 @@ __compiletime_warning("copy_from_user() buffer size is not provably correct")
  * @from: Source address, in user space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to kernel space.
  *
@@ -348,7 +352,8 @@ static inline unsigned long strnlen_user(const char __user *src, unsigned long n
  * strlen_user: - Get the size of a string in user space.
  * @str: The string to measure.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Get the size of a NUL-terminated string in user space.
  *
diff --git a/arch/score/include/asm/uaccess.h b/arch/score/include/asm/uaccess.h
index ab66ddd..20a3591 100644
--- a/arch/score/include/asm/uaccess.h
+++ b/arch/score/include/asm/uaccess.h
@@ -36,7 +36,8 @@
  * @addr: User space pointer to start of block to check
  * @size: Size of block to check
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Checks if a pointer to a block of memory in user space is valid.
  *
@@ -61,7 +62,8 @@
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -79,7 +81,8 @@
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -98,7 +101,8 @@
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -119,7 +123,8 @@
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
diff --git a/arch/tile/include/asm/uaccess.h b/arch/tile/include/asm/uaccess.h
index d598c11..0a9c4265 100644
--- a/arch/tile/include/asm/uaccess.h
+++ b/arch/tile/include/asm/uaccess.h
@@ -85,7 +85,8 @@ int __range_ok(unsigned long addr, unsigned long size);
  * @addr: User space pointer to start of block to check
  * @size: Size of block to check
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Checks if a pointer to a block of memory in user space is valid.
  *
@@ -199,7 +200,8 @@ extern int __get_user_bad(void)
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -281,7 +283,8 @@ extern int __put_user_bad(void)
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -337,7 +340,8 @@ extern int __put_user_bad(void)
  * @from: Source address, in kernel space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from kernel space to user space.  Caller must check
  * the specified block with access_ok() before calling this function.
@@ -373,7 +377,8 @@ copy_to_user(void __user *to, const void *from, unsigned long n)
  * @from: Source address, in user space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to kernel space.  Caller must check
  * the specified block with access_ok() before calling this function.
@@ -444,7 +449,8 @@ static inline unsigned long __must_check copy_from_user(void *to,
  * @from: Source address, in user space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to user space.  Caller must check
  * the specified blocks with access_ok() before calling this function.
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index ace9dec..a8df874 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -74,7 +74,8 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
  * @addr: User space pointer to start of block to check
  * @size: Size of block to check
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Checks if a pointer to a block of memory in user space is valid.
  *
@@ -145,7 +146,8 @@ __typeof__(__builtin_choose_expr(sizeof(x) > sizeof(0UL), 0ULL, 0UL))
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -240,7 +242,8 @@ extern void __put_user_8(void);
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
@@ -455,7 +458,8 @@ struct __large_struct { unsigned long buf[100]; };
  * @x:   Variable to store result.
  * @ptr: Source address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple variable from user space to kernel
  * space.  It supports simple types like char and int, but not larger
@@ -479,7 +483,8 @@ struct __large_struct { unsigned long buf[100]; };
  * @x:   Value to copy to user space.
  * @ptr: Destination address, in user space.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * This macro copies a single simple value from kernel space to user
  * space.  It supports simple types like char and int, but not larger
diff --git a/arch/x86/include/asm/uaccess_32.h b/arch/x86/include/asm/uaccess_32.h
index 0ed5504..f5dcb52 100644
--- a/arch/x86/include/asm/uaccess_32.h
+++ b/arch/x86/include/asm/uaccess_32.h
@@ -74,7 +74,8 @@ __copy_to_user_inatomic(void __user *to, const void *from, unsigned long n)
  * @from: Source address, in kernel space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from kernel space to user space.  Caller must check
  * the specified block with access_ok() before calling this function.
@@ -121,7 +122,8 @@ __copy_from_user_inatomic(void *to, const void __user *from, unsigned long n)
  * @from: Source address, in user space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to kernel space.  Caller must check
  * the specified block with access_ok() before calling this function.
diff --git a/arch/x86/lib/usercopy_32.c b/arch/x86/lib/usercopy_32.c
index e2f5e21..91d93b9 100644
--- a/arch/x86/lib/usercopy_32.c
+++ b/arch/x86/lib/usercopy_32.c
@@ -647,7 +647,8 @@ EXPORT_SYMBOL(__copy_from_user_ll_nocache_nozero);
  * @from: Source address, in kernel space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from kernel space to user space.
  *
@@ -668,7 +669,8 @@ EXPORT_SYMBOL(_copy_to_user);
  * @from: Source address, in user space.
  * @n:    Number of bytes to copy.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Copy data from user space to kernel space.
  *
diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
index a28df52..36c15a2 100644
--- a/lib/strnlen_user.c
+++ b/lib/strnlen_user.c
@@ -84,7 +84,8 @@ static inline long do_strnlen_user(const char __user *src, unsigned long count,
  * @str: The string to measure.
  * @count: Maximum count (including NUL character)
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Get the size of a NUL-terminated string in user space.
  *
@@ -113,7 +114,8 @@ EXPORT_SYMBOL(strnlen_user);
  * strlen_user: - Get the size of a user string INCLUDING final NUL.
  * @str: The string to measure.
  *
- * Context: User context only.  This function may sleep.
+ * Context: User context only. This function may sleep if pagefaults are
+ *          enabled.
  *
  * Get the size of a NUL-terminated string in user space.
  *
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
