Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFF2C6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:05:27 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d21so13264377pll.12
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 07:05:27 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l80si7786694pfb.178.2018.02.15.07.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 07:05:26 -0800 (PST)
Subject: Re: [PATCH v3 1/4] mm/memory_hotplug: enforce block size aligned
 range check
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213193159.14606-2-pasha.tatashin@oracle.com>
 <20180215113407.GB7275@dhcp22.suse.cz>
 <CAOAebxvF6mxDb4Ub02F0B9TEMRJUG0UGrKJ6ypaMGcje80cy6w@mail.gmail.com>
 <20180215144011.GF7275@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <6b02e1f4-a68f-787d-fbde-ec081ebba058@oracle.com>
Date: Thu, 15 Feb 2018 10:05:19 -0500
MIME-Version: 1.0
In-Reply-To: <20180215144011.GF7275@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

> No, not really. I just think the alignment shouldn't really matter. Each
> memory block should simply represent a hotplugable entitity with a well
> defined pfn start and size (in multiples of section size). This is in
> fact what we do internally anyway. One problem might be that an existing
> userspace might depend on the existing size restrictions so we might not
> be able to have variable block sizes. But block size alignment should be
> fixable.
> 
Hi Michal,

I see what you mean, and I agree Linux should simply honor reasonable 
requests from HW/HV.

On x86 qemu hotplugable entity is 128M, on sun4v SPARC it is 256M, with 
current scheme we still would end up with huge number of memory devices 
in sysfs if block size is fixed and equal to minimum hotplugable 
entitity. Just as an example, SPARC sun4v may have logical domains up-to 
32T, with 256M granularity that is 131K files in 
/sys/devices/system/memory/!

But, if it is variable, I am not sure how to solve it. The whole 
interface must be redefined. Because even if we hotplugged a highly 
aligned large chunk of memory and created only one memory device for it, 
we should have a way to remove just a small piece of that memory if 
underlying HV/HW requested.

/sys/devices/system/memory/block_size_bytes

Would have to be moved into memory block

echo offline > /sys/devices/system/memory/memoryXXX/state

This would need to be redefined somehow to work only on part of the block.

I am not really sure what a good solution would be without breaking the 
userspace.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
