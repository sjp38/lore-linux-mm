Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 534356B0044
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 21:46:35 -0500 (EST)
Received: by mail-da0-f51.google.com with SMTP id i30so8947065dad.38
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 18:46:34 -0800 (PST)
Date: Mon, 7 Jan 2013 18:46:31 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v7 1/2] KSM: numa awareness sysfs knob
In-Reply-To: <1357609227.4105.3.camel@kernel.cn.ibm.com>
Message-ID: <alpine.LNX.2.00.1301071812001.18327@eggly.anvils>
References: <20121224050817.GA25749@kroah.com> <1356658337-12540-1-git-send-email-pholasek@redhat.com> <1357015310.1379.2.camel@kernel.cn.ibm.com> <20130103122416.GB2277@thinkpad-work.redhat.com> <1357609227.4105.3.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Mon, 7 Jan 2013, Simon Jeons wrote:
> On Thu, 2013-01-03 at 13:24 +0100, Petr Holasek wrote:
> > Hi Simon,
> > 
> > On Mon, 31 Dec 2012, Simon Jeons wrote:
> > > On Fri, 2012-12-28 at 02:32 +0100, Petr Holasek wrote:
> > > > 
> > > > v7:	- added sysfs ABI documentation for KSM
> > > 
> > > Hi Petr,
> > > 
> > > How you handle "memory corruption because the ksm page still points to
> > > the stable_node that has been freed" mentioned by Andrea this time?
> > > 
> > 
> 
> Hi Petr,
> 
> You still didn't answer my question mentioned above. :)

Yes, I noticed that too :)  I think Petr probably hopes that I'll
answer; and yes, I do hold myself responsible for solving this.

The honest answer is that I forgot all about it for a while.  I
had to go back to read the various threads to remind myself of what
Andrea said back then, and the ideas I had in replying.  Thank you
for reminding us.

I do intend to fix it along the lines I suggested then, if that works
out; but that is a danger in memory hotremove only, so at present I'm
still wrestling with the more immediate problem of stale stable_nodes
when switching merge_across_nodes between 1 and 0 and 1.

Many of the problems there come from reclaim under memory pressure:
stable pages being written out to swap, and faulted back in at "the
wrong time".  Essentially, existing bugs in KSM_RUN_UNMERGE, that
were not visible until merge_across_nodes brought us to rely upon it.

I have "advanced" from kernel oopses to userspace corruption: that's
no advance at all, no doubt I'm doing something stupid, but I haven't
spotted it yet; and once I've fixed that up, shall probably want to
look back at the little heap of fixups (a remove_all_stable_nodes()
function) and go about it quite differently - but for now I'm still
learning from the bugs I give myself.

> 
> > <snip>
> > 
> > > >  
> > > > +		/*
> > > > +		 * If tree_page has been migrated to another NUMA node, it
> > > > +		 * will be flushed out and put into the right unstable tree
> > > > +		 * next time: only merge with it if merge_across_nodes.
> > > 
> > > Why? Do you mean swap based migration? Or where I miss ....?
> > > 
> > 
> > It can be physical page migration triggered by page compaction, memory hotplug
> > or some NUMA sched/memory balancing algorithm developed recently.
> > 
> > > > +		 * Just notice, we don't have similar problem for PageKsm
> > > > +		 * because their migration is disabled now. (62b61f611e)
> > > > +		 */
> > 
> > Migration of KSM pages is disabled now, you can look into ^^^ commit and
> > changes introduced to migrate.c.

Migration of KSM pages is still enabled in the memory hotremove case.

I don't remember how I tested that back then, so I want to enable KSM
page migration generally, just to be able to test it more thoroughly.
That would then benefit compaction, no longer frustrated by a KSM
page in the way.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
