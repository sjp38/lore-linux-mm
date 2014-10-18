Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id EFE316B0069
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 14:23:40 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so2567155pde.28
        for <linux-mm@kvack.org>; Sat, 18 Oct 2014 11:23:40 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id mq9si3957328pdb.91.2014.10.18.11.23.39
        for <linux-mm@kvack.org>;
        Sat, 18 Oct 2014 11:23:39 -0700 (PDT)
Date: Sat, 18 Oct 2014 14:23:35 -0400 (EDT)
Message-Id: <20141018.142335.1935310766779155342.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141018.135907.356113264227709132.davem@davemloft.net>
References: <20141016.165017.1151349565275102498.davem@davemloft.net>
	<alpine.LRH.2.11.1410171410210.25429@adalberg.ut.ee>
	<20141018.135907.356113264227709132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sat, 18 Oct 2014 13:59:07 -0400 (EDT)

> I don't want to define the array size of the fpregs save area
> explicitly and thereby placing an artificial limit there.

Nevermind, it seems we have a hard limit of 7 FPU save areas anyways.

Meelis, please try this patch:

diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
index f85dc85..cc6275c 100644
--- a/arch/sparc/include/asm/thread_info_64.h
+++ b/arch/sparc/include/asm/thread_info_64.h
@@ -63,7 +63,8 @@ struct thread_info {
 	struct pt_regs		*kern_una_regs;
 	unsigned int		kern_una_insn;
 
-	unsigned long		fpregs[0] __attribute__ ((aligned(64)));
+	unsigned long		fpregs[(7 * 256) / sizeof(unsigned long)]
+		__attribute__ ((aligned(64)));
 };
 
 #endif /* !(__ASSEMBLY__) */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
