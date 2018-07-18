Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 867206B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 22:56:37 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w1-v6so1694505plq.8
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 19:56:37 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id t10-v6si2378620pge.624.2018.07.17.19.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 19:56:35 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v2 7/7] swap, put_swap_page: Share more between huge/normal code path
References: <20180717005556.29758-1-ying.huang@intel.com>
	<20180717005556.29758-8-ying.huang@intel.com>
	<98288fec-1199-1b25-8c8c-18d60c33e596@linux.intel.com>
Date: Wed, 18 Jul 2018 10:56:32 +0800
In-Reply-To: <98288fec-1199-1b25-8c8c-18d60c33e596@linux.intel.com> (Dave
	Hansen's message of "Tue, 17 Jul 2018 11:36:54 -0700")
Message-ID: <87k1ptgskf.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

> On 07/16/2018 05:55 PM, Huang, Ying wrote:
>> 		text	   data	    bss	    dec	    hex	filename
>> base:	       24215	   2028	    340	  26583	   67d7	mm/swapfile.o
>> unified:       24577	   2028	    340	  26945	   6941	mm/swapfile.o
>
> That's a bit more than I'd expect looking at the rest of the diff.  Make
> me wonder if we missed an #ifdef somewhere or the compiler is getting
> otherwise confused.
>
> Might be worth a 10-minute look at the disassembly.

Dig one step deeper via 'size -A mm/swapfile.o' and diff between base
and unified,

--- b.s	2018-07-18 09:42:07.872501680 +0800
+++ h.s	2018-07-18 09:50:37.984499168 +0800
@@ -1,6 +1,6 @@
 mm/swapfile.o  :
 section                               size   addr
-.text                                17815      0
+.text                                17927      0
 .data                                 1288      0
 .bss                                   340      0
 ___ksymtab_gpl+nr_swap_pages             8      0
@@ -26,8 +26,8 @@
 .data.once                               1      0
 .comment                                35      0
 .note.GNU-stack                          0      0
-.orc_unwind_ip                        1380      0
-.orc_unwind                           2070      0
-Total                                26810
+.orc_unwind_ip                        1480      0
+.orc_unwind                           2220      0
+Total                                27172

The total difference is same: 27172 - 26810 = 362 = 24577 - 24215.

The text section difference is small: 17927 - 17815 = 112.  The
additional size change comes from unwinder information: (1480 + 2220) -
(1380 + 2070) = 250.  If the frame pointer unwinder is chosen, this cost
nothing, but if the ORC unwinder is chosen, this is the real difference.

For 112 text section difference, use 'objdump -t' to get symbol size and
compare,

--- b.od	2018-07-18 10:45:05.768483075 +0800
+++ h.od	2018-07-18 10:44:39.556483204 +0800
@@ -30,9 +30,9 @@
 00000000000000a3 cluster_list_add_tail
 000000000000001e __kunmap_atomic.isra.34
 000000000000018c swap_count_continued
-00000000000000ac __swap_entry_free
 000000000000000f put_swap_device.isra.35
 00000000000000b4 inc_cluster_info_page
+000000000000006f __swap_entry_free_locked
 000000000000004a _enable_swap_info
 0000000000000046 wait_on_page_writeback
 000000000000002e inode_to_bdi
@@ -53,8 +53,8 @@
 0000000000000012 __x64_sys_swapon
 0000000000000011 __ia32_sys_swapon
 000000000000007a get_swap_device
-0000000000000032 swap_free
-0000000000000035 put_swap_page
+000000000000006e swap_free
+0000000000000078 put_swap_page
 0000000000000267 swapcache_free_entries
 0000000000000058 page_swapcount
 000000000000003a __swap_count
@@ -64,7 +64,7 @@
 000000000000011a try_to_free_swap
 00000000000001fb get_swap_pages
 0000000000000098 get_swap_page_of_type
-00000000000001b8 free_swap_and_cache
+00000000000001e6 free_swap_and_cache
 0000000000000543 try_to_unuse
 000000000000000e __x64_sys_swapoff
 000000000000000d __ia32_sys_swapoff

The size of put_swap_page() change is small: 0x78 - 0x35 = 67.  But
__swap_entry_free() is inlined by compiler, which cause some code
dilating.

Best Regards,
Huang, Ying
