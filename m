Message-ID: <46BA3137.3020701@mbligh.org>
Date: Wed, 08 Aug 2007 14:10:15 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804192615.GA25600@lazybastard.org> <20070804194259.GA25753@lazybastard.org> <20070805203602.GB25107@infradead.org>
In-Reply-To: <20070805203602.GB25107@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, J??rn Engel <joern@logfs.org>, Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Sat, Aug 04, 2007 at 09:42:59PM +0200, J??rn Engel wrote:
>   
>> On Sat, 4 August 2007 21:26:15 +0200, J??rn Engel wrote:
>>     
>>> Given the choice between only "atime" and "noatime" I'd agree with you.
>>> Heck, I use it myself.  But "relatime" seems to combine the best of both
>>> worlds.  It currently just suffers from mount not supporting it in any
>>> relevant distro.
>>>       
>> And here is a completely untested patch to enable it by default.  Ingo,
>> can you see how good this fares compared to "atime" and
>> "noatime,nodiratime"?
>>     
>
> Umm, no f**king way.  atime selection is 100% policy and belongs into
> userspace.  Add to that the problem that we can't actually re-enable
> atimes because of the way the vfs-level mount flags API is designed.
> Instead of doing such a fugly kernel patch just talk to the handfull
> of distributions that matter to update their defaults.
>   

 From what I've seen the problem seems to be that the inode
gets marked dirty when we update atime.

Why isn't this easily fixable by just adding an additional dirty
flag that says atime has changed? Then we only cause a write
when we remove the inode from the inode cache, if only atime
is updated.

Unlike relatime, there's no user-visible change (unless the
machine crashes without clean unmount, but not sure anyone
cares that much about that cornercase). Atime changes are
thus kept in-ram until umount / inode reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
