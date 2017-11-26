Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD836B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 14:38:34 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id a72so18696376ioe.13
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 11:38:34 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g64si11825087ite.49.2017.11.26.11.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 11:38:32 -0800 (PST)
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
From: Wengang Wang <wen.gang.wang@oracle.com>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <08db0958-220a-f31e-0ddb-273d7126150e@virtuozzo.com>
 <9659392e-2b59-901e-a3bc-570946729b12@oracle.com>
Message-ID: <d4e34938-40b7-4b2c-fb4b-3fad36e4c6f1@oracle.com>
Date: Sun, 26 Nov 2017 11:37:21 -0800
MIME-Version: 1.0
In-Reply-To: <9659392e-2b59-901e-a3bc-570946729b12@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org
Cc: glider@google.com, dvyukov@google.com



On 2017/11/22 11:29, Wengang Wang wrote:
>
>
> On 2017/11/22 4:04, Andrey Ryabinin wrote:
>> On 11/18/2017 01:30 AM, Wengang Wang wrote:
>>> Kasan advanced check, I'm going to add this feature.
>>> Currently Kasan provide the detection of use-after-free and 
>>> out-of-bounds
>>> problems. It is not able to find the overwrite-on-allocated-memory 
>>> issue.
>>> We sometimes hit this kind of issue: We have a messed up structure
>>> (usually dynamially allocated), some of the fields in the structure 
>>> were
>>> overwritten with unreasaonable values. And kernel may panic due to 
>>> those
>>> overeritten values. We know those fields were overwritten somehow, 
>>> but we
>>> have no easy way to find out which path did the overwritten. The 
>>> advanced
>>> check wants to help in this scenario.
>>>
>>> The idea is to define the memory owner. When write accesses come from
>>> non-owner, error should be reported. Normally the write accesses on 
>>> a given
>>> structure happen in only several or a dozen of functions if the 
>>> structure
>>> is not that complicated. We call those functions "allowed functions".
>>> The work of defining the owner and binding memory to owner is 
>>> expected to
>>> be done by the memory consumer. In the above case, memory consume 
>>> register
>>> the owner as the functions which have write accesses to the 
>>> structure then
>>> bind all the structures to the owner. Then kasan will do the "owner 
>>> check"
>>> after the basic checks.
>>>
>>> As implementation, kasan provides a API to it's user to register their
>>> allowed functions. The API returns a token to users.A  At run time, 
>>> users
>>> bind the memory ranges they are interested in to the check they 
>>> registered.
>>> Kasan then checks the bound memory ranges with the allowed functions.
>>>
>> NAK. We don't add APIs with no users in the kernel.
>> If nothing in the kernel uses this API than there is no way to tell 
>> if this works or not.
If the concern is just if this works or not. I think the last patch in 
the set is a user of owner check. It shows the owner check works well.

