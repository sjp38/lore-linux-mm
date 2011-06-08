Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BBD986B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 17:22:37 -0400 (EDT)
Received: by wyf19 with SMTP id 19so890446wyf.14
        for <linux-mm@kvack.org>; Wed, 08 Jun 2011 14:22:33 -0700 (PDT)
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4DEFAB15.2060905@fnarfbargle.com>
References: <20110601011527.GN19505@random.random>
	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>
	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>
	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>
	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>
	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
	 <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com>
	 <4DED344D.7000005@pandora.be> <4DED9C23.2030408@fnarfbargle.com>
	 <4DEE27DE.7060004@trash.net> <4DEE3859.6070808@fnarfbargle.com>
	 <4DEE4538.1020404@trash.net> <1307471484.3091.43.camel@edumazet-laptop>
	 <4DEEACC3.3030509@trash.net>  <4DEEBFC2.4060102@fnarfbargle.com>
	 <1307505541.3102.12.camel@edumazet-laptop>
	 <4DEFAB15.2060905@fnarfbargle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Jun 2011 23:22:29 +0200
Message-ID: <1307568149.3980.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <brad@fnarfbargle.com>
Cc: Patrick McHardy <kaber@trash.net>, Bart De Schuymer <bdschuym@pandora.be>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Le jeudi 09 juin 2011 A  01:02 +0800, Brad Campbell a A(C)crit :
> On 08/06/11 11:59, Eric Dumazet wrote:
> 
> > Well, a bisection definitely should help, but needs a lot of time in
> > your case.
> 
> Yes. compile, test, crash, walk out to the other building to press 
> reset, lather, rinse, repeat.
> 
> I need a reset button on the end of a 50M wire, or a hardware watchdog!
> 
> Actually it's not so bad. If I turn off slub debugging the kernel panics 
> and reboots itself.
> 
> This.. :
> [    2.913034] netconsole: remote ethernet address 00:16:cb:a7:dd:d1
> [    2.913066] netconsole: device eth0 not up yet, forcing it
> [    3.660062] Refined TSC clocksource calibration: 3213.422 MHz.
> [    3.660118] Switching to clocksource tsc
> [   63.200273] r8169 0000:03:00.0: eth0: unable to load firmware patch 
> rtl_nic/rtl8168e-1.fw (-2)
> [   63.223513] r8169 0000:03:00.0: eth0: link down
> [   63.223556] r8169 0000:03:00.0: eth0: link down
> 
> ..is slowing down reboots considerably. 3.0-rc does _not_ like some 
> timing hardware in my machine. Having said that, at least it does not 
> randomly panic on SCSI like 2.6.39 does.
> 
> Ok, I've ruled out TCPMSS. Found out where it was being set and neutered 
> it. I've replicated it with only the single DNAT rule.
> 
> 
> > Could you try following patch, because this is the 'usual suspect' I had
> > yesterday :
> >
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 46cbd28..9f548f9 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -792,6 +792,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
> >   		fastpath = atomic_read(&skb_shinfo(skb)->dataref) == delta;
> >   	}
> >
> > +#if 0
> >   	if (fastpath&&
> >   	size + sizeof(struct skb_shared_info)<= ksize(skb->head)) {
> >   		memmove(skb->head + size, skb_shinfo(skb),
> > @@ -802,7 +803,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
> >   		off = nhead;
> >   		goto adjust_others;
> >   	}
> > -
> > +#endif
> >   	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
> >   	if (!data)
> >   		goto nodata;
> >
> >
> >
> 
> Nope.. that's not it. <sigh> That might have changed the characteristic 
> of the fault slightly, but unfortunately I got caught with a couple of 
> fsck's, so I only got to test it 3 times tonight.
> 
> It's unfortunate that this is a production system, so I can only take it 
> down between about 9pm and 1am. That would normally be pretty 
> productive, except that an fsck of a 14TB ext4 can take 30 minutes if it 
> panics at the wrong time.
> 
> I'm out of time tonight, but I'll have a crack at some bisection 
> tomorrow night. Now I just have to go back far enough that it works, and 
> be near enough not to have to futz around with /proc /sys or drivers.
> 
> I really, really, really appreciate you guys helping me with this. It 
> has been driving me absolutely bonkers. If I'm ever in the same town as 
> any of you, dinner and drinks are on me.

Hmm, I wonder if kmemcheck could help you, but its slow as hell, so not
appropriate for production :(



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
