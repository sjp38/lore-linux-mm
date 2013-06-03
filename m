Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 2CF396B0032
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 13:11:00 -0400 (EDT)
Date: Mon, 3 Jun 2013 19:10:31 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 10/10] mm: workingset: keep shadow entries in check
Message-ID: <20130603171031.GD8923@twins.programming.kicks-ass.net>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
 <1369937046-27666-11-git-send-email-hannes@cmpxchg.org>
 <20130603082209.GG5910@twins.programming.kicks-ass.net>
 <20130603150154.GE15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603150154.GE15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Mon, Jun 03, 2013 at 11:01:54AM -0400, Johannes Weiner wrote:
> On Mon, Jun 03, 2013 at 10:22:09AM +0200, Peter Zijlstra wrote:
> > On Thu, May 30, 2013 at 02:04:06PM -0400, Johannes Weiner wrote:
> > > 2. a list of files that contain shadow entries is maintained.  If the
> > >    global number of shadows exceeds a certain threshold, a shrinker is
> > >    activated that reclaims old entries from the mappings.  This is
> > >    heavy-handed but it should not be a common case and is only there
> > >    to protect from accidentally/maliciously induced OOM kills.
> > 
> > Grrr.. another global files list. We've been trying rather hard to get
> > rid of the first one :/
> > 
> > I see why you want it but ugh.
> 
> I'll try to make it per-SB like the inode list.  It probably won't be
> per-SB shrinkers because of the global nature of the shadow limit, but
> at least per-SB inode lists should be doable.

per have per-cpu-per-sb lists, see file_sb_list_{add,del} and
do_file_list_for_each_entry()

> > I have similar worries for your global time counter, large machines
> > might thrash on that one cacheline.
> 
> Fair enough.
> 
> So I'm trying the following idea: instead of the global time counter,
> have per-zone time counters and store the zone along with those local
> timestamps in the shadow entries (nid | zid | time).  On refault, we
> can calculate the zone-local distance first and then use the inverse
> of the zone's eviction proportion to scale it to a global distance.

The thinking is since that's the same granularity as the zone lock,
you're likely to at least trash the zone lock in equal measure?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
