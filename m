Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 272036B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 18:18:24 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v48so29098591qtc.12
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 15:18:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b5si5766277qkg.144.2017.03.31.15.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 15:18:23 -0700 (PDT)
Date: Fri, 31 Mar 2017 15:18:18 -0700
From: Jessica Yu <jeyu@redhat.com>
Subject: Re: [PATCH v2] module: check if memory leak by module.
Message-ID: <20170331221818.jc5werfzszwbjwbh@jeyu>
References: <alpine.LSU.2.20.1703290958390.4250@pobox.suse.cz>
 <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
 <20170329074522.GB27994@dhcp22.suse.cz>
 <CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcms5p1>
 <20170329092332epcms5p10ae8263c6e3ef14eac40e08a09eff9e6@epcms5p1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170329092332epcms5p10ae8263c6e3ef14eac40e08a09eff9e6@epcms5p1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaneet Narang <v.narang@samsung.com>
Cc: Miroslav Benes <mbenes@suse.cz>, Michal Hocko <mhocko@kernel.org>, Maninder Singh <maninder1.s@samsung.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris@chris-wilson.co.uk" <chris@chris-wilson.co.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "joonas.lahtinen@linux.intel.com" <joonas.lahtinen@linux.intel.com>, "keescook@chromium.org" <keescook@chromium.org>, "pavel@ucw.cz" <pavel@ucw.cz>, "jinb.park7@gmail.com" <jinb.park7@gmail.com>, "anisse@astier.eu" <anisse@astier.eu>, "rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>, "zijun_hu@htc.com" <zijun_hu@htc.com>, "mingo@kernel.org" <mingo@kernel.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "thgarnie@google.com" <thgarnie@google.com>, "joelaf@google.com" <joelaf@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, PANKAJ MISHRA <pankaj.m@samsung.com>, Ajeet Kumar Yadav <ajeet.y@samsung.com>, =?utf-8?B?7J207ZWZ67SJ?= <hakbong5.lee@samsung.com>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, =?utf-8?B?656E66a/?= <lalit.mohan@samsung.com>, CPGS <cpgs@samsung.com>

+++ Vaneet Narang [29/03/17 09:23 +0000]:
>Hi,
>
>>> Hmm, how can you track _all_ vmalloc allocations done on behalf of the
>>> module? It is quite some time since I've checked kernel/module.c but
>>> from my vague understading your check is basically only about statically
>>> vmalloced areas by module loader. Is that correct? If yes then is this
>>> actually useful? Were there any bugs in the loader code recently? What
>>> led you to prepare this patch? All this should be part of the changelog!
>
>First of all there is no issue in kernel/module.c. This patch add functionality
>to detect scenario where some kernel module does some memory allocation but gets
>unloaded without doing vfree. For example
>static int kernel_init(void)
>{
>        char * ptr = vmalloc(400 * 1024);
>        return 0;
>}
>
>static void kernel_exit(void)
>{
>}
>
>Now in this case if we do rmmod then memory allocated by kernel_init
>will not be freed but this patch will detect such kind of bugs in kernel module
>code.

kmemleak already detects leaks just like this, and it is not just
limited to vmalloc (but also kmalloc, kmem_cache_alloc, etc). See
mm/kmemleak-test.c, it is exactly like your example.

