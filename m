Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4116B00E0
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 03:45:23 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id kp14so5564871pab.32
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 00:45:23 -0700 (PDT)
Received: from psmtp.com ([74.125.245.128])
        by mx.google.com with SMTP id cx4si8840591pbc.359.2013.10.27.00.45.21
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 00:45:22 -0700 (PDT)
Received: by mail-vb0-f74.google.com with SMTP id w8so504026vbj.5
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 00:45:20 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 2/3] percpu counter: cast this_cpu_sub() adjustment
Date: Sun, 27 Oct 2013 00:44:35 -0700
Message-Id: <1382859876-28196-3-git-send-email-gthelen@google.com>
In-Reply-To: <1382859876-28196-1-git-send-email-gthelen@google.com>
References: <1382859876-28196-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, Andrew Morton <akpm@linux-foundation.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>

this_cpu_sub() is implemented as negation and addition.

This patch casts the adjustment to the counter type before negation to
sign extend the adjustment.  This helps in cases where the counter
type is wider than an unsigned adjustment.  An alternative to this
patch is to declare such operations unsupported, but it seemed useful
to avoid surprises.

This patch specifically helps the following example:
  unsigned int delta = 1
  preempt_disable()
  this_cpu_write(long_counter, 0)
  this_cpu_sub(long_counter, delta)
  preempt_enable()

Before this change long_counter on a 64 bit machine ends with value
0xffffffff, rather than 0xffffffffffffffff.  This is because
this_cpu_sub(pcp, delta) boils down to this_cpu_add(pcp, -delta),
which is basically:
  long_counter = 0 + 0xffffffff

Also apply the same cast to:
  __this_cpu_sub()
  this_cpu_sub_return()
  and __this_cpu_sub_return()

All percpu_test.ko passes, especially the following cases which
previously failed:

  l -= ui_one;
  __this_cpu_sub(long_counter, ui_one);
  CHECK(l, long_counter, -1);

  l -= ui_one;
  this_cpu_sub(long_counter, ui_one);
  CHECK(l, long_counter, -1);
  CHECK(l, long_counter, 0xffffffffffffffff);

  ul -= ui_one;
  __this_cpu_sub(ulong_counter, ui_one);
  CHECK(ul, ulong_counter, -1);
  CHECK(ul, ulong_counter, 0xffffffffffffffff);

  ul = this_cpu_sub_return(ulong_counter, ui_one);
  CHECK(ul, ulong_counter, 2);

  ul = __this_cpu_sub_return(ulong_counter, ui_one);
  CHECK(ul, ulong_counter, 1);

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 arch/x86/include/asm/percpu.h | 3 ++-
 include/linux/percpu.h        | 8 ++++----
 lib/percpu_test.c             | 2 +-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/percpu.h b/arch/x86/include/asm/percpu.h
index 0da5200..b3e18f8 100644
--- a/arch/x86/include/asm/percpu.h
+++ b/arch/x86/include/asm/percpu.h
@@ -128,7 +128,8 @@ do {							\
 do {									\
 	typedef typeof(var) pao_T__;					\
 	const int pao_ID__ = (__builtin_constant_p(val) &&		\
-			      ((val) == 1 || (val) == -1)) ? (val) : 0;	\
+			      ((val) == 1 || (val) == -1)) ?		\
+				(int)(val) : 0;				\
 	if (0) {							\
 		pao_T__ pao_tmp__;					\
 		pao_tmp__ = (val);					\
diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index cc88172..c74088a 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -332,7 +332,7 @@ do {									\
 #endif
 
 #ifndef this_cpu_sub
-# define this_cpu_sub(pcp, val)		this_cpu_add((pcp), -(val))
+# define this_cpu_sub(pcp, val)		this_cpu_add((pcp), -(typeof(pcp))(val))
 #endif
 
 #ifndef this_cpu_inc
@@ -418,7 +418,7 @@ do {									\
 # define this_cpu_add_return(pcp, val)	__pcpu_size_call_return2(this_cpu_add_return_, pcp, val)
 #endif
 
-#define this_cpu_sub_return(pcp, val)	this_cpu_add_return(pcp, -(val))
+#define this_cpu_sub_return(pcp, val)	this_cpu_add_return(pcp, -(typeof(pcp))(val))
 #define this_cpu_inc_return(pcp)	this_cpu_add_return(pcp, 1)
 #define this_cpu_dec_return(pcp)	this_cpu_add_return(pcp, -1)
 
@@ -586,7 +586,7 @@ do {									\
 #endif
 
 #ifndef __this_cpu_sub
-# define __this_cpu_sub(pcp, val)	__this_cpu_add((pcp), -(val))
+# define __this_cpu_sub(pcp, val)	__this_cpu_add((pcp), -(typeof(pcp))(val))
 #endif
 
 #ifndef __this_cpu_inc
@@ -668,7 +668,7 @@ do {									\
 	__pcpu_size_call_return2(__this_cpu_add_return_, pcp, val)
 #endif
 
-#define __this_cpu_sub_return(pcp, val)	__this_cpu_add_return(pcp, -(val))
+#define __this_cpu_sub_return(pcp, val)	__this_cpu_add_return(pcp, -(typeof(pcp))(val))
 #define __this_cpu_inc_return(pcp)	__this_cpu_add_return(pcp, 1)
 #define __this_cpu_dec_return(pcp)	__this_cpu_add_return(pcp, -1)
 
diff --git a/lib/percpu_test.c b/lib/percpu_test.c
index 1ebeb44..8ab4231 100644
--- a/lib/percpu_test.c
+++ b/lib/percpu_test.c
@@ -118,7 +118,7 @@ static int __init percpu_test_init(void)
 	CHECK(ul, ulong_counter, 2);
 
 	ul = __this_cpu_sub_return(ulong_counter, ui_one);
-	CHECK(ul, ulong_counter, 0);
+	CHECK(ul, ulong_counter, 1);
 
 	preempt_enable();
 
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
