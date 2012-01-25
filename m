Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 005216B004D
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 19:03:51 -0500 (EST)
Date: Tue, 24 Jan 2012 16:03:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] KSM: numa awareness sysfs knob
Message-Id: <20120124160350.17b6e92b.akpm@linux-foundation.org>
In-Reply-To: <1327314568-13942-1-git-send-email-pholasek@redhat.com>
References: <1327314568-13942-1-git-send-email-pholasek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Mon, 23 Jan 2012 11:29:28 +0100
Petr Holasek <pholasek@redhat.com> wrote:

> This patch is based on RFC
> 
> https://lkml.org/lkml/2011/11/30/91
> 
> Introduces new sysfs binary knob /sys/kernel/mm/ksm/merge_nodes

It's not binary - it's ascii text!  "boolean" is a better term here ;)

> which control merging pages across different numa nodes.
> When it is set to zero only pages from the same node are merged,
> otherwise pages from all nodes can be merged together (default behavior).
> 
> Typical use-case could be a lot of KVM guests on NUMA machine
> where cpus from more distant nodes would have significant increase
> of access latency to the merged ksm page. Switching merge_nodes
> to 1 will result into these steps:
> 
> 	1) unmerging all ksm pages
> 	2) re-merging all pages from VM_MERGEABLE vmas only within
> 		their NUMA nodes.
> 	3) lower average access latency to merged pages at the
> 	   expense of higher memory usage.
> 
> Every numa node has its own stable & unstable trees because
> of faster searching and inserting. Changing of merge_nodes
> value breaks COW on all current ksm pages.
> 

How useful is this code?  Do you have any performance testing results
to help make the case for merging it?

Should the unmerged case be made permanent and not configurable?  IOW,
what is the argument for continuing to permit the user to merge across
nodes?

Should the code bother doing this unmerge when
/sys/kernel/mm/ksm/merge_nodes is written to?  It would be simpler to
expect the user to configure /sys/kernel/mm/ksm/merge_nodes prior to
using KSM at all?

> @@ -58,6 +58,9 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
>                     e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
>                     Default: 20 (chosen for demonstration purposes)
>  
> +merge_nodes      - specifies if pages from different numa nodes can be merged
> +                   Default: 1

This documentation would be better if it informed the user about how to
use merge_nodes.  What are the effects of altering it and why might
they wish to do this?

>
> ...
>
> +static ssize_t merge_nodes_store(struct kobject *kobj,
> +				   struct kobj_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	int err;
> +	long unsigned int knob;

Plain old "unsigned long" is more usual.

Better would be to make this "unsigned", to match ksm_merge_nodes.  Use
kstrtouint() below.

>
> ...
>
> @@ -1987,6 +2070,9 @@ static struct attribute *ksm_attrs[] = {
>  	&pages_unshared_attr.attr,
>  	&pages_volatile_attr.attr,
>  	&full_scans_attr.attr,
> +#ifdef CONFIG_NUMA
> +	&merge_nodes_attr.attr,
> +#endif

One might think that with CONFIG_NUMA=n, we just added a pile of
useless codebloat to vmlinux.  But gcc is sneaky and removes the
unreferenced functions.

However while doing so, gcc shows that it reads
Documentation/SubmitChecklist, section 2:

mm/ksm.c:2017: warning: 'merge_nodes_attr' defined but not used

So...

diff -puN mm/ksm.c~ksm-numa-awareness-sysfs-knob-fix mm/ksm.c
--- a/mm/ksm.c~ksm-numa-awareness-sysfs-knob-fix
+++ a/mm/ksm.c
@@ -1973,6 +1973,7 @@ static ssize_t run_store(struct kobject 
 }
 KSM_ATTR(run);
 
+#ifdef CONFIG_NUMA
 static ssize_t merge_nodes_show(struct kobject *kobj,
 				struct kobj_attribute *attr, char *buf)
 {
@@ -2015,6 +2016,7 @@ static ssize_t merge_nodes_store(struct 
 	return count;
 }
 KSM_ATTR(merge_nodes);
+#endif
 
 static ssize_t pages_shared_show(struct kobject *kobj,
 				 struct kobj_attribute *attr, char *buf)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
