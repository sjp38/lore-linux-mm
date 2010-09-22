Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E714D6B0047
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 14:58:54 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8MIq9KZ023303
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 14:52:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8MIwqOE447014
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 14:58:52 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8MIwpog024423
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 12:58:51 -0600
Subject: Re: [PATCH 0/8] De-couple sysfs memory directories from memory
 sections
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C9A4DBB.6080500@austin.ibm.com>
References: <4C9A0F8F.2030409@austin.ibm.com>
	 <1285168800.3292.5228.camel@nimitz>  <4C9A4DBB.6080500@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Wed, 22 Sep 2010 11:58:49 -0700
Message-ID: <1285181929.3292.6287.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-09-22 at 13:40 -0500, Nathan Fontenot wrote:
> On 09/22/2010 10:20 AM, Dave Hansen wrote:
> >                            and phys_index's calculation needs to be:
> > 
> > 	mem->start_phys_index * SECTION_SIZE / memory_block_size_bytes()
> 
> I'm not sure if  I follow where you suggest using this formula.  Is this
> instead of what is used now, the base_memory_block_id() calculation?
> 
> If so, then I'm not sure it would work. The formula used in base_memory_block_id()
> is done because the memory sections are not guaranteed to be added to the
> memory block starting with the first section of the block.
> 
> If you meant somewhere else let me know.

My point was just that if we change the "block_size_bytes" contents,
then we have to scale down the "memoryXXXX/phys_index" by that same
amount.

It *used* to be in numbers of SECTION_SIZE units, and I think it still
is:

-       mem->start_phys_index = __section_nr(section);
+       mem->start_phys_index = base_memory_block_id(__section_nr(section));
+       mem->end_phys_index = mem->start_phys_index + sections_per_block - 1;

but now it needs to be changed to be in memory_block_size_bytes() units,
*NOT* SECTION_SIZE units.

Let's say we have a system with 4 16MB sections starting at 0x0.
Before, we would have:

	block_size_bytes: 16777216
	memory0/phys_index: 0
	memory1/phys_index: 1
	memory2/phys_index: 2
	memory3/phys_index: 3

Now, we change memory_block_size_bytes() to be 32MB instead.  We reduce
the number of sections in half, and I think the right thing to get is:

	block_size_bytes: 33554432
	memory0/phys_index: 0
	memory1/phys_index: 1

I think, with your code (as it stands in these patches, no fixes) that
we'd instead get this:

	block_size_bytes: 16777216
	memory0/phys_index: 0
	memory1/phys_index: 2

Without consulting "end_phys_index" (which isn't and can't be a part of
the existing ABI), we'd think that we have two 16MB banks instead of
four.


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
