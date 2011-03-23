Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C2D3A8D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 20:32:20 -0400 (EDT)
Date: Wed, 23 Mar 2011 09:27:08 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: consider per-cpu stock reserves when returning
 RES_USAGE for _MEM
Message-Id: <20110323092708.021d555d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110322073150.GA12940@tiehlicka.suse.cz>
References: <20110318152532.GB18450@tiehlicka.suse.cz>
	<20110321093419.GA26047@tiehlicka.suse.cz>
	<20110321102420.GB26047@tiehlicka.suse.cz>
	<20110322091014.27677ab3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110322104723.fd81dddc.nishimura@mxp.nes.nec.co.jp>
	<20110322073150.GA12940@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Tue, 22 Mar 2011 08:31:50 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 22-03-11 10:47:23, Daisuke Nishimura wrote:
> > On Tue, 22 Mar 2011 09:10:14 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Mon, 21 Mar 2011 11:24:20 +0100
> > > Michal Hocko <mhocko@suse.cz> wrote:
> > > 
> > > > [Sorry for reposting but I forgot to fully refresh the patch before
> > > > posting...]
> > > > 
> > > > On Mon 21-03-11 10:34:19, Michal Hocko wrote:
> > > > > On Fri 18-03-11 16:25:32, Michal Hocko wrote:
> > > > > [...]
> > > > > > According to our documention this is a reasonable test case:
> > > > > > Documentation/cgroups/memory.txt:
> > > > > > memory.usage_in_bytes           # show current memory(RSS+Cache) usage.
> > > > > > 
> > > > > > This however doesn't work after your commit:
> > > > > > cdec2e4265d (memcg: coalesce charging via percpu storage)
> > > > > > 
> > > > > > because since then we are charging in bulks so we can end up with
> > > > > > rss+cache <= usage_in_bytes.
> > > > > [...]
> > > > > > I think we have several options here
> > > > > > 	1) document that the value is actually >= rss+cache and it shows
> > > > > > 	   the guaranteed charges for the group
> > > > > > 	2) use rss+cache rather then res->count
> > > > > > 	3) remove the file
> > > > > > 	4) call drain_all_stock_sync before asking for the value in
> > > > > > 	   mem_cgroup_read
> > > > > > 	5) collect the current amount of stock charges and subtract it
> > > > > > 	   from the current res->count value
> > > > > > 
> > > > > > 1) and 2) would suggest that the file is actually not very much useful.
> > > > > > 3) is basically the interface change as well
> > > > > > 4) sounds little bit invasive as we basically lose the advantage of the
> > > > > > pool whenever somebody reads the file. Btw. for who is this file
> > > > > > intended?
> > > > > > 5) sounds like a compromise
> > > > > 
> > > > > I guess that 4) is really too invasive - for no good reason so here we
> > > > > go with the 5) solution.
> > > 
> > > I think the test in LTP is bad...(it should be fuzzy.) because we cannot
> > > avoid races...
> > I agree.
> 
> I think that as well. In fact, I quite do not understand what it is
> testing actually (that we account charges correctly? If yes then what if
> both values are wrong?). The other point is, though, we have exported this
> interface and documented its semantic. This is the reason I have asked
> for the initial purpose of the file in the first place. Is this
> something for debugging only? Can we make use of the value somehow
> (other than a shortcut for rss+cache)?
> 
> If there is realy no strong reason for the file existence I would rather
> vote for its removing than having a unusable semantic.
> 
Considering more, without these files, we cannot know the actual usage of
a res_counter, although we set a limit to a res_counter. So, I want to keep
these files.

If no-one have any objections, I'll prepare a patch to update the documentation.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
