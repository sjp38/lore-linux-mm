Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D43226B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 02:38:45 -0400 (EDT)
Message-ID: <COL115-W2FC39E504A4388BDEC8E99FC10@phx.gbl>
From: Bo Liu <bo-liu@hotmail.com>
Subject: [RFC]get_swap_page():delay update swap_list.next
Date: Mon, 19 Oct 2009 14:38:43 +0800
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, hugh.dickins@tiscali.co.uk
List-ID: <linux-mm.kvack.org>


If scan_swap_map() successed in current si, there is no
need to update swap_list.next.So get_swap_page next time 
called can start search from the last swap_info(which still
have free slots).
 
 
Signed-off-by: Bo Liu <bo-liu@hotmail.com>
---
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 63ce10f..b3ba2c5 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -480,13 +480,13 @@ swp_entry_t get_swap_page(void)
   if (!(si->flags & SWP_WRITEOK))
    continue;
 
-  swap_list.next = next;
   /* This is called for allocating swap entry for cache */
   offset = scan_swap_map(si, SWAP_CACHE);
   if (offset) {
    spin_unlock(&swap_lock);
    return swp_entry(type, offset);
   }
+  swap_list.next = next;
   next = swap_list.next;
  }
  		 	   		  
_________________________________________________________________
Windows Live: Friends get your Flickr, Yelp, and Digg updates when they e-mail you.
http://www.microsoft.com/middleeast/windows/windowslive/see-it-in-action/social-network-basics.aspx?ocid=PID23461::T:WLMTAGL:ON:WL:en-xm:SI_SB_3:092010

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
