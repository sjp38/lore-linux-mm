Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A19D16B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 05:40:13 -0400 (EDT)
Received: from e35131.upc-e.chello.nl ([213.93.35.131] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1NujXt-0004zt-VC
	for linux-mm@kvack.org; Thu, 25 Mar 2010 09:40:10 +0000
Subject: Re: [rfc][patch] mm: lockdep page lock
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100325053608.GB7493@laptop.nomadix.com>
References: <20100315155859.GE2869@laptop>
	 <20100315180759.GA7744@quack.suse.cz> <20100316022153.GJ2869@laptop>
	 <1269437291.5109.238.camel@twins>
	 <20100325053608.GB7493@laptop.nomadix.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 25 Mar 2010 10:40:05 +0100
Message-ID: <1269510005.12097.26.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-03-25 at 16:36 +1100, Nick Piggin wrote:
> On Wed, Mar 24, 2010 at 02:28:11PM +0100, Peter Zijlstra wrote:
> > On Tue, 2010-03-16 at 13:21 +1100, Nick Piggin wrote:
> > > 
> > > 
> > > Agreed (btw. Peter is there any way to turn lock debugging back on?
> > > it's annoying when cpufreq hotplug code or something early breaks and
> > > you have to reboot in order to do any testing).
> > 
> > Not really, the only way to do that is to get the full system back into
> > a known (zero) lock state and then fully reset the lockdep state.
> > 
> > It might be possible using the freezer, but I haven't really looked at
> > that, its usually simpler to simply fix the offending code or simply not
> > build it in your kernel.
> 
> Right, but sometimes that is not possible (or you don't want to
> turn off cpufreq). I guess you could have an option to NOT turn
> it off in the first place. You could just turn off warnings, but
> leave everything else running, couldn't you?
> 
> And then the option would just be to turn the printing back on.

Well, once there are cycles in the class graph you could end up finding
that cycle again and again. So the easiest option is to simply bail
after printing the acquisition that established the cycle.

Alternatively you'd have to undo the cycle creation and somehow mark a
class as bad and ignore it afterwards, which of course carries the risk
that you'll not detect other cycles which would depend on that class.

You could do as you suggest, but I would not trust the answers you get
after that because you already have cycles in the graph so interpreting
the things gets more and more interesting.

So non of the options really work well, and fixing, reverting or simply
not building is by far the easier thing to do.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
