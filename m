From: Rich Felker <dalias@libc.org>
Subject: Re: [RFC PATCH 00/13] Introduce first class virtual address spaces
Date: Wed, 15 Mar 2017 15:47:23 -0400
Message-ID: <20170315194723.GJ1693__14401.0103344501$1489607445$gmane$org@brightrain.aerifal.cx>
References: <CALCETrX5gv+zdhOYro4-u3wGWjVCab28DFHPSm5=BVG_hKxy3A@mail.gmail.com>
 <20170315194447.scsf3fiwvf7z5gzc@arch-dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by blaine.gmane.org with esmtp (Exim 4.84_2)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1coEwG-0000b0-Vh
	for glkm-linux-mm-2@m.gmane.org; Wed, 15 Mar 2017 20:50:29 +0100
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD306B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 15:50:34 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j127so21867944qke.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 12:50:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170315194447.scsf3fiwvf7z5gzc@arch-dev>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, Till Smejkal <till.smejkal@googlemail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de>

On Wed, Mar 15, 2017 at 12:44:47PM -0700, Till Smejkal wrote:
> On Wed, 15 Mar 2017, Andy Lutomirski wrote:
> > > One advantage of VAS segments is that they can be globally queried by user programs
> > > which means that VAS segments can be shared by applications that not necessarily have
> > > to be related. If I am not mistaken, MAP_SHARED of pure in memory data will only work
> > > if the tasks that share the memory region are related (aka. have a common parent that
> > > initialized the shared mapping). Otherwise, the shared mapping have to be backed by a
> > > file.
> > 
> > What's wrong with memfd_create()?
> > 
> > > VAS segments on the other side allow sharing of pure in memory data by
> > > arbitrary related tasks without the need of a file. This becomes especially
> > > interesting if one combines VAS segments with non-volatile memory since one can keep
> > > data structures in the NVM and still be able to share them between multiple tasks.
> > 
> > What's wrong with regular mmap?
> 
> I never wanted to say that there is something wrong with regular mmap. We just
> figured that with VAS segments you could remove the need to mmap your shared data but
> instead can keep everything purely in memory.
> 
> Unfortunately, I am not at full speed with memfds. Is my understanding correct that
> if the last user of such a file descriptor closes it, the corresponding memory is
> freed? Accordingly, memfd cannot be used to keep data in memory while no program is
> currently using it, can it? To be able to do this you need again some representation

I have a name for application-allocated kernel resources that persist
without a process holding a reference to them or a node in the
filesystem: a bug. See: sysvipc.

Rich

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
