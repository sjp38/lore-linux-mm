Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B02BA6B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 05:05:48 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w37so73616589wrc.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 02:05:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b188si18179261wmc.96.2017.03.07.02.05.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 02:05:47 -0800 (PST)
Date: Tue, 7 Mar 2017 11:05:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170307100545.GC28642@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <89efde633559de1ec07444f2ef0f4963a97a2ce8.1487965799.git.shli@fb.com>
 <20170301133624.GF1124@dhcp22.suse.cz>
 <20170301183149.GA14277@cmpxchg.org>
 <20170301185735.GA24905@dhcp22.suse.cz>
 <20170302140101.GA16021@cmpxchg.org>
 <20170302163054.GR1404@dhcp22.suse.cz>
 <20170303161027.6fe4ceb0bcd27e1dbed44a5d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303161027.6fe4ceb0bcd27e1dbed44a5d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net

On Fri 03-03-17 16:10:27, Andrew Morton wrote:
> On Thu, 2 Mar 2017 17:30:54 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > It's not that I think you're wrong: it *is* an implementation detail.
> > > But we take a bit of incoherency from batching all over the place, so
> > > it's a little odd to take a stand over this particular instance of it
> > > - whether demanding that it'd be fixed, or be documented, which would
> > > only suggest to users that this is special when it really isn't etc.
> > 
> > I am not aware of other counter printed in smaps that would suffer from
> > the same problem, but I haven't checked too deeply so I might be wrong. 
> > 
> > Anyway it seems that I am alone in my position so I will not insist.
> > If we have any bug report then we can still fix it.
> 
> A single lru_add_drain_all() right at the top level (in smaps_show()?)
> won't kill us

I do not think we want to put lru_add_drain_all cost to a random
process reading /proc/<pid>/smaps. If anything the one which does the
madvise should be doing this.

> and should significantly improve this issue.  And it
> might accidentally make some of the other smaps statistics more
> accurate as well.
> 
> If not, can we please have a nice comment somewhere appropriate which
> explains why LazyFree is inaccurate and why we chose to leave it that
> way?

Yeah, I would appreciate the comment more. What about the following
---
diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 45853e116eef..0b58b317dc76 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -444,7 +444,9 @@ a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
 "LazyFree" shows the amount of memory which is marked by madvise(MADV_FREE).
 The memory isn't freed immediately with madvise(). It's freed in memory
-pressure if the memory is clean.
+pressure if the memory is clean. Please note that the printed value might
+be lower than the real value due to optimizations used in the current
+implementation. If this is not desirable please file a bug report.
 "AnonHugePages" shows the ammount of memory backed by transparent hugepage.
 "ShmemPmdMapped" shows the ammount of shared (shmem/tmpfs) memory backed by
 huge pages.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