A copy of one report is like this:
2134 [A  448.477923] 
==================================================================
2135 [A  448.565140] BUG: KASAN: Non-owner write access violation in 
funcB+0xd/0x3d [test_kasan]
2136 [A  448.661699] Write of size 1 at addr ffff881fa516e90c by task 
insmod/5606
2137 [A  448.742314]
2138 [A  448.760514] CPU: 3 PID: 5606 Comm: insmod Tainted: G BA A A A A  OEA A  
4.14.0-rc8 #9
2139 [A  448.760517] Hardware name: Oracle Corporation ORACLE SERVER 
X6-2/ASM,MOTHERBOARD,1U, BIOS 38050100 08/30/2016
2140 [A  448.760519] Call Trace:
2141 [A  448.760529]A  dump_stack+0x63/0x8d
2142 [A  448.760538]A  print_address_description+0x7c/0x290
2143 [A  448.760547]A  kasan_report+0x274/0x3d0
2144 [A  448.760554]A  ? kasan_kmalloc+0xad/0xe0
2145 [A  448.760566]A  ? funcB+0xd/0x3d [test_kasan]
2146 [A  448.760578]A  ? kasan_adv+0x1f3/0x1f3 [test_kasan]
2147 [A  448.760585]A  __asan_store1+0xa4/0xb0
2148 [A  448.760597]A  ? funcB+0xd/0x3d [test_kasan]
2149 [A  448.760608]A  funcB+0xd/0x3d [test_kasan]
2150 [A  448.760620]A  kasan_adv+0x12a/0x1f3 [test_kasan]
2151 [A  448.760633]A  ? copy_user_test+0x1ba/0x1ba [test_kasan]
2152 [A  448.760641]A  ? percpu_counter_add_batch+0x22/0xa0
2153 [A  448.760646]A  ? 0xffffffffa0dd0000
2154 [A  448.760657]A  ? funcA+0x20/0x20 [test_kasan]
2155 [A  448.760667]A  ? do_munmap+0x52e/0x6a0
2156 [A  448.760675]A  ? vm_munmap+0xd8/0x110
2157 [A  448.760684]A  ? kasan_slab_free+0x89/0xc0
2158 [A  448.760690]A  ? kfree+0x95/0x190
2159 [A  448.760702]A  ? kasan_adv+0x1f3/0x1f3 [test_kasan]
2160 [A  448.760714]A  ? copy_user_test+0x1b3/0x1ba [test_kasan]
2161 [A  448.760726]A  kmalloc_tests_init+0x84/0xf89 [test_kasan]
2162 [A  448.760733]A  do_one_initcall+0xa6/0x210
2163 [A  448.760740]A  ? initcall_blacklisted+0x150/0x150
2164 [A  448.760748]A  ? kasan_unpoison_shadow+0x36/0x50
2165 [A  448.760755]A  ? kasan_kmalloc+0xad/0xe0
2166 [A  448.760762]A  ? kasan_unpoison_shadow+0x36/0x50
2167 [A  448.760770]A  ? __asan_register_globals+0x87/0xa0
2168 [A  448.760779]A  do_init_module+0xf4/0x312
2169 [A  448.760786]A  load_module+0x283a/0x3120
2170 [A  448.760802]A  ? layout_and_allocate+0x18b0/0x18b0
2171 [A  448.760809]A  ? vmap_page_range_noflush+0x2e3/0x400
2172 [A  448.760821]A  SYSC_init_module+0x1c3/0x1e0
2173 [A  448.760826]A  ? SYSC_init_module+0x1c3/0x1e0
2174 [A  448.760831]A  ? load_module+0x3120/0x3120
2175 [A  448.760839]A  ? SYSC_finit_module+0x1a0/0x1a0
2176 [A  448.760845]A  SyS_init_module+0xe/0x10
2177 [A  448.760851]A  do_syscall_64+0xe3/0x270
2178 [A  448.760860]A  entry_SYSCALL64_slow_path+0x25/0x25
2179 [A  448.760865] RIP: 0033:0x35f80e923a
2180 [A  448.760868] RSP: 002b:00007ffc8835e9a8 EFLAGS: 00000202 
ORIG_RAX: 00000000000000af
2181 [A  448.760875] RAX: ffffffffffffffda RBX: 00007ffc8835f4ff RCX: 
00000035f80e923a
2182 [A  448.760879] RDX: 00000000016d3010 RSI: 0000000000044f78 RDI: 
00007fedf04b9010
2183 [A  448.760883] RBP: 00000000016d3010 R08: 0000000000081000 R09: 
0000000000041000
2184 [A  448.760886] R10: 00000035f80db710 R11: 0000000000000202 R12: 
0000000000044f78
2185 [A  448.760890] R13: 0000000000080000 R14: 00007fedf04b9010 R15: 
0000000000000003
2186 [A  448.760894]
2187 [A  448.779081] Allocated by task 5606:
2188 [A  448.821206]A  save_stack_trace+0x1b/0x20
2189 [A  448.821212]A  save_stack+0x46/0xd0
2190 [A  448.821218]A  kasan_kmalloc+0xad/0xe0
2191 [A  448.821224]A  kmem_cache_alloc_trace+0xf0/0x1e0
2192 [A  448.821235]A  kasan_adv+0xe1/0x1f3 [test_kasan]
2193 [A  448.821246]A  kmalloc_tests_init+0x84/0xf89 [test_kasan]
2194 [A  448.821252]A  do_one_initcall+0xa6/0x210
2195 [A  448.821256]A  do_init_module+0xf4/0x312
2196 [A  448.821261]A  load_module+0x283a/0x3120
2197 [A  448.821265]A  SYSC_init_module+0x1c3/0x1e0
2198 [A  448.821269]A  SyS_init_module+0xe/0x10
2199 [A  448.821275]A  do_syscall_64+0xe3/0x270
2200 [A  448.821282]A  return_from_SYSCALL_64+0x0/0x6a
2201 [A  448.821284]
2202 [A  448.839471] Freed by task 0:
2203 [A  448.874305] (stack is not available)
2204 [A  448.917458]
2205 [A  448.935655] The buggy address belongs to the object at 
ffff881fa516e900
2206 [A  448.935655]A  which belongs to the cache kmalloc-64 of size 64
2207 [A  449.084234] The buggy address is located 12 bytes inside of
2208 [A  449.084234]A  64-byte region [ffff881fa516e900, ffff881fa516e940)
2209 [A  449.223442] The buggy address belongs to the page:
2210 [A  449.281170] page:ffffea007e945b80 count:1 mapcount:0 
mapping:A A A A A A A A A  (null) index:0x0
2211 [A  449.377720] flags: 0x2fffff80000100(slab)
2212 [A  449.426094] raw: 002fffff80000100 0000000000000000 
0000000000000000 00000001802a002a
2213 [A  449.519525] raw: dead000000000100 dead000000000200 
ffff881fff40f640 0000000000000000
2214 [A  449.612961] page dumped because: kasan: bad access detected
2215 [A  449.680054]
2216 [A  449.698244] Memory state around the buggy address:
2217 [A  449.755972]A  ffff881fa516e800: fb fb fb fb fc fc fc fc fb fb fb 
fb fb fb fb fb
2218 [A  449.843154]A  ffff881fa516e880: fc fc fc fc fb fb fb fb fb fb fb 
fb fc fc fc fc
2219 [A  449.930345] >ffff881fa516e900: 30 30 30 30 00 00 00 06 fc fc fc 
fc fc fc fc fc
2220 [A  450.017535]A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  ^
2221 [A  450.059660]A  ffff881fa516e980: fc fc fc fc fc fc fc fc fc fc fc 
fc fc fc fc fc
2222 [A  450.146846]A  ffff881fa516ea00: fc fc fc fc fc fc fc fc fc fc fc 
fc fc fc fc fc
2223 [A  450.234027] 
==================================================================

