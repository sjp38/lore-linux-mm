Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 330816B00AE
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 10:47:41 -0400 (EDT)
Date: Mon, 15 Oct 2012 16:47:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] memcg: oom: fix totalpages calculation for
 swappiness==0
Message-ID: <20121015144736.GI29069@dhcp22.suse.cz>
References: <20121010141142.GG23011@dhcp22.suse.cz>
 <507BD33C.4030209@jp.fujitsu.com>
 <20121015094907.GE29069@dhcp22.suse.cz>
 <CAHGf_=p4d33t7i5++YHTkc0PbAUckca1oBxR5dZ48EzybKYHgw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=p4d33t7i5++YHTkc0PbAUckca1oBxR5dZ48EzybKYHgw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 15-10-12 10:25:14, KOSAKI Motohiro wrote:
> > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> > index 078701f..308fd77 100644
> > --- a/Documentation/sysctl/vm.txt
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -640,6 +640,9 @@ swappiness
> >  This control is used to define how aggressive the kernel will swap
> >  memory pages.  Higher values will increase agressiveness, lower values
> >  decrease the amount of swap.
> > +The value can be used from the [0, 100] range, where 0 means no swapping
> > +at all (even if there is a swap storage enabled) while 100 means that
> > +anonymous pages are reclaimed in the same rate as file pages.
> 
> I think this only correct when memcg. Even if swappiness==0, global reclaim swap
> out anon pages before oom.

Right you are (we really do swap when the file pages are really
low)! Sorry about the confusion. I kind of became if(global_reclaim)
block blind...

Then this really needs a memcg specific documentation fix. What about
the following?
---
