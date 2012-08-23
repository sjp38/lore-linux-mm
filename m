Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3272F6B0068
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 03:52:39 -0400 (EDT)
Message-ID: <5035E086.2090505@parallels.com>
Date: Thu, 23 Aug 2012 11:49:26 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH V8 1/2] mm: memcg softlimit reclaim rework
References: <1343942658-13307-1-git-send-email-yinghan@google.com> <20120803152234.GE8434@dhcp22.suse.cz> <501BF952.7070202@redhat.com> <CALWz4iw6Q500k5qGWaubwLi-3V3qziPuQ98Et9Ay=LS0-PB0dQ@mail.gmail.com> <20120806133324.GD6150@dhcp22.suse.cz> <CALWz4iw2NqQw3FgjM9k6nbMb7k8Gy2khdyL_9NpGM6T7Ma5t3g@mail.gmail.com> <5031EF4C.6070204@parallels.com> <CALWz4izy1zK5ZNZOK+82x-YPa-WdQnJu1Gq=70SDJmOVVrpPwQ@mail.gmail.com> <503354FF.1070809@parallels.com> <CALWz4iwtRzO07pU859CaK4Oz2EgziMvSJWRYDhULQ6ZdtR-4xg@mail.gmail.com>
In-Reply-To: <CALWz4iwtRzO07pU859CaK4Oz2EgziMvSJWRYDhULQ6ZdtR-4xg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 08/23/2012 02:27 AM, Ying Han wrote:
> 
> 
> On Tue, Aug 21, 2012 at 2:29 AM, Glauber Costa <glommer@parallels.com
> <mailto:glommer@parallels.com>> wrote:
> 
>     On 08/20/2012 10:30 PM, Ying Han wrote:
>     > Not exactly. Here reclaiming from root is mainly for "reclaiming from
>     > root's exclusive lru", which links the page includes:
>     > 1. processes running under root
>     > 2. reparented pages from rmdir memcg under root
>     > 3. bypassed pages
>     >
>     > Setting root cgroup's softlimit = 0 has the implication of putting
>     > those pages to likely to reclaim, which works fine. The question is
>     > that if no other memcg is above its softlimit, would it be a problem
>     > to adding a bit extra pressure to root which always is eligible for
>     > softlimit reclaim ( usage is always greater than softlimit).
>     >
>     > As an example, it works fine in our environment since we don't
>     > explicitly put any process under root. Most of  the pages linked in
>     > root lru would be reparented pages which should be reclaimed prior to
>     > others.
> 
>     Keep in mind that not all environments will be specialized to the point
>     of having root memcg empty. This basically treats root memcg as a trash
>     bin, and can be very detrimental to use cases where actual memory is
>     present in there.
> 
>     It would maybe be better to have all this garbage to go to a separate
>     place, like a shadow garbage memcg, which is invisible to the
>     filesystem, and is always the first to be reclaimed from, in any
>     circumstance.
> 
> 
> We can certainly do something like that, and actually we have the
> *special* cgroup setup today in google's environment. It is mainly
> targeting for pages that are allocated not on behalf of applications,
> but more of 
> system maintainess overhead. One example would be kernel thread memory
> charging.
> 
> In this case, it might make sense to put those reparented pages to
> a separate cgroup. However I do wonder with the following questions:
> 
> 1.  it might only make sense to do that if something else running under
> root. As we know, root is kind of special in memcg where there is no
> limit on it. So I wonder what would be the real life use case to put
> something under root?
> 

It is a common desktop environment cgroups usage to separate some
special processes only in memcg, and bind their memory usage. This is
even mentioned in the docs as an example case, if I recall correctly.

Systemd, for instance, places all services in cgroups. All the rest of
the system, applications user launches, etc, would live in the root memcg.

> 2.  even the reparented pages are mixed together with pages from process
> running under root, the LRU mechanism should still take effect of
> evicting cold pages first. if the reparent pages are the left-over pages
> from the removed cgroups, I would assume they are the candidate to
> reclaim first.
> 

I think this is a big assumption. To begin with, pages *just* reparented
will still be hot. They can be a lot.

> I am curious that in your environment, do you have things running root? 
> 
Our environment is also pretty easy, in the sense that all processes
that matters lives in a cgroup, 1 per-container. But say the admin wants
to install a management deamon, for instance, it won't necessarily be
accounted.

In any case, our use case is not my top concern here. Rather, it is the
general usage for people other than us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
