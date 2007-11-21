Message-ID: <47445D2D.8090703@sgi.com>
Date: Wed, 21 Nov 2007 08:30:37 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] x86: Reduce pressure on stack from cpumask usage
 -v2
References: <20071121100201.156191000@sgi.com> <200711211118.45137.ak@suse.de>
In-Reply-To: <200711211118.45137.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, mingo@elte.hu, apw@shadowen.org, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Wednesday 21 November 2007 11:02:01 travis@sgi.com wrote:
>> v2:
>>     - fix some compile errors when NR_CPUS > default for ia386 (128 & 4096)
>>     - remove unnecessary includes
>>
>> Convert cpumask_of_cpu to use a static percpu data array and
>> set_cpus_allowed to pass the cpumask_t arg as a pointer.
> 
> I'm not sure that is too useful alone because you didn't solve the
> set_cpus_allowed(oldmask) problem.

Passing by reference does reduce the amount of data pushed onto the stack
for all cases.

I've been looking at a couple of options to fix up the rest of the cpumask_t
users.  The least disruptive would be to make cpumask_t a "const *cpumask"
type and then fix up instances where a cpumask var is needed.  It does get
messy attempting to keep cpumask_t a simple integer in the NR_CPUS <=
BITS_PER_LONG case, in a transparent manner.

The other is to continue to modify subroutines that expect cpumask_t
arguments and work back up the call chain passing by reference instead.
In this case I could use the idea of allocating a "scratch" cpumask_t
array in the task struct (or somewhere else?) to accommodate trivial
changes, to lessen local frame storage.  Again though, the code gets
messy in the same manner as above.

The set_cpus_allowed is about 30% of the "cpumask_t pass by value" code
though much lower in call usage.  The highest call count goes to the
send_IPI_mask, irq and smp_call functions.

Btw, is there a good source code call trace analyzer tool around someplace?

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
