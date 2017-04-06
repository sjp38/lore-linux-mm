Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1826B040E
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 07:25:29 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k22so5729161wrk.5
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 04:25:29 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id k72si2581183wmi.139.2017.04.06.04.25.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 04:25:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 918B0F4025
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 11:25:27 +0000 (UTC)
Date: Thu, 6 Apr 2017 12:25:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [Nbd] [PATCH 3/4] treewide: convert PF_MEMALLOC manipulations to
 new helpers
Message-ID: <20170406112526.jj7zwzxqvushy5g2@techsingularity.net>
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-4-vbabka@suse.cz>
 <20170405113030.GL6035@dhcp22.suse.cz>
 <20170406063810.dmv4fg2irsqgdvyq@grep.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170406063810.dmv4fg2irsqgdvyq@grep.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wouter Verhelst <w@uter.be>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, nbd-general@lists.sourceforge.net, Chris Leech <cleech@redhat.com>, linux-scsi@vger.kernel.org, Josef Bacik <jbacik@fb.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <edumazet@google.com>, Lee Duncan <lduncan@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, open-iscsi@googlegroups.com, "David S. Miller" <davem@davemloft.net>

On Thu, Apr 06, 2017 at 08:38:10AM +0200, Wouter Verhelst wrote:
> On Wed, Apr 05, 2017 at 01:30:31PM +0200, Michal Hocko wrote:
> > On Wed 05-04-17 09:46:59, Vlastimil Babka wrote:
> > > We now have memalloc_noreclaim_{save,restore} helpers for robust setting and
> > > clearing of PF_MEMALLOC. Let's convert the code which was using the generic
> > > tsk_restore_flags(). No functional change.
> > 
> > It would be really great to revisit why those places outside of the mm
> > proper really need this flag. I know this is a painful exercise but I
> > wouldn't be surprised if there were abusers there.
> [...]
> > > ---
> > >  drivers/block/nbd.c      | 7 ++++---
> > >  drivers/scsi/iscsi_tcp.c | 7 ++++---
> > >  net/core/dev.c           | 7 ++++---
> > >  net/core/sock.c          | 7 ++++---
> > >  4 files changed, 16 insertions(+), 12 deletions(-)
> 
> These were all done to make swapping over network safe. The idea is that
> if a socket has SOCK_MEMALLOC set, incoming packets for that socket can
> access PFMEMALLOC reserves (whereas other sockets cannot); this all in
> the hope that one packe destined to that socket will contain the TCP ACK
> that confirms the swapout was successful and we can now release RAM
> pages for other processes.
> 
> I don't know whether they need the PF_MEMALLOC flag specifically (not a
> kernel hacker), but they do need to interact with it at any rate.
> 

At the time it was required to get access to emergency reserves so swapping
can continue. The flip side is that the memory is then protected so pages
allocated from emergency reserves are not used for network traffic that
is not involved with swap. This means that under heavy swap load, it was
perfectly possible for unrelated traffic to get dropped for quite some
time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
