Date: Wed, 7 Mar 2007 09:53:23 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307085323.GB27337@elte.hu>
References: <20070221023656.6306.246.sendpatchset@linux.site> <20070221023735.6306.83373.sendpatchset@linux.site> <20070306225101.f393632c.akpm@linux-foundation.org> <20070307070853.GB15877@wotan.suse.de> <20070307081948.GA9563@wotan.suse.de> <20070307082755.GA25733@elte.hu> <20070307003520.08b1a082.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070307003520.08b1a082.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> > btw., if we decide that nonlinear isnt worth the continuing 
> > maintainance pain, we could internally implement/emulate 
> > sys_remap_file_pages() via a call to mremap() and essentially 
> > deprecate it, without breaking the ABI - and remove all the 
> > nonlinear code. (This would split fremap areas into separate vmas)
> > 
> 
> I'm rather regretting having merged it - I don't think it has been 
> used for much.
> 
> Paolo's UML speedup patches might use nonlinear though.

yes, i wrote the first, prototype version of that for UML, it needs an 
extended version of the syscall, sys_remap_file_pages_prot():

 http://redhat.com/~mingo/remap-file-pages-patches/remap-file-pages-prot-2.6.4-rc1-mm1-A1

i also wrote an x86 hypervisor kind of thing for UML, called 
'sys_vcpu()', which allows UML to execute guest user-mode in a box, 
which also relies on sys_remap_file_pages_prot():

 http://redhat.com/~mingo/remap-file-pages-patches/vcpu-2.6.4-rc2-mm1-A2

which reduced the UML guest syscall overhead from 30 usecs to 4 usecs 
(with native syscalls taking 2 usecs, on the box i tested, years ago).

So it certainly looked useful to me - but wasnt really picked up widely. 

We'll always have the option to get rid of it (and hence completely 
reverse the decision to merge it) without breaking the ABI, by emulating 
the API via mremap(). That eliminates the UML speedup though. So no need 
to feel sorry about having merged it, we can easily revisit that 
years-old 'do we want it' decision, without any ABI worries.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
