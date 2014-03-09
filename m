Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id E5CE96B0031
	for <linux-mm@kvack.org>; Sat,  8 Mar 2014 19:46:51 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id rr13so5742919pbb.25
        for <linux-mm@kvack.org>; Sat, 08 Mar 2014 16:46:51 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bo2si12574552pbc.51.2014.03.08.16.46.50
        for <linux-mm@kvack.org>;
        Sat, 08 Mar 2014 16:46:50 -0800 (PST)
Date: Sun, 09 Mar 2014 08:46:47 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 441/471]
 arch/x86/kernel/cpu/perf_event_intel_rapl.c:132:27: sparse: incorrect type
 in initializer (different address spaces)
Message-ID: <531bb9f7.s+mHb8SXb4UDyDkz%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_531bb9f7.92fn6X+SNqe99TkIAtyvJySCAiibqz3RuL5pU9mSWil06jgK"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

This is a multi-part message in MIME format.

--=_531bb9f7.92fn6X+SNqe99TkIAtyvJySCAiibqz3RuL5pU9mSWil06jgK
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   f6bf2766c2091cbf8ffcc2c5009875dbdb678282
commit: 8fe1e4640220f24ca6d7c040d4849a8988ababf7 [441/471] x86: change __get_cpu_var calls introduced in 3.14
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> arch/x86/kernel/cpu/perf_event_intel_rapl.c:132:27: sparse: incorrect type in initializer (different address spaces)
   arch/x86/kernel/cpu/perf_event_intel_rapl.c:132:27:    expected void const [noderef] <asn:3>*__vpp_verify
   arch/x86/kernel/cpu/perf_event_intel_rapl.c:132:27:    got int *<noident>
>> arch/x86/kernel/cpu/perf_event_intel_rapl.c:444:30: sparse: symbol 'rapl_attr_groups' was not declared. Should it be static?
--
>> kernel/sched/deadline.c:1144:38: sparse: incorrect type in initializer (different address spaces)
   kernel/sched/deadline.c:1144:38:    expected void const [noderef] <asn:3>*__vpp_verify
   kernel/sched/deadline.c:1144:38:    got struct cpumask *<noident>
   kernel/sched/deadline.c:1183:9: sparse: incompatible types in comparison expression (different address spaces)

Please consider folding the attached diff :-)

vim +132 arch/x86/kernel/cpu/perf_event_intel_rapl.c

   116	
   117	static inline u64 rapl_read_counter(struct perf_event *event)
   118	{
   119		u64 raw;
   120		rdmsrl(event->hw.event_base, raw);
   121		return raw;
   122	}
   123	
   124	static inline u64 rapl_scale(u64 v)
   125	{
   126		/*
   127		 * scale delta to smallest unit (1/2^32)
   128		 * users must then scale back: count * 1/(1e9*2^32) to get Joules
   129		 * or use ldexp(count, -32).
   130		 * Watts = Joules/Time delta
   131		 */
 > 132		return v << (32 - __this_cpu_read(rapl_pmu->hw_unit));
   133	}
   134	
   135	static u64 rapl_event_update(struct perf_event *event)
   136	{
   137		struct hw_perf_event *hwc = &event->hw;
   138		u64 prev_raw_count, new_raw_count;
   139		s64 delta, sdelta;
   140		int shift = RAPL_CNTR_WIDTH;

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--=_531bb9f7.92fn6X+SNqe99TkIAtyvJySCAiibqz3RuL5pU9mSWil06jgK
Content-Type: text/x-diff;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="make-it-static-8fe1e4640220f24ca6d7c040d4849a8988ababf7.diff"

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH mmotm] x86: rapl_attr_groups[] can be static
TO: Christoph Lameter <cl@linux-foundation.org>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: linux-kernel@vger.kernel.org 

CC: Christoph Lameter <cl@linux-foundation.org>
CC: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 perf_event_intel_rapl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/cpu/perf_event_intel_rapl.c b/arch/x86/kernel/cpu/perf_event_intel_rapl.c
index d0dbcdf..cf4aaf3 100644
--- a/arch/x86/kernel/cpu/perf_event_intel_rapl.c
+++ b/arch/x86/kernel/cpu/perf_event_intel_rapl.c
@@ -441,7 +441,7 @@ static struct attribute_group rapl_pmu_format_group = {
 	.attrs = rapl_formats_attr,
 };
 
-const struct attribute_group *rapl_attr_groups[] = {
+static const struct attribute_group *rapl_attr_groups[] = {
 	&rapl_pmu_attr_group,
 	&rapl_pmu_format_group,
 	&rapl_pmu_events_group,

--=_531bb9f7.92fn6X+SNqe99TkIAtyvJySCAiibqz3RuL5pU9mSWil06jgK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
