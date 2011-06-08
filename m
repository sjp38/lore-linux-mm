Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C8CC36B007B
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 23:59:08 -0400 (EDT)
Received: by wyf19 with SMTP id 19so81237wyf.14
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 20:59:05 -0700 (PDT)
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4DEEBFC2.4060102@fnarfbargle.com>
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
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Jun 2011 05:59:01 +0200
Message-ID: <1307505541.3102.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <brad@fnarfbargle.com>
Cc: Patrick McHardy <kaber@trash.net>, Bart De Schuymer <bdschuym@pandora.be>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Le mercredi 08 juin 2011 A  08:18 +0800, Brad Campbell a A(C)crit :
> On 08/06/11 06:57, Patrick McHardy wrote:
> > On 07.06.2011 20:31, Eric Dumazet wrote:
> >> Le mardi 07 juin 2011 A  17:35 +0200, Patrick McHardy a A(C)crit :
> >>
> >>> The main suspects would be NAT and TCPMSS. Did you also try whether
> >>> the crash occurs with only one of these these rules?
> >>>
> >>>> I've just compiled out CONFIG_BRIDGE_NETFILTER and can no longer access
> >>>> the address the way I was doing it, so that's a no-go for me.
> >>>
> >>> That's really weird since you're apparently not using any bridge
> >>> netfilter features. It shouldn't have any effect besides changing
> >>> at which point ip_tables is invoked. How are your network devices
> >>> configured (specifically any bridges)?
> >>
> >> Something in the kernel does
> >>
> >> u16 *ptr = addr (given by kmalloc())
> >>
> >> ptr[-1] = 0;
> >>
> >> Could be an off-one error in a memmove()/memcopy() or loop...
> >>
> >> I cant see a network issue here.
> >
> > So far me neither, but netfilter appears to trigger the bug.
> 
> Would it help if I tried some older kernels? This issue only surfaced 
> for me recently as I only installed the VM's in question about 12 weeks 
> ago and have only just started really using them in anger. I could try 
> reproducing it on progressively older kernels to see if I can find one 
> that works and then bisect from there.

Well, a bisection definitely should help, but needs a lot of time in
your case.

Could you try following patch, because this is the 'usual suspect' I had
yesterday :

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 46cbd28..9f548f9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -792,6 +792,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		fastpath = atomic_read(&skb_shinfo(skb)->dataref) == delta;
 	}
 
+#if 0
 	if (fastpath &&
 	    size + sizeof(struct skb_shared_info) <= ksize(skb->head)) {
 		memmove(skb->head + size, skb_shinfo(skb),
@@ -802,7 +803,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		off = nhead;
 		goto adjust_others;
 	}
-
+#endif
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
 	if (!data)
 		goto nodata;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
