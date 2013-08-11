Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 03BE36B0033
	for <linux-mm@kvack.org>; Sun, 11 Aug 2013 19:37:39 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 12 Aug 2013 09:30:38 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 637FA2CE804D
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 09:37:26 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7BNbFpV56164382
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 09:37:15 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7BNbOwu001420
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 09:37:25 +1000
Date: Mon, 12 Aug 2013 07:37:22 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm/hotplug: Verify hotplug memory range
Message-ID: <20130811233722.GA27223@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1376162252-26074-1-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376162252-26074-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, dave@sr71.net, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Sat, Aug 10, 2013 at 01:17:32PM -0600, Toshi Kani wrote:
>add_memory() and remove_memory() can only handle a memory range aligned
>with section.  There are problems when an unaligned range is added and
>then deleted as follows:
>
> - add_memory() with an unaligned range succeeds, but __add_pages()
>   called from add_memory() adds a whole section of pages even though
>   a given memory range is less than the section size.
> - remove_memory() to the added unaligned range hits BUG_ON() in
>   __remove_pages().
>
>This patch changes add_memory() and remove_memory() to check if a given
>memory range is aligned with section at the beginning.  As the result,
>add_memory() fails with -EINVAL when a given range is unaligned, and
>does not add such memory range.  This prevents remove_memory() to be
>called with an unaligned range as well.  Note that remove_memory() has
>to use BUG_ON() since this function cannot fail.
>
>Signed-off-by: Toshi Kani <toshi.kani@hp.com>
>Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
>v2: Updated the error message.
>
>---
> mm/memory_hotplug.c |   22 ++++++++++++++++++++++
> 1 file changed, 22 insertions(+)
>
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index ca1dd3a..3bb1f39 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -1069,6 +1069,22 @@ out:
> 	return ret;
> }
>
>+static int check_hotplug_memory_range(u64 start, u64 size)
>+{
>+	u64 start_pfn = start >> PAGE_SHIFT;
>+	u64 nr_pages = size >> PAGE_SHIFT;
>+
>+	/* Memory range must be aligned with section */
>+	if ((start_pfn & ~PAGE_SECTION_MASK) ||
>+	    (nr_pages % PAGES_PER_SECTION) || (!nr_pages)) {
>+		pr_err("Section-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
>+				start, size);
>+		return -EINVAL;
>+	}
>+
>+	return 0;
>+}
>+
> /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
> int __ref add_memory(int nid, u64 start, u64 size)
> {
>@@ -1078,6 +1094,10 @@ int __ref add_memory(int nid, u64 start, u64 size)
> 	struct resource *res;
> 	int ret;
>
>+	ret = check_hotplug_memory_range(start, size);
>+	if (ret)
>+		return ret;
>+
> 	lock_memory_hotplug();
>
> 	res = register_memory_resource(start, size);
>@@ -1786,6 +1806,8 @@ void __ref remove_memory(int nid, u64 start, u64 size)
> {
> 	int ret;
>
>+	BUG_ON(check_hotplug_memory_range(start, size));
>+
> 	lock_memory_hotplug();
>
> 	/*
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
