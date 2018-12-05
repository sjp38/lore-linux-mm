Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21B9F6B745D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 07:37:58 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id e89so16601571pfb.17
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 04:37:58 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id v9si21144629pfl.45.2018.12.05.04.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 04:37:57 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2 1/6] powerpc: prefer memblock APIs returning virtual address
In-Reply-To: <20181204171327.GL26700@rapoport-lnx>
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com> <1543852035-26634-2-git-send-email-rppt@linux.ibm.com> <87woophasy.fsf@concordia.ellerman.id.au> <20181204171327.GL26700@rapoport-lnx>
Date: Wed, 05 Dec 2018 23:37:44 +1100
Message-ID: <87mupkkv3b.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

Mike Rapoport <rppt@linux.ibm.com> writes:
> On Tue, Dec 04, 2018 at 08:59:41PM +1100, Michael Ellerman wrote:
>> Hi Mike,
>> 
>> Thanks for trying to clean these up.
>> 
>> I think a few could be improved though ...
>> 
>> Mike Rapoport <rppt@linux.ibm.com> writes:
>> > diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
>> > index 913bfca..fa884ad 100644
>> > --- a/arch/powerpc/kernel/paca.c
>> > +++ b/arch/powerpc/kernel/paca.c
>> > @@ -42,17 +42,15 @@ static void *__init alloc_paca_data(unsigned long size, unsigned long align,
>> >  		nid = early_cpu_to_node(cpu);
>> >  	}
>> >  
>> > -	pa = memblock_alloc_base_nid(size, align, limit, nid, MEMBLOCK_NONE);
>> > -	if (!pa) {
>> > -		pa = memblock_alloc_base(size, align, limit);
>> > -		if (!pa)
>> > -			panic("cannot allocate paca data");
>> > -	}
>> > +	ptr = memblock_alloc_try_nid_raw(size, align, MEMBLOCK_LOW_LIMIT,
>> > +					 limit, nid);
>> > +	if (!ptr)
>> > +		panic("cannot allocate paca data");
>>   
>> The old code doesn't zero, but two of the three callers of
>> alloc_paca_data() *do* zero the whole allocation, so I'd be happy if we
>> did it in here instead.
>
> I looked at the callers and couldn't tell if zeroing memory in
> init_lppaca() would be ok.
> I'll remove the _raw here.
  
Thanks.

>> That would mean we could use memblock_alloc_try_nid() avoiding the need
>> to panic() manually.
>
> Actual, my plan was to remove panic() from all memblock_alloc* and make all
> callers to check the returned value.
> I believe it's cleaner and also allows more meaningful panic messages. Not
> mentioning the reduction of memblock code.

Hmm, not sure.

I see ~200 calls to the panicking functions, that seems like a lot of
work to change all those.

And I think I disagree on the "more meaningful panic message". This is a
perfect example, compare:

	panic("cannot allocate paca data");
to:
	panic("%s: Failed to allocate %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa\n",
	      __func__, (u64)size, (u64)align, nid, &min_addr, &max_addr);

The former is basically useless, whereas the second might at least give
you a hint as to *why* the allocation failed.

I know it's kind of odd for a function to panic() rather than return an
error, but memblock is kind of special because it's so early in boot.
Most of these allocations have to succeed to get the system up and
running.

cheers
