Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 775406B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 00:47:44 -0500 (EST)
Subject: Re: [patch 1/5]thp: improve the error code path
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.DEB.2.00.1111092039110.27280@chino.kir.corp.google.com>
References: <1319511521.22361.135.camel@sli10-conroe>
	 <20111025114406.GC10182@redhat.com>
	 <1319593680.22361.145.camel@sli10-conroe>
	 <1320643049.22361.204.camel@sli10-conroe>
	 <20111110021853.GQ5075@redhat.com>
	 <1320892395.22361.229.camel@sli10-conroe>
	 <alpine.DEB.2.00.1111091828500.32414@chino.kir.corp.google.com>
	 <20111110030646.GT5075@redhat.com>
	 <alpine.DEB.2.00.1111092039110.27280@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Nov 2011 13:56:49 +0800
Message-ID: <1320904609.22361.239.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, 2011-11-10 at 12:43 +0800, David Rientjes wrote:
> On Thu, 10 Nov 2011, Andrea Arcangeli wrote:
> 
> > Before after won't matter much I guess... If you really want to clean
> > the code, I wonder what is exactly the point of those dummy functions
> > if we can't call those outside of #ifdefs.
> 
> You can, you just need to declare the actuals that you pass to the dummy 
> functions for CONFIG_SYSFS=n as well.  Or, convert the dummy functions to 
> do
> 
> 	#define sysfs_remove_group(kobj, grp) do {} while (0)
> 
> but good luck getting that passed Andrew :)
> 
> > I mean a cleanup that adds
> > more #ifdefs when there are explicit dummy functions which I assume
> > are meant to be used outside of #ifdef CONFIG_SYSFS doesn't sound so
> > clean in the first place. I understand you need to refactor the code
> > above to call those outside of #ifdefs but hey if you're happy with
> > #ifdef I'm happy too :). It just looks fishy to read sysfs.h dummy
> > functions and #ifdefs. When I wrote the code I hardly could have
> > wondered about the sysfs #ifdefs but at this point it's only cleanups
> > I'm seeing so I actually noticed that.
> > 
> 
> The cleaniest solution would probably be to just extract all the calls 
> that depend on CONFIG_SYSFS out of hugepage_init(), call it 
> hugepage_sysfs_init(), and then return a failure code if it fails to setup 
> then do the error handling there.  hugepage_sysfs_init() would be defined 
> right after the attributes are defined.
ok, make the code better.

Improve the error code path. Delete unnecessary sysfs file for example.
Also remove the #ifdef xxx to make code better.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 mm/huge_memory.c |   63 ++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 46 insertions(+), 17 deletions(-)

Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2011-11-07 13:52:48.000000000 +0800
+++ linux/mm/huge_memory.c	2011-11-10 13:52:08.000000000 +0800
@@ -487,41 +487,68 @@ static struct attribute_group khugepaged
 	.attrs = khugepaged_attr,
 	.name = "khugepaged",
 };
-#endif /* CONFIG_SYSFS */
 
-static int __init hugepage_init(void)
+static struct kobject *hugepage_kobj;
+static int __init hugepage_init_sysfs(void)
 {
 	int err;
-#ifdef CONFIG_SYSFS
-	static struct kobject *hugepage_kobj;
-#endif
 
-	err = -EINVAL;
-	if (!has_transparent_hugepage()) {
-		transparent_hugepage_flags = 0;
-		goto out;
-	}
-
-#ifdef CONFIG_SYSFS
-	err = -ENOMEM;
 	hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
 	if (unlikely(!hugepage_kobj)) {
 		printk(KERN_ERR "hugepage: failed kobject create\n");
-		goto out;
+		return -ENOMEM;
 	}
 
 	err = sysfs_create_group(hugepage_kobj, &hugepage_attr_group);
 	if (err) {
 		printk(KERN_ERR "hugepage: failed register hugeage group\n");
-		goto out;
+		goto delete_obj;
 	}
 
 	err = sysfs_create_group(hugepage_kobj, &khugepaged_attr_group);
 	if (err) {
 		printk(KERN_ERR "hugepage: failed register hugeage group\n");
-		goto out;
+		goto remove_hp_group;
 	}
-#endif
+
+	return 0;
+
+remove_hp_group:
+	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
+delete_obj:
+	kobject_put(hugepage_kobj);
+	return err;
+}
+
+static void __init hugepage_exit_sysfs(void)
+{
+	sysfs_remove_group(hugepage_kobj, &khugepaged_attr_group);
+	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
+	kobject_put(hugepage_kobj);
+}
+#else
+static inline int hugepage_init_sysfs(void)
+{
+	return 0;
+}
+
+static inline void hugepage_exit_sysfs(void)
+{
+}
+#endif /* CONFIG_SYSFS */
+
+static int __init hugepage_init(void)
+{
+	int err;
+
+	if (!has_transparent_hugepage()) {
+		transparent_hugepage_flags = 0;
+		return -EINVAL;
+	}
+
+	err = hugepage_init_sysfs();
+	if (err)
+		return err;
 
 	err = khugepaged_slab_init();
 	if (err)
@@ -545,7 +572,9 @@ static int __init hugepage_init(void)
 
 	set_recommended_min_free_kbytes();
 
+	return 0;
 out:
+	hugepage_exit_sysfs();
 	return err;
 }
 module_init(hugepage_init)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
