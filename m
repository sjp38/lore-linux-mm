Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 64E328D0046
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 13:32:29 -0400 (EDT)
Date: Thu, 17 Mar 2011 18:32:23 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110317173223.GG4116@quack.suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <AANLkTimeH-hFiqtALfzyyrHiLz52qQj0gCisaJ-taCdq@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimeH-hFiqtALfzyyrHiLz52qQj0gCisaJ-taCdq@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

On Thu 17-03-11 08:46:23, Curt Wohlgemuth wrote:
> On Tue, Mar 8, 2011 at 2:31 PM, Jan Kara <jack@suse.cz> wrote:
> The design of IO-less foreground throttling of writeback in the context of
> memory cgroups is being discussed in the memcg patch threads (e.g.,
> "[PATCH v6 0/9] memcg: per cgroup dirty page accounting"), but I've got
> another concern as well.  And that's how restricting per-BDI writeback to a
> single task will affect proposed changes for tracking and accounting of
> buffered writes to the IO scheduler ("[RFC] [PATCH 0/6] Provide cgroup
> isolation for buffered writes", https://lkml.org/lkml/2011/3/8/332 ).
> 
> It seems totally reasonable that reducing competition for write requests to
> a BDI -- by using the flusher thread to "handle" foreground writeout --
> would increase throughput to that device.  At Google, we experiemented with
> this in a hacked-up fashion several months ago (FG task would enqueue a work
> item and sleep for some period of time, wake up and see if it was below the
> dirty limit), and found that we were indeed getting better throughput.
> 
> But if one of one's goals is to provide some sort of disk isolation based on
> cgroup parameters, than having at most one stream of write requests
> effectively neuters the IO scheduler.  We saw that in practice, which led to
> abandoning our attempt at "IO-less throttling."
  Let me check if I understand: The problem you have with one flusher
thread is that when written pages all belong to a single memcg, there is
nothing IO scheduler can prioritize, right?

> One possible solution would be to put some of the disk isolation smarts into
> the writeback path, so the flusher thread could choose inodes with this as a
> criteria, but this seems ugly on its face, and makes my head hurt.
  Well, I think it could be implemented in a reasonable way but then you
still miss reads and direct IO from the mix so it will be a poor isolation.
But maybe we could propagate the information from IO scheduler to flusher
thread? If IO scheduler sees memcg has run out of its limit, it could hint
to a flusher thread that it should switch to an inode from a different memcg.
But still the details get nasty as I think about them (how to pick next
memcg, how to pick inodes,...). Essentially, we'd have to do with flusher
threads what old pdflush did when handling congested devices. Ugh.

> Otherwise, I'm having trouble thinking of a way to do effective isolation in
> the IO scheduler without having competing threads -- for different cgroups --
> making write requests for buffered data.  Perhaps the best we could do would
> be to enable IO-less throttling in writeback as a config option?
  Well, nothing prevents us to choose to do foreground writeback throttling
for memcgs and IO-less one without them but as Christoph writes, this
doesn't seem very compeling either... I'll let this brew in my head for
some time and maybe something comes.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
