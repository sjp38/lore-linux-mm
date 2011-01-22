Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5AEDB6B0092
	for <linux-mm@kvack.org>; Sat, 22 Jan 2011 14:51:04 -0500 (EST)
Date: Sat, 22 Jan 2011 20:51:32 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Fix uninitialized variable use in
 mm/memcontrol.c::mem_cgroup_move_parent()
Message-ID: <alpine.LNX.2.00.1101222044580.7746@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

In mm/memcontrol.c::mem_cgroup_move_parent() there's a path that jumps to 
the 'put_back' label
  	ret = __mem_cgroup_try_charge(NULL, gfp_mask, &parent, false, charge);
  	if (ret || !parent)
  		goto put_back;
 where we'll 
  	if (charge > PAGE_SIZE)
  		compound_unlock_irqrestore(page, flags);
but, we have not assigned anything to 'flags' at this point, nor have we 
called 'compound_lock_irqsave()' (which is what sets 'flags').
So, I believe the 'put_back' label should be moved below the call to 
compound_unlock_irqrestore() as per this patch. 

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 memcontrol.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

  compile tested only.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index db76ef7..4fcf47a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2292,9 +2292,10 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
 	ret = mem_cgroup_move_account(pc, child, parent, true, charge);
 	if (ret)
 		mem_cgroup_cancel_charge(parent, charge);
-put_back:
+
 	if (charge > PAGE_SIZE)
 		compound_unlock_irqrestore(page, flags);
+put_back:
 	putback_lru_page(page);
 put:
 	put_page(page);


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
