Date: Sun, 5 Aug 2007 09:45:19 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
In-Reply-To: <20070805124648.GA21173@elte.hu>
Message-ID: <alpine.LFD.0.999.0708050944470.5037@woody.linux-foundation.org>
References: <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
 <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
 <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
 <46B4C0A8.1000902@garzik.org> <20070805102021.GA4246@unthought.net>
 <46B5A996.5060006@garzik.org> <20070805105850.GC4246@unthought.net>
 <20070805124648.GA21173@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jakob Oestergaard <jakob@unthought.net>, Jeff Garzik <jeff@garzik.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, 5 Aug 2007, Ingo Molnar wrote:
> 
> you mean tmpwatch? The trivial change below fixes this. And with that 
> we've come to the end of an extremely short list of atime dependencies.

You wouldn't even need these kinds of games.

What we could do is to make "relatime" updates a bit smarter.

A bit smarter would be:

 - update atime if the old atime is <= than mtime/ctime

   Logic: things like mailers can care about whether some new state has 
   been read or not. This is the current relatime.

 - update atime if the old atime is more than X seconds in the past 
   (defaulting to one day or something)

   Logic: things like tmpwatch and backup software may want to remove 
   stuff that hasn't been touched in a long time, but they sure don't care 
   about "exact" atime.

Now, you could also make the rule be that "X" depends on mtime/ctime, ie 
if a file has been "recently" created or modified, we keep more exact 
track of it and use one hour instead of one day, but if it's some old file 
that hasn't been modified in the last six months, we change X to a week. 
IOW, the "exactness" of atime is relative to how old the inode 
modifications are.

We could obviously do with an additional rule:

 - update atime if the inode is dirty anyway. Logic: there's no downside.

which just says that we'll make it exact if there is no reason not to.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
