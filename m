Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 181398D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 11:41:53 -0500 (EST)
Date: Thu, 17 Feb 2011 17:26:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
Message-ID: <20110217162641.GC3781@tiehlicka.suse.cz>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
 <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz>
 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 17-02-11 08:13:50, Linus Torvalds wrote:
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

I am using transparent hugepages:
$ grep -i huge /proc/vmstat 
nr_anon_transparent_hugepages 24

and this is the usual number that I can see with my day-to-day workload.

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

I can try those later as well. Currently I am not able to trigger the
issue. I am running rmmod wireless stack + modproble it back in the loop
because this was the last thing before I saw the bug last time. Let's
see if it changes later.

> 
> > Btw.
> > $ objdump -d ./vmlinux-2.6.38-rc4-00001-g07409af-vmscan-test | grep 0x1e68
> >
> > didn't print out anything. Do you have any other way to find out the
> > structure?
> 
> Nope, that's roughly what I did to (in addition to doing all the .ko
> files and checking for 0xe68 too). 

Ohh, I forgot about modules. Just did it and also nothing found.

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
