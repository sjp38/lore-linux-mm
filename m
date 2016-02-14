Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id B4BF56B0009
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 04:09:09 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id bc4so64542432lbc.2
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 01:09:09 -0800 (PST)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id j3si11743777lbc.107.2016.02.14.01.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 01:09:08 -0800 (PST)
Received: by mail-lf0-x231.google.com with SMTP id m1so73883680lfg.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 01:09:07 -0800 (PST)
Subject: [PATCH RFC] Introduce atomic and per-cpu add-max and sub-min
 operations
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sun, 14 Feb 2016 12:09:00 +0300
Message-ID: <145544094056.28219.12239469516497703482.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

bool atomic_add_max(atomic_t *var, int add, int max);
bool atomic_sub_min(atomic_t *var, int sub, int min);

bool this_cpu_add_max(var, add, max);
bool this_cpu_sub_min(var, sub, min);

They add/subtract only if result will be not bigger than max/lower that min.
Returns true if operation was done and false otherwise.

Inside they check that (add <= max - var) and (sub <= var - min). Signed
operations work if all possible values fits into range which length fits
into non-negative range of that type: 0..INT_MAX, INT_MIN+1..0, -1000..1000.
Unsigned operations work if value always in valid range: min <= var <= max.
Char and short automatically casts to int, they never overflows.

Patch adds the same for atomic_long_t, atomic64_t, local_t, local64_t.
And unsigned variants: atomic_u32_add_max atomic_u32_sub_min for atomic_t,
atomic_u64_add_max atomic_u64_sub_min for atomic64_t.

Patch comes with test which hopefully covers all possible cornercases,
see CONFIG_ATOMIC64_SELFTEST and CONFIG_PERCPU_TEST.

All this allows to build any kind of counter in several lines:

- Simple atomic resource counter

atomic_t usage;
int limit;

result = atomic_add_max(&usage, charge, limit);

atomic_sub(uncharge, &usage);

- Event counter with per-cpu batch

atomic_t events;
DEFINE_PER_CPU(int, cpu_events);
int batch;

if (!this_cpu_add_max(cpu_events, count, batch))
	atomic_add(this_cpu_xchg(cpu_events, 0) + count,  &events);

- Object counter with per-cpu part

atomic_t objects;
DEFINE_PER_CPU(int, cpu_objects);
int batch;

if (!this_cpu_add_max(cpu_objects, 1, batch))
	atomic_add(this_cpu_xchg(cpu_events, 0) + 1,  &objects);

if (!this_cpu_sub_min(cpu_objects, 1, -batch))
	atomic_add(this_cpu_xchg(cpu_events, 0) - 1,  &objects);

- Positive object counter with negative per-cpu parts

atomic_t objects;
DEFINE_PER_CPU(int, cpu_objects);
int batch;

if (!this_cpu_add_max(cpu_objects, 1, 0))
	atomic_add(this_cpu_xchg(cpu_events, -batch / 2) + 1,  &objects);

if (!this_cpu_sub_min(cpu_objects, 1, -batch))
	atomic_add(this_cpu_xchg(cpu_events, -batch / 2) - 1,  &objects);

- Resource counter with per-cpu precharge

atomic_t usage;
int limit;
DEFINE_PER_CPU(int, precharge);
int batch;

result = this_cpu_sub_min(precharge, charge, 0);
if (!result) {
	preempt_disable();
	charge += batch / 2 - __this_cpu_read(precharge);
	result = atomic_add_max(&usage, charge, limit);
	if (result)
		__this_cpu_write(precharge, batch / 2);
	preempt_enable();
}

if (!this_cpu_add_max(precharge, uncharge, batch)) {
	preempt_disable();
	if (__this_cpu_read(precharge) > batch / 2) {
		uncharge += __this_cpu_read(precharge) - batch / 2;
		__this_cpu_write(precharge, batch / 2);
	}
	atomic_sub(uncharge, &usage);
	preempt_enable();
}

- Each operation easily split into static-inline per-cpu fast-path and
  atomic slow-path which could be hidden in separate function which
  performs resource reclaim, logging, etc.
