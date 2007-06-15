Date: Fri, 15 Jun 2007 17:06:18 +0200
From: Johannes Weiner <hannes-kernel@saeurebad.de>
Subject: Re: PROBLEM: kernel BUG at mm/swap_state.c:78! (v2.6.21 under vmware)
Message-ID: <20070615150618.GA19912@saeurebad.de>
References: <745af2c30706140842w5eabdf1bjdcc5fd7c2a92b77e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Content-Disposition: inline
In-Reply-To: <745af2c30706140842w5eabdf1bjdcc5fd7c2a92b77e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Tom Robinson <thomas.robinson@gmail.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I am not sure if this patch is a fix or a hiding (or leads to more trouble at
all), so, could PLEASE anyone with knowledge about the code see over it?
Thanks :)

shrink_page_list() should not pass a private page to add_to_swap().
Is it a bug if the page is private when reaching this point? I do not think
so, because a few lines below is a condition where private pages are handled
legally.


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="do-not-swap-private-pages.patch"

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1be5a63..92573b7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -489,7 +489,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page))
+		if (PageAnon(page) && !PageSwapCache(page) &&
+		    !PagePrivate(page))
 			if (!add_to_swap(page, GFP_ATOMIC))
 				goto activate_locked;
 #endif /* CONFIG_SWAP */

--vtzGhvizbBRQ85DL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
