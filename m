Received: by wx-out-0506.google.com with SMTP id s8so682614wxc
        for <linux-mm@kvack.org>; Fri, 19 Jan 2007 21:50:50 -0800 (PST)
Message-ID: <6d6a94c50701191908i63fe7eebi9a97a4afb94f5df4@mail.gmail.com>
Date: Sat, 20 Jan 2007 11:08:40 +0800
From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [RPC][PATCH 2.6.20-rc5] limit total vfs page cache
In-Reply-To: <45B17D6D.2030004@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6d6a94c50701171923g48c8652ayd281a10d1cb5dd95@mail.gmail.com>
	 <45B0DB45.4070004@linux.vnet.ibm.com>
	 <6d6a94c50701190805saa0c7bbgbc59d2251bed8537@mail.gmail.com>
	 <45B112B6.9060806@linux.vnet.ibm.com>
	 <6d6a94c50701191804m79c70afdo1e664a072f928b9e@mail.gmail.com>
	 <45B17D6D.2030004@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, "linux-os (Dick Johnson)" <linux-os@analogic.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>
List-ID: <linux-mm.kvack.org>

On 1/20/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Aubrey Li wrote:
> > On 1/20/07, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> wrote:
>
> >> If pagecache is overlimit, we expect old (cold) pagecache pages to
> >> be thrown out and reused for new file data.  We do not expect to
> >> drop a few text or data pages to make room for new pagecache.
> >>
> > Well, actually I think this probably not necessary. Because the
> > reclaimer has no way to predict the behavior of user mode processes,
> > how do you make sure the pagecache will not be access again in a short
>
> It is not about predicting behaviour, it is about directing the reclaim
> effort at the actual resource that is under pressure.
>
> Even given a pagecache limiting patch which does the proper accounting
> to keep pagecache pages under a % limit (unlike yours), kicking off an
> undirected reclaim could (in theory) reclaim all slab and anonymous
> memory pages before bringing pagecache under the limit. So I think
> you need to be a bit more thorough than just assuming everything will
> be OK. Page reclaim behaviour is pretty strange and complex.

So what's the right way to limit pagecache?

>
> Secondly, your patch isn't actually very good. It unconditionally
> shrinks memory to below the given % mark each time a pagecache alloc
> occurs, regardless of how much pagecache is in the system. Effectively
> that seems to just reduce the amount of memory available to the system.

It doesn't reduce the amount of memory available to the system. It
just reduce the amount of memory available to the page cache. So that
page cache is limited and the reserved memory can be allocated by the
application.

>
> Luckily, there are actually good, robust solutions for your higher
> order allocation problem. Do higher order allocations at boot time,
> modifiy userspace applications, or set up otherwise-unused, or easily
> reclaimable reserve pools for higher order allocations. I don't
> understand why you are so resistant to all of these approaches?
>

I think we have explained the reason too much. We are working on
no-mmu arch and provide a platform running linux to our customer. They
are doing very good things like mplayer, asterisk, ip camera, etc on
our platform, some applications was migrated from mmu arch. I think
that means in some cases no-mmu arch is somewhat better than mmu arch.
So we are taking effort to make the migration smooth or make no-mmu
linux stronger.
It's no way to let our customer modify their applications, we also
unwilling to do it. And we have not an existing mechanism to set up a
pools for the complex applications. So I'm trying to do some coding
hack in the kernel to satisfy these kinds of requirement.

And as you see, the patch seems to solve the problems on my side. But
I'm not sure it's the right way to limit vfs cache, So I'm asking for
comments and suggestions and help, I'm not asking to clobber the
kernel.

-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
