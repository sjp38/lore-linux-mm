Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4EB6B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 02:29:16 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id d205so40472746oia.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 23:29:16 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id eb7si24422309oeb.35.2016.02.29.23.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 23:29:15 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id xx9so45660552obc.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 23:29:15 -0800 (PST)
Date: Mon, 29 Feb 2016 23:29:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
In-Reply-To: <20160229203502.GW16930@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <20160203132718.GI6757@dhcp22.suse.cz> <alpine.LSU.2.11.1602241832160.15564@eggly.anvils> <20160229203502.GW16930@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 29 Feb 2016, Michal Hocko wrote:
> On Wed 24-02-16 19:47:06, Hugh Dickins wrote:
> [...]
> > Boot with mem=1G (or boot your usual way, and do something to occupy
> > most of the memory: I think /proc/sys/vm/nr_hugepages provides a great
> > way to gobble up most of the memory, though it's not how I've done it).
> > 
> > Make sure you have swap: 2G is more than enough.  Copy the v4.5-rc5
> > kernel source tree into a tmpfs: size=2G is more than enough.
> > make defconfig there, then make -j20.
> > 
> > On a v4.5-rc5 kernel that builds fine, on mmotm it is soon OOM-killed.
> > 
> > Except that you'll probably need to fiddle around with that j20,
> > it's true for my laptop but not for my workstation.  j20 just happens
> > to be what I've had there for years, that I now see breaking down
> > (I can lower to j6 to proceed, perhaps could go a bit higher,
> > but it still doesn't exercise swap very much).
> 
> I have tried to reproduce and failed in a virtual on my laptop. I
> will try with another host with more CPUs (because my laptop has only
> two). Just for the record I did: boot 1G machine in kvm, I have 2G swap
> and reserve 800M for hugetlb pages (I got 445 of them). Then I extract
> the kernel source to tmpfs (-o size=2G), make defconfig and make -j20
> (16, 10 no difference really). I was also collecting vmstat in the
> background. The compilation takes ages but the behavior seems consistent
> and stable.

Thanks a lot for giving it a go.

I'm puzzled.  445 hugetlb pages in 800M surprises me: some of them
are less than 2M big??  But probably that's just a misunderstanding
or typo somewhere.

Ignoring that, you're successfully doing a make -20 defconfig build
in tmpfs, with only 224M of RAM available, plus 2G of swap?  I'm not
at all surprised that it takes ages, but I am very surprised that it
does not OOM.  I suppose by rights it ought not to OOM, the built
tree occupies only a little more than 1G, so you do have enough swap;
but I wouldn't get anywhere near that myself without OOMing - I give
myself 1G of RAM (well, minus whatever the booted system takes up)
to do that build in, four times your RAM, yet in my case it OOMs.

That source tree alone occupies more than 700M, so just copying it
into your tmpfs would take a long time.  I'd expect a build in 224M
RAM plus 2G of swap to take so long, that I'd be very grateful to be
OOM killed, even if there is technically enough space.  Unless
perhaps it's some superfast swap that you have?

I was only suggesting to allocate hugetlb pages, if you preferred
not to reboot with artificially reduced RAM.  Not an issue if you're
booting VMs.

It's true that my testing has been done on the physical machines,
no virtualization involved: I expect that accounts for some difference
between us, but as much difference as we're seeing?  That's strange.

> 
> If I try 900M for huge pages then I get OOMs but this happens with the
> mmotm without my oom rework patch set as well.

Right, not at all surprising.

> 
> It would be great if you could retry and collect /proc/vmstat data
> around the OOM time to see what compaction did? (I was using the
> attached little program to reduce interference during OOM (no forks, the
> code locked in and the resulting file preallocated - e.g.
> read_vmstat 1s vmstat.log 10M and interrupt it by ctrl+c after the OOM
> hits).
> 
> Thanks!

I'll give it a try, thanks, but not tonight.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
