Content-Type: text/plain;
  charset="iso-8859-1"
From: Hubertus Franke <frankeh@watson.ibm.com>
Reply-To: frankeh@watson.ibm.com
Subject: Re: [Lse-tech] Re: Examining the Performance and Cost of =?iso-8859-1?q?Revesema	ps=20on=202=2E5=2E26=20Under=20=20Heavy?=
  DBWorkload
Date: Tue, 17 Sep 2002 18:49:54 -0400
References: <39B5C4829263D411AA93009027AE9EBB13299719@fmsmsx35.fm.intel.com> <129560000.1032298951@flay> <20020917214753.GA2179@holomorphy.com>
In-Reply-To: <20020917214753.GA2179@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209171849.54450.frankeh@watson.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <mbligh@aracnet.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@digeo.com>, Peter Wong <wpeter@us.ibm.com>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net, riel@nl.linux.org, dmccr@us.ibm.com, gh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 17 September 2002 05:47 pm, William Lee Irwin III wrote:
> At some point in the past, Tony Luck wrote:
> >> Can't you use LD_PRELOAD tricks to sneak a different version
> >> shmget/shmat to your DB2 binary so that you can intercept the important
> >> calls and divert them to use huge tlb pages?
>
> On Tue, Sep 17, 2002 at 02:42:31PM -0700, Martin J. Bligh wrote:
> > If we had a shmget/shmat call that supported large pages, that would
> > probably make it easier ? ;-) That's the whole issue - large pages aren't
> > supported with standard syscalls, so every app is required to rewrite
> > their memory handling, which isn't going to happen.
> > M.
>
> The pressure on this never lets up. It's being done, though I can't say
> I'm entirely happy with how quickly/slowly I'm getting it done myself.
>
>
> Bill

Yes, its feasible to do the LD_PRELOAD. But Martin is right.
If the large page is the proper concept, than it should be supported
in the base kernel concept, not through some wirdo off the beaten 
path stuff. Non-trivial but possible.

I have been talking with Bill.

One should conceptually distinguish (as we already did in the discussions 7 
weeks ago) that there are two benefits to large pages
(a) TLB miss reduction
(b) larger possible I/O  (page clustering)

The concept can be merged, but for x86 we got   4K vs. 4M which doesn't really
warrant the I/O question.
If more diverse TLB sizes are supported as on other architectures that it 
makes sense to support through the base kernel multiple page sizes, and
if one of the page sizes supported overlaps with a TLB entry size we also
get the benefit for (a).

In case that the TLB size is insanely large like for IA64 (2GB ?) then one
can fallback to the Intel-HugeTLB patch solution, but for the general
consumption that doesn't make sense.


-- 
-- Hubertus Franke  (frankeh@watson.ibm.com)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
