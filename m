Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A98576B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 13:32:52 -0500 (EST)
Date: Thu, 3 Jan 2013 18:32:51 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130103183251.GA10113@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130102204712.GA17806@dcvr.yhbt.net>
 <1357220469.21409.24574.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357220469.21409.24574.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-01-02 at 20:47 +0000, Eric Wong wrote:
> > Eric Wong <normalperson@yhbt.net> wrote:
> > > [1] my full setup is very strange.
> > > 
> > >     Other than the FUSE component I forgot to mention, little depends on
> > >     the kernel.  With all this, the standalone toosleepy can get stuck.
> > >     I'll try to reproduce it with less...
> > 
> > I just confirmed my toosleepy processes will get stuck while just
> > doing "rsync -a" between local disks.  So this does not depend on
> > sendfile or FUSE to reproduce.
> > --
> 
> How do you tell your 'toosleepy' is stuck ?

My original post showed it stuck with strace (in ppoll + send).
I only strace after seeing it's not using any CPU in top.

http://mid.gmane.org/20121228014503.GA5017@dcvr.yhbt.net
(lsof also confirmed the ppoll/send sockets were peers)

> If reading its output, you should change its logic, there is no
> guarantee the recv() will deliver exactly 16384 bytes each round.
> 
> With the following patch, I cant reproduce the 'apparent stuck'

Right, the output is just an approximation and the logic there
was bogus.

Thanks for looking at this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
