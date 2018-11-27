Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB056B471C
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 04:32:09 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id o8so5804888otp.16
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 01:32:09 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n1si1526155otk.301.2018.11.27.01.32.07
        for <linux-mm@kvack.org>;
        Tue, 27 Nov 2018 01:32:07 -0800 (PST)
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com>
 <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
 <c6abb754-0d82-8739-fe08-24e9402bae75@intel.com>
 <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
 <f5315662-5c1a-68a3-4d04-21b4b5ca94b1@intel.com>
 <ac942498-8966-6a9b-0e55-c79ae167c679@arm.com>
 <9015e51a-3584-7bb2-cc5e-25b0ec8e5494@intel.com>
 <1a9e887b-8087-e897-6195-e8df325bd458@arm.com>
 <3b86c5c5-53f2-29bf-48e7-5749c7287dca@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <6208771a-43da-ecc4-40ed-8e99cd5169fc@arm.com>
Date: Tue, 27 Nov 2018 15:02:07 +0530
MIME-Version: 1.0
In-Reply-To: <3b86c5c5-53f2-29bf-48e7-5749c7287dca@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>



On 11/26/2018 10:50 PM, Dave Hansen wrote:
> On 11/26/18 7:38 AM, Anshuman Khandual wrote:
>> On 11/24/2018 12:51 AM, Dave Hansen wrote:
>>> On 11/22/18 10:42 PM, Anshuman Khandual wrote:
>>>> Are we willing to go in the direction for inclusion of a new system
>>>> call, subset of it appears on sysfs etc ? My primary concern is not
>>>> how the attribute information appears on the sysfs but lack of it's
>>>> completeness.
>>>
>>> A new system call makes total sense to me.  I have the same concern
>>> about the completeness of what's exposed in sysfs, I just don't see a
>>> _route_ to completeness with sysfs itself.  Thus, the minimalist
>>> approach as a first step.
>>
>> Okay if we agree on the need for a new specific system call extracting
>> the superset attribute information MAX_NUMNODES * MAX_NUMNODES * U64
>> (u64 packs 8 bit values for 8 attributes or something like that) as we
>> had discussed before, it makes sense to export a subset of it which can
>> be faster but useful for the user space without going through a system
>> call. 
> 
> The information that needs to be exported is a bit more than that.  It's
> not just a binary attribute.

Right wont be binary because it would contain a value for an attribute.

> 
> The information we have from the new ACPI table, for instance, is the
> read and write bandwidth and latency between two nodes.  They are, IIRC,
> two-byte values in the ACPI table[1], each.  That's 8 bytes worth of
> data right there, which wouldn't fit *anything* else.

Hmm I get your point. We would need to have interfaces both system call
and sysfs where number of attributes and bit field to contain value for
any attribute can grow in the future with backward compatibility. 

> 
> The list of things we want to export will certainly grow.  That means we
> need a syscall something like this:
> 
> int get_mem_attribute(unsigned long attribute_nr,
> 		      unsigned long __user * initiator_nmask,
> 		      unsigned long __user * target_nmask,
> 		      unsigned long maxnode,
> 		      unsigned long *attributes_out);

Agreed. I was also thinking something like above syscall interface works
where attribute_nr can grow as an enum with MAX_MEM_ATTRIBUTES increasing
but still keeping previous order intact for backward compatibility. But I
guess we would need to pass a size of an attribute structure (UAPI like
perf_event_attr) so that it can grow further but then structure packing
order is maintained for backward compatibility.

int get_mem_attribute(unsigned long attribute_nr,
		      unsigned long __user * initiator_nmask,
		      unsigned long __user * target_nmask,
		      unsigned long maxnode,
 		      unsigned long *attributes_out,
		      size_t attribute_size);

 
> 
> #define MEM_ATTR_READ_BANDWIDTH		1
> #define MEM_ATTR_WRITE_BANDWIDTH	2
> #define MEM_ATTR_READ_LATENCY		3
> #define MEM_ATTR_WRITE_LATENCTY		4
> #define MEM_ATTR_ENCRYPTION		5
> 
> If you want to know the read latency between nodes 4 and 8, you do:
> 
> 	ret = get_mem_attr(MEM_ATTR_READ_LATENCY,
> 			   (1<<4), (1<<8), max, &array);
> 
> And the answer shows up at array[0] in this example.  If you had more
> than one bit set in the two nmasks, you would have a longer array.
> 
> The length of the array is the number of bits set in initiator_nmask *
> the number of bits set in target_nmask * sizeof(ulong).

Right. Hmm, I guess now that the interface is requesting for a single
attribute it does not have to worry about structure for the attribute
field. A single ULONG_MAX should be enough to hold value for any given
attribute and also it does not have to worry much about compatibility.
This is better.

> 
> This has the advantage of supporting ULONG_MAX attributes, and scales

Right.

> from asking for one attribute at a time all the way up to dumping the
> entire system worth of data for a single attribute.  The only downside

Right.

> is that it's one syscall per attribute instead of packing them all
> together.  But, if we have a small enough number to pack them in one
> ulong, then I think we can make 64 syscalls without too much trouble.

I agree. It also enables single attribute to have ULONG_MAX length value
and avoid compatibility issues because of packing order due to multiple
attributes requested together. This is definitely a cleaner interface.

> 
>> Do you agree on a (system call + sysfs) approach in principle ?
>> Also sysfs exported information has to be derived from whats available
>> through the system call not the other way round. Hence the starting
>> point has to be the system call definition.
> 
> Both the sysfs information *and* what will be exported in any future
> interfaces are derived from platform-specific information.  They are not
> derived from one _interface_ or the other.
> 
> They obviously need to be consistent, though.

What I meant was the most comprehensive set of information should be
available to be fetched from the system call. Any other interface like
sysfs (or some other) will have to be a subset of whats available through
the system call. It should never be the case where there are information
available via sysfs but not through system call route. What is exported
through either syscall or sysfs will always be derived from platform
specific information.

> 
> 1. See "Table 5-142 System Locality Latency and Bandwidth Information
> Structure" here:
> http://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
> 

In conclusion something like this sort of a system call interface really
makes sense and can represent superset of memory attribute information.