- Types of global atomic part and per-cpu part might differs: for example
  like in vmstat counters atomit_long_t global and s8 local part.
- Resource could be counted upwards to the limit or downwards to the zero.
- Bounds min=INT_MIN/max=INT_MAX could be used for catching und/overflows.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 arch/x86/include/asm/local.h  |    2 +
 include/asm-generic/local.h   |    2 +
 include/asm-generic/local64.h |    4 ++
 include/linux/atomic.h        |   52 +++++++++++++++++++++++++
 include/linux/percpu-defs.h   |   56 +++++++++++++++++++++++++++
 lib/atomic64_test.c           |   49 ++++++++++++++++++++++++
 lib/percpu_test.c             |   84 +++++++++++++++++++++++++++++++++++++++++
 7 files changed, 249 insertions(+)

diff --git a/arch/x86/include/asm/local.h b/arch/x86/include/asm/local.h
index 4ad6560847b1..c97e0c0b3f48 100644
--- a/arch/x86/include/asm/local.h
+++ b/arch/x86/include/asm/local.h
@@ -149,6 +149,8 @@ static inline long local_sub_return(long i, local_t *l)
 })
 #define local_inc_not_zero(l) local_add_unless((l), 1, 0)
 
+ATOMIC_MINMAX_OP(local, local, long)
+
 /* On x86_32, these are no better than the atomic variants.
  * On x86-64 these are better than the atomic variants on SMP kernels
  * because they dont use a lock prefix.
diff --git a/include/asm-generic/local.h b/include/asm-generic/local.h
index 9ceb03b4f466..e46d9dfb7c21 100644
--- a/include/asm-generic/local.h
+++ b/include/asm-generic/local.h
@@ -44,6 +44,8 @@ typedef struct
 #define local_xchg(l, n) atomic_long_xchg((&(l)->a), (n))
 #define local_add_unless(l, _a, u) atomic_long_add_unless((&(l)->a), (_a), (u))
 #define local_inc_not_zero(l) atomic_long_inc_not_zero(&(l)->a)
+#define local_add_max(l, add, max)	atomic_long_add_max(&(l)->a, add, max)
+#define local_sub_min(l, sub, min)	atomic_long_sub_min(&(l)->a, sub, min)
 
 /* Non-atomic variants, ie. preemption disabled and won't be touched
  * in interrupt, etc.  Some archs can optimize this case well. */
