Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5958C6B0047
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 14:41:06 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8MIUVmc008059
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 12:30:31 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8MIf1AO155246
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 12:41:01 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8MIf0de012472
	for <linux-mm@kvack.org>; Wed, 22 Sep 2010 12:41:01 -0600
Message-ID: <4C9A4DBB.6080500@austin.ibm.com>
Date: Wed, 22 Sep 2010 13:40:59 -0500
From: Nathan Fontenot <nfont@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] De-couple sysfs memory directories from memory sections
References: <4C9A0F8F.2030409@austin.ibm.com> <1285168800.3292.5228.camel@nimitz>
In-Reply-To: <1285168800.3292.5228.camel@nimitz>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 09/22/2010 10:20 AM, Dave Hansen wrote:
> On Wed, 2010-09-22 at 09:15 -0500, Nathan Fontenot wrote:
>> For architectures that define their own version of this routine,
>> as is done for powerpc in this patchset, the view in userspace
>> would change such that each memoryXXX directory would span
>> multiple memory sections.  The number of sections spanned would
>> depend on the value reported by memory_block_size_bytes.
>>
>> In both cases a new file 'end_phys_index' is created in each
>> memoryXXX directory.  This file will contain the physical id
>> of the last memory section covered by the sysfs directory.  For
>> the default case, the value in 'end_phys_index' will be the same
>> as in the existing 'phys_index' file.
> 
> Hi Nathan,
> 
> There's one bit missing here, I think.
> 
> "block_size_bytes" today means two things today:
> 1. the SECTION_SIZE from sparsemem
> 2. the size covered by each memoryXXXX directory
> 
> SECTION_SIZE isn't exposed to userspace, but the memoryXXXX directories
> are.  You've done all of the heavy lifting here to make sure that the
> memory directories are no longer bound to SECTION_SIZE, but you've also
> broken the assumption that _each_ directory covers "block_size_bytes".
> 
> I think it's fairly simple to fix.  block_size_bytes() needs to return
> memory_block_size_bytes(),

yes, missed that.  I will update the patch set to include this.

>                            and phys_index's calculation needs to be:
> 
> 	mem->start_phys_index * SECTION_SIZE / memory_block_size_bytes()

I'm not sure if  I follow where you suggest using this formula.  Is this
instead of what is used now, the base_memory_block_id() calculation?

If so, then I'm not sure it would work. The formula used in base_memory_block_id()
is done because the memory sections are not guaranteed to be added to the
memory block starting with the first section of the block.

If you meant somewhere else let me know.

-Nathan
> 
> That way, to userspace, it just looks like before, but with a larger
> SECTION_SIZE.  Doing that preserves the ABI pretty nicely, I believe.
> 
> -- Dave
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
