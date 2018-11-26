Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4996B42E2
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:20:07 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id l131so8216604pga.2
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:20:07 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a28si902880pgl.530.2018.11.26.09.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 09:20:05 -0800 (PST)
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
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3b86c5c5-53f2-29bf-48e7-5749c7287dca@intel.com>
Date: Mon, 26 Nov 2018 09:20:04 -0800
MIME-Version: 1.0
In-Reply-To: <1a9e887b-8087-e897-6195-e8df325bd458@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On 11/26/18 7:38 AM, Anshuman Khandual wrote:
> On 11/24/2018 12:51 AM, Dave Hansen wrote:
>> On 11/22/18 10:42 PM, Anshuman Khandual wrote:
>>> Are we willing to go in the direction for inclusion of a new system
>>> call, subset of it appears on sysfs etc ? My primary concern is not
>>> how the attribute information appears on the sysfs but lack of it's
>>> completeness.
>>
>> A new system call makes total sense to me.  I have the same concern
>> about the completeness of what's exposed in sysfs, I just don't see a
>> _route_ to completeness with sysfs itself.  Thus, the minimalist
>> approach as a first step.
> 
> Okay if we agree on the need for a new specific system call extracting
> the superset attribute information MAX_NUMNODES * MAX_NUMNODES * U64
> (u64 packs 8 bit values for 8 attributes or something like that) as we
> had discussed before, it makes sense to export a subset of it which can
> be faster but useful for the user space without going through a system
> call. 

The information that needs to be exported is a bit more than that.  It's
not just a binary attribute.

The information we have from the new ACPI table, for instance, is the
read and write bandwidth and latency between two nodes.  They are, IIRC,
two-byte values in the ACPI table[1], each.  That's 8 bytes worth of
data right there, which wouldn't fit *anything* else.

The list of things we want to export will certainly grow.  That means we
need a syscall something like this:

int get_mem_attribute(unsigned long attribute_nr,
		      unsigned long __user * initiator_nmask,
		      unsigned long __user * target_nmask,
		      unsigned long maxnode,
		      unsigned long *attributes_out);

#define MEM_ATTR_READ_BANDWIDTH		1
#define MEM_ATTR_WRITE_BANDWIDTH	2
#define MEM_ATTR_READ_LATENCY		3
#define MEM_ATTR_WRITE_LATENCTY		4
#define MEM_ATTR_ENCRYPTION		5

If you want to know the read latency between nodes 4 and 8, you do:

	ret = get_mem_attr(MEM_ATTR_READ_LATENCY,
			   (1<<4), (1<<8), max, &array);

And the answer shows up at array[0] in this example.  If you had more
than one bit set in the two nmasks, you would have a longer array.

The length of the array is the number of bits set in initiator_nmask *
the number of bits set in target_nmask * sizeof(ulong).

This has the advantage of supporting ULONG_MAX attributes, and scales
from asking for one attribute at a time all the way up to dumping the
entire system worth of data for a single attribute.  The only downside
is that it's one syscall per attribute instead of packing them all
together.  But, if we have a small enough number to pack them in one
ulong, then I think we can make 64 syscalls without too much trouble.

> Do you agree on a (system call + sysfs) approach in principle ?
> Also sysfs exported information has to be derived from whats available
> through the system call not the other way round. Hence the starting
> point has to be the system call definition.

Both the sysfs information *and* what will be exported in any future
interfaces are derived from platform-specific information.  They are not
derived from one _interface_ or the other.

They obviously need to be consistent, though.

1. See "Table 5-142 System Locality Latency and Bandwidth Information
Structure" here:
http://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