diff --git a/include/asm-generic/local64.h b/include/asm-generic/local64.h
index 5980002b8b7b..6eaeab1fc0cc 100644
--- a/include/asm-generic/local64.h
+++ b/include/asm-generic/local64.h
@@ -45,6 +45,8 @@ typedef struct {
 #define local64_xchg(l, n)	local_xchg((&(l)->a), (n))
 #define local64_add_unless(l, _a, u) local_add_unless((&(l)->a), (_a), (u))
 #define local64_inc_not_zero(l)	local_inc_not_zero(&(l)->a)
+#define local64_add_max(l, add, max)	local_add_max(&(l)->a, add, max)
+#define local64_sub_min(l, sub, min)	local_sub_min(&(l)->a, sub, min)
 
 /* Non-atomic variants, ie. preemption disabled and won't be touched
  * in interrupt, etc.  Some archs can optimize this case well. */
@@ -83,6 +85,8 @@ typedef struct {
 #define local64_xchg(l, n)	atomic64_xchg((&(l)->a), (n))
 #define local64_add_unless(l, _a, u) atomic64_add_unless((&(l)->a), (_a), (u))
 #define local64_inc_not_zero(l)	atomic64_inc_not_zero(&(l)->a)
+#define local64_add_max(l, add, max)	atomic64_add_max(&(l)->a, add, max)
+#define local64_sub_min(l, sub, min)	atomic64_sub_min(&(l)->a, sub, min)
 
 /* Non-atomic variants, ie. preemption disabled and won't be touched
  * in interrupt, etc.  Some archs can optimize this case well. */
diff --git a/include/linux/atomic.h b/include/linux/atomic.h
index 301de78d65f7..06b12a60645b 100644
--- a/include/linux/atomic.h
+++ b/include/linux/atomic.h
@@ -561,4 +561,56 @@ static inline void atomic64_andnot(long long i, atomic64_t *v)
 
 #include <asm-generic/atomic-long.h>
 
+/*
+ * atomic_add_max - add unless result will be bugger that max
+ * @var:  pointer of type atomic_t
+ * @add:  value to add
+ * @max:  maximum result
+ *
+ * Atomic value must be already lower or equal to max before call.
+ * The function returns true if operation was done and false otherwise.
+ */
+
+/*
+ * atomic_sub_min - subtract unless result will be lower than min
+ * @var:  pointer of type atomic_t
+ * @sub:  value to subtract
+ * @min:  minimal result
+ *
+ * Atomic value must be already bigger or equal to min before call.
+ * The function returns true if operation was done and false otherwise.
+ */
+
+#define ATOMIC_MINMAX_OP(nm, at, type)					\
+static inline bool nm##_add_max(at##_t *var, type add, type max)	\
+{									\
+	type val = at##_read(var);					\
+	while (likely(add <= max - val)) {				\
+		type old = at##_cmpxchg(var, val, val + add);		\
+		if (likely(old == val))					\
+			return true;					\
+		val = old;						\
+	}								\
+	return false;							\
+}									\
+									\
+static inline bool nm##_sub_min(at##_t *var, type sub, type min)	\
+{									\
+	type val = at##_read(var);					\
+	while (likely(sub <= val - min)) {				\
+		type old = at##_cmpxchg(var, val, val - sub);		\
+		if (likely(old == val))					\
+			return true;					\
+		val = old;						\
+	}								\
+	return false;							\
+}
+
+ATOMIC_MINMAX_OP(atomic, atomic, int)
+ATOMIC_MINMAX_OP(atomic_long, atomic_long, long)
+ATOMIC_MINMAX_OP(atomic64, atomic64, long long)
+
+ATOMIC_MINMAX_OP(atomic_u32, atomic, unsigned)
+ATOMIC_MINMAX_OP(atomic_u64, atomic64, unsigned long long)
+
 #endif /* _LINUX_ATOMIC_H */
diff --git a/include/linux/percpu-defs.h b/include/linux/percpu-defs.h
index 8f16299ca068..113ebff1cecf 100644
--- a/include/linux/percpu-defs.h
+++ b/include/linux/percpu-defs.h
@@ -371,6 +371,48 @@ do {									\
 } while (0)
 
 /*
+ * Add unless result will be bigger than max.
+ * Returns true if operantion was done.
+ */
+#define __pcpu_add_max(stem, pcp, add, max)		\
+({	bool __ret = false;				\
+	typeof(add) __add = (add);			\
+	typeof(max) __max = (max);			\
+	typeof(pcp) __val = stem##read(pcp);		\
+	while (likely(__add <= __max - __val)) {	\
+		typeof(pcp) __old = stem##cmpxchg(pcp,	\
+				__val, __val + __add);	\
+		if (likely(__old == __val)) {		\
+			__ret = true;			\
+			break;				\
+		}					\
+		__val = __old;				\
+	}						\
+	__ret;						\
+})
+
+/*
+ * Sub unless result will be lower than min.
+ * Returns true if operantion was done.
+ */
+#define __pcpu_sub_min(stem, pcp, sub, min)		\
+({	bool __ret = false;				\
+	typeof(sub) __sub = (sub);			\
+	typeof(min) __min = (min);			\
+	typeof(pcp) __val = stem##read(pcp);		\
+	while (likely(__sub <= __val - __min)) {	\
+		typeof(pcp) __old = stem##cmpxchg(pcp,	\
+				__val, __val - __sub);	\
+		if (likely(__old == __val)) {		\
+			__ret = true;			\
+			break;				\
+		}					\
+		__val = __old;				\
+	}						\
+	__ret;						\
+})
+
+/*
  * this_cpu operations (C) 2008-2013 Christoph Lameter <cl@linux.com>
  *
  * Optimized manipulation for memory allocated through the per cpu
@@ -422,6 +464,8 @@ do {									\
 #define raw_cpu_sub_return(pcp, val)	raw_cpu_add_return(pcp, -(typeof(pcp))(val))
 #define raw_cpu_inc_return(pcp)		raw_cpu_add_return(pcp, 1)
 #define raw_cpu_dec_return(pcp)		raw_cpu_add_return(pcp, -1)
+#define raw_cpu_add_max(pcp, add, max)	__pcpu_add_max(raw_cpu_, pcp, add, max)
+#define raw_cpu_sub_min(pcp, sub, min)	__pcpu_sub_min(raw_cpu_, pcp, sub, min)
 
 /*
  * Operations for contexts that are safe from preemption/interrupts.  These
@@ -480,6 +524,16 @@ do {									\
 	raw_cpu_cmpxchg_double(pcp1, pcp2, oval1, oval2, nval1, nval2);	\
 })
 
+#define __this_cpu_add_max(pcp, add, max)				\
+({	__this_cpu_preempt_check("add_max");				\
+	raw_cpu_add_max(pcp, add, max);					\
+})
+
+#define __this_cpu_sub_min(pcp, sub, min)				\
+({	__this_cpu_preempt_check("sub_min");				\
+	raw_cpu_sub_min(pcp, sub, min);					\
+})
+
 #define __this_cpu_sub(pcp, val)	__this_cpu_add(pcp, -(typeof(pcp))(val))
 #define __this_cpu_inc(pcp)		__this_cpu_add(pcp, 1)
 #define __this_cpu_dec(pcp)		__this_cpu_sub(pcp, 1)
@@ -509,6 +563,8 @@ do {									\
 #define this_cpu_sub_return(pcp, val)	this_cpu_add_return(pcp, -(typeof(pcp))(val))
 #define this_cpu_inc_return(pcp)	this_cpu_add_return(pcp, 1)
 #define this_cpu_dec_return(pcp)	this_cpu_add_return(pcp, -1)
+#define this_cpu_add_max(pcp, add, max)	__pcpu_add_max(this_cpu_, pcp, add, max)
+#define this_cpu_sub_min(pcp, sub, min)	__pcpu_sub_min(this_cpu_, pcp, sub, min)
 
 #endif /* __ASSEMBLY__ */
 #endif /* _LINUX_PERCPU_DEFS_H */
