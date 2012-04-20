Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 8ABBA6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 04:28:51 -0400 (EDT)
Date: Fri, 20 Apr 2012 10:28:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
Message-ID: <20120420082848.GD4191@tiehlicka.suse.cz>
References: <1334680666-12361-1-git-send-email-yinghan@google.com>
 <20120418122448.GB1771@cmpxchg.org>
 <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
 <20120419170434.GE15634@tiehlicka.suse.cz>
 <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
 <20120419223318.GA2536@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20120419223318.GA2536@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ying Han <yinghan@google.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri 20-04-12 00:33:18, Johannes Weiner wrote:
> On Thu, Apr 19, 2012 at 10:47:27AM -0700, Ying Han wrote:
> > On Thu, Apr 19, 2012 at 10:04 AM, Michal Hocko <mhocko@suse.cz> wrote:
[...]
> > > Hmm, I guess that both approaches have cons and pros.
> > > * Hierarchical soft limit reclaim - reclaim the whole subtree of the over
> > >  soft limit memcg
> > >  + it is consistent with the hard limit reclaim
> > Not sure why we want them to be consistent. Soft_limit is serving
> > different purpose and the one of the main purpose is to preserve the
> > working set of the cgroup.
> 
> I'd argue, given the history of cgroups, one of the main purposes is
> having a machine of containers where you overcommit their hard limit
> and set the soft limit accordingly to provide fairness.
> 
> Yes, we don't want to reclaim hierarchies that are below their soft
> limit as long as there are some in excess, of course.  This is a flaw
> and needs fixing.  But it's something completely different than
> changing how the soft limit is defined and suddenly allow child
> groups, which you may not trust, to override rules defined by parental
> groups.

As I wrote in other email. Who is allowed to set the limit? Owner of the
container? If yes then how is admin supposed to set the top limit for
the container? Default (0) will not work, right?

> 
> It bothers me that we should add something that will almost certainly
> bite us in the future while we are discussing on the cgroups list what
> would stand in the way of getting sane hierarchy semantics across
> controllers to provide consistency, nesting, etc.
> 
> To support a single use case, which I feel we still have not discussed
> nearly enough to justify this change.
> 
> For example, I get that you want 'meta-groups' that group together
> subgroups for common accounting and hard limiting.  But I don't see
> why such meta-groups have their own processes.  Conceptually, I mean,
> how does a process fit into A?  Is it superior to the tasks in A1 and
> A2?  Why can't it live in A3?

That was my thinking as well but it will get harder if we really want to
have the unified hierarchy for all controllers.
Consider a school lab and per-user group which basically limits cpu
bandwidth and maximum amount of memory by hard limit (soft limit 0).
If a user would like to run a workload which would benefit from resident
memory he could create a subgroup and set a soft limit. All other tasks
would be executed in his native group by default because we probably do
not want him to think about cgroups for all tasks.

[...]
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
