From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH]: Clean up of __alloc_pages
Date: Tue, 4 Oct 2005 11:26:52 -0500
References: <20051001120023.A10250@unix-os.sc.intel.com>
 <1128361714.8472.44.camel@akash.sc.intel.com>
 <p733bnh1kgj.fsf@verdi.suse.de>
In-Reply-To: <p733bnh1kgj.fsf@verdi.suse.de>
MIME-Version: 1.0
Message-ID: <200510041126.53247.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Rohit Seth <rohit.seth@intel.com>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 04 October 2005 08:27, Andi Kleen wrote:
> Rohit Seth <rohit.seth@intel.com> writes:
> > I think conceptually this ask for a new flag __GFP_NODEONLY that
> > indicate allocations to come from current node only.
> >
> > This definitely though means I will need to separate out the allocation
> > from pcp patch (as Nick suggested earlier).
>
> This reminds me - the current logic is currently a bit suboptimal on
> many NUMA systems. Often it would be better to be a bit more
> aggressive at freeing memory (maybe do a very low overhead light try to
> free pages) in the first node before falling back to other nodes. What
> right now happens is that when you have even minor memory pressure
> because e.g. you node is filled up with disk cache the local memory
> affinity doesn't work too well anymore.
>
> -Andi
>
That's exactly what Martin Hick's additions to __alloc_pages() were trying to 
achieve.   However, we've never figured out how to make the "very low 
overhead light try to free pages" thing work with low enough overhead that it 
can be left on all of the time.    As soon as we make this the least bit more 
expensive, then this hurts those workloads (file servers being one example) 
who don't care about local, but who need the fastest possible allocations. 

This problem is often a showstopper on larger NUMA systems, at least for HPC 
type applications, where the inability to guarantee local storage allocation 
when it is requested can make the application run significantly slower.
-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
