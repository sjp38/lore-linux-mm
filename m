Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAD1A6B025F
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:01:25 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 101so122790036qtb.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:01:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ss6si20418101wjb.7.2016.08.15.08.01.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Aug 2016 08:01:24 -0700 (PDT)
Date: Mon, 15 Aug 2016 17:01:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160815150123.GG3360@dhcp22.suse.cz>
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
Cc: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon 15-08-16 11:16:36, Vlastimil Babka wrote:
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
> 
> > grep "nr_failed=32" -B1 trace_pipe.log | grep isolate_freepages.*nr_taken=0 | wc -l
> 3246
> 
> So is it one of the cases where fs is unable to migrate dirty/writeback pages?

It smells that way. Now we should find out why and what can we do about
that. I suspect that try_to_release_page is not able to release the page
for migration. Btrfs doesn't seem to have migratepage for page cache
pages so it should go via fallback_migrate_page.

The following diff should tell us whether this is really the case. Just
open trace_pipe and see whether this path really triggered.
---
diff --git a/mm/migrate.c b/mm/migrate.c
index 72c09dea6526..120e2e5fcbea 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -729,8 +729,10 @@ static int fallback_migrate_page(struct address_space *mapping,
 	 * We must have no buffers or drop them.
 	 */
 	if (page_has_private(page) &&
-	    !try_to_release_page(page, GFP_KERNEL))
+	    !try_to_release_page(page, GFP_KERNEL)) {
+		trace_printk("try_to_release_page failed for a_ops:%pS\n", page->a_ops);
 		return -EAGAIN;
+	}
 
 	return migrate_page(mapping, newpage, page, mode);
 }
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
