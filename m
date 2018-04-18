Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1DB46B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:43:19 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id v20-v6so856187otd.10
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:43:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w130-v6si329631oib.269.2018.04.18.04.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 04:43:18 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs, elf: drop MAP_FIXED usage from elf_map
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171213092550.2774-1-mhocko@kernel.org>
	<20171213092550.2774-3-mhocko@kernel.org>
	<0b5c541a-91ee-220b-3196-f64264f9f0bc@I-love.SAKURA.ne.jp>
	<20180418113301.GY17484@dhcp22.suse.cz>
In-Reply-To: <20180418113301.GY17484@dhcp22.suse.cz>
Message-Id: <201804182043.JFH90161.LStOOMFFOJQHVF@I-love.SAKURA.ne.jp>
Date: Wed, 18 Apr 2018 20:43:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > Don't complain if IS_ERR_VALUE(),
> 
> this is simply wrong. We do want to warn on the failure because this is
> when the actual clash happens. We should just warn on EEXIST.

>From 25442cdd31aa5cc8522923a0153a77dfd2ebc832 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 18 Apr 2018 20:38:15 +0900
Subject: [PATCH] fs, elf: don't complain MAP_FIXED_NOREPLACE unless -EEXIST
 error.

Commit 4ed28639519c7bad ("fs, elf: drop MAP_FIXED usage from elf_map") is
printing spurious messages under memory pressure due to map_addr == -ENOMEM.

 9794 (a.out): Uhuuh, elf segment at 00007f2e34738000(fffffffffffffff4) requested but the memory is mapped already
 14104 (a.out): Uhuuh, elf segment at 00007f34fd76c000(fffffffffffffff4) requested but the memory is mapped already
 16843 (a.out): Uhuuh, elf segment at 00007f930ecc7000(fffffffffffffff4) requested but the memory is mapped already

Complain only if -EEXIST, and use %px for printing the address.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrei Vagin <avagin@openvz.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Kees Cook <keescook@chromium.org>
Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
Cc: Joel Stanley <joel@jms.id.au>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 fs/binfmt_elf.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 41e0418..96615d9 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -377,10 +377,9 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
 	} else
 		map_addr = vm_mmap(filep, addr, size, prot, type, off);
 
-	if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr))
-		pr_info("%d (%s): Uhuuh, elf segment at %p requested but the memory is mapped already\n",
-				task_pid_nr(current), current->comm,
-				(void *)addr);
+	if ((type & MAP_FIXED_NOREPLACE) && map_addr == -EEXIST)
+		pr_info("%d (%s): Uhuuh, elf segment at %px requested but the memory is mapped already\n",
+			task_pid_nr(current), current->comm, (void *)addr);
 
 	return(map_addr);
 }
-- 
1.8.3.1
