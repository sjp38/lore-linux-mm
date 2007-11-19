Message-ID: <4741D3C4.4020809@sgi.com>
Date: Mon, 19 Nov 2007 10:19:48 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] x86_64: Configure stack size
References: <Pine.LNX.4.64.0711121147350.27017@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0711121147350.27017@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, apw@shadowen.org, Jack Steiner <steiner@sgi.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, Mike Travis <travis@sgi.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen writes:
> 
>> What else can we do?  Change all sites to do some dynamic allocation if
>> (NR_CPUS >= lots), I guess.
> 
> I think that's an reasonable alternative. Perhaps push one or two into
> task_struct and grab them from there, then go dynamic. Only issue
> is error handling and making it look nice in the source.

I've been looking into this issue of cpumasks quite closely.  The idea of
having one or two "scratch" cpumask variables available is a good one.
Integrating it into the current cpumask API is a big issue.

One of the problem areas is cpumask_of_cpu().  This pushes not only a large
array onto the stack, but the zeroing of all but 1 bit is expensive in
cpu cycles.  The predominant uses center on the following.  (usage counts are
only based on x86 and ia64 at the moment - 78 total references):

    * Modifying a task's CPU affinity:  (29 usages)
	set_cpus_allowed(current, cpumask_of_cpu(cpu))

    * Initialization of arrays: (32 usages)
        = cpumask_of_cpu(0)
        = cpumask_of_cpu(cpu)
        = cpumask_of_cpu(smp_processor_id())

    * other random instances in balance_irq, smp_send_reschedule, !SMP target_cpu
      replacement macro, etc.

I think adding another api call or an optional interface to include a scalar cpu #
avoids this fairly easily.  Whether the cpumask primitives need this optional
scalar operation is still a bit unclear.

> 
>> As for timing: we might as well merge it now so that 2.6.25 has at least a
>> chance of running on 16384-way.
> 
> x86 is still limited to 256 virtual CPUs. What makes you think that changed?
> With x2APIC from Intel it will be higher, but I haven't seen code for 
> that yet.

Yes, there will be more support needed for this new APIC as well as new ACPI
tables.

> 
>> otoh, I doubt if anyone will actually ship an NR_CPUS=16384 kernel, so it
>> isn't terribly pointful.

Ideally, NR_CPUS would just go away, and become a startup initialization problem... ;-)

> NR_CPUS==4096 might happen. Of course that still needs eliminating
> a lot of NR_CPUS arrays and fixing up of NR_INTERRUPTS and some other
> things.

I've also looked at the irq problems with cpumask in the irq_desc and irq_cfg
arrays all being on node 0.  The code in ia64 seems to be a fairly good model
to base changes on...?

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
