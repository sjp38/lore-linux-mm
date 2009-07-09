Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D5C9D6B005A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 10:25:53 -0400 (EDT)
Received: from coyote.coyote.den ([72.65.71.44]) by vms173013.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KMI00G8FRJ23U40@vms173013.mailsrvcs.net> for
 linux-mm@kvack.org; Thu, 09 Jul 2009 09:42:39 -0500 (CDT)
From: Gene Heskett <gene.heskett@verizon.net>
Subject: Re: OOM killer in 2.6.31-rc2
Date: Thu, 09 Jul 2009 10:42:37 -0400
References: <200907061056.00229.gene.heskett@verizon.net>
 <20090708051515.GA17156@localhost> <20090708075501.GA1122@localhost>
In-reply-to: <20090708075501.GA1122@localhost>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7bit
Content-disposition: inline
Message-id: <200907091042.38022.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 08 July 2009, Wu Fengguang wrote:
>On Wed, Jul 08, 2009 at 01:15:15PM +0800, Wu Fengguang wrote:
>> On Tue, Jul 07, 2009 at 11:42:07PM -0400, Gene Heskett wrote:
[...]
>> I guess your near 800MB slab cache is somehow under scanned.
>
>Gene, can you run .31 with this patch? When OOM happens, it will tell
>us whether the majority slab pages are reclaimable. Another way to
>find things out is to run `slabtop` when your system is moderately loaded.

Its been running continuously, and after 24 hours is now showing:

 Active / Total Objects (% used)    : 578136 / 869737 (66.5%)
 Active / Total Slabs (% used)      : 35832 / 35836 (100.0%)
 Active / Total Caches (% used)     : 104 / 163 (63.8%)
 Active / Total Size (% used)       : 115103.39K / 135776.88K (84.8%)
 Minimum / Average / Maximum Object : 0.01K / 0.16K / 4096.00K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
439989 179391  40%    0.05K   6567       67     26268K buffer_head
126237 126222  99%    0.13K   4353       29     17412K dentry
121296 121296 100%    0.48K  15162        8     60648K ext3_inode_cache
 64779  47350  73%    0.28K   4983       13     19932K radix_tree_node
 17158  16014  93%    0.08K    373       46      1492K vm_area_struct
 14250  14250 100%    0.12K    475       30      1900K size-128
 12600  12544  99%    0.04K    150       84       600K sysfs_dir_cache
 11187  10813  96%    0.03K     99      113       396K size-32
  9170   9170 100%    0.36K    917       10      3668K proc_inode_cache
  8820   7560  85%    0.12K    294       30      1176K filp
  8791   6107  69%    0.06K    149       59       596K size-64
  6858   5532  80%    0.01K     27      254       108K anon_vma
  3213   3157  98%    0.06K     51       63       204K 
inotify_inode_mark_entry
  2392   2319  96%    0.04K     26       92       104K Acpi-Operand
  2020    778  38%    0.19K    101       20       404K skbuff_head_cache
  1467   1442  98%    0.43K    163        9       652K shmem_inode_cache
  1352   1212  89%    0.02K      8      169        32K Acpi-Namespace
  1350    579  42%    0.12K     45       30       180K cred_jar
  1288   1252  97%    0.50K    161        8       644K size-512
  1121   1062  94%    0.06K     19       59        76K pid
   998    990  99%    2.00K    499        2      1996K size-2048
   780    665  85%    0.05K     10       78        40K ext3_xattr
   702    653  93%    0.14K     27       26       108K idr_layer_cache
   668    567  84%    1.00K    167        4       668K size-1024
   650    547  84%    0.38K     65       10       260K sock_inode_cache
   594    442  74%    0.44K     66        9       264K UNIX
   585    474  81%    0.25K     39       15       156K size-256
   560    526  93%    0.19K     28       20       112K size-192
   555    272  49%    0.25K     37       15       148K ip_dst_cache
   539    423  78%    0.34K     49       11       196K inode_cache
   452    198  43%    0.03K      4      113        16K fs_cache

Is there anything unusual there?

>Thanks,
>Fengguang
>---
>From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
>Subject: [PATCH] add per-zone statistics to show_free_areas()
>
>Currently, show_free_area() mainly display system memory usage. but it
>doesn't display per-zone memory usage information.
>
>However, if DMA zone OOM occur, Administrator definitely need to know
>per-zone memory usage information.
[...]
To Wu Fengguang, David H., Rafael W., lkml:

With this patch, the newest bios for this board, and without the 
CONFIG_HIGHMEM64G in the config, 2.6.31-rc2 has achieved a full days uptime.
I did do a swapoff -a; swapon -a about an hour into the boot to zero the swap, 
and in nearly 24 hours it hasn't used any.  No oom's that I can find in the 
logs.

If the 64G highmem option, and this bios meet on this machine, the crash is at 
least 20 hours overdue.  But it appears to be 100% normal yet.

My opinion is that the 64G, long address memory handling may be broken 
somewhere.  Running w/o it costs me about half a gig of ram, but in this case, 
the loss is well worth it.

What is the reason that setting the 4G of memory option results in only 
approximately 3.5G being shown again?

Many Thanks to all of you, I have a stable machine now.

-- 
Cheers, Gene
"There are four boxes to be used in defense of liberty:
 soap, ballot, jury, and ammo. Please use in that order."
-Ed Howdershelt (Author)
The NRA is offering FREE Associate memberships to anyone who wants them.
<https://www.nrahq.org/nrabonus/accept-membership.asp>

People are like onions -- you cut them up, and they make you cry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
