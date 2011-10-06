Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA306B025F
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 04:46:11 -0400 (EDT)
Date: Thu, 6 Oct 2011 11:46:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 7/8] Display current tcp memory allocation in kmem
 cgroup
Message-ID: <20111006084609.GA28820@shutemov.name>
References: <1317637123-18306-1-git-send-email-glommer@parallels.com>
 <1317637123-18306-8-git-send-email-glommer@parallels.com>
 <20111003121446.GD29312@shutemov.name>
 <4E89A846.1010200@parallels.com>
 <20111003122511.GA29982@shutemov.name>
 <4E89AA01.3000803@parallels.com>
 <20111003123620.GA30018@shutemov.name>
 <4E8ACD6E.3090208@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E8ACD6E.3090208@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, avagin@parallels.com

On Tue, Oct 04, 2011 at 01:10:06PM +0400, Glauber Costa wrote:
> On 10/03/2011 04:36 PM, Kirill A. Shutemov wrote:
> > On Mon, Oct 03, 2011 at 04:26:41PM +0400, Glauber Costa wrote:
> >> On 10/03/2011 04:25 PM, Kirill A. Shutemov wrote:
> >>> On Mon, Oct 03, 2011 at 04:19:18PM +0400, Glauber Costa wrote:
> >>>> On 10/03/2011 04:14 PM, Kirill A. Shutemov wrote:
> >>>>> On Mon, Oct 03, 2011 at 02:18:42PM +0400, Glauber Costa wrote:
> >>>>>> This patch introduces kmem.tcp_current_memory file, living in the
> >>>>>> kmem_cgroup filesystem. It is a simple read-only file that displays the
> >>>>>> amount of kernel memory currently consumed by the cgroup.
> >>>>>>
> >>>>>> Signed-off-by: Glauber Costa<glommer@parallels.com>
> >>>>>> CC: David S. Miller<davem@davemloft.net>
> >>>>>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
> >>>>>> CC: Eric W. Biederman<ebiederm@xmission.com>
> >>>>>> ---
> >>>>>>     Documentation/cgroups/memory.txt |    1 +
> >>>>>>     mm/memcontrol.c                  |   11 +++++++++++
> >>>>>>     2 files changed, 12 insertions(+), 0 deletions(-)
> >>>>>>
> >>>>>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> >>>>>> index 1ffde3e..f5a539d 100644
> >>>>>> --- a/Documentation/cgroups/memory.txt
> >>>>>> +++ b/Documentation/cgroups/memory.txt
> >>>>>> @@ -79,6 +79,7 @@ Brief summary of control files.
> >>>>>>      memory.independent_kmem_limit	 # select whether or not kernel memory limits are
> >>>>>>     				   independent of user limits
> >>>>>>      memory.kmem.tcp.max_memory      # set/show hard limit for tcp buf memory
> >>>>>> + memory.kmem.tcp.current_memory  # show current tcp buf memory allocation
> >>>>>
> >>>>> Both are in pages, right?
> >>>>> Shouldn't it be scaled to bytes and named uniform with other memcg file?
> >>>>> memory.kmem.tcp.limit_in_bytes/usage_in_bytes.
> >>>>>
> >>>> You are absolutely correct.
> >>>> Since the internal tcp comparison works, I just ended up never noticing
> >>>> this.
> >>>
> >>> Should we have failcnt and max_usage_in_bytes for tcp as well?
> >>>
> >>
> >> Well, we get a fail count from the tracer anyway, so I don't really see
> >> a need for that. I see value in having it for the slab allocation
> >> itself, but since this only controls the memory pressure framework, I
> >> think we can live without it.
> >>
> >> That said, this is not a strong opinion. I can add it if you'd prefer.
> >
> > It's good for userspace to have the same set of files for all domains:
> >   - memory;
> >   - memory.memsw;
> >   - memory.kmem;
> >   - memory.kmem.tcp;
> >   - etc.
> > Userspace can reuse code for handling them in this case.
> >
> Ok. Back on this.
> 
> Not all domains have all files anyway.

$ ls -l *.{failcnt,limit_in_bytes,max_usage_in_bytes,usage_in_bytes}
-rw-r--r-- 1 root root 0 Oct  6 11:34 memory.failcnt
-rw-r--r-- 1 root root 0 Oct  6 11:34 memory.limit_in_bytes
-rw-r--r-- 1 root root 0 Oct  6 11:34 memory.max_usage_in_bytes
-rw-r--r-- 1 root root 0 Oct  6 11:34 memory.memsw.failcnt
-rw-r--r-- 1 root root 0 Oct  6 11:34 memory.memsw.limit_in_bytes
-rw-r--r-- 1 root root 0 Oct  6 11:34 memory.memsw.max_usage_in_bytes
-r--r--r-- 1 root root 0 Oct  6 11:34 memory.memsw.usage_in_bytes
-r--r--r-- 1 root root 0 Oct  6 11:34 memory.usage_in_bytes

Hm?..

> max_usage seems to be a property of the main memcg, not of its domains.
> failcnt is present on memsw, and on that only. The problem here, is that 
> this can fail ( and usually will ) in codepaths outside the memory
> controller. (see net/core/sock.c:__sk_mem_schedule)

+1 reason to use res_counter. It provides all data needed for this files.
 
> Also, max_usage makes sense for kernel memory as a whole, but I don't 
> think it makes sense here as we're only controlling a specific pressure 
> condition.

max_usage is reasonable for everything you can limit. It allows you to
track if limit is set appropriate.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
