Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id F13706B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 04:38:09 -0400 (EDT)
Date: Fri, 17 May 2013 10:38:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V2 0/3] memcg: simply lock of page stat accounting
Message-ID: <20130517083806.GB5048@dhcp22.suse.cz>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
 <519380FC.1040504@openvz.org>
 <20130515134110.GD5455@dhcp22.suse.cz>
 <51946071.4030101@openvz.org>
 <20130516132846.GE13848@dhcp22.suse.cz>
 <5195C6D1.6040005@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5195C6D1.6040005@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Sha Zhengju <handai.szj@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

On Fri 17-05-13 09:57:37, Konstantin Khlebnikov wrote:
> Michal Hocko wrote:
> >On Thu 16-05-13 08:28:33, Konstantin Khlebnikov wrote:
[...]
> >>If somebody needs more detailed information there are enough ways to get it.
> >>Amount of mapped pages can be estimated via summing rss counters from mm-structs.
> >>Exact numbers can be obtained via examining /proc/pid/pagemap.
> >
> >How do you find out whether given pages were charged to the group of
> >interest - e.g. shared data or taks that has moved from a different
> >group without move_at_immigrate?
> 
> For example we can export pages ownership and charging state via
> single file in proc, something similar to /proc/kpageflags

So you would like to add a new interface with cryptic api (I consider
kpageflags to be a devel tool not an admin aid) to replace something
that is easy to use? Doesn't make much sense to me.

> BTW
> In our kernel the memory controller tries to change page's ownership
> at first mmap and at each page activation, probably it's worth to add
> this into mainline memcg too.

Dunno, there are different approaches for this. I haven't evalueted them
so I don't know all the pros and cons. Why not just unmap&uncharge the
page when the charging process dies. This should be more lightweight
wrt. recharge on re-activation.
 
> >>I don't think that simulating 'Mapped' line in /proc/mapfile is a worth reason
> >>for adding such weird stuff into the rmap code on map/unmap paths.
> >
> >The accounting code is trying to be not intrusive as much as possible.
> >This patchset makes it more complicated without a good reason and that
> >is why it has been Nacked by me.
> 
> I think we can remove it or replace it with something different but
> much less intrusive, if nobody strictly requires exactly this approach
> in managing 'mapped' pages counters.

Do you have any numbers on the intrusiveness? I do not mind to change
the internal implementation but the file is a part of the user space API
so we cannot get rid of it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
