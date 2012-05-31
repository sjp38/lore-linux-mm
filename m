Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E7F536B0062
	for <linux-mm@kvack.org>; Thu, 31 May 2012 03:57:51 -0400 (EDT)
Date: Thu, 31 May 2012 09:57:18 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Message-ID: <20120531075718.GB1371@cmpxchg.org>
References: <alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com>
 <4FC70355.70805@jp.fujitsu.com>
 <alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com>
 <4FC70E5E.1010003@gmail.com>
 <alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com>
 <4FC711A5.4090003@gmail.com>
 <alpine.DEB.2.00.1205302351510.25774@chino.kir.corp.google.com>
 <CAHGf_=qVDVT6VW2j9gE3bQKwizW24iivrDryiCKoxVu4m_fWKw@mail.gmail.com>
 <alpine.DEB.2.00.1205310028420.8864@chino.kir.corp.google.com>
 <4FC720EE.3010307@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FC720EE.3010307@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Thu, May 31, 2012 at 03:42:38AM -0400, KOSAKI Motohiro wrote:
> (5/31/12 3:35 AM), David Rientjes wrote:
> >On Thu, 31 May 2012, KOSAKI Motohiro wrote:
> >
> >>>As I said, LXC and namespace isolation is a tangent to the discussion of
> >>>faking the /proc/meminfo for the memcg context of a thread.
> >>
> >>Because of, /proc/meminfo affect a lot of libraries behavior. So, it's not only
> >>application issue. If you can't rewrite _all_ of userland assets, fake meminfo
> >>can't be escaped. Again see alternative container implementation.
> >>
> >
> >It's a tangent because it isn't a complete psuedo /proc/meminfo for all
> >threads attached to a memcg regardless of any namespace isolation; the LXC
> >solution has existed for a couple of years by its procfs patchset that
> >overlaps procfs with fuse and can suppress or modify any output in the
> >context of a memory controller using things like
> >memory.{limit,usage}_in_bytes.  I'm sure all other fields could be
> >modified if outputted in some structured way via memcg; it looks like
> >memory.stat would need to be extended to provide that.  If that's mounted
> >prior to executing the application, then your isolation is achieved and
> >all libraries should see the new output that you've defined in LXC.
> >
> >However, this seems like a seperate topic than the patch at hand which
> >does this directly to /proc/meminfo based on a thread's memcg context,
> >that's the part that I'm nacking.
> 
> Then, I NAKed current patch too. Yeah, current one is ugly. It assume _all_
> user need namespace isolation and it clearly is not.

Actually, it only chooses the memcg version for tasks that are not in
the init pid namespace.  Tying this to the pid namespace is a bit
ugly, but would probably end up doing the right thing most of the
time.  A separate namespace would be better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
