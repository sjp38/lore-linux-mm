Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 667276B00D1
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 08:18:39 -0400 (EDT)
Date: Wed, 7 Aug 2013 14:18:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCHSET cgroup/for-3.12] cgroup: make cgroup_event specific to
 memcg
Message-ID: <20130807121836.GF8184@dhcp22.suse.cz>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
 <20130805160107.GM10146@dhcp22.suse.cz>
 <20130805162958.GF19631@mtj.dyndns.org>
 <20130805191641.GA24003@dhcp22.suse.cz>
 <20130805194431.GD23751@mtj.dyndns.org>
 <20130806155804.GC31138@dhcp22.suse.cz>
 <20130806161509.GB10779@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130806161509.GB10779@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 06-08-13 12:15:09, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, Aug 06, 2013 at 05:58:04PM +0200, Michal Hocko wrote:
> > I am objecting to moving the generic part of that code into memcg. The
> > memcg part and the additional complexity (all the parsing and conditions
> > for signalling) is already in the memcg code.
> 
> But how is it generic if it's specific to memcg?

How is it specific to memcg? The fact only memcg uses the interface
doesn't imply it is memcg specific.

> The practical
> purpose here is making it clear that the interface is only used by
> memcg and preventing any new usages from sprining up and the best way
> to achieve that is making the code actually memcg-specific. 

There are other ways to achieve the same. E.g. not ack new usage of
register callback users. We have done similar with other things like
use_hierarchy...

> It also helps cleaning up cftype in general.  I'm not sure what you're
> objecting to here.

The cleanup is removing 2 callbacks with a cost of moving non-memcg
specific code inside memcg. That is what I am objecting to.
 
> > Such an interface would be really welcome but I would also ask how
> > it would implement/allow context passing. E.g. how do we know which
> > treshold has been reached? How do we find out the vmpressure level? Is
> > the consumer supposed to do an additional action after it gets
> > notification?
> > Etc.
> 
> Yeap, exactly and that's how it should have been from the beginning.
> Attaching information to notification itself isn't a particularly good
> design (anyone remembers rtsig?) if there's polling mechanism to
> report the current state. 

There are pros and cons for both approaches and it should be discussed
in a separate thread with a code to back all the claims.

> It essentially amounts to duplicate delivery mechanisms for the same
> information, which you usually don't want.  Here, the inconvenience /
> performance implications are negligible or even net-positive.  Plain
> file modified notification is way more familiar / conventional and
> the overhead of an extra read call, which is highly unlikely to be
> relevant given the expected frequency of the events we're talking
> about, is small compared to the action of event delivery and context
> switch.
> 
> > Really that natural? So memcg should touch internals like cgroup dentry
> 
> Functionally, it is completely specific to memcg at this point.  It's
> the only user and will stay the only user.
> 
> > reference counting. You seem have forgotten all the hassles with
> > cgroup_mutex, haven't you?
> 
> Was the above sentence necessary?
> 
> > No that part doesn't belong to memcg! You can discourage from new usage
> > of this interface of course.
> 
> Oh, if you're objecting to the details of the implementation, we of
> course can clean it up.  It should conceptually and functionally be
> part of memcg and that is the guiding line we follow.  Implementations
> follow the concepts and functions, not the other way around.  The
> refcnt of course can be replaced with memcg css refcnting and we can
> of course factor out dentry comparison in a prettier form.
> 
> Compare it to the other way around - having event callbacks in cftype
> and clearing code embedded in cgroup core destruction path when both
> of which are completely irrelevant to all other controllers.  Let's
> clean up the implementation details and put things where they belong.
> What's the excuse for not doing so when it's almost trivially doable?

I will not repeat myself. We seem to disagree on where the code belongs.
As I've said I will not ack this code, try to find somebody else who
think it is a good idea. I do not see any added value.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
