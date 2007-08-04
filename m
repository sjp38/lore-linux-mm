Date: Sat, 4 Aug 2007 10:39:56 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
In-Reply-To: <20070804163733.GA31001@elte.hu>
Message-ID: <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
References: <20070803123712.987126000@chello.nl>
 <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
 <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
 <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
 <20070804163733.GA31001@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>


On Sat, 4 Aug 2007, Ingo Molnar wrote:
> 
> yeah, it's really ugly. But otherwise i've got no real complaint about 
> ext3 - with the obligatory qualification that "noatime,nodiratime" in 
> /etc/fstab is a must.

I agree, we really should do something about atime.

But the fsync thing is a real issue. It literally makes ext3 almost 
unusable from a latency standpoint on many loads. I have a fast disk, and 
don't actually tend to have all that much going on normally, and it still 
hurts occasionally. 

One of the most common (and *best*) reasons for using fsync is for the 
mail spool. So anybody that uses local email will actually be doing a lot 
of fsync, and while you could try to thread the interfaces, I don't think 
a lot of mailers do.

So fsync ends up being a latency issue for something that a lot of people 
actually see, and something that you actually end up working with and you 
notice the latencies very clearly. Your editor auto-save feature is 
another good example of that exact same thing: the fsync actually is there 
for a very good reason, even if you apparently decided that you'd rather 
disable it.

But yeah, "noatime,data=writeback" will quite likely be *quite* noticeable 
(with different effects for different loads), but almost nobody actually 
runs that way.

I ended up using O_NOATIME for the individual object "open()" calls inside 
git, and it was an absolutely huge time-saver for the case of not having 
"noatime" in the mount options. Certainly more than your estimated 10% 
under some loads.

The "relatime" thing that David mentioned might well be very useful, but 
it's probably even less used than "noatime" is. And sadly, I don't really 
see that changing (unless we were to actually change the defaults inside 
the kernel).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
