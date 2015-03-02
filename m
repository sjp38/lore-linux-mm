Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id B1DFA6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 15:33:08 -0500 (EST)
Received: by widex7 with SMTP id ex7so17900470wid.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:33:08 -0800 (PST)
Received: from mail-wg0-x231.google.com (mail-wg0-x231.google.com. [2a00:1450:400c:c00::231])
        by mx.google.com with ESMTPS id s9si24015281wjs.200.2015.03.02.12.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 12:33:07 -0800 (PST)
Received: by wggy19 with SMTP id y19so35862494wgg.10
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 12:33:06 -0800 (PST)
Date: Mon, 2 Mar 2015 21:33:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/4] sparc: remove __GFP_NOFAIL reuquirement
Message-ID: <20150302203304.GA20513@dhcp22.suse.cz>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
 <1425304483-7987-4-git-send-email-mhocko@suse.cz>
 <20150302.150405.2072800922470200977.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150302.150405.2072800922470200977.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, david@fromorbit.com, tytso@mit.edu, mgorman@suse.de, penguin-kernel@I-love.SAKURA.ne.jp, sparclinux@vger.kernel.org, vipul@chelsio.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 02-03-15 15:04:05, David S. Miller wrote:
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon,  2 Mar 2015 14:54:42 +0100
> 
> > mdesc_kmalloc is currently requiring __GFP_NOFAIL allocation although it
> > seems that the allocation failure is handled by all callers (via
> > mdesc_alloc). __GFP_NOFAIL is a strong liability for the memory
> > allocator and so the users are discouraged to use the flag unless the
> > allocation failure is really a nogo. Drop the flag here as this doesn't
> > seem to be the case.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> It is a serious failure.
> 
> If we miss an MDESC update due to this allocation failure, the update
> is not an event which gets retransmitted so we will lose the updated
> machine description forever.
> 
> We really need this allocation to succeed.

OK, thanks for the clarification. This wasn't clear from the commit
which has introduced this code. I will drop this patch. Would you
accept something like the following instead?
---
diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
index 99632a87e697..26c80e18d7b1 100644
--- a/arch/sparc/kernel/mdesc.c
+++ b/arch/sparc/kernel/mdesc.c
@@ -130,26 +130,26 @@ static struct mdesc_mem_ops memblock_mdesc_ops = {
 static struct mdesc_handle *mdesc_kmalloc(unsigned int mdesc_size)
 {
 	unsigned int handle_size;
+	struct mdesc_handle *hp;
+	unsigned long addr;
 	void *base;
 
 	handle_size = (sizeof(struct mdesc_handle) -
 		       sizeof(struct mdesc_hdr) +
 		       mdesc_size);
 
+	/*
+	 * Allocation has to succeed because mdesc update would be missed
+	 * and such events are not retransmitted.
+	 */
 	base = kmalloc(handle_size + 15, GFP_KERNEL | __GFP_NOFAIL);
-	if (base) {
-		struct mdesc_handle *hp;
-		unsigned long addr;
-
-		addr = (unsigned long)base;
-		addr = (addr + 15UL) & ~15UL;
-		hp = (struct mdesc_handle *) addr;
+	addr = (unsigned long)base;
+	addr = (addr + 15UL) & ~15UL;
+	hp = (struct mdesc_handle *) addr;
 
-		mdesc_handle_init(hp, handle_size, base);
-		return hp;
-	}
+	mdesc_handle_init(hp, handle_size, base);
 
-	return NULL;
+	return hp;
 }
 
 static void mdesc_kfree(struct mdesc_handle *hp)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
