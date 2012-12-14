Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 79A6A6B002B
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 19:19:43 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 13 Dec 2012 19:19:42 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 66FCE38C8039
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 19:18:59 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBE0Iwxx332492
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 19:18:59 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBE0IwJ4000978
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 19:18:58 -0500
Message-ID: <50CA7067.4080706@linux.vnet.ibm.com>
Date: Thu, 13 Dec 2012 16:18:47 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add node physical memory range to sysfs
References: <1354919696.2523.6.camel@buesod1.americas.hpqcorp.net> <20121207155125.d3117244.akpm@linux-foundation.org> <50C28720.3070205@linux.vnet.ibm.com> <1355361524.5255.9.camel@buesod1.americas.hpqcorp.net> <50C933E9.2040707@linux.vnet.ibm.com> <1355364222.9244.3.camel@buesod1.americas.hpqcorp.net> <50C95E4A.9010509@linux.vnet.ibm.com> <1355440542.1823.21.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1355440542.1823.21.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/13/2012 03:15 PM, Davidlohr Bueso wrote:
> On Wed, 2012-12-12 at 20:49 -0800, Dave Hansen wrote:
>> How is that possible?  If NUMA nodes are defined by distances from CPUs
>> to memory, how could a DIMM have more than a single distance to any
>> given CPU?
> 
> Can't this occur when interleaving emulated nodes with physical ones?

I'm glad you mentioned numa=fake. Its interleaving node configuration
would also make the patch you've proposed completely useless.  Let's say
you've got a two-node system with 16GB of RAM:

|        0        |      1      |

And you use numa=fake=1G, you'll get the interleaved like this:

|0|1|0|1|0|1|0|1|0|1|0|1|0|1|0|1|

The information that is exported from the interface you're proposing
would be:

node0: start_pfn=0  and spanned_pages = 15G
node1: start_pfn=1G and spanned_pages = 15G

In that situation, there is no way, to figure out which DIMM is backed
by a given node since the node ranges overlap.

>>>> How do you plan to use this in practice, btw?
>>>
>>> It started because I needed to recognize the address of a node to remove
>>> it from the e820 mappings and have the system "ignore" the node's
>>> memory.
>>
>> Actually, now that I think about it, can you check in the
>> /sys/devices/system/ directories for memory and nodes?  We have linkages
>> there for each memory section to every NUMA node, and you can also
>> derive the physical address from the phys_index in each section.  That
>> should allow you to work out physical addresses for a given node.
>> 
> I had looked at the memory-hotplug interface but found that this
> 'phys_index' doesn't include holes, while ->node_spanned_pages does.

I'm not sure what you mean.  Each memory section in sysfs accounts for
SECTION_SIZE where sections are 128MB by default on x86_64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
