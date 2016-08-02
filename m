Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 384FE6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 03:10:13 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k135so87965277lfb.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 00:10:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx15si1213483wjc.291.2016.08.02.00.10.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 00:10:11 -0700 (PDT)
Date: Tue, 2 Aug 2016 09:10:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160802071010.GB12403@dhcp22.suse.cz>
References: <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
 <939def12-3fa8-e877-ce17-b59db9fa1876@Quantum.com>
 <20160801194323.GE31957@dhcp22.suse.cz>
 <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
 <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon 01-08-16 14:27:51, Ralf-Peter Rohbeck wrote:
> On 01.08.2016 14:14, Ralf-Peter Rohbeck wrote:
> > On 01.08.2016 13:26, Michal Hocko wrote:
> > > 
> > > > sdc, sdd and sde each at max speed, with a little bit of garden
> > > > variety IO
> > > > on sda and sdb.
> > > So do I get it right that the majority of the IO is to those slower USB
> > > disks?  If yes then does lowering the dirty_bytes to something smaller
> > > help?
> > 
> > Yes, the vast majority.
> > 
> > I set dirty_bytes to 128MiB and started a fairly IO and memory intensive
> > process and the OOM killer kicked in within a few seconds.
> > 
> > Same with 16MiB dirty_bytes and 1MiB.
> > 
> > Some additional IO load from my fast subsystem is enough:
> > 
> > At 1MiB dirty_bytes,
> > 
> > find /btrfs0/ -type f -exec md5sum {} \;
> > 
> > was enough (where /btrfs0 is on a LVM2 LV and the PV is on sda.) It read
> > a few dozen files (random stuff with very mixed file sizes, none very
> > big) until the OOM killer kicked in.
> > 
> > I'll try 4.6.
>
> With Debian 4.6.0.1 (4.6.4-1) it works: Writing to 3 USB drives and running
> each of the 3 tests that triggered the OOM killer in parallel, with default
> dirty settings.

Thanks for retesting! Now that it seems you are able to reproduce this,
could you do some experiments, please? First of all it would be great to
find out why we do not retry the compaction and whether it could make
some progress. The patch below will tell us the first part. Tracepoints 
can tell us the other part. Vlastimil, could you recommend some which
would give us some hints without generating way too much output?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8b3e1341b754..a10b29a918d4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3274,6 +3274,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 			*migrate_mode = MIGRATE_SYNC_LIGHT;
 			return true;
 		}
+		pr_info("XXX: compaction_failed\n");
 		return false;
 	}
 
@@ -3283,8 +3284,12 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	 * But do not retry if the given zonelist is not suitable for
 	 * compaction.
 	 */
-	if (compaction_withdrawn(compact_result))
-		return compaction_zonelist_suitable(ac, order, alloc_flags);
+	if (compaction_withdrawn(compact_result)) {
+		int ret = compaction_zonelist_suitable(ac, order, alloc_flags);
+		if (!ret)
+			pr_info("XXX: no zone suitable for compaction\n");
+		return ret;
+	}
 
 	/*
 	 * !costly requests are much more important than __GFP_REPEAT
@@ -3299,6 +3304,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	if (compaction_retries <= max_retries)
 		return true;
 
+	pr_info("XXX: compaction retries fail after %d\n", compaction_retries);
 	return false;
 }
 #else

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