Also, this patch is currently limited to direct vmalloc allocations
from module core code (since you are only checking for vmalloc callers
originating from mod->core_layout, not mod->init_layout, which is
discarded at the end of do_init_module(). If we want to be complete,
we'd have to do another leak check before module init code is freed.

>Also We have seen bugs in some kernel modules where they allocate some memory and
>gets removed without freeing them and if new module gets loaded in place
>of removed module then /proc/vmallocinfo shows wrong information. vmalloc info will
>show pages getting allocated by new module. So these logs will help in detecting
>such issues.

This is an unfortunate side effect of having dynamically loadable modules.
After a module is gone, sprint_symbol() (which is used to display caller
information in /proc/vmallocinfo) simply cannot trace an address back to
a module that no longer exists, it is a natural limitation, and I'm not really
sure if there's much we can do about it. When chasing leaks like this,
one possibility might be to leave the module loaded so vmallocinfo can report
accurate information, and then compare the reported information after the
module unloads.

And unfortunately, this patch also demonstrates the same problem you're describing:

(1) Load leaky_module and read /proc/vmallocinfo:
0xffffa8570005d000-0xffffa8570005f000    8192 leaky_function+0x2f/0x75 [leaky_module] pages=1 vmalloc N0=1

(2) Unload leaky_module and read /proc/vmallocinfo:
0xffffa8570005d000-0xffffa8570005f000    8192 0xffffffffc038902f pages=1 vmalloc N0=1
                                              ^^^ missing caller symbol since module is now gone
On module unload, your patch prints:
[  289.834428] Module [leaky_module] is getting unloaded before doing vfree
[  289.835226] Memory still allocated: addr:0xffffa8570005d000 - 0xffffa8570005f000, pages 1
[  289.836185] Allocating function leaky_function+0x2f/0x75 [leaky_module]

Ok, so far that looks fine. But kmemleak also provides information about the same leak:

  unreferenced object 0xffffa8570005d000 (size 64):
    comm "insmod", pid 114, jiffies 4294673713 (age 208.968s)
    hex dump (first 32 bytes):
      e6 7e 00 00 00 00 00 00 0a 00 00 00 16 00 00 00  .~..............
      21 52 00 00 00 00 00 00 f4 7e 00 00 00 00 00 00  !R.......~......
    backtrace:
      [<ffffffff838415ca>] kmemleak_alloc+0x4a/0xa0
      [<ffffffff83214df4>] __vmalloc_node_range+0x1e4/0x300
      [<ffffffff83214fb4>] vmalloc+0x54/0x60
      [<ffffffffc038902f>] leaky_function+0x2f/0x75 [leaky_module]
      [<ffffffffc038e00b>] 0xffffffffc038e00b
      [<ffffffff83002193>] do_one_initcall+0x53/0x1a0
      [<ffffffff831bfca1>] do_init_module+0x5f/0x1ff
      [<ffffffff8313189f>] load_module+0x273f/0x2b00
      [<ffffffff83131dc6>] SYSC_init_module+0x166/0x180
      [<ffffffff83131efe>] SyS_init_module+0xe/0x10
      [<ffffffff8384d177>] entry_SYSCALL_64_fastpath+0x1a/0xa9
      [<ffffffffffffffff>] 0xffffffffffffffff

(3) Load test_module, which happens to load where leaky_module used to reside in memory:
0xffffa8570005d000-0xffffa8570005f000    8192 test_module_exit+0x2f/0x1000 [test_module] pages=1 vmalloc N0=1
                                              ^^^ incorrect caller, because test_module loaded where old caller used to be

(4) Unload test_module and your patch prints:
[  459.140089] Module [test_module] is getting unloaded before doing vfree
[  459.140551] Memory still allocated: addr:0xffffa8570005d000 - 0xffffa8570005f000, pages 1
[  459.141127] Allocating function test_module_exit+0x2f/0x1000 [test_module] <- incorrect caller

So unfortunately this patch also runs into the same problem, reporting
the incorrect caller, and I'm not really convinced that this patch
adds new information that isn't already available with kmemleak and
/proc/vmallocinfo.

Jessica

>> >  static void free_module(struct module *mod)
>> >  {
>> > +	check_memory_leak(mod);
>> > +
>
>>Of course, vfree() has not been called yet. It is the beginning of
>>free_module(). vfree() is one of the last things you need to do. See
>>module_memfree(). If I am not missing something, you get pr_err()
>>everytime a module is unloaded.
>
>This patch is not to detect memory allocated by kernel. module_memfree
>will allocated by kernel for kernel modules but our intent is to detect
>memory allocated directly by kernel modules and not getting freed.
>
>Regards,
>Vaneet Narang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
