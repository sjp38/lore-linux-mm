Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B1D246B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 16:00:02 -0500 (EST)
Date: Wed, 5 Jan 2011 12:59:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
Message-Id: <20110105125959.c6e3d90a.akpm@linux-foundation.org>
In-Reply-To: <20110105084357.GA21349@tiehlicka.suse.cz>
References: <20110104105214.GA10759@tiehlicka.suse.cz>
	<907929848.134962.1294203162923.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	<20110105084357.GA21349@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Jan 2011 09:43:57 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> ...
>
> proc_doulongvec_minmax may fail if the given buffer doesn't represent
> a valid number. If we provide something invalid we will initialize the
> resulting value (nr_overcommit_huge_pages in this case) to a random
> value from the stack.
> 
> The issue was introduced by a3d0c6aa when the default handler has been
> replaced by the helper function where we do not check the return value.
> 
> Reproducer:
> echo "" > /proc/sys/vm/nr_overcommit_hugepages
> 
> ...
>
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1928,7 +1928,8 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>  
>  	table->data = &tmp;
>  	table->maxlen = sizeof(unsigned long);
> -	proc_doulongvec_minmax(table, write, buffer, length, ppos);
> +	if (proc_doulongvec_minmax(table, write, buffer, length, ppos))
> +		return -EINVAL;

proc_doulongvec_minmax() can return -EFAULT or -ENOMEM.  It is
incorrect to unconditionally convert those into -EINVAL.

>  	if (write) {
>  		NODEMASK_ALLOC(nodemask_t, nodes_allowed,

hm, the code doesn't check that NODEMASK_ALLOC succeeded.  That
NODEMASK_ALLOC conversion was quite sloppy.


--- a/mm/hugetlb.c~hugetlb-check-the-return-value-of-string-conversion-in-sysctl-handler-fix
+++ a/mm/hugetlb.c
@@ -1859,14 +1859,16 @@ static int hugetlb_sysctl_handler_common
 {
 	struct hstate *h = &default_hstate;
 	unsigned long tmp;
+	int ret;
 
 	if (!write)
 		tmp = h->max_huge_pages;
 
 	table->data = &tmp;
 	table->maxlen = sizeof(unsigned long);
-	if (proc_doulongvec_minmax(table, write, buffer, length, ppos))
-		return -EINVAL;
+	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos);
+	if (ret)
+		goto out;
 
 	if (write) {
 		NODEMASK_ALLOC(nodemask_t, nodes_allowed,
@@ -1881,8 +1883,8 @@ static int hugetlb_sysctl_handler_common
 		if (nodes_allowed != &node_states[N_HIGH_MEMORY])
 			NODEMASK_FREE(nodes_allowed);
 	}
-
-	return 0;
+out:
+	return ret;
 }
 
 int hugetlb_sysctl_handler(struct ctl_table *table, int write,
@@ -1920,22 +1922,24 @@ int hugetlb_overcommit_handler(struct ct
 {
 	struct hstate *h = &default_hstate;
 	unsigned long tmp;
+	int ret;
 
 	if (!write)
 		tmp = h->nr_overcommit_huge_pages;
 
 	table->data = &tmp;
 	table->maxlen = sizeof(unsigned long);
-	if (proc_doulongvec_minmax(table, write, buffer, length, ppos))
-		return -EINVAL;
+	ret = proc_doulongvec_minmax(table, write, buffer, length, ppos);
+	if (ret)
+		goto out;
 
 	if (write) {
 		spin_lock(&hugetlb_lock);
 		h->nr_overcommit_huge_pages = tmp;
 		spin_unlock(&hugetlb_lock);
 	}
-
-	return 0;
+out:
+	return ret;
 }
 
 #endif /* CONFIG_SYSCTL */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
