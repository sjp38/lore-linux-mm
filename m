Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCA576B7662
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 16:22:43 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t26so11923894pgu.18
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 13:22:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i2si20051110pgl.153.2018.12.05.13.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 13:22:42 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB5LEOmx050337
	for <linux-mm@kvack.org>; Wed, 5 Dec 2018 16:22:42 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p6mr2met4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Dec 2018 16:22:41 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 5 Dec 2018 21:22:39 -0000
Date: Wed, 5 Dec 2018 23:22:27 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 1/6] powerpc: prefer memblock APIs returning virtual
 address
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-2-git-send-email-rppt@linux.ibm.com>
 <87woophasy.fsf@concordia.ellerman.id.au>
 <20181204171327.GL26700@rapoport-lnx>
 <87mupkkv3b.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mupkkv3b.fsf@concordia.ellerman.id.au>
Message-Id: <20181205212226.GF19181@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

On Wed, Dec 05, 2018 at 11:37:44PM +1100, Michael Ellerman wrote:
> Mike Rapoport <rppt@linux.ibm.com> writes:
> > On Tue, Dec 04, 2018 at 08:59:41PM +1100, Michael Ellerman wrote:
> >> Hi Mike,
> >> 
> >> Thanks for trying to clean these up.
> >> 
> >> I think a few could be improved though ...
> >> 
> >> Mike Rapoport <rppt@linux.ibm.com> writes:
> >> > diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
> >> > index 913bfca..fa884ad 100644
> >> > --- a/arch/powerpc/kernel/paca.c
> >> > +++ b/arch/powerpc/kernel/paca.c
> >> > @@ -42,17 +42,15 @@ static void *__init alloc_paca_data(unsigned long size, unsigned long align,
> >> >  		nid = early_cpu_to_node(cpu);
> >> >  	}
> >> >  
> >> > -	pa = memblock_alloc_base_nid(size, align, limit, nid, MEMBLOCK_NONE);
> >> > -	if (!pa) {
> >> > -		pa = memblock_alloc_base(size, align, limit);
> >> > -		if (!pa)
> >> > -			panic("cannot allocate paca data");
> >> > -	}
> >> > +	ptr = memblock_alloc_try_nid_raw(size, align, MEMBLOCK_LOW_LIMIT,
> >> > +					 limit, nid);
> >> > +	if (!ptr)
> >> > +		panic("cannot allocate paca data");
> >>   
> >> The old code doesn't zero, but two of the three callers of
> >> alloc_paca_data() *do* zero the whole allocation, so I'd be happy if we
> >> did it in here instead.
> >
> > I looked at the callers and couldn't tell if zeroing memory in
> > init_lppaca() would be ok.
> > I'll remove the _raw here.
>   
> Thanks.
> 
> >> That would mean we could use memblock_alloc_try_nid() avoiding the need
> >> to panic() manually.
> >
> > Actual, my plan was to remove panic() from all memblock_alloc* and make all
> > callers to check the returned value.
> > I believe it's cleaner and also allows more meaningful panic messages. Not
> > mentioning the reduction of memblock code.
> 
> Hmm, not sure.
> 
> I see ~200 calls to the panicking functions, that seems like a lot of
> work to change all those.

Yeah, I know :)

> And I think I disagree on the "more meaningful panic message". This is a
> perfect example, compare:
> 
> 	panic("cannot allocate paca data");
> to:
> 	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa\n",
> 	      __func__, (u64)size, (u64)align, nid, &min_addr, &max_addr);
> 
> The former is basically useless, whereas the second might at least give
> you a hint as to *why* the allocation failed.

We can easily keep the memblock message, just make it pr_err instead of
panic.
The message at the call site can show where the problem was without the
need to dive into the stack dump.

> I know it's kind of odd for a function to panic() rather than return an
> error, but memblock is kind of special because it's so early in boot.
> Most of these allocations have to succeed to get the system up and
> running.

The downside of having panic() inside some memblock functions is that it
makes the API way too bloated. And, at least currently, it's inconsistent.
For instance memblock_alloc_try_nid_raw() does not panic, but
memblock_alloc_try_nid() does.

When it was about 2 functions and a wrapper, it was perfectly fine, but
since than memblock has three sets of partially overlapping APIs with
endless convenience wrappers.

I believe that patching up ~200 calls is worth the reduction of memblock
API to saner size.

Another thing, the absence of check for return value for memory allocation
is not only odd, but it also makes the code obfuscated.
 
> cheers
> 

-- 
Sincerely yours,
Mike.
