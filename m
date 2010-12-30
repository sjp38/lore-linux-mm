Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 562826B00AC
	for <linux-mm@kvack.org>; Thu, 30 Dec 2010 07:31:05 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1555416Ab0L3MaN (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 30 Dec 2010 13:30:13 +0100
Date: Thu, 30 Dec 2010 13:30:13 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH R2 1/7] mm: Add add_registered_memory() to memory hotplug API
Message-ID: <20101230123013.GA12765@router-fw-old.local.net-space.pl>
References: <20101229170212.GF2743@router-fw-old.local.net-space.pl> <alpine.DEB.2.00.1012291643290.6040@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nFreZHaLTZJo0R7j"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012291643290.6040@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

On Wed, Dec 29, 2010 at 04:50:25PM -0800, David Rientjes wrote:
> On Wed, 29 Dec 2010, Daniel Kiper wrote:
>
> > diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> > index 864035f..2458b2f 100644
> > --- a/include/linux/memory_hotplug.h
> > +++ b/include/linux/memory_hotplug.h
> > @@ -203,6 +203,7 @@ static inline int is_mem_section_removable(unsigned long pfn,
> >  #endif /* CONFIG_MEMORY_HOTREMOVE */
> >
> >  extern int mem_online_node(int nid);
> > +extern int add_registered_memory(int nid, u64 start, u64 size);
> >  extern int add_memory(int nid, u64 start, u64 size);
> >  extern int arch_add_memory(int nid, u64 start, u64 size);
> >  extern int remove_memory(u64 start, u64 size);
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index dd186c1..b642f26 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -509,20 +509,12 @@ out:
> >  }
> >
> >  /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
> > -int __ref add_memory(int nid, u64 start, u64 size)
> > +static int __ref __add_memory(int nid, u64 start, u64 size)
> >  {
> >  	pg_data_t *pgdat = NULL;
> >  	int new_pgdat = 0;
> > -	struct resource *res;
> >  	int ret;
> >
> > -	lock_system_sleep();
> > -
> > -	res = register_memory_resource(start, size);
> > -	ret = -EEXIST;
> > -	if (!res)
> > -		goto out;
> > -
> >  	if (!node_online(nid)) {
> >  		pgdat = hotadd_new_pgdat(nid, start);
> >  		ret = -ENOMEM;
>
> Looks like this patch was based on a kernel before 2.6.37-rc4 since it
> doesn't have 20d6c96b5f (mem-hotplug: introduce {un}lock_memory_hotplug())

As I wrote in "[PATCH R2 0/7] Xen memory balloon driver with memoryhotplug
support" this patch applies to Linux kernel Ver. 2.6.36.

> Lots of unnecessary empty lines here, and scripts/checkpatch.pl says there
> are trailing whitespaces as well.

Strange. I tested it with this script and I received:

0001-mm-Add-add_registered_memory-to-memory-hotplug-API.txt has no
obvious style problems and is ready for submission.

I do not know why my e-mail was mangled. For your convenience
I am sending this patch as attachment.

Empty lines are added for better readability (it is my
opinion) however, I do not insist to leave this patch
with that formating.

Daniel

--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-Add-add_registered_memory-to-memory-hotplug-API.txt"

add_registered_memory() adds memory ealier registered
as memory resource. It is required by memory hotplug
for Xen guests, however it could be used also by other
modules.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 include/linux/memory_hotplug.h |    1 +
 mm/memory_hotplug.c            |   50 ++++++++++++++++++++++++++++++---------
 2 files changed, 39 insertions(+), 12 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 864035f..2458b2f 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -203,6 +203,7 @@ static inline int is_mem_section_removable(unsigned long pfn,
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 extern int mem_online_node(int nid);
+extern int add_registered_memory(int nid, u64 start, u64 size);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int remove_memory(u64 start, u64 size);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index dd186c1..b642f26 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -509,20 +509,12 @@ out:
 }
 
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-int __ref add_memory(int nid, u64 start, u64 size)
+static int __ref __add_memory(int nid, u64 start, u64 size)
 {
 	pg_data_t *pgdat = NULL;
 	int new_pgdat = 0;
-	struct resource *res;
 	int ret;
 
-	lock_system_sleep();
-
-	res = register_memory_resource(start, size);
-	ret = -EEXIST;
-	if (!res)
-		goto out;
-
 	if (!node_online(nid)) {
 		pgdat = hotadd_new_pgdat(nid, start);
 		ret = -ENOMEM;
@@ -556,14 +548,48 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	goto out;
 
 error:
-	/* rollback pgdat allocation and others */
+	/* rollback pgdat allocation */
 	if (new_pgdat)
 		rollback_node_hotadd(nid, pgdat);
-	if (res)
-		release_memory_resource(res);
+
+out:
+	return ret;
+}
+
+int add_registered_memory(int nid, u64 start, u64 size)
+{
+	int ret;
+
+	lock_system_sleep();
+	ret = __add_memory(nid, start, size);
+	unlock_system_sleep();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(add_registered_memory);
+
+int add_memory(int nid, u64 start, u64 size)
+{
+	int ret = -EEXIST;
+	struct resource *res;
+
+	lock_system_sleep();
+
+	res = register_memory_resource(start, size);
+
+	if (!res)
+		goto out;
+
+	ret = __add_memory(nid, start, size);
+
+	if (!ret)
+		goto out;
+
+	release_memory_resource(res);
 
 out:
 	unlock_system_sleep();
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory);
-- 
1.4.4.4


--nFreZHaLTZJo0R7j--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
