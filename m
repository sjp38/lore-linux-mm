Date: Fri, 03 Oct 2008 12:15:57 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: 2.6.27-rc8 hot memory remove panic
In-Reply-To: <1222985880.3419.20.camel@badari-desktop>
References: <1222968181.3419.12.camel@badari-desktop> <1222985880.3419.20.camel@badari-desktop>
Message-Id: <20081003115721.38C0.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 2008-10-02 at 10:23 -0700, Badari Pulavarty wrote:
> > Hi,
> > 
> > Ran into this while testing hotplug memory remove on 2.6.27-rc8.
> > Never saw this earlier.
> > 
> > Any ideas on whats happening.
> > 
> > put_page_bootmem():
> >         BUG_ON(type >= -1);
> 
> 
> It looks like we have undocumented dependency on CONFIG_NUMA=y to get
> hotplug memory remove working.
> 
> register_page_bootmem_info_node() gets called only if 
> CONFIG_NEED_MULTIPLE_NODES=y which gets selected only if CONFIG_NUMA=y.

Oops. My bad....

I remember its dependency is removed from Kconfig some month ago.
Then, register_page_bootmem_info_node() should be called when CONFIG_NUMA
is off.
Is this patch enough?

---

register_page_bootmem_info_node() should be called for memory hot-remove
even when CONFIG_NUMA is off.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 mm/bootmem.c |    1 +
 1 file changed, 1 insertion(+)

Index: current/mm/bootmem.c
===================================================================
--- current.orig/mm/bootmem.c	2008-10-03 09:58:58.000000000 +0900
+++ current/mm/bootmem.c	2008-10-03 11:57:21.000000000 +0900
@@ -222,6 +222,7 @@ unsigned long __init free_all_bootmem_no
  */
 unsigned long __init free_all_bootmem(void)
 {
+	register_page_bootmem_info_node(NODE_DATA(0));
 	return free_all_bootmem_core(NODE_DATA(0)->bdata);
 }
 

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
