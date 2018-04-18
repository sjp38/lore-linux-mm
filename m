Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 13F356B0009
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 10:07:28 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 11-v6so1120570otj.1
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:07:28 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e125-v6si411862oif.16.2018.04.18.07.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 07:07:26 -0700 (PDT)
Subject: [PATCH v2] fs, elf: don't complain MAP_FIXED_NOREPLACE unless -EEXIST error.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171213092550.2774-3-mhocko@kernel.org>
	<0b5c541a-91ee-220b-3196-f64264f9f0bc@I-love.SAKURA.ne.jp>
	<20180418113301.GY17484@dhcp22.suse.cz>
	<201804182043.JFH90161.LStOOMFFOJQHVF@I-love.SAKURA.ne.jp>
	<20180418115546.GZ17484@dhcp22.suse.cz>
In-Reply-To: <20180418115546.GZ17484@dhcp22.suse.cz>
Message-Id: <201804182307.FAC17665.SFMOFJVFtHOLOQ@I-love.SAKURA.ne.jp>
Date: Wed, 18 Apr 2018 23:07:12 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@kernel.org, avagin@openvz.org, khalid.aziz@oracle.com, mpe@ellerman.id.au, keescook@chromium.org, abdhalee@linux.vnet.ibm.com, joel@jms.id.au, khandual@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

>From 3f396857d23d4bf1fac4d4332316b5ba0af6d2f9 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 18 Apr 2018 23:00:53 +0900
Subject: [PATCH v2] fs, elf: don't complain MAP_FIXED_NOREPLACE unless -EEXIST error.

Commit 4ed28639519c7bad ("fs, elf: drop MAP_FIXED usage from elf_map") is
printing spurious messages under memory pressure due to map_addr == -ENOMEM.

 9794 (a.out): Uhuuh, elf segment at 00007f2e34738000(fffffffffffffff4) requested but the memory is mapped already
 14104 (a.out): Uhuuh, elf segment at 00007f34fd76c000(fffffffffffffff4) requested but the memory is mapped already
 16843 (a.out): Uhuuh, elf segment at 00007f930ecc7000(fffffffffffffff4) requested but the memory is mapped already

Complain only if -EEXIST, and use %px for printing the address.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Andrei Vagin <avagin@openvz.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Kees Cook <keescook@chromium.org>
Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
Cc: Joel Stanley <joel@jms.id.au>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 fs/binfmt_elf.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 41e0418..4ad6f66 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -377,10 +377,10 @@ static unsigned long elf_map(struct file *filep, unsigned long addr,
 	} else
 		map_addr = vm_mmap(filep, addr, size, prot, type, off);
 
-	if ((type & MAP_FIXED_NOREPLACE) && BAD_ADDR(map_addr))
-		pr_info("%d (%s): Uhuuh, elf segment at %p requested but the memory is mapped already\n",
-				task_pid_nr(current), current->comm,
-				(void *)addr);
+	if ((type & MAP_FIXED_NOREPLACE) &&
+	    PTR_ERR((void *)map_addr) == -EEXIST)
+		pr_info("%d (%s): Uhuuh, elf segment at %px requested but the memory is mapped already\n",
+			task_pid_nr(current), current->comm, (void *)addr);
 
 	return(map_addr);
 }
-- 
1.8.3.1
