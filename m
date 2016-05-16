Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED84828E1
	for <linux-mm@kvack.org>; Mon, 16 May 2016 03:37:19 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so95649041lfc.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 00:37:19 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id f5si37067375wjt.204.2016.05.16.00.37.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 00:37:18 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so16062852wmn.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 00:37:17 -0700 (PDT)
Date: Mon, 16 May 2016 09:37:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: unhide vmstat_text definition for CONFIG_SMP
Message-ID: <20160516073716.GB23146@dhcp22.suse.cz>
References: <1462978517-2972312-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462978517-2972312-1-git-send-email-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 11-05-16 16:54:55, Arnd Bergmann wrote:
> In randconfig builds with sysfs, procfs and numa all disabled,
> but SMP enabled, we now get a link error in the newly introduced
> vmstat_refresh function:
> 
> mm/built-in.o: In function `vmstat_refresh':
> :(.text+0x15c78): undefined reference to `vmstat_text'
> 
> This modifes the already elaborate #ifdef to also cover that
> configuration.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: mmotm ("mm: /proc/sys/vm/stat_refresh to force vmstat update")

I agree with Christoph that vmstat_refresh is PROC_FS only so we should
fix it there. It is not like this would be generally reusable helper...
Why don't we just do:
---
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 57a24e919907..c759b526287b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1370,6 +1370,7 @@ static void refresh_vm_stats(struct work_struct *work)
 	refresh_cpu_vm_stats(true);
 }
 
+#ifdef CONFIG_PROC_FS
 int vmstat_refresh(struct ctl_table *table, int write,
 		   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -1422,6 +1423,7 @@ int vmstat_refresh(struct ctl_table *table, int write,
 		*lenp = 0;
 	return 0;
 }
+#endif
 
 static void vmstat_update(struct work_struct *w)
 {
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
