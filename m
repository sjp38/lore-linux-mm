Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A043B6B0290
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 20:50:37 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so3061433pab.23
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 17:50:37 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id q5si4613213pbh.100.2014.03.21.17.50.36
        for <linux-mm@kvack.org>;
        Fri, 21 Mar 2014 17:50:36 -0700 (PDT)
Date: Sat, 22 Mar 2014 08:50:32 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 203/499] include/linux/vmstat.h:32:2: error:
 implicit declaration of function 'raw_cpu_inc'
Message-ID: <532cde58.CgQv/f5/Xxy3YpRB%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   4ddd4bc6e081ef29f7adaacb357b77052fefcd7e
commit: 4ac4f1a27eed39f833aa8874515127e3bd0ff971 [203/499] vmstat: use raw_cpu_ops to avoid false positives on preemption checks
config: make ARCH=x86_64 allnoconfig

Note: the mmotm/master HEAD 4ddd4bc6e081ef29f7adaacb357b77052fefcd7e builds fine.
      It only hurts bisectibility.

All error/warnings:

   In file included from include/linux/mm.h:897:0,
                    from include/linux/suspend.h:8,
                    from arch/x86/kernel/asm-offsets.c:12:
   include/linux/vmstat.h: In function '__count_vm_event':
>> include/linux/vmstat.h:32:2: error: implicit declaration of function 'raw_cpu_inc' [-Werror=implicit-function-declaration]
     raw_cpu_inc(vm_event_states.event[item]);
     ^
   include/linux/vmstat.h: In function '__count_vm_events':
>> include/linux/vmstat.h:42:2: error: implicit declaration of function 'raw_cpu_add' [-Werror=implicit-function-declaration]
     raw_cpu_add(vm_event_states.event[item], delta);
     ^
   cc1: some warnings being treated as errors
   make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
   make[2]: Target `__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target `prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +/raw_cpu_inc +32 include/linux/vmstat.h

    26	};
    27	
    28	DECLARE_PER_CPU(struct vm_event_state, vm_event_states);
    29	
    30	static inline void __count_vm_event(enum vm_event_item item)
    31	{
  > 32		raw_cpu_inc(vm_event_states.event[item]);
    33	}
    34	
    35	static inline void count_vm_event(enum vm_event_item item)
    36	{
    37		this_cpu_inc(vm_event_states.event[item]);
    38	}
    39	
    40	static inline void __count_vm_events(enum vm_event_item item, long delta)
    41	{
  > 42		raw_cpu_add(vm_event_states.event[item], delta);
    43	}
    44	
    45	static inline void count_vm_events(enum vm_event_item item, long delta)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
