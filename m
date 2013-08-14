Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E8A556B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:15:01 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Wed, 14 Aug 2013 15:15:01 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 93AA83E40030
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:14:35 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7ELExeR108308
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:14:59 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7ELEwnl023715
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 15:14:59 -0600
Date: Wed, 14 Aug 2013 16:14:54 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
Message-ID: <20130814211454.GA17423@variantweb.net>
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <520BECDF.8060501@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520BECDF.8060501@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 14, 2013 at 01:47:27PM -0700, Dave Hansen wrote:
> On 08/14/2013 12:31 PM, Seth Jennings wrote:
> > There was a significant amount of refactoring to allow for this but
> > IMHO, the code is much easier to understand now.
> ...
> >  drivers/base/memory.c  | 248 +++++++++++++++++++++++++++++++++++++------------
> >  include/linux/memory.h |   1 -
> >  2 files changed, 188 insertions(+), 61 deletions(-)
> 
> Adding 120 lines of code made it easier to understand? ;)

Currently, the memory block abstraction is bolted onto the section
layout pretty loosely. The add_memory_section() function is
particularly bad as the memory block is passed from call to call from
memory_dev_init() and there was a lot of logic surrounding, does the
memory block already exist and ifs about whether we were adding it at
boot or the result of hotplug.

Also because we were releasing the mem_sysfs_mutex after each section
add we were having to do a get/put on the dev.kobj every time.  That
isn't even actually done properly right now as the memory block is not
looked up under lock each time a ref is taken.  This hasn't been a
problem since that is only done during boot when memory blocks can't
be concurrently unregistered.  But still.  It speaks to the complexity.

This patch introduces add_memory_block() which helps with the delineation
of sections and blocks and makes the code easier to understand IMHO.

> 
> > diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> > index 2b7813e..392ccd3 100644
> > --- a/drivers/base/memory.c
> > +++ b/drivers/base/memory.c
> > @@ -30,7 +30,7 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
> >  
> >  #define MEMORY_CLASS_NAME	"memory"
> >  
> > -static int sections_per_block;
> > +static int sections_per_block __read_mostly;
> >  
> >  static inline int base_memory_block_id(int section_nr)
> >  {
> > @@ -47,6 +47,9 @@ static struct bus_type memory_subsys = {
> >  	.offline = memory_subsys_offline,
> >  };
> >  
> > +static unsigned long *memblock_present;
> > +static bool largememory_enable __read_mostly;
> 
> How would you see this getting used in practice?  Are you just going to
> set this by default on ppc?  Or, would you ask the distros to put it on
> the command-line by default?  Would it only affect machines larger than
> a certain size?

It would not be on by default, but for people running into the problem
on their large memory machines, we could enable this after verifying
that any tools that operate on the memory block configs are "dynamic
memory block aware"

> 
> This approach breaks the ABI, right?.

ABI... API... it does modify an expectation of current userspace tools.

> An existing tool would not work
> with this patch (plus boot option) since it would not know how to
> show/hide things.  It lets _part_ of those existing tools get reused
> since they only have to be taught how to show/hide things.
> 
> I'd find this really intriguing if you found a way to keep even the old
> tools working.  Instead of having an explicit show/hide, why couldn't
> you just create the entries on open(), for instance?

Nathan and I talked about this and I'm not sure if sysfs would support
such a thing, i.e. memory block creation when someone tried to cd into
the memory block device config.  I wouldn't know where to start on that.

> 
> >  int register_memory_notifier(struct notifier_block *nb)
> > @@ -565,16 +568,13 @@ static const struct attribute_group *memory_memblk_attr_groups[] = {
> >  static
> >  int register_memory(struct memory_block *memory)
> >  {
> > -	int error;
> > -
> >  	memory->dev.bus = &memory_subsys;
> >  	memory->dev.id = memory->start_section_nr / sections_per_block;
> >  	memory->dev.release = memory_block_release;
> >  	memory->dev.groups = memory_memblk_attr_groups;
> >  	memory->dev.offline = memory->state == MEM_OFFLINE;
> >  
> > -	error = device_register(&memory->dev);
> > -	return error;
> > +	return device_register(&memory->dev);
> >  }
> 
> This kind of simplification could surely stand in its own patch.

Yes.

> 
> >  static int init_memory_block(struct memory_block **memory,
> > @@ -582,67 +582,72 @@ static int init_memory_block(struct memory_block **memory,
> >  {
> >  	struct memory_block *mem;
> >  	unsigned long start_pfn;
> > -	int scn_nr;
> > -	int ret = 0;
> > +	int scn_nr, ret, memblock_id;
> >  
> > +	*memory = NULL;
> >  	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
> >  	if (!mem)
> >  		return -ENOMEM;
> >  
> >  	scn_nr = __section_nr(section);
> > +	memblock_id = base_memory_block_id(scn_nr);
> >  	mem->start_section_nr =
> >  			base_memory_block_id(scn_nr) * sections_per_block;
> >  	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
> >  	mem->state = state;
> > -	mem->section_count++;
> >  	mutex_init(&mem->state_mutex);
> >  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
> >  	mem->phys_device = arch_get_memory_phys_device(start_pfn);
> >  
> >  	ret = register_memory(mem);
> > +	if (ret) {
> > +		kfree(mem);
> > +		return ret;
> > +	}
> >  
> >  	*memory = mem;
> > -	return ret;
> > +	return 0;
> >  }
> 
> memblock_id doesn't appear to ever get used.  This also appears to
> change the conventions about where the 'memory_block' is allocated and
> freed.  It isn't immediately clear why it needed to be changed.
> 
> Looking at the rest, this _really_ needs to get refactored before it's
> reviewable.

Yes, this doesn't review well in diff format, unfortunately.   I guess
I'll need to break this down into steps that rewrite the same code
blocks from step to step.

> 
> > +static ssize_t memory_present_show(struct device *dev,
> > +				  struct device_attribute *attr, char *buf)
> > +{
> > +	int n_bits, ret;
> > +
> > +	n_bits = NR_MEM_SECTIONS / sections_per_block;
> > +	ret = bitmap_scnlistprintf(buf, PAGE_SIZE - 2,
> > +				memblock_present, n_bits);
> > +	buf[ret++] = '\n';
> > +	buf[ret] = '\0';
> > +
> > +	return ret;
> > +}
> 
> Doesn't this break the one-value-per-file rule?

I didn't know there was such a rule but it might. Is there any
acceptable way to express a ranges of values.  I would just do a
"last_memblock_id" but the range can have holes.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
