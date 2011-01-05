Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5366B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 16:12:22 -0500 (EST)
Date: Wed, 5 Jan 2011 13:11:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2] Do not allow pagesize >= MAX_ORDER pool adjustment
Message-Id: <20110105131151.b5b9cf5b.akpm@linux-foundation.org>
In-Reply-To: <1294259397-15553-1-git-send-email-emunson@mgebm.net>
References: <1294259397-15553-1-git-send-email-emunson@mgebm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@csn.ul.ie, caiqian@redhat.com, mhocko@suse.cz
List-ID: <linux-mm.kvack.org>

On Wed,  5 Jan 2011 13:29:57 -0700
Eric B Munson <emunson@mgebm.net> wrote:

> Huge pages with order >= MAX_ORDER must be allocated at boot via
> the kernel command line, they cannot be allocated or freed once
> the kernel is up and running.  Currently we allow values to be
> written to the sysfs and sysctl files controling pool size for these
> huge page sizes.  This patch makes the store functions for nr_hugepages
> and nr_overcommit_hugepages return -EINVAL when the pool for a
> page size >= MAX_ORDER is changed.
> 

gack, you people keep on making me look at the hugetlb code :(

> index 5cb71a9..15bd633 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1443,6 +1443,12 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
>  		return -EINVAL;

Why do these functions do a `return 0' if strict_strtoul() failed?

>  
>  	h = kobj_to_hstate(kobj, &nid);
> +
> +	if (h->order >= MAX_ORDER) {
> +		NODEMASK_FREE(nodes_allowed);
> +		return -EINVAL;
> +	}

Let's avoid having multiple unwind-and-return paths in a function,
please.  it often leads to resource leaks and locking errors as the
code evolves.

--- a/mm/hugetlb.c~hugetlb-do-not-allow-pagesize-=-max_order-pool-adjustment-fix
+++ a/mm/hugetlb.c
@@ -1363,6 +1363,7 @@ static ssize_t nr_hugepages_show_common(
 
 	return sprintf(buf, "%lu\n", nr_huge_pages);
 }
+
 static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 			struct kobject *kobj, struct kobj_attribute *attr,
 			const char *buf, size_t len)
@@ -1375,15 +1376,14 @@ static ssize_t nr_hugepages_store_common
 
 	err = strict_strtoul(buf, 10, &count);
 	if (err) {
-		NODEMASK_FREE(nodes_allowed);
-		return 0;
+		err = 0;		/* This seems wrong */
+		goto out;
 	}
 
 	h = kobj_to_hstate(kobj, &nid);
-
 	if (h->order >= MAX_ORDER) {
-		NODEMASK_FREE(nodes_allowed);
-		return -EINVAL;
+		err = -EINVAL;
+		goto out;
 	}
 
 	if (nid == NUMA_NO_NODE) {
@@ -1411,6 +1411,9 @@ static ssize_t nr_hugepages_store_common
 		NODEMASK_FREE(nodes_allowed);
 
 	return len;
+out:
+	NODEMASK_FREE(nodes_allowed);
+	return err;
 }
 
 static ssize_t nr_hugepages_show(struct kobject *kobj,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
