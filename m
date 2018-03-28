Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1476B005A
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:17:00 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id w125-v6so2008126itf.0
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 03:17:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u66-v6sor1647568itd.102.2018.03.28.03.16.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 03:16:59 -0700 (PDT)
Date: Wed, 28 Mar 2018 03:16:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 01/24] mm: Introduce CONFIG_SPECULATIVE_PAGE_FAULT
In-Reply-To: <32c80b6a-28c6-bf63-ed7b-6a042ae18e8f@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803280310380.68839@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-2-git-send-email-ldufour@linux.vnet.ibm.com> <alpine.DEB.2.20.1803251442090.80485@chino.kir.corp.google.com>
 <32c80b6a-28c6-bf63-ed7b-6a042ae18e8f@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Wed, 28 Mar 2018, Laurent Dufour wrote:

> >> This configuration variable will be used to build the code needed to
> >> handle speculative page fault.
> >>
> >> By default it is turned off, and activated depending on architecture
> >> support.
> >>
> >> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
> >> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> >> ---
> >>  mm/Kconfig | 3 +++
> >>  1 file changed, 3 insertions(+)
> >>
> >> diff --git a/mm/Kconfig b/mm/Kconfig
> >> index abefa573bcd8..07c566c88faf 100644
> >> --- a/mm/Kconfig
> >> +++ b/mm/Kconfig
> >> @@ -759,3 +759,6 @@ config GUP_BENCHMARK
> >>  	  performance of get_user_pages_fast().
> >>  
> >>  	  See tools/testing/selftests/vm/gup_benchmark.c
> >> +
> >> +config SPECULATIVE_PAGE_FAULT
> >> +       bool
> > 
> > Should this be configurable even if the arch supports it?
> 
> Actually, this is not configurable unless by manually editing the .config file.
> 
> I made it this way on the Thomas's request :
> https://lkml.org/lkml/2018/1/15/969
> 
> That sounds to be the smarter way to achieve that, isn't it ?
> 

Putting this in mm/Kconfig is definitely the right way to go about it 
instead of any generic option in arch/*.

My question, though, was making this configurable by the user:

config SPECULATIVE_PAGE_FAULT
	bool "Speculative page faults"
	depends on X86_64 || PPC
	default y
	help
	  ..

It's a question about whether we want this always enabled on x86_64 and 
power or whether the user should be able to disable it (right now they 
can't).  With a large feature like this, you may want to offer something 
simple (disable CONFIG_SPECULATIVE_PAGE_FAULT) if someone runs into 
regressions.
