Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id D39196B038C
	for <linux-mm@kvack.org>; Sat, 18 Mar 2017 12:57:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id r141so72732737ita.6
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 09:57:19 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id k129si12647334iok.32.2017.03.18.09.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Mar 2017 09:57:19 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id y18so9624625itc.2
        for <linux-mm@kvack.org>; Sat, 18 Mar 2017 09:57:19 -0700 (PDT)
MIME-Version: 1.0
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 18 Mar 2017 09:57:18 -0700
Message-ID: <CA+55aFyq++yzU6bthhy1eDebkaAiXnH6YXHCTNzsC2-KZqN=Pw@mail.gmail.com>
Subject: kernel BUG at mm/swap_slots.c:270
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Tim at al,
 I got this on my desktop at shutdown:

  ------------[ cut here ]------------
  kernel BUG at mm/swap_slots.c:270!
  invalid opcode: 0000 [#1] SMP
  CPU: 5 PID: 1745 Comm: (sd-pam) Not tainted 4.11.0-rc1-00243-g24c534bb161b #1
  Hardware name: System manufacturer System Product Name/Z170-K, BIOS
1803 05/06/2016
  RIP: 0010:free_swap_slot+0xba/0xd0
  Call Trace:
   swap_free+0x36/0x40
   do_swap_page+0x360/0x6d0
   __handle_mm_fault+0x880/0x1080
   handle_mm_fault+0xd0/0x240
   __do_page_fault+0x232/0x4d0
   do_page_fault+0x20/0x70
   page_fault+0x22/0x30
  ---[ end trace aefc9ede53e0ab21 ]---

so there seems to be something screwy in the new swap_slots code.

Any ideas? I'm not finding other reports of this, but I'm also not
seeing why it should BUG_ON(). The "use_swap_slot_cache" thing very
much checks whether swap_slot_cache_initialized has been set, so the
BUG_ON() just seems like garbage. But please take a look.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
