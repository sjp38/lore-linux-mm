Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A35056B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 12:20:13 -0400 (EDT)
Subject: Re: [PATCH] memcg: remove unneeded preempt_disable
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1108251009120.27407@router.home>
References: <1313650253-21794-1-git-send-email-gthelen@google.com>
	 <20110818144025.8e122a67.akpm@linux-foundation.org>
	 <1314284272.27911.32.camel@twins>
	 <alpine.DEB.2.00.1108251009120.27407@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 25 Aug 2011 09:20:08 -0700
Message-ID: <1314289208.3268.4.camel@mulgrave>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-arch@vger.kernel.org

On Thu, 2011-08-25 at 10:11 -0500, Christoph Lameter wrote:
> On Thu, 25 Aug 2011, Peter Zijlstra wrote:
> 
> > On Thu, 2011-08-18 at 14:40 -0700, Andrew Morton wrote:
> > >
> > > I think I'll apply it, as the call frequency is low (correct?) and the
> > > problem will correct itself as other architectures implement their
> > > atomic this_cpu_foo() operations.
> >
> > Which leads me to wonder, can anything but x86 implement that this_cpu_*
> > muck? I doubt any of the risk chips can actually do all this.
> > Maybe Itanic, but then that seems to be dying fast.
> 
> The cpu needs to have an RMW instruction that does something to a
> variable relative to a register that points to the per cpu base.
> 
> Thats generally possible. The problem is how expensive the RMW is going to
> be.

Risc systems generally don't have a single instruction for this, that's
correct.  Obviously we can do it as a non atomic sequence: read
variable, compute relative, read, modify, write ... but there's
absolutely no point hand crafting that in asm since the compiler can
usually work it out nicely.  And, of course, to have this atomic, we
have to use locks, which ends up being very expensive.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
