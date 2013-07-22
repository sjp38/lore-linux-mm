From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: zswap: add runtime enable/disable
Date: Tue, 23 Jul 2013 07:25:29 +0800
Message-ID: <6536.98015162281$1374535548@news.gmane.org>
References: <1374521642-25478-1-git-send-email-sjenning@linux.vnet.ibm.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1PU4-00057Q-Re
	for glkm-linux-mm-2@m.gmane.org; Tue, 23 Jul 2013 01:25:41 +0200
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 720176B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 19:25:38 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 23 Jul 2013 04:47:42 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id EEF49394004E
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 04:55:26 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6MNPRgC40173680
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 04:55:27 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6MNPUgc004367
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 09:25:31 +1000
Content-Disposition: inline
In-Reply-To: <1374521642-25478-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Bob Liu <lliubbo@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 22, 2013 at 02:34:02PM -0500, Seth Jennings wrote:
>Right now, zswap can only be enabled at boot time.  This patch
>modifies zswap so that it can be dynamically enabled or disabled
>at runtime.
>
>In order to allow this ability, zswap unconditionally registers as a
>frontswap backend regardless of whether or not zswap.enabled=1 is passed
>in the boot parameters or not.  This introduces a very small overhead
>for systems that have zswap disabled as calls to frontswap_store() will
>call zswap_frontswap_store(), but there is a fast path to immediately
>return if zswap is disabled.
>
>Disabling zswap does not unregister zswap from frontswap.  It simply
>blocks all future stores.
>
>Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>---
> Documentation/vm/zswap.txt | 18 ++++++++++++++++--
> mm/zswap.c                 |  9 +++------
> 2 files changed, 19 insertions(+), 8 deletions(-)
>
>diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
>index 7e492d8..d588477 100644
>--- a/Documentation/vm/zswap.txt
>+++ b/Documentation/vm/zswap.txt
>@@ -26,8 +26,22 @@ Zswap evicts pages from compressed cache on an LRU basis to the backing swap
> device when the compressed pool reaches it size limit.  This requirement had
> been identified in prior community discussions.
>
>-To enabled zswap, the "enabled" attribute must be set to 1 at boot time.  e.g.
>-zswap.enabled=1
>+Zswap is disabled by default but can be enabled at boot time by setting
>+the "enabled" attribute to 1 at boot time. e.g. zswap.enabled=1.  Zswap
>+can also be enabled and disabled at runtime using the sysfs interface.
>+An exmaple command to enable zswap at runtime, assuming sysfs is mounted
>+at /sys, is:
>+
>+echo 1 > /sys/modules/zswap/parameters/enabled
>+
>+When zswap is disabled at runtime, it will stop storing pages that are
>+being swapped out.  However, it will _not_ immediately write out or
>+fault back into memory all of the pages stored in the compressed pool.
>+The pages stored in zswap will continue to remain in the compressed pool
>+until they are either invalidated or faulted back into memory.  In order
>+to force all pages out of the compressed pool, a swapoff on the swap
>+device(s) will fault all swapped out pages, included those in the
>+compressed pool, back into memory.
>
> Design:
>
>diff --git a/mm/zswap.c b/mm/zswap.c
>index deda2b6..199b1b0 100644
>--- a/mm/zswap.c
>+++ b/mm/zswap.c
>@@ -75,9 +75,9 @@ static u64 zswap_duplicate_entry;
> /*********************************
> * tunables
> **********************************/
>-/* Enable/disable zswap (disabled by default, fixed at boot for now) */
>+/* Enable/disable zswap (disabled by default) */
> static bool zswap_enabled __read_mostly;
>-module_param_named(enabled, zswap_enabled, bool, 0);
>+module_param_named(enabled, zswap_enabled, bool, 0644);
>
> /* Compressor to be used by zswap (fixed at boot for now) */
> #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
>@@ -612,7 +612,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> 	u8 *src, *dst;
> 	struct zswap_header *zhdr;
>
>-	if (!tree) {
>+	if (!zswap_enabled || !tree) {

If this check should be added to all hooks in zswap?

> 		ret = -ENODEV;
> 		goto reject;
> 	}
>@@ -908,9 +908,6 @@ static void __exit zswap_debugfs_exit(void) { }
> **********************************/
> static int __init init_zswap(void)
> {
>-	if (!zswap_enabled)
>-		return 0;
>-
> 	pr_info("loading zswap\n");
> 	if (zswap_entry_cache_create()) {
> 		pr_err("entry cache creation failed\n");
>-- 
>1.8.1.2
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
