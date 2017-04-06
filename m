Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6053A6B03EF
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 02:38:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a80so2188598wrc.19
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 23:38:31 -0700 (PDT)
Received: from latin.grep.be (latin.grep.be. [2a01:4f8:140:52e5::2])
        by mx.google.com with ESMTPS id 57si1120353wry.114.2017.04.05.23.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 23:38:29 -0700 (PDT)
Date: Thu, 6 Apr 2017 08:38:10 +0200
From: Wouter Verhelst <w@uter.be>
Subject: Re: [Nbd] [PATCH 3/4] treewide: convert PF_MEMALLOC manipulations to
 new helpers
Message-ID: <20170406063810.dmv4fg2irsqgdvyq@grep.be>
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-4-vbabka@suse.cz>
 <20170405113030.GL6035@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405113030.GL6035@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, nbd-general@lists.sourceforge.net, Chris Leech <cleech@redhat.com>, linux-scsi@vger.kernel.org, Josef Bacik <jbacik@fb.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <edumazet@google.com>, Lee Duncan <lduncan@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, open-iscsi@googlegroups.com, Mel Gorman <mgorman@techsingularity.net>, "David S. Miller" <davem@davemloft.net>

On Wed, Apr 05, 2017 at 01:30:31PM +0200, Michal Hocko wrote:
> On Wed 05-04-17 09:46:59, Vlastimil Babka wrote:
> > We now have memalloc_noreclaim_{save,restore} helpers for robust setting and
> > clearing of PF_MEMALLOC. Let's convert the code which was using the generic
> > tsk_restore_flags(). No functional change.
> 
> It would be really great to revisit why those places outside of the mm
> proper really need this flag. I know this is a painful exercise but I
> wouldn't be surprised if there were abusers there.
[...]
> > ---
> >  drivers/block/nbd.c      | 7 ++++---
> >  drivers/scsi/iscsi_tcp.c | 7 ++++---
> >  net/core/dev.c           | 7 ++++---
> >  net/core/sock.c          | 7 ++++---
> >  4 files changed, 16 insertions(+), 12 deletions(-)

These were all done to make swapping over network safe. The idea is that
if a socket has SOCK_MEMALLOC set, incoming packets for that socket can
access PFMEMALLOC reserves (whereas other sockets cannot); this all in
the hope that one packe destined to that socket will contain the TCP ACK
that confirms the swapout was successful and we can now release RAM
pages for other processes.

I don't know whether they need the PF_MEMALLOC flag specifically (not a
kernel hacker), but they do need to interact with it at any rate.

-- 
< ron> I mean, the main *practical* problem with C++, is there's like a dozen
       people in the world who think they really understand all of its rules,
       and pretty much all of them are just lying to themselves too.
 -- #debian-devel, OFTC, 2016-02-12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
