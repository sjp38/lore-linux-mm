Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 196786B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 12:48:40 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id g67so11785687qkf.11
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 09:48:40 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s3sor4896820qkb.98.2017.11.13.09.48.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Nov 2017 09:48:39 -0800 (PST)
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Subject: Allocation failure of ring buffer for trace
Message-ID: <9631b871-99cc-82bb-363f-9d429b56f5b9@gmail.com>
Date: Mon, 13 Nov 2017 12:48:36 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: rostedt@goodmis.org, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, koki.sanagi@us.fujitsu.com

When using trace_buf_size= boot option, memory allocation of ring buffer
for trace fails as follows:

[ ] x86: Booting SMP configuration:
[ ] .... node  #0, CPUs:          #1   #2   #3   #4   #5   #6   #7   #8   #9  #10  #11  #12  #13  #14  #15  #16  #17  #18  #19  #20  #21  #22  #23
[ ] .... node  #1, CPUs:    #24  #25  #26  #27  #28  #29  #30  #31  #32  #33  #34  #35  #36  #37  #38  #39  #40  #41  #42  #43  #44  #45  #46  #47
[ ] .... node  #2, CPUs:    #48  #49  #50  #51  #52  #53  #54  #55  #56  #57  #58  #59  #60  #61  #62  #63  #64  #65  #66  #67  #68  #69  #70  #71
[ ] .... node  #3, CPUs:    #72  #73  #74  #75  #76  #77  #78  #79  #80  #81  #82  #83  #84  #85  #86  #87  #88  #89  #90  #91  #92  #93  #94  #95
[ ] .... node  #4, CPUs:    #96  #97  #98  #99 #100 #101 #102 #103 #104 #105 #106 #107 #108 #109 #110 #111 #112 #113 #114 #115 #116 #117 #118 #119
[ ] .... node  #5, CPUs:   #120 #121 #122 #123 #124 #125 #126 #127 #128 #129 #130 #131 #132 #133 #134 #135 #136 #137 #138 #139 #140 #141 #142 #143
[ ] .... node  #6, CPUs:   #144 #145 #146 #147 #148 #149 #150 #151 #152 #153 #154
[ ] swapper/0: page allocation failure: order:0, mode:0x16004c0(GFP_KERNEL|__GFP_RETRY_MAYFAIL|__GFP_NOTRACK), nodemask=(null)
[ ] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.14.0-rc8+ #13
[ ] Hardware name: ...
[ ] Call Trace:
[ ]  dump_stack+0x63/0x89
[ ]  warn_alloc+0x114/0x1c0
[ ]  ? _find_next_bit+0x60/0x60
[ ]  __alloc_pages_slowpath+0x9a6/0xba7
[ ]  __alloc_pages_nodemask+0x26a/0x290
[ ]  new_slab+0x297/0x500
[ ]  ___slab_alloc+0x335/0x4a0
[ ]  ? __rb_allocate_pages+0xae/0x180
[ ]  ? __rb_allocate_pages+0xae/0x180
[ ]  __slab_alloc+0x40/0x66
[ ]  __kmalloc_node+0xbd/0x270
[ ]  __rb_allocate_pages+0xae/0x180
[ ]  rb_allocate_cpu_buffer+0x204/0x2f0
[ ]  trace_rb_cpu_prepare+0x7e/0xc5
[ ]  cpuhp_invoke_callback+0x3ea/0x5c0
[ ]  ? init_idle+0x1a7/0x1c0
[ ]  ? ring_buffer_record_is_on+0x20/0x20
[ ]  _cpu_up+0xbc/0x190
[ ]  do_cpu_up+0x87/0xb0
[ ]  cpu_up+0x13/0x20
[ ]  smp_init+0x69/0xca
[ ]  kernel_init_freeable+0x115/0x244
[ ]  ? rest_init+0xb0/0xb0
[ ]  kernel_init+0xe/0x109
[ ]  ret_from_fork+0x25/0x30
[ ] Mem-Info:
[ ] active_anon:0 inactive_anon:0 isolated_anon:0
[ ]  active_file:0 inactive_file:0 isolated_file:0
[ ]  unevictable:0 dirty:0 writeback:0 unstable:0
[ ]  slab_reclaimable:1260 slab_unreclaimable:489185
[ ]  mapped:0 shmem:0 pagetables:0 bounce:0
[ ]  free:46 free_pcp:1421 free_cma:0
.
[ ] failed to allocate ring buffer on CPU 155

In my server, there are 384 CPUs, 512 GB memory and 8 nodes. And
"trace_buf_size=100M" is set.

When using trace_buf_size=100M, kernel allocates 100 MB memory
per CPU before calling free_are_init_core(). Kernel tries to
allocates 38.4GB (100 MB * 384 CPU) memory. But available memory
at this time is about 16GB (2 GB * 8 nodes) due to the following commit:

  3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages
                 if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")

So allocation failure occurs.

Thanks,
Yasuaki Ishimatsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
