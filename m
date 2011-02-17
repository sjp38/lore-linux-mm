Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 836F28D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 11:37:57 -0500 (EST)
Received: by fxm12 with SMTP id 12so2828920fxm.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 08:36:24 -0800 (PST)
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
	 <20110216193700.GA6377@elte.hu>
	 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
	 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
	 <20110217090910.GA3781@tiehlicka.suse.cz>
	 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Feb 2011 17:36:14 +0100
Message-ID: <1297960574.2769.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Octavian Purdila <opurdila@ixiacom.com>, David Miller <davem@davemloft.net>

Le jeudi 17 fA(C)vrier 2011 A  08:13 -0800, Linus Torvalds a A(C)crit :
> On Thu, Feb 17, 2011 at 1:09 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >
> > I have seen that thread but I didn't think it is related. I thought
> > this is an another anon_vma issue. But you seem to be right that the
> > offset pattern can be related.
> 
> Hey, maybe it turns out to be about anon_vma's in the end, but I see
> no big reason to blame them per se. And we haven't had all that much
> churn wrt anon_vma's this release window, so I wouldn't expect
> anything exciting unless you're actively using transparent hugepages.
> And iirc, Eric was not using them (or memory compaction).
> 
> I'd be more likely to blame either the new path lookup (which uses
> totally new RCU freeing of inodes _and_
> INIT_LIST_HEAD(&inode->i_dentry)), but I'm not seeing how that could
> break either (I've gone through that patch many times).
> 
> And in addition, I don't see why others wouldn't see it (I've got
> DEBUG_PAGEALLOC and SLUB_DEBUG_ON turned on myself, and I know others
> do too).
> 
> So I'm wondering what triggers it. Must be something subtle.
> 
> > OK. I have just booted with the same kernel and the config turned on.
> > Let's see if I am able to reproduce.
> 
> Thanks. It might have been good to turn on SLUB_DEBUG_ON and
> DEBUG_LIST too, but PAGEALLOC is the big one.
> 
> > Btw.
> > $ objdump -d ./vmlinux-2.6.38-rc4-00001-g07409af-vmscan-test | grep 0x1e68
> >
> > didn't print out anything. Do you have any other way to find out the
> > structure?
> 
> Nope, that's roughly what I did to (in addition to doing all the .ko
> files and checking for 0xe68 too). Which made me worry that the 0x1e68
> offset is actually just the stack offset at some random code-path (it
> would stay constant for a particular kernel if there is only one way
> to reach that code, and it's always reached through some stable
> non-irq entrypoint).
> 
> People do use on-stack lists, and if you do it wrong I could imagine a
> stale list entry still pointing to the stack later. And while
> INIT_LIST_HEAD() is one pattern to get that "two consecutive words
> pointing to themselves", so is doing a "list_del()" on the last list
> entry that the head points to.
> 
> So _if_ somebody has a list_head on the stack, and leaves a stale list
> entry pointing to it, and then later on, when the stack has been
> released that stale list entry is deleted with "list_del()", you'd see
> the same memory corruption pattern. But I'm not aware of any new code
> that would do anything like that.
> 
> So I'm stumped, which is why I'm just hoping that extra debugging
> options would catch it closer to the place where it actually occurs.
> The "2kB allocation with a nice compile-time structure offset" sounded
> like _such_ a great way to catch it, but it clearly doesn't :(
> 
>  

Hmm, this rings a bell here.

Unfortunately I have to run so cannot check right now.

Please take a look at commit 443457242beb6716b43db4d (net: factorize
sync-rcu call in unregister_netdevice_many)

CC David and Octavian

dev_close_many() can apparently return with an non empty list






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
