Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B22056B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 08:05:49 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c82so11693183wme.8
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 05:05:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n13si16097136wmh.184.2017.12.29.05.05.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Dec 2017 05:05:47 -0800 (PST)
Date: Fri, 29 Dec 2017 14:05:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug regression in 4.13
Message-ID: <20171229130546.GD27077@dhcp22.suse.cz>
References: <20170919164114.f4ef6oi3yhhjwkqy@ubuntu-xps13>
 <20170920092931.m2ouxfoy62wr65ld@dhcp22.suse.cz>
 <20170921054034.judv6ovyg5yks4na@ubuntu-hedt>
 <20170925125825.zpgasjhjufupbias@dhcp22.suse.cz>
 <20171201142327.GA16952@ubuntu-xps13>
 <20171218145320.GO16951@dhcp22.suse.cz>
 <20171222144925.GR4831@dhcp22.suse.cz>
 <20171222161240.GA25425@ubuntu-xps13>
 <20171222184515.GT11858@ubuntu-hedt>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222184515.GT11858@ubuntu-hedt>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Forshee <seth.forshee@canonical.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 22-12-17 12:45:15, Seth Forshee wrote:
> On Fri, Dec 22, 2017 at 10:12:40AM -0600, Seth Forshee wrote:
> > On Fri, Dec 22, 2017 at 03:49:25PM +0100, Michal Hocko wrote:
> > > On Mon 18-12-17 15:53:20, Michal Hocko wrote:
> > > > On Fri 01-12-17 08:23:27, Seth Forshee wrote:
> > > > > On Mon, Sep 25, 2017 at 02:58:25PM +0200, Michal Hocko wrote:
> > > > > > On Thu 21-09-17 00:40:34, Seth Forshee wrote:
> > > > [...]
> > > > > > > It seems I don't have that kernel anymore, but I've got a 4.14-rc1 build
> > > > > > > and the problem still occurs there. It's pointing to the call to
> > > > > > > __builtin_memcpy in memcpy (include/linux/string.h line 340), which we
> > > > > > > get to via wp_page_copy -> cow_user_page -> copy_user_highpage.
> > > > > > 
> > > > > > Hmm, this is interesting. That would mean that we have successfully
> > > > > > mapped the destination page but its memory is still not accessible.
> > > > > > 
> > > > > > Right now I do not see how the patch you have bisected to could make any
> > > > > > difference because it only postponed the onlining to be independent but
> > > > > > your config simply onlines automatically so there shouldn't be any
> > > > > > semantic change. Maybe there is some sort of off-by-one or something.
> > > > > > 
> > > > > > I will try to investigate some more. Do you think it would be possible
> > > > > > to configure kdump on your system and provide me with the vmcore in some
> > > > > > way?
> > > > > 
> > > > > Sorry, I got busy with other stuff and this kind of fell off my radar.
> > > > > It came to my attention again recently though.
> > > > 
> > > > Apology on my side. This has completely fall of my radar.
> > > > 
> > > > > I was looking through the hotplug rework changes, and I noticed that
> > > > > 32-bit x86 previously was using ZONE_HIGHMEM as a default but after the
> > > > > rework it doesn't look like it's possible for memory to be associated
> > > > > with ZONE_HIGHMEM when onlining. So I made the change below against 4.14
> > > > > and am now no longer seeing the oopses.
> > > > 
> > > > Thanks a lot for debugging! Do I read the above correctly that the
> > > > current code simply returns ZONE_NORMAL and maps an unrelated pfn into
> > > > this zone and that leads to later blowups? Could you attach the fresh
> > > > boot dmesg output please?
> > > > 
> > > > > I'm sure this isn't the correct fix, but I think it does confirm that
> > > > > the problem is that the memory should be associated with ZONE_HIGHMEM
> > > > > but is not.
> > > > 
> > > > 
> > > > Yes, the fix is not quite right. HIGHMEM is not a _kernel_ memory
> > > > zone. The kernel cannot access that memory directly. It is essentially a
> > > > movable zone from the hotplug API POV. We simply do not have any way to
> > > > tell into which zone we want to online this memory range in.
> > > > Unfortunately both zones _can_ be present. It would require an explicit
> > > > configuration (movable_node and a NUMA hoptlugable nodes running in 32b
> > > > or and movable memory configured explicitly on the kernel command line).
> > > > 
> > > > The below patch is not really complete but I would rather start simple.
> > > > Maybe we do not even have to care as most 32b users will never use both
> > > > zones at the same time. I've placed a warning to learn about those.
> > > > 
> > > > Does this pass your testing?
> > > 
> > > Any chances to test this?
> > 
> > Yes, I should get to testing it soon. I'm working through a backlog of
> > things I need to get done and this just hasn't quite made it to the top.
> 
> I started by testing vanilla 4.15-rc4 with a vm that has several memory
> slots already populated at boot. With that I no longer get an oops,
> however while /sys/devices/system/memory/*/online is 1 it looks like the
> memory isn't being used. With your patch the behavior is the same. I'm
> attaching dmesg from both kernels.

What do you mean? The overal available memory doesn't match the size of
all memblocks?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