diff --git a/lib/atomic64_test.c b/lib/atomic64_test.c
index d62de8bf022d..3adbf8301a41 100644
--- a/lib/atomic64_test.c
+++ b/lib/atomic64_test.c
@@ -90,6 +90,42 @@ do {							\
 			i, (i) - one, (i) - one);	\
 } while (0)
 
+#define TEST_MINMAX(bit, val, op, c_op, arg, lim, ret)		\
+do {								\
+	atomic##bit##_set(&v, val);				\
+	r = (typeof(r))(ret ? ((val) c_op (arg)) : (val));	\
+	BUG_ON(atomic##bit##_##op(&v, arg, lim) != ret);	\
+	BUG_ON(atomic##bit##_read(&v) != r);			\
+} while (0)
+
+#define MINMAX_RANGE_TEST(bit, lo, hi)				\
+do {								\
+	TEST_MINMAX(bit, hi, add_max, +, 0, hi, true);		\
+	TEST_MINMAX(bit, hi-1, add_max, +, 1, hi, true);	\
+	TEST_MINMAX(bit, hi, add_max, +, 1, hi, false);		\
+	TEST_MINMAX(bit, lo, add_max, +, 1, hi, true);		\
+	TEST_MINMAX(bit, lo, add_max, +, hi - lo, hi, true);	\
+	TEST_MINMAX(bit, lo, add_max, +, hi - lo, hi-1, false);	\
+	TEST_MINMAX(bit, lo+1, add_max, +, hi - lo, hi, false);	\
+								\
+	TEST_MINMAX(bit, lo, sub_min, -, 0, lo, true);		\
+	TEST_MINMAX(bit, lo+1, sub_min, -, 1, lo, true);	\
+	TEST_MINMAX(bit, lo, sub_min, -, 1, lo, false);		\
+	TEST_MINMAX(bit, hi, sub_min, -, 1, lo, true);		\
+	TEST_MINMAX(bit, hi, sub_min, -, hi - lo, lo, true);	\
+	TEST_MINMAX(bit, hi, sub_min, -, hi - lo, lo+1, false);	\
+	TEST_MINMAX(bit, hi-1, sub_min, -, hi - lo, lo, false);	\
+} while (0)
+
+#define MINMAX_FAMILY_TEST(bit, min, max)	\
+do {						\
+	MINMAX_RANGE_TEST(bit, 0, max);		\
+	MINMAX_RANGE_TEST(bit, (min + 1), 0);	\
+	MINMAX_RANGE_TEST(bit, min, -1);	\
+	MINMAX_RANGE_TEST(bit, -1, 1);		\
+	MINMAX_RANGE_TEST(bit, -273, 451);	\
+} while (0)
+
 static __init void test_atomic(void)
 {
 	int v0 = 0xaaa31337;
@@ -120,6 +156,12 @@ static __init void test_atomic(void)
 	XCHG_FAMILY_TEST(, v0, v1);
 	CMPXCHG_FAMILY_TEST(, v0, v1, onestwos);
 
+	MINMAX_FAMILY_TEST(, INT_MIN, INT_MAX);
+
+#define atomic_u32_set(var, val)	atomic_set(var, val)
+#define atomic_u32_read(var)		atomic_read(var)
+	MINMAX_RANGE_TEST(_u32, 0, UINT_MAX);
+	MINMAX_RANGE_TEST(_u32, 100, 500);
 }
 
 #define INIT(c) do { atomic64_set(&v, c); r = c; } while (0)
@@ -170,6 +212,13 @@ static __init void test_atomic64(void)
 	XCHG_FAMILY_TEST(64, v0, v1);
 	CMPXCHG_FAMILY_TEST(64, v0, v1, v2);
 
+	MINMAX_FAMILY_TEST(64, LLONG_MIN, LLONG_MAX);
+
+#define atomic_u64_set(var, val)	atomic64_set(var, val)
+#define atomic_u64_read(var)		atomic64_read(var)
+	MINMAX_RANGE_TEST(_u64, 0, ULLONG_MAX);
+	MINMAX_RANGE_TEST(_u64, 100, 500);
+
 	INIT(v0);
 	BUG_ON(atomic64_add_unless(&v, one, v0));
 	BUG_ON(v.counter != r);
diff --git a/lib/percpu_test.c b/lib/percpu_test.c
index 0b5d14dadd1a..92c3ca30b483 100644
--- a/lib/percpu_test.c
+++ b/lib/percpu_test.c
@@ -13,9 +13,87 @@
 		     (long long)(expected), (long long)(expected));	\
 	} while (0)
 
