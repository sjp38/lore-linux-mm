Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id C0C1B6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 16:12:57 -0500 (EST)
Date: Wed, 23 Jan 2013 13:12:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2013-01-18-15-48 uploaded (memory_hotplug.c)
Message-Id: <20130123131255.756b65b2.akpm@linux-foundation.org>
In-Reply-To: <50FAF197.5010700@infradead.org>
References: <20130118234944.5C99C31C240@corp2gmr1-1.hot.corp.google.com>
	<50FAF197.5010700@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>

On Sat, 19 Jan 2013 11:18:47 -0800
Randy Dunlap <rdunlap@infradead.org> wrote:

> On 01/18/13 15:49, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2013-01-18-15-48 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> > 
> 
> 
> mm/memory_hotplug.c:1092:29: warning: the address of 'contig_page_data' will always evaluate as 'true' [-Waddress]
> 

yup, due to

	new_pgdat = NODE_DATA(nid) ? 0 : 1;

and

	#ifndef CONFIG_NEED_MULTIPLE_NODES

	extern struct pglist_data contig_page_data;
	#define NODE_DATA(nid)		(&contig_page_data)


This fixes it and removes a couple of unneeded initialisations.



From: Andrew Morton <akpm@linux-foundation.org>
Subject: memory-hotplug-do-not-allocate-pdgat-if-it-was-not-freed-when-offline-fix

fix warning when CONFIG_NEED_MULTIPLE_NODES=n

Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: Jianguo Wu <wujianguo@huawei.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Wu Jianguo <wujianguo@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory_hotplug.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN mm/memory_hotplug.c~memory-hotplug-do-not-allocate-pdgat-if-it-was-not-freed-when-offline-fix mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~memory-hotplug-do-not-allocate-pdgat-if-it-was-not-freed-when-offline-fix
+++ a/mm/memory_hotplug.c
@@ -1077,7 +1077,8 @@ out:
 int __ref add_memory(int nid, u64 start, u64 size)
 {
 	pg_data_t *pgdat = NULL;
-	int new_pgdat = 0, new_node = 0;
+	bool new_pgdat;
+	bool new_node;
 	struct resource *res;
 	int ret;
 
@@ -1088,8 +1089,8 @@ int __ref add_memory(int nid, u64 start,
 	if (!res)
 		goto out;
 
-	new_pgdat = NODE_DATA(nid) ? 0 : 1;
-	new_node = node_online(nid) ? 0 : 1;
+	new_pgdat = (NODE_DATA(nid) == NULL);
+	new_node = !node_online(nid);
 	if (new_node) {
 		pgdat = hotadd_new_pgdat(nid, start);
 		ret = -ENOMEM;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
