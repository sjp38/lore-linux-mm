Message-ID: <48FEE616.6050603@tensilica.com>
Date: Wed, 22 Oct 2008 01:36:38 -0700
From: Piet Delaney <piet.delaney@tensilica.com>
MIME-Version: 1.0
Subject: Initialization of init_pid_ns.pid_cachep->nodelists[]
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Piet Delaney <piet.delaney@tensilica.com>
List-ID: <linux-mm.kvack.org>

I'm working on a 2.6.24 kernel with SPINLOCK debug enabled I ran into a 
NULL pointer in nit_pid_ns.pid_cachep->nodelists[].
Problem occurs while creating the pid cache:

   #0          panic (fmt=0xd01fd500 "kmem_list3 == 
NU"...)                                         at 
/export/src/xtensa-2.6.24-smp/kernel/panic.c:77
   #1         do_tune_cpucache (cachep=0xd3803f00, limit=0x20, 
batchcount=0x10, shared=0x8)         at 
/export/src/xtensa-2.6.24-smp/mm/slab.c:3962
   #2        enable_cpucache 
(cachep=0xd3803f00)                                                    
at /export/src/xtensa-2.6.24-smp/mm/slab.c:4022
   #3       setup_cpu_cache 
(cachep=0xd3803f00)                                                     
at /export/src/xtensa-2.6.24-smp/mm/slab.c:2088
   #4      kmem_cache_create (name=0xd38054b4 "pid_1", size=0x48, 
align=0x8, flags=0x12c00, ctor=0) at 
/export/src/xtensa-2.6.24-smp/mm/slab.c:2401
   #5     create_pid_cachep 
(nr_ids=0x1)                                                            
at /export/src/xtensa-2.6.24-smp/kernel/pid.c:520
   #6    pidmap_init 
()                                                                             
at /export/src/xtensa-2.6.24-smp/kernel/pid.c:696
   #7   start_kernel 
()                                                                             
at /export/src/xtensa-2.6.24-smp/init/main.c:616
   #8  _startup 
()                                                                                  
at /export/src/xtensa-2.6.24-smp/arch/xtensa/kernel/head.S:250

It appears that a kmem_cache is initialized in
            set_up_list3s() to point to initkmem_list3[].
          init_list() to a newly allocated list

Looks like setup_cpu_cache() above #3 didn't call  set_up_list3s() due to
g_cpucache_up being set to FULL. g_cpucache_up is set to FULL in  
kmem_cache_init()
which was called from start_kernel() much earlier that the call to 
pidmap_init().

How was nodelist to this newly created kmem_cache for pids
suppose to have been initialized by the time it gets here?

-piet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
