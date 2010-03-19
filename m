Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7DD6B0093
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 20:29:50 -0400 (EDT)
Date: Thu, 18 Mar 2010 17:25:58 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [RFC PATCH] Fix Readahead stalling by plugged device queues
Message-ID: <20100319002558.GD5454@kroah.com>
References: <4B979104.6010907@linux.vnet.ibm.com>
 <20100310130932.GB18509@localhost>
 <4B97AD52.7080201@linux.vnet.ibm.com>
 <20100311014542.GA8134@localhost>
 <4B98BEB0.6020800@linux.vnet.ibm.com>
 <20100311132913.GB6692@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100311132913.GB6692@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ronald <intercommit@gmail.com>, Bart Van Assche <bart.vanassche@gmail.com>, Vladislav Bolkhovitin <vst@vlnb.net>, Randy Dunlap <randy.dunlap@oracle.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 11, 2010 at 09:29:13PM +0800, Wu Fengguang wrote:
> On Thu, Mar 11, 2010 at 05:58:08PM +0800, Christian Ehrhardt wrote:
> > Wu Fengguang wrote:
> > > On Wed, Mar 10, 2010 at 10:31:46PM +0800, Christian Ehrhardt wrote:
> > >>
> > >> Wu Fengguang wrote:
> > >> [...]
> > >>> Christian, did you notice this commit for 2.6.33?
> > >>>
> > >>> commit 65a80b4c61f5b5f6eb0f5669c8fb120893bfb388
> > >> [...]
> > >>
> > >> I didn't see that particular one, due to the fact that whatever the 
> > >> result is it needs to work .32
> > >>
> > >> Anyway I'll test it tomorrow and if that already accepted one fixes my 
> > >> issue as well I'll recommend distros older than 2.6.33 picking that one 
> > >> up in their on top patches.
> > > 
> > > OK, thanks!
> > 
> > That patch fixes my issue completely and is as we discussed less 
> > aggressive which is fine - thanks for pointing it out - Now I have 
> > something already upstream accepted to fix the issue, thats much better!
> 
> That's great news, it works beyond my expectation.. :)
> 
> > >>> It should at least improve performance between .32 and .33, because
> > >>> once two readahead requests are merged into one single IO request,
> > >>> the PageUptodate() will be true at next readahead, and hence
> > >>> blk_run_backing_dev() get called to break out of the suboptimal
> > >>> situation.
> > >> As you saw from my blktrace thats already the case without that patch.
> > >> Once the second readahead comes in and merged it gets unplugged in 
> > >> 2.6.32 too - but still that is bad behavior as it denies my things like 
> > >> 68% throughput improvement :-).
> > > 
> > > I mean, when readahead windows A and B are submitted in one IO --
> > > let's call it AB -- commit 65a80b4c61 will explicitly unplug on doing
> > > readahead C.  While in your trace, the unplug appears on AB.
> > > 
> > > The 68% improvement is very impressive. Wondering if commit 65a80b4c61
> > > (the _conditional_ unplug) can achieve the same level of improvement :)
> > 
> > Yep it can !
> > We can post update the patch description to bigger numbers :-)
> 
> Andrew/Greg, shall we push the patch to .32 stable?

I've now queued it up.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
