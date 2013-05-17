Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 106D26B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:53:31 -0400 (EDT)
Date: Fri, 17 May 2013 14:53:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V2 0/3] memcg: simply lock of page stat accounting
Message-ID: <20130517125327.GG5048@dhcp22.suse.cz>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
 <519380FC.1040504@openvz.org>
 <20130515134110.GD5455@dhcp22.suse.cz>
 <51946071.4030101@openvz.org>
 <20130516132846.GE13848@dhcp22.suse.cz>
 <5195C6D1.6040005@openvz.org>
 <20130517083806.GB5048@dhcp22.suse.cz>
 <5196068D.2050608@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5196068D.2050608@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Sha Zhengju <handai.szj@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

On Fri 17-05-13 14:29:33, Konstantin Khlebnikov wrote:
> Michal Hocko wrote:
> >On Fri 17-05-13 09:57:37, Konstantin Khlebnikov wrote:
> >>Michal Hocko wrote:
> >>>On Thu 16-05-13 08:28:33, Konstantin Khlebnikov wrote:
> >[...]
> >>>>If somebody needs more detailed information there are enough ways to get it.
> >>>>Amount of mapped pages can be estimated via summing rss counters from mm-structs.
> >>>>Exact numbers can be obtained via examining /proc/pid/pagemap.
> >>>
> >>>How do you find out whether given pages were charged to the group of
> >>>interest - e.g. shared data or taks that has moved from a different
> >>>group without move_at_immigrate?
> >>
> >>For example we can export pages ownership and charging state via
> >>single file in proc, something similar to /proc/kpageflags
> >
> >So you would like to add a new interface with cryptic api (I consider
> >kpageflags to be a devel tool not an admin aid) to replace something
> >that is easy to use? Doesn't make much sense to me.
> 
> Hmm. Kernel api is just api. It's not supposed to be a tool itself.
> It must be usable for making tools which admins can use.

But the file is there and we have to keep it for ever. That was my
point. I do not care how do we account.
 
> >>BTW
> >>In our kernel the memory controller tries to change page's ownership
> >>at first mmap and at each page activation, probably it's worth to add
> >>this into mainline memcg too.
> >
> >Dunno, there are different approaches for this. I haven't evalueted them
> >so I don't know all the pros and cons. Why not just unmap&uncharge the
> >page when the charging process dies. This should be more lightweight
> >wrt. recharge on re-activation.
> 
> On activation it's mostly free, because we need to lock lru anyway.
> If memcg charge/uncharge isn't fast enough for that it should be optimized.

Be careful about that. charge can end up in OOM lock waiting for the
user to handle free some memory. You cannot call charge from within any
locks (well mmap_sem for reading is somehow acceptable because that one
is really hard to get rid of).
 
> So, you propose to uncharge pages at unmap and charge them to who?
> To the next mm in rmap?

No, unmap it from all processes if there is no other process from the
same group as the exiting task and charge on the re-fault.
I have heared about some usecases where this could help to age shared
data but the reporter disappeared so I've lost interest in fixing it
because it wouldn't be cheap and I do not remember many details about
the workload which would be necessary to justify such a change.

> What if next map will happens from different memcg, but after that unmap:
> 
> A:map
> <pages owned by A>
> A:unmap
> <no new owner in rmap>
> B:map
> <pages still owned by A>
> 
> Anyway this is difficult question and I bring this just to show
> that currently used logic isn't perfect in many ways.

Well, the world is not ideal. I wasn't involved in the early discussion
about this topic but what I remember from mailing list archives is that
"charge at the first touch" was the most reasonable compromise at the
time.

> Switching ownership lazily in particular places is a best solution
> which I can see now. So, page will be owned by its last active user.

There are other options as well. We can have a background daemon which
unmaps shared pages if there no processes from the group it has been
charged against. This wouldn't touch any hot paths. But this is getting
off-topic.
 
> >>>>I don't think that simulating 'Mapped' line in /proc/mapfile is a worth reason
> >>>>for adding such weird stuff into the rmap code on map/unmap paths.
> >>>
> >>>The accounting code is trying to be not intrusive as much as possible.
> >>>This patchset makes it more complicated without a good reason and that
> >>>is why it has been Nacked by me.
> >>
> >>I think we can remove it or replace it with something different but
> >>much less intrusive, if nobody strictly requires exactly this approach
> >>in managing 'mapped' pages counters.
> >
> >Do you have any numbers on the intrusiveness? I do not mind to change
> >the internal implementation but the file is a part of the user space API
> >so we cannot get rid of it.
> 
> Main problem here that it increases complexity of switching pages'
> ownership.  We need not just charge/uncharge page and move it to
> the different LRU, but also synchronize with map/unmap paths in
> rmap to update nr-mapped counters carefully. If you want to add
> per-page dirty/writeback counters it will increase that complexity
> even further.

The patches didn't add too much complexity when it were sent the last
time. Well, there was a big problem at the time because s390 has called
set_page_dirty from the rmap code which caused a lot of troubles but
that one is gone and so our free ride can start.

> I haven't started yet migrating our product to mainline memory
> controller, so I don't have any numbers. But my old code completely
> lockless on charging and uncharging fast paths. LRU lock is the only
> lock on changing page's owner, LRU isolation itself protects page
> ownership reference.

Send those patches and we can discuss that further.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