The "^" is pointing to the second "30" in above line (not sure it shows 
correctly after copy/paste)

thanks,
wengang

> In production kernel, we don't want unnecessary APIs without users in 
> the kernel because that
> would consume binary size (a pure space waste) and leave "dead" code.
> KASAN code is a bit different from other kernel components, its self 
> is debugging purpose only.
> When KASAN is enabled, the APIs would have potential users and the 
> code is not "dead" code.
> The size increasing in binary would be acceptable since the kernel 
> with KASAN enabled only has
> a short time life -- only used to find the root cause, when root 
> caused is found, it will be no
> longer used;A  Also the KASAN enabled kernel is used by limited user 
> where they have a particular
> issue. I say "potential users" because this functionality its self is 
> dynamically used or to say a
> one-shot use. The functionality is helpful.
>
> I think even KASAN its self we don't know if it works or not when it 
> is not enabled.
> -- Before I tried it, I am curious if this can work well; After 
> testing it, I know it works.
> If we don't give users the chance, they will never know there is such 
> a functionality and will never
> get benefit from it.
>
>
>> Besides, I'm bit skeptical about usefulness of this feature. Those 
>> kinds of issues that
>> advanced check is supposed to catch, is almost always is just some 
>> sort of longstanding
>> use after free, which eventually should be caught by kasan.
> Yes, if luckily, the issue is possible to be catched by UAF check.
> Well considering busy production systems, the memory is very likely to 
> be reallocated rather than
> staying in free state for very long time.A  That is the 
> overwritten-to-allocated-memory is more
> likely to happen than UAF does I think.A  When 
> overwritten-to-allocated-memory happened,
> UAF check has no chance to detect the problem.
>
> KASAN is helpful to detect problematic memory usage, so does this 
> patch set!
> I really hope this can be included and developers can get benefit from 
> it.
>
> Thanks,
> Wengang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
