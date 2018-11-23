Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0154B6B2FAE
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 01:43:00 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id 62so5620639otr.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 22:43:00 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e37si21513151otb.83.2018.11.22.22.42.59
        for <linux-mm@kvack.org>;
        Thu, 22 Nov 2018 22:42:59 -0800 (PST)
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
References: <20181114224902.12082-1-keith.busch@intel.com>
 <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com>
 <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
 <c6abb754-0d82-8739-fe08-24e9402bae75@intel.com>
 <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
 <f5315662-5c1a-68a3-4d04-21b4b5ca94b1@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ac942498-8966-6a9b-0e55-c79ae167c679@arm.com>
Date: Fri, 23 Nov 2018 12:12:56 +0530
MIME-Version: 1.0
In-Reply-To: <f5315662-5c1a-68a3-4d04-21b4b5ca94b1@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dan Williams <dan.j.williams@intel.com>



On 11/22/2018 11:31 PM, Dave Hansen wrote:
> On 11/22/18 3:52 AM, Anshuman Khandual wrote:
>>>
>>> It sounds like the subset that's being exposed is insufficient for yo
>>> We did that because we think doing anything but a subset in sysfs will
>>> just blow up sysfs:  MAX_NUMNODES is as high as 1024, so if we have 4
>>> attributes, that's at _least_ 1024*1024*4 files if we expose *all*
>>> combinations.
>> Each permutation need not be a separate file inside all possible NODE X
>> (/sys/devices/system/node/nodeX) directories. It can be a top level file
>> enumerating various attribute values for a given (X, Y) node pair based
>> on an offset something like /proc/pid/pagemap.
> 
> My assumption has been that this kind of thing is too fancy for sysfs:

Applications need to know the matrix of multi attribute properties as
seen from various memory accessors/initiators to be able to bind them
to desired CPUs and memory. That gives applications true view of an
heterogeneous system. While I understand your concern here about the
sysfs (which can be worked around with probably multiple global files
may be if the size is a problem etc) but an insufficient interface is
definitely problematic in longer term. This is going to be an ABI which
is locked in for good. Hence even it might appear over engineering at
the moment but IMHO is the right thing to do.

> 
> Documentation/filesystems/sysfs.txt:
>> Attributes should be ASCII text files, preferably with only one value
>> per file. It is noted that it may not be efficient to contain only one
>> value per file, so it is socially acceptable to express an array of
>> values of the same type. 
>>
>> Mixing types, expressing multiple lines of data, and doing fancy
>> formatting of data is heavily frowned upon. Doing these things may get
>> you publicly humiliated and your code rewritten without notice. 
> 
> /proc/pid/pagemap is binary, not one-value-per-file and relatively
> complicated to parse.

I agree but it does provide user space really valuable information about
the faulted pages for it's VA space. Was there any better way of getting
it ? May be but at this point in time it is essential.

> 
> Do you really think following something like pagemap is the right model
> for sysfs.> 
> BTW, I'm not saying we don't need *some* interface like you propose.  We
> almost certainly will at some point.  I just don't think it will be in
> sysfs.

I am not saying doing this in sysfs is very elegant. I would rather have
a syscall read back (MAX_NODES * MAX_NODES * u64) attribute matrix from
the kernel. Probably a subset of that information can appear on sysfs to
speed of queries for various optimizations as Keith mentioned before. But
we will have to first evaluate and come to an agreement what constitutes
a comprehensive set for multi attribute properties. Are we willing to go
in the direction for inclusion of a new system call, subset of it appears
on sysfs etc ? My primary concern is not how the attribute information
appears on the sysfs but lack of it's completeness.
