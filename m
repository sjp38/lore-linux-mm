Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA1A76B0262
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 23:06:32 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j67so183198986oih.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 20:06:32 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id z201si19122186itb.24.2016.08.15.20.06.31
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 20:06:32 -0700 (PDT)
Date: Tue, 16 Aug 2016 12:12:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: OOM killer changes
Message-ID: <20160816031222.GC16913@js1304-P5Q-DELUXE>
References: <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
 <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
 <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Aug 15, 2016 at 11:16:36AM +0200, Vlastimil Babka wrote:
> On 08/15/2016 06:48 AM, Ralf-Peter Rohbeck wrote:
> > On 02.08.2016 12:25, Ralf-Peter Rohbeck wrote:
> >>
> > Took me a little longer than expected due to work. The failure wouldn't 
> > happen for a while and so I started a couple of scripts and let them 
> > run. When I checked today the server didn't respond on the network and 
> > sure enough it had killed everything. This is with 4.7.0 with the config 
> > based on Debian 4.7-rc7.
> > 
> > trace_pipe got a little big (5GB) so I uploaded the logs to 
> > https://filebin.net/box0wycfouvhl6sr/OOM_4.7.0.tar.bz2. before_btrfs is 
> > before the btrfs filesystems were mounted.
> > I did run a btrfs balance because it creates IO load and I needed to 
> > balance anyway. Maybe that's what caused it?
> 
> pgmigrate_success        46738962
> pgmigrate_fail          135649772
> compact_migrate_scanned 309726659
> compact_free_scanned   9715615169
> compact_isolated        229689596
> compact_stall 4777
> compact_fail 3068
> compact_success 1709
> compact_daemon_wake 207834
> 
> The migration failures are quite enormous. Very quick analysis of the
> trace seems to confirm that these are mostly "real", as opposed to result
> of failure to isolate free pages for migration targets, although the free
> scanner spent a lot of time:

I don't think that main reason of OOM is 'real' migration failure.
If it is the case, compaction would find next migratable pages and
eventually some of pages would be migrated successfully.

pagetypeinfo shows that there are too many unmovable pageblock.
Freepage scanner don't scan those pageblocks so there is a large
possibility that it cannot find freepages even if the system has many
freepages. I think that this is the root cause of the problem.

It's better to check that following work-around help the problem.

Thanks.

------------>8-----------
diff --git a/mm/compaction.c b/mm/compaction.c
index 9affb29..965eddd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1082,10 +1082,6 @@ static void isolate_freepages(struct compact_control *cc)
                if (!page)
                        continue;
 
-               /* Check the block is suitable for migration */
-               if (!suitable_migration_target(page))
-                       continue;
-
                /* If isolation recently failed, do not retry */
                if (!isolation_suitable(cc, page))
                        continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
