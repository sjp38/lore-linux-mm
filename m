Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0C78E0047
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 06:57:06 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id f22-v6so1594560lja.7
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 03:57:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor4406543ljg.10.2019.01.24.03.57.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 03:57:04 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [PATCH v1 1/2] mm/vmalloc: fix kernel BUG at mm/vmalloc.c:512!
Date: Thu, 24 Jan 2019 12:56:47 +0100
Message-Id: <20190124115648.9433-2-urezki@gmail.com>
In-Reply-To: <20190124115648.9433-1-urezki@gmail.com>
References: <20190124115648.9433-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

One of the vmalloc stress test case triggers the kernel BUG():

<snip>
[60.562151] ------------[ cut here ]------------
[60.562154] kernel BUG at mm/vmalloc.c:512!
[60.562206] invalid opcode: 0000 [#1] PREEMPT SMP PTI
[60.562247] CPU: 0 PID: 430 Comm: vmalloc_test/0 Not tainted 4.20.0+ #161
[60.562293] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[60.562351] RIP: 0010:alloc_vmap_area+0x36f/0x390
<snip>

it can happen due to big align request resulting in overflowing
of calculated address, i.e. it becomes 0 after ALIGN()'s fixup.

Fix it by checking if calculated address is within vstart/vend
range.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1c512fff8a56..fb4fb5fcee74 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -498,7 +498,11 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	}
 
 found:
-	if (addr + size > vend)
+	/*
+	 * Check also calculated address against the vstart,
+	 * because it can be 0 because of big align request.
+	 */
+	if (addr + size > vend || addr < vstart)
 		goto overflow;
 
 	va->va_start = addr;
-- 
2.11.0
