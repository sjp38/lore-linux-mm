Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id BB6966B005A
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 21:50:26 -0500 (EST)
Received: by ghrr18 with SMTP id r18so5217740ghr.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 18:50:25 -0800 (PST)
Date: Tue, 20 Dec 2011 18:50:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Android low memory killer vs. memory pressure notifications
In-Reply-To: <20111221002853.GA11504@oksana.dev.rtsoft.ru>
Message-ID: <alpine.DEB.2.00.1112201840340.11635@chino.kir.corp.google.com>
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru> <20111219121255.GA2086@tiehlicka.suse.cz> <alpine.DEB.2.00.1112191110060.19949@chino.kir.corp.google.com> <20111220145654.GA26881@oksana.dev.rtsoft.ru> <alpine.DEB.2.00.1112201322170.22077@chino.kir.corp.google.com>
 <20111221002853.GA11504@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>

On Wed, 21 Dec 2011, Anton Vorontsov wrote:

> > It's helpful for certain end users, particularly those in the embedded 
> > world, to be able to disable as many config options as possible to reduce 
> > the size of kernel image as much as possible, so they'll want a minimal 
> > amount of kernel functionality that allows such notifications.  Keep in 
> > mind that CONFIG_CGROUP_MEM_RES_CTLR is not enabled by default because of 
> > this (enabling it, CONFIG_RESOURCE_COUNTERS, and CONFIG_CGROUPS increases 
> > the size of the kernel text by ~1%),
> 
> So for 2MB kernel that's about 20KB of an additional text... This seems
> affordable, especially as a trade-off for the things that cgroups may
> provide.
> 

No, this was with defconfig and then defconfig + CONFIG_CGROUPS + 
CONFIG_RESOURCE_COUNTERS + CONFIG_CGROUP_MEM_RES_CTLR.  Configs that want 
a very small kernel image will definitely not be running with defconfig, 
they'll be using a stripped down version that allows for the smallest 
footprint possible.  Requiring those config options would then increase 
the size of the kernel text by much more than 1%.

Compare this situation with using CONFIG_SLOB for embedded devices (which 
is actually quite popular) over CONFIG_SLAB and CONFIG_SLUB specifically 
for that low memory footprint.

> The fact is, for desktop and server Linux, cgroups slowly becomes a
> mandatory thing.

And that's definitely in the wrong direction for Linux.  It would be like 
asking users to convert to slab or slub because we don't want to maintain 
a slob allocator that is specifically designed for an extremely low memory 
footprint.  Such a proposal would be rejected outright unless you could 
match the same footprint with the alternatives.

> As Alan Cox pointed out, we should probably focus on improving (if needed)
> existing solutions, instead of duplicating functionality for the sake of
> doing the same thing, but in a more "lightweight" and ad-hocish way.
> 

I'm very in favor of extracting out notifiers of low-memory situations and 
extended for global use rather than tying it specifically to the memory 
controller.  Then, memcg would be responsible only for limitation of 
resources rather than tying additional functionality to it that would be 
generally useful to everyone (memory notifiers) and requiring them to 
incur the overhead of memcg.

> > and it's becoming increasingly 
> > important for certain workloads to be notified of low memory conditions 
> > without any restriction on its usage other than the amount of RAM that the 
> > system has
> 
> I'm not sure what you mean here. Mem_cg may provide a way to the
> userland to be notified on low memory conditions, i.e. amount of RAM
> that the system has -- the same thing as /dev/mem_notify would do...
> 

Yes, but without the requirements of the above-mentioned subsystems.  The 
point here is that some embedded devices may want notification of low-
memory conditions without the overhead (both size and performance) of 
cgroups or memcg.  Please focus on that specifically.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
