Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 24C676B0253
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 01:26:18 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id b13so123800093pat.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 22:26:18 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id r5si4567401pfr.51.2016.06.22.22.26.16
        for <linux-mm@kvack.org>;
        Wed, 22 Jun 2016 22:26:16 -0700 (PDT)
Date: Thu, 23 Jun 2016 13:24:58 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 201/309] arch/arm/include/asm/atomic.h:47:2: note: in
 expansion of macro 'prefetchw'
Message-ID: <201606231355.aUHzGFWU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   90fbe8d8441dfa4fc00ac1bc49bc695ec2659b8e
commit: 5c3cf7b159aee92080899618bd0b578db6c0de85 [201/309] mm: move vmscan writes and file write accounting to the node
config: arm-allnoconfig (attached as .config)
compiler: arm-linux-gnueabi-gcc (Debian 5.3.1-8) 5.3.1 20160205
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 5c3cf7b159aee92080899618bd0b578db6c0de85
        # save the attached .config to linux build tree
        make.cross ARCH=arm 

All warnings (new ones prefixed by >>):

   In file included from arch/arm/include/asm/atomic.h:15:0,
                    from include/linux/atomic.h:4,
                    from include/linux/spinlock.h:406,
                    from include/linux/wait.h:8,
                    from include/linux/fs.h:5,
                    from include/linux/dax.h:4,
                    from mm/filemap.c:14:
   mm/filemap.c: In function '__delete_from_page_cache':
   include/linux/prefetch.h:42:22: warning: array subscript is above array bounds [-Warray-bounds]
    #define prefetchw(x) __builtin_prefetch(x,1)
                         ^
>> arch/arm/include/asm/atomic.h:47:2: note: in expansion of macro 'prefetchw'
     prefetchw(&v->counter);      \
     ^
>> arch/arm/include/asm/atomic.h:189:2: note: in expansion of macro 'ATOMIC_OP'
     ATOMIC_OP(op, c_op, asm_op)     \
     ^
>> arch/arm/include/asm/atomic.h:192:1: note: in expansion of macro 'ATOMIC_OPS'
    ATOMIC_OPS(add, +=, add)
    ^
   include/linux/prefetch.h:42:22: warning: array subscript is above array bounds [-Warray-bounds]
    #define prefetchw(x) __builtin_prefetch(x,1)
                         ^
>> arch/arm/include/asm/atomic.h:47:2: note: in expansion of macro 'prefetchw'
     prefetchw(&v->counter);      \
     ^
>> arch/arm/include/asm/atomic.h:189:2: note: in expansion of macro 'ATOMIC_OP'
     ATOMIC_OP(op, c_op, asm_op)     \
     ^
>> arch/arm/include/asm/atomic.h:192:1: note: in expansion of macro 'ATOMIC_OPS'
    ATOMIC_OPS(add, +=, add)
    ^

vim +/prefetchw +47 arch/arm/include/asm/atomic.h

aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   41  #define ATOMIC_OP(op, c_op, asm_op)					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   42  static inline void atomic_##op(int i, atomic_t *v)			\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   43  {									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   44  	unsigned long tmp;						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   45  	int result;							\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   46  									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  @47  	prefetchw(&v->counter);						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   48  	__asm__ __volatile__("@ atomic_" #op "\n"			\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   49  "1:	ldrex	%0, [%3]\n"						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   50  "	" #asm_op "	%0, %0, %4\n"					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   51  "	strex	%1, %0, [%3]\n"						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   52  "	teq	%1, #0\n"						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   53  "	bne	1b"							\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   54  	: "=&r" (result), "=&r" (tmp), "+Qo" (v->counter)		\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   55  	: "r" (&v->counter), "Ir" (i)					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   56  	: "cc");							\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   57  }									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   58  
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   59  #define ATOMIC_OP_RETURN(op, c_op, asm_op)				\
0ca326de7 arch/arm/include/asm/atomic.h Will Deacon       2015-08-06   60  static inline int atomic_##op##_return_relaxed(int i, atomic_t *v)	\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   61  {									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   62  	unsigned long tmp;						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   63  	int result;							\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   64  									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   65  	prefetchw(&v->counter);						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   66  									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   67  	__asm__ __volatile__("@ atomic_" #op "_return\n"		\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   68  "1:	ldrex	%0, [%3]\n"						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   69  "	" #asm_op "	%0, %0, %4\n"					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   70  "	strex	%1, %0, [%3]\n"						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   71  "	teq	%1, #0\n"						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   72  "	bne	1b"							\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   73  	: "=&r" (result), "=&r" (tmp), "+Qo" (v->counter)		\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   74  	: "r" (&v->counter), "Ir" (i)					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   75  	: "cc");							\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   76  									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23   77  	return result;							\
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16   78  }
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16   79  
0ca326de7 arch/arm/include/asm/atomic.h Will Deacon       2015-08-06   80  #define atomic_add_return_relaxed	atomic_add_return_relaxed
0ca326de7 arch/arm/include/asm/atomic.h Will Deacon       2015-08-06   81  #define atomic_sub_return_relaxed	atomic_sub_return_relaxed
0ca326de7 arch/arm/include/asm/atomic.h Will Deacon       2015-08-06   82  
0ca326de7 arch/arm/include/asm/atomic.h Will Deacon       2015-08-06   83  static inline int atomic_cmpxchg_relaxed(atomic_t *ptr, int old, int new)
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13   84  {
4dcc1cf73 arch/arm/include/asm/atomic.h Chen Gang         2013-10-26   85  	int oldval;
4dcc1cf73 arch/arm/include/asm/atomic.h Chen Gang         2013-10-26   86  	unsigned long res;
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13   87  
c32ffce0f arch/arm/include/asm/atomic.h Will Deacon       2014-02-21   88  	prefetchw(&ptr->counter);
bac4e960b arch/arm/include/asm/atomic.h Russell King      2009-05-25   89  
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13   90  	do {
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13   91  		__asm__ __volatile__("@ atomic_cmpxchg\n"
398aa6682 arch/arm/include/asm/atomic.h Will Deacon       2010-07-08   92  		"ldrex	%1, [%3]\n"
a7d068336 include/asm-arm/atomic.h      Nicolas Pitre     2005-11-16   93  		"mov	%0, #0\n"
398aa6682 arch/arm/include/asm/atomic.h Will Deacon       2010-07-08   94  		"teq	%1, %4\n"
398aa6682 arch/arm/include/asm/atomic.h Will Deacon       2010-07-08   95  		"strexeq %0, %5, [%3]\n"
398aa6682 arch/arm/include/asm/atomic.h Will Deacon       2010-07-08   96  		    : "=&r" (res), "=&r" (oldval), "+Qo" (ptr->counter)
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13   97  		    : "r" (&ptr->counter), "Ir" (old), "r" (new)
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13   98  		    : "cc");
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13   99  	} while (res);
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  100  
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  101  	return oldval;
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  102  }
0ca326de7 arch/arm/include/asm/atomic.h Will Deacon       2015-08-06  103  #define atomic_cmpxchg_relaxed		atomic_cmpxchg_relaxed
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  104  
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  105  static inline int __atomic_add_unless(atomic_t *v, int a, int u)
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  106  {
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  107  	int oldval, newval;
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  108  	unsigned long tmp;
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  109  
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  110  	smp_mb();
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  111  	prefetchw(&v->counter);
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  112  
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  113  	__asm__ __volatile__ ("@ atomic_add_unless\n"
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  114  "1:	ldrex	%0, [%4]\n"
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  115  "	teq	%0, %5\n"
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  116  "	beq	2f\n"
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  117  "	add	%1, %0, %6\n"
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  118  "	strex	%2, %1, [%4]\n"
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  119  "	teq	%2, #0\n"
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  120  "	bne	1b\n"
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  121  "2:"
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  122  	: "=&r" (oldval), "=&r" (newval), "=&r" (tmp), "+Qo" (v->counter)
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  123  	: "r" (&v->counter), "r" (u), "r" (a)
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  124  	: "cc");
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  125  
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  126  	if (oldval != u)
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  127  		smp_mb();
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  128  
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  129  	return oldval;
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  130  }
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  131  
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16  132  #else /* ARM_ARCH_6 */
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16  133  
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16  134  #ifdef CONFIG_SMP
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16  135  #error SMP not supported on pre-ARMv6 CPUs
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16  136  #endif
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16  137  
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  138  #define ATOMIC_OP(op, c_op, asm_op)					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  139  static inline void atomic_##op(int i, atomic_t *v)			\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  140  {									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  141  	unsigned long flags;						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  142  									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  143  	raw_local_irq_save(flags);					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  144  	v->counter c_op i;						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  145  	raw_local_irq_restore(flags);					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  146  }									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  147  
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  148  #define ATOMIC_OP_RETURN(op, c_op, asm_op)				\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  149  static inline int atomic_##op##_return(int i, atomic_t *v)		\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  150  {									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  151  	unsigned long flags;						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  152  	int val;							\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  153  									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  154  	raw_local_irq_save(flags);					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  155  	v->counter c_op i;						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  156  	val = v->counter;						\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  157  	raw_local_irq_restore(flags);					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  158  									\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  159  	return val;							\
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16  160  }
^1da177e4 include/asm-arm/atomic.h      Linus Torvalds    2005-04-16  161  
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  162  static inline int atomic_cmpxchg(atomic_t *v, int old, int new)
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  163  {
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  164  	int ret;
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  165  	unsigned long flags;
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  166  
8dd5c845b include/asm-arm/atomic.h      Lennert Buytenhek 2006-09-16  167  	raw_local_irq_save(flags);
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  168  	ret = v->counter;
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  169  	if (likely(ret == old))
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  170  		v->counter = new;
8dd5c845b include/asm-arm/atomic.h      Lennert Buytenhek 2006-09-16  171  	raw_local_irq_restore(flags);
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  172  
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  173  	return ret;
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  174  }
4a6dae6d3 include/asm-arm/atomic.h      Nick Piggin       2005-11-13  175  
f24219b4e arch/arm/include/asm/atomic.h Arun Sharma       2011-07-26  176  static inline int __atomic_add_unless(atomic_t *v, int a, int u)
8426e1f6a include/asm-arm/atomic.h      Nick Piggin       2005-11-13  177  {
8426e1f6a include/asm-arm/atomic.h      Nick Piggin       2005-11-13  178  	int c, old;
8426e1f6a include/asm-arm/atomic.h      Nick Piggin       2005-11-13  179  
8426e1f6a include/asm-arm/atomic.h      Nick Piggin       2005-11-13  180  	c = atomic_read(v);
8426e1f6a include/asm-arm/atomic.h      Nick Piggin       2005-11-13  181  	while (c != u && (old = atomic_cmpxchg((v), c, c + a)) != c)
8426e1f6a include/asm-arm/atomic.h      Nick Piggin       2005-11-13  182  		c = old;
f24219b4e arch/arm/include/asm/atomic.h Arun Sharma       2011-07-26  183  	return c;
8426e1f6a include/asm-arm/atomic.h      Nick Piggin       2005-11-13  184  }
8426e1f6a include/asm-arm/atomic.h      Nick Piggin       2005-11-13  185  
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  186  #endif /* __LINUX_ARM_ARCH__ */
db38ee874 arch/arm/include/asm/atomic.h Will Deacon       2014-02-21  187  
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  188  #define ATOMIC_OPS(op, c_op, asm_op)					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23 @189  	ATOMIC_OP(op, c_op, asm_op)					\
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  190  	ATOMIC_OP_RETURN(op, c_op, asm_op)
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  191  
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23 @192  ATOMIC_OPS(add, +=, add)
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  193  ATOMIC_OPS(sub, -=, sub)
aee9a5545 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-03-23  194  
125897908 arch/arm/include/asm/atomic.h Peter Zijlstra    2014-04-23  195  #define atomic_andnot atomic_andnot

:::::: The code at line 47 was first introduced by commit
:::::: aee9a55452f0371258e18b41649ce650ff344090 locking,arch,arm: Fold atomic_ops

:::::: TO: Peter Zijlstra <peterz@infradead.org>
:::::: CC: Ingo Molnar <mingo@kernel.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--fdj2RfSjLxBAspz7
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--fdj2RfSjLxBAspz7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
