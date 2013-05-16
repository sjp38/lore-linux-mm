Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 184DF6B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 07:16:27 -0400 (EDT)
Date: Thu, 16 May 2013 14:15:36 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 07/10] powerpc: uaccess s/might_sleep/might_fault/
Message-ID: <2aa6c3da21a28120126732b5e0b4ecd6cba8ca3b.1368702323.git.mst@redhat.com>
References: <cover.1368702323.git.mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1368702323.git.mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

The only reason uaccess routines might sleep
is if they fault. Make this explicit.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 arch/powerpc/include/asm/uaccess.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/include/asm/uaccess.h b/arch/powerpc/include/asm/uaccess.h
index 4db4959..9485b43 100644
--- a/arch/powerpc/include/asm/uaccess.h
+++ b/arch/powerpc/include/asm/uaccess.h
@@ -178,7 +178,7 @@ do {								\
 	long __pu_err;						\
 	__typeof__(*(ptr)) __user *__pu_addr = (ptr);		\
 	if (!is_kernel_addr((unsigned long)__pu_addr))		\
-		might_sleep();					\
+		might_fault();					\
 	__chk_user_ptr(ptr);					\
 	__put_user_size((x), __pu_addr, (size), __pu_err);	\
 	__pu_err;						\
@@ -188,7 +188,7 @@ do {								\
 ({									\
 	long __pu_err = -EFAULT;					\
 	__typeof__(*(ptr)) __user *__pu_addr = (ptr);			\
-	might_sleep();							\
+	might_fault();							\
 	if (access_ok(VERIFY_WRITE, __pu_addr, size))			\
 		__put_user_size((x), __pu_addr, (size), __pu_err);	\
 	__pu_err;							\
@@ -268,7 +268,7 @@ do {								\
 	const __typeof__(*(ptr)) __user *__gu_addr = (ptr);	\
 	__chk_user_ptr(ptr);					\
 	if (!is_kernel_addr((unsigned long)__gu_addr))		\
-		might_sleep();					\
+		might_fault();					\
 	__get_user_size(__gu_val, __gu_addr, (size), __gu_err);	\
 	(x) = (__typeof__(*(ptr)))__gu_val;			\
 	__gu_err;						\
@@ -282,7 +282,7 @@ do {								\
 	const __typeof__(*(ptr)) __user *__gu_addr = (ptr);	\
 	__chk_user_ptr(ptr);					\
 	if (!is_kernel_addr((unsigned long)__gu_addr))		\
-		might_sleep();					\
+		might_fault();					\
 	__get_user_size(__gu_val, __gu_addr, (size), __gu_err);	\
 	(x) = (__typeof__(*(ptr)))__gu_val;			\
 	__gu_err;						\
@@ -294,7 +294,7 @@ do {								\
 	long __gu_err = -EFAULT;					\
 	unsigned long  __gu_val = 0;					\
 	const __typeof__(*(ptr)) __user *__gu_addr = (ptr);		\
-	might_sleep();							\
+	might_fault();							\
 	if (access_ok(VERIFY_READ, __gu_addr, (size)))			\
 		__get_user_size(__gu_val, __gu_addr, (size), __gu_err);	\
 	(x) = (__typeof__(*(ptr)))__gu_val;				\
@@ -419,14 +419,14 @@ static inline unsigned long __copy_to_user_inatomic(void __user *to,
 static inline unsigned long __copy_from_user(void *to,
 		const void __user *from, unsigned long size)
 {
-	might_sleep();
+	might_fault();
 	return __copy_from_user_inatomic(to, from, size);
 }
 
 static inline unsigned long __copy_to_user(void __user *to,
 		const void *from, unsigned long size)
 {
-	might_sleep();
+	might_fault();
 	return __copy_to_user_inatomic(to, from, size);
 }
 
@@ -434,7 +434,7 @@ extern unsigned long __clear_user(void __user *addr, unsigned long size);
 
 static inline unsigned long clear_user(void __user *addr, unsigned long size)
 {
-	might_sleep();
+	might_fault();
 	if (likely(access_ok(VERIFY_WRITE, addr, size)))
 		return __clear_user(addr, size);
 	if ((unsigned long)addr < TASK_SIZE) {
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
