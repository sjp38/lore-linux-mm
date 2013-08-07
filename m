Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 6E9E36B00DB
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 09:26:16 -0400 (EDT)
Date: Wed, 7 Aug 2013 15:26:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCHSET cgroup/for-3.12] cgroup: make cgroup_event specific to
 memcg
Message-ID: <20130807132613.GH8184@dhcp22.suse.cz>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
 <20130805160107.GM10146@dhcp22.suse.cz>
 <20130805162958.GF19631@mtj.dyndns.org>
 <20130805191641.GA24003@dhcp22.suse.cz>
 <20130805194431.GD23751@mtj.dyndns.org>
 <20130806155804.GC31138@dhcp22.suse.cz>
 <20130806161509.GB10779@mtj.dyndns.org>
 <20130807121836.GF8184@dhcp22.suse.cz>
 <20130807124321.GA27006@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807124321.GA27006@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 07-08-13 08:43:21, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Aug 07, 2013 at 02:18:36PM +0200, Michal Hocko wrote:
> > How is it specific to memcg? The fact only memcg uses the interface
> > doesn't imply it is memcg specific.
> 
> I don't follow.  It's only for memcg.  That is *by definition* memcg
> specific.  It's the verbatim meaning of the word.

My understanding of "memcg specific" is that it uses memcg specific
code/data structures. But let's not play with words.

> Now, I do
> understand that it can be a concern the implementation details as-is
> could be a bit too invasive into cgroup core to be moved to memcg, but
> that's something we can work on, right?

Does it really make sense to work on this interface if it is planned to
be replaced by something different. Isn't that just a waste of time?

> Can you at least agree that the feature is nmemcg specific and it'd be
> better to be located in memcg if possible?  That really isn't not much
> to ask and is a logical thing to do.

I would rather see it not changed unless it really is a big win in the
cgroup core. So far I do not see anything like that (just look at
__cgroup_from_dentry which needs to be exported to allow for the move).
You reduce the amount of code in cgroup.c, alright, but the code
doesn't go away really. It just moves out of your sight and moves the
same burden on somebody else without providing a new generic interface.

> > There are other ways to achieve the same. E.g. not ack new usage of
> > register callback users. We have done similar with other things like
> > use_hierarchy...
> 
> Yes, but those are all inferior to actually moving the code where it
> belongs.  Those makes the code harder to follow and people
> misunderstand and waste time working on stuff (either in the core or
> controllers) which eventually end up getting nacked.  Why do that when
> we can easily do better?  What's the rationale behind that?

If somebody needs a notification interface (and there is no one available
right now) then you cannot prevent from such a pointless work anyway...

> > The cleanup is removing 2 callbacks with a cost of moving non-memcg
> > specific code inside memcg. That is what I am objecting to.
> 
> I don't really get your "non-memcg" specific code assertion when it is
> by definition memcg-specific.  What are you talking about?

cgroup_event_* don't sound memcg specific at all. They are playing with
cgroup dentry reference counting and do a generic functionality which
memcg doesn't need to know about.

> > I will not repeat myself. We seem to disagree on where the code belongs.
> > As I've said I will not ack this code, try to find somebody else who
> > think it is a good idea. I do not see any added value.
> 
> Nacking is part of your authority as maintainer but you should still
> provide plausible rationale for that.

I didn't say I Nack it. I said I won't Ack it. If Johannes or Kamezawa
think this is OK and another bloat in memcg is not a big deal I will not
block it. I won't be happy but how is the life.

> Are you saying that even if the
> code is restructured so that it's not invasive into cgroup core, you
> are still gonna disagree with it because it's still somehow not
> memcg-specifc?

I wouldn't object to having non-cgroup internals playing variant. I just
do not think it makes sense to invest time to something that should go
away long term.

> Please don't repeat yourself but do explain your rationale.  That's
> part of your duty as a maintainer too.

I think I am clear what I do not like about this move.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
