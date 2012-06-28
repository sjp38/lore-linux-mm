Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 525E36B0075
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 12:03:04 -0400 (EDT)
Message-ID: <4FEC7F97.5010209@redhat.com>
Date: Thu, 28 Jun 2012 19:00:23 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
References: <20120627211540.459910855@chello.nl>  <20120627212831.137126018@chello.nl>  <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>  <1340838154.10063.86.camel@twins> <1340838807.10063.90.camel@twins>  <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>  <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>  <1340880904.28750.13.camel@twins> <20120628131950.0afe39f0@de.ibm.com> <1340883048.28750.25.camel@twins>
In-Reply-To: <1340883048.28750.25.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On 06/28/2012 02:30 PM, Peter Zijlstra wrote:
> On Thu, 2012-06-28 at 13:19 +0200, Martin Schwidefsky wrote:
> 
>> The cpu can create speculative TLB entries, but only if it runs in the
>> mode that uses the respective mm. We have two mm's active at the same
>> time, the kernel mm (init_mm) and the user mm. While the cpu runs only
>> in kernel mode it is not allowed to create TLBs for the user mm.
>> While running in user mode it is allowed to speculatively create TLBs.
> 
> OK, that's neat.

Note that we can do that for x86 now using the new PCID feature.
Basically you get a tagged TLB, so you can switch between the
kernel-only address space and the kernel+user address space quickly.

It's still going to be slower than what we do now, but it might please
some security people if the kernel can't accidentally access user data.

-- 
error compiling committee.c: too many arguments to function


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
