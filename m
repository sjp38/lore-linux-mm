Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA4Gx4Ae001700
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 09:59:04 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA4GxIHb135776
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 09:59:19 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA4Gx8lJ002905
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 09:59:09 -0700
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
	hotplug
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <200811041734.04802.rjw@sisk.pl>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz>
	 <200811041635.49932.rjw@sisk.pl> <1225813182.12673.587.camel@nimitz>
	 <200811041734.04802.rjw@sisk.pl>
Content-Type: multipart/mixed; boundary="=-hzcDoJEWaFbmAH62IJdH"
Date: Tue, 04 Nov 2008 08:59:05 -0800
Message-Id: <1225817945.12673.602.camel@nimitz>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>, Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--=-hzcDoJEWaFbmAH62IJdH
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2008-11-04 at 17:34 +0100, Rafael J. Wysocki wrote:
> Now, I need to do one more thing, which is to check how much memory has to be
> freed before creating the image.  For this purpose I need to lock memory
> hotplug temporarily, count pages to free and unlock it.  What interface should
> I use for this purpose? 
> 
> [I'll also need to lock memory hotplug temporarily during resume.]

We currently don't have any big switch to disable memory hotplug, like
lock_memory_hotplug() or something. :)

If you are simply scanning and counting pages, I think the best thing to
use would be the zone_span_seq*() seqlock stuff.  Do your count inside
the seqlock's while loop.  That covers detecting a zone changing while
it is being scanned.

The other case to detect is when a new zone gets added.  These are
really rare.  Rare enough that we actually use a stop_machine() call in
build_all_zonelists() to do it.  All you would have to do is detect when
one of these calls gets made.  I think that's a good application for a
new seq_lock.

I've attached an utterly untested patch that should do the trick.
Yasunori and KAME should probably take a look at it since the node
addition code is theirs.

-- Dave

--=-hzcDoJEWaFbmAH62IJdH
Content-Disposition: attachment; filename=zone-list-seqlock.patch
Content-Type: text/x-patch; name=zone-list-seqlock.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit



---

 linux-2.6.git-dave/mm/page_alloc.c |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff -puN mm/page_alloc.c~zone-list-seqlock mm/page_alloc.c
--- linux-2.6.git/mm/page_alloc.c~zone-list-seqlock	2008-11-04 08:53:38.000000000 -0800
+++ linux-2.6.git-dave/mm/page_alloc.c	2008-11-04 08:57:04.000000000 -0800
@@ -2378,17 +2378,43 @@ static void build_zonelist_cache(pg_data
 
 #endif	/* CONFIG_NUMA */
 
+/*
+ * This provides a way for other parts of the
+ * system to detect when the list of zones
+ * might have changed underneath them.
+ *
+ * Use this if you are doing a for_each_zone()
+ * or for_each_node() and really, really care
+ * if you miss some memory.
+ */
+static seqlock_t zonelist_seqlock = SEQLOCK_UNLOCKED;
+
+/*
+ * We could #ifdef these under MEMORY_HOTPLUG, but they
+ * are tiny.
+ */
+unsigned zonelist_seqbegin(void)
+{
+        return read_seqbegin(&zonelist_seqlock);
+}
+int zonelist_seqretry(void)
+{
+        return read_seqretry(&zonelist_seqlock, iv);
+}
+
 /* return values int ....just for stop_machine() */
 static int __build_all_zonelists(void *dummy)
 {
 	int nid;
 
+	write_seqlock(&zonelist_seqlock);
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
 
 		build_zonelists(pgdat);
 		build_zonelist_cache(pgdat);
 	}
+	write_sequnlock(&zonelist_seqlock);
 	return 0;
 }
 
_

--=-hzcDoJEWaFbmAH62IJdH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
