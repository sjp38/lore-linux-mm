Subject: Re: [RFC] buddy allocator without bitmap(2) [0/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <41345491.1020209@jp.fujitsu.com>
References: <41345491.1020209@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093969590.26660.4806.camel@nighthawk>
Mime-Version: 1.0
Date: Tue, 31 Aug 2004 09:26:30 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-08-31 at 03:36, Hiroyuki KAMEZAWA wrote:
> Disadvantage:
>   - using one more PG_xxx flag.
>   - If mem_map is not aligned, reserve one page as a victim for buddy allocater.
> 
> How about this approach ?

Granted, we have some free wiggle room in page->flags right now, but
using another bit effectively shifts the entire benefit of your patch. 
Instead of getting rid of the buddy bitmaps, you simply consume a
page->flag instead.  While you don't have to allocate anything (because
of the page->flags use), the number of bits consumed in the operation is
still the same as before.  And the patch is getting more complex by the
minute.

Something ate your patch:

   * Global page accounting.  One instance per CPU.  Only unsigned longs are
@@ -290,6 +297,9 @@ extern unsigned long __read_page_state(u
  #define SetPageCompound(page) set_bit(PG_compound, &(page)->flags)
  #define ClearPageCompound(page)       clear_bit(PG_compound, &(page)->flags)

+#define PageBuddyend(page)      test_bit(PG_buddyend, &(page)->flags)
+#define SetPageBuddyend(page)   set_bit(PG_buddyend, &(page)->flags)
+
  #ifdef CONFIG_SWAP
  #define PageSwapCache(page)   test_bit(PG_swapcache, &(page)->flags)
  #define SetPageSwapCache(page)        set_bit(PG_swapcache, &(page)->flags)


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