+#define TEST_MINMAX_(stem, bit, val, op, c_op, arg, lim, ret)		\
+do {									\
+	stem##write(bit##_counter, val);				\
+	bit##_var = (typeof(bit))(ret ? ((val) c_op (arg)) : val);	\
+	WARN(stem##op(bit##_counter, arg, lim) != ret,			\
+		"unexpected %s", ret ? "fail" : "success");		\
+	WARN(stem##read(bit##_counter) != bit##_var,			\
+		"%s %lld %lld %lld pcp %lld != expected %lld",		\
+		#stem #op, (long long)(val), (long long)(arg),		\
+		(long long)(lim),					\
+		(long long)stem##read(bit##_counter),			\
+		(long long)bit##_var);					\
+} while (0)
+
+#define TEST_MINMAX(bit, val, op, c_op, arg, lim, ret)			\
+do {									\
+	TEST_MINMAX_(raw_cpu_, bit, val, op, c_op, arg, lim, ret);	\
+	TEST_MINMAX_(__this_cpu_, bit, val, op, c_op, arg, lim, ret);	\
+	TEST_MINMAX_(this_cpu_, bit, val, op, c_op, arg, lim, ret);	\
+} while (0)
+
+#define MINMAX_RANGE_TEST(bit, lo, hi)				\
+do {								\
+	TEST_MINMAX(bit, hi, add_max, +, 0, hi, true);		\
+	TEST_MINMAX(bit, hi-1, add_max, +, 1, hi, true);	\
+	TEST_MINMAX(bit, hi, add_max, +, 1, hi, false);		\
+	TEST_MINMAX(bit, lo, add_max, +, 1, hi, true);		\
+	TEST_MINMAX(bit, lo, add_max, +, hi - lo, hi, true);	\
+	TEST_MINMAX(bit, lo, add_max, +, hi - lo, hi-1, false);	\
+	TEST_MINMAX(bit, lo+1, add_max, +, hi - lo, hi, false);	\
+								\
+	TEST_MINMAX(bit, lo, sub_min, -, 0, lo, true);		\
+	TEST_MINMAX(bit, lo+1, sub_min, -, 1, lo, true);	\
+	TEST_MINMAX(bit, lo, sub_min, -, 1, lo, false);		\
+	TEST_MINMAX(bit, hi, sub_min, -, 1, lo, true);		\
+	TEST_MINMAX(bit, hi, sub_min, -, hi - lo, lo, true);	\
+	TEST_MINMAX(bit, hi, sub_min, -, hi - lo, lo+1, false);	\
+	TEST_MINMAX(bit, hi-1, sub_min, -, hi - lo, lo, false);	\
+} while (0)
+
+#define MINMAX_FAMILY_TEST(bit, min, max, ubit, umax)	\
+do {							\
+	MINMAX_RANGE_TEST(bit, 0, max);			\
+	MINMAX_RANGE_TEST(bit, (min + 1), 0);		\
+	MINMAX_RANGE_TEST(bit, min, -1);		\
+	MINMAX_RANGE_TEST(bit, -1, 1);			\
+	MINMAX_RANGE_TEST(bit, -100, 100);		\
+	MINMAX_RANGE_TEST(ubit, 0, umax);		\
+	MINMAX_RANGE_TEST(ubit, 100, 200);		\
+} while (0)
+
+static s8 s8_var;
+static DEFINE_PER_CPU(s8, s8_counter);
+
+static u8 u8_var;
+static DEFINE_PER_CPU(u8, u8_counter);
+
+static s16 s16_var;
+static DEFINE_PER_CPU(s16, s16_counter);
+
+static u16 u16_var;
+static DEFINE_PER_CPU(u16, u16_counter);
+
+static s32 s32_var;
+static DEFINE_PER_CPU(s32, s32_counter);
+
+static u32 u32_var;
+static DEFINE_PER_CPU(u32, u32_counter);
+
+static long long_var;
 static DEFINE_PER_CPU(long, long_counter);
+
+static unsigned long ulong_var;
 static DEFINE_PER_CPU(unsigned long, ulong_counter);
 
+static s64 s64_var;
+static DEFINE_PER_CPU(s64, s64_counter);
+
+static u64 u64_var;
+static DEFINE_PER_CPU(u64, u64_counter);
+
 static int __init percpu_test_init(void)
 {
 	/*
@@ -120,6 +198,12 @@ static int __init percpu_test_init(void)
 	ul = __this_cpu_sub_return(ulong_counter, ui_one);
 	CHECK(ul, ulong_counter, 1);
 
+	MINMAX_FAMILY_TEST(s8, S8_MIN, S8_MAX, u8, U8_MAX);
+	MINMAX_FAMILY_TEST(s16, S16_MIN, S16_MAX, u16, U16_MAX);
+	MINMAX_FAMILY_TEST(s32, S32_MIN, S32_MAX, u32, U32_MAX);
+	MINMAX_FAMILY_TEST(long, LONG_MIN, LONG_MAX, ulong, ULONG_MAX);
+	MINMAX_FAMILY_TEST(s64, S64_MIN, S64_MAX, u64, U64_MAX);
+
 	preempt_enable();
 
 	pr_info("percpu test done\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
