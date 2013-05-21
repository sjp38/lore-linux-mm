Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id DB82E6B0036
	for <linux-mm@kvack.org>; Tue, 21 May 2013 14:57:36 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 21 May 2013 14:57:34 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5A0116E8039
	for <linux-mm@kvack.org>; Tue, 21 May 2013 14:57:29 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4LIvWp9286038
	for <linux-mm@kvack.org>; Tue, 21 May 2013 14:57:32 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4LIvSxu010624
	for <linux-mm@kvack.org>; Tue, 21 May 2013 12:57:29 -0600
Date: Tue, 21 May 2013 13:57:20 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] zswap: add zswap shrinker
Message-ID: <20130521185720.GA3398@medulla>
References: <1369117567-26704-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369117567-26704-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, minchan@kernel.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, rcj@linux.vnet.ibm.com, mgorman@suse.de, riel@redhat.com, dave@sr71.net, hughd@google.com, Bob Liu <bob.liu@oracle.com>

On Tue, May 21, 2013 at 02:26:07PM +0800, Bob Liu wrote:
> In my understanding, currenlty zswap have a few problems.
> 1. The zswap pool size is 20% of total memory that's too random and once it
> gets full the performance may even worse because everytime pageout() an anon
> page two disk-io write ops may happend instead of one.

Just to clarify, 20% is a default maximum amount that zswap can occupy.

Also, in the steady over-the-limit state, the average number of writebacks is
equal to the number of pages coming into zswap.  The description above makes it
sound like there is a reclaim amplification effect (two writebacks per zswap
store) when, on average, there is none. The 2:1 effect only happens on one or
two store operations right after the pool becomes full.

This is unclear though, mostly because the pool limit is enforced in
zswap.  A situation exists where there might be an unbuddied zbud page with
room for the upcoming allocation but, because we are over the pool limit,
reclaim is done during that store anyway. I'm working on a clean way to fix
that up, probably by moving the limit enforcement into zbud as suggested by
Mel.

> 2. The reclaim hook will only be triggered in frontswap_store().
> It may be result that the zswap pool size can't be adjusted in time which may
> caused 20% memory lose for other users.
> 
> This patch introduce a zswap shrinker, it make the balance that the zswap
> pool size will be the same as anon pages in use.

Using zbud, with 2 zpages per zbud page, that would mean that up to 2/3 of anon
pages could be compressed while 1/3 remain uncompressed.

How did you conclude that this is the right balance?

If nr_reclaim in the shrinker became very large due to global_anon_pages_inuse
suddenly dropping, we could be writing back a LOT of pages all at once.

Having already looked at the patch, I can say that this isn't going to be the
way to do this.  I agree that there should be some sort of dynamic sizing, but
IMHO using a shrinker isn't the way.  Dave Chinner would not be happy about
this since it is based on the zcache shrinker logic and he didn't have many
kind words to say about it: https://lkml.org/lkml/2012/11/27/552

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
