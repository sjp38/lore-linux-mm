Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB75C6B032B
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 08:37:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x1-v6so7404624edh.8
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 05:37:08 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5-v6si8649141edl.65.2018.11.06.05.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 05:37:07 -0800 (PST)
Date: Tue, 6 Nov 2018 14:37:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: NUMA memchr_inv() in mm/vmstat.c:need_update()?
Message-ID: <20181106133706.GE2453@dhcp22.suse.cz>
References: <1541162651.27706.93.camel@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1541162651.27706.93.camel@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janne Huttunen <janne.huttunen@nokia.com>
Cc: linux-mm@kvack.org

On Fri 02-11-18 14:44:11, Janne Huttunen wrote:
> Hi,
> 
> The commit 1d90ca897 changed the type of the vm_numa_stat_diff
> from s8 into u16. It also changed the associated BUILD_BUG_ON()
> in need_update(), but didn't touch the memchr_inv() call after
> it. Is the memchr_inv() call still supposed to cover the whole
> array or am I just misreading the code?
 
I guess you are not missing anything. We need something like
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 6038ce593ce3..c42f01fbe964 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1829,10 +1829,10 @@ static bool need_update(int cpu)
 		 * The fast way of checking if there are any vmstat diffs.
 		 * This works because the diffs are byte sized items.
 		 */
-		if (memchr_inv(p->vm_stat_diff, 0, NR_VM_ZONE_STAT_ITEMS))
+		if (memchr_inv(p->vm_stat_diff, 0, sizeof(*p->vm_stat_diff) * NR_VM_ZONE_STAT_ITEMS))
 			return true;
 #ifdef CONFIG_NUMA
-		if (memchr_inv(p->vm_numa_stat_diff, 0, NR_VM_NUMA_STAT_ITEMS))
+		if (memchr_inv(p->vm_numa_stat_diff, 0, sizeof(p->vm_numa_stat_diff) * NR_VM_NUMA_STAT_ITEMS))
 			return true;
 #endif
 	}

sizeof(p->vm_numa_stat_diff) would be shorter but more fragile if we
ever decide to change the type to be a pointer rather than a fixed
arrasy.

Care to send a full patch?
-- 
Michal Hocko
SUSE Labs
