Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5D06B002C
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 12:30:24 -0400 (EDT)
Date: Thu, 20 Oct 2011 09:30:09 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFD] Isolated memory cgroups again
Message-ID: <20111020163009.GB25505@tiehlicka.suse.cz>
References: <20111020013305.GD21703@tiehlicka.suse.cz>
 <20111020105950.fd04f58f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111020105950.fd04f58f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@HansenPartnership.com>

On Thu 20-10-11 10:59:50, KAMEZAWA Hiroyuki wrote:
> On Wed, 19 Oct 2011 18:33:09 -0700
> Michal Hocko <mhocko@suse.cz> wrote:
[...]
> > I realize that this will be controversial but I would like to hear
> > whether this is strictly no-go or whether we can go that direction (the
> > implementation might differ of course).
> > 
> > The patch is still half baked but I guess it should be sufficient to
> > show what I am trying to achieve.
> > The basic idea is that memcgs would get a new attribute (isolated) which
> > would control whether that group should be considered during global
> > reclaim.
> > This means that we could achieve a certain memory isolation for
> > processes in the group from the rest of the system activity which has
> > been traditionally done by mlocking the important parts of memory.
> > This approach, however, has some advantages. First of all, it is a kind
> > of all or nothing type of approach. Either the memory is important and
> > mlocked or you have no guarantee that it keeps resident. 
> > Secondly it is much more prone to OOM situation.
> > Let's consider a case where a memory is evictable in theory but you
> > would pay quite much if you have to get it back resident (pre calculated
> > data from database - e.g. reports). The memory wouldn't be used very
> > often so it would be a number one candidate to evict after some time.
> > We would want to have something like a clever mlock in such a case which
> > would evict that memory only if the cgroup itself gets under memory
> > pressure (e.g. peak workload). This is not hard to do if we are not
> > over committing the memory but things get tricky otherwise.
> > With the isolated memcgs we get exactly such a guarantee because we would
> > reclaim such a memory only from the hard limit reclaim paths or if the
> > soft limit reclaim if it is set up.
> > 
> > Any thoughts comments?
> > 
> 
> I can only say
>  - it can be implemented in a clean way.
>  - maybe customers wants it.
>  - This kinds of "mlock" can be harmful and make system admin difficult.

It is usually admin who sets up control groups and their attributes.

>  - I'm not sure there will be a chance for security issue, DOS attack.

It depends what you consider by the DOS attack. In scenarios I have in
mind it is usually the important workload that is isolated which means
that the feature helps preventing DOS attack on it.
If you are more thinking about the rest (not isolated groups) then yes,
there will be a bigger pressure on them. This is something that has to
be considered when the system is set up.

> 
> Hmm...if the number of isolated pages can be shown in /proc/meminfo,
> I'll not have strong NACK.

This will be trivial to implement.

> 
> But I personally think we should make softlimit better rather than
> adding new interface. If this feature can be archieved when setting
> softlimit=UNLIMITED, it's simple. And Johannes' work will make this
> easy to be implemented.

As I already said. I am not insisting on the implementation. I just
consider isolation important and we have several customers who need
this. If this can be done by the soft limit reclaim only I will not
object for sure. Configuration would need to be careful in both cases
anyway.

> (total rewrite of softlimit should be required...I think.)
> 
> Thanks,
> -Kame

Thanks

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
