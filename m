Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 89E4C6B01F3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 15:23:39 -0400 (EDT)
Message-ID: <4BC0CFF4.5000207@redhat.com>
Date: Sat, 10 Apr 2010 22:22:28 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org> <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org> <20100406011345.GT5825@random.random> <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org> <20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu>
In-Reply-To: <20100410190233.GA30882@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/10/2010 10:02 PM, Ingo Molnar wrote:
> * Andrea Arcangeli<aarcange@redhat.com>  wrote:
>
>    
>> [...]
>>
>> This is already fully usable and works great, and as Avi showed it boosts
>> even a sort on host by 6%, think about HPC applications, and soon I hope to
>> boost gcc on host by 6% (and of>15% in guest with NPT/EPT) by extending
>> vm_end in 2M chunks in glibc, at least for those huge gcc builds taking
>>      
>>> 200M like translate.o of qemu-kvm... (so I hope soon gcc running on KVM
>>>        
>> guest, thanks to EPT/NPT, will run faster than on mainline kernel without
>> transparent hugepages on bare metal).
>>      
> I think what would be needed is some non-virtualization speedup example of a
> 'non-special' workload, running on the native/host kernel. 'sort' is an
> interesting usecase - could it be patched to use hugepages if it has to sort
> through lots of data?
>    

In fact it works well unpatched, the 6% I measured was with the system sort.

Currently in order to use hugepages (with the 'always' option) the only 
requirement is that the application uses a few large vmas.

> Is it practical to run something like a plain make -jN kernel compile all in
> hugepages, and see a small but measurable speedup?
>    

I doubt it - kernel builds run in relatively little memory.  The link 
stage uses a lot of memory but is fairly fast (I guess due to the 
partial links before).  Building a template-heavy C++ application might 
show some gains.

> Although it's not an ideal workload for computational speedups at all because
> a lot of the time we spend in a kernel build is really buildup/teardown of
> process state/context and similar 'administrative' overhead, while the true
> 'compilation work' is just a burst of a few dozen milliseconds and then we
> tear down all the state again. (It's very inefficient really.)
>
> Something like GIMP calculations would be a lot more representative of the
> speedup potential. Is it possible to run the GIMP with transparent hugepages
> enabled for it?
>    

I thought of it, but raster work is too regular so speculative execution 
should hide the tlb fill latency.  It's also easy to code in a way which 
hides cache effects (no idea if it is actually coded that way).  Sort 
showed a speedup since it defeats branch prediction and thus the 
processor cannot pipeline the loop.

I thought ray tracers with large scenes should show a nice speedup, but 
setting this up is beyond my capabilities.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
