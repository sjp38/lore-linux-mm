Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 09C476B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 16:47:32 -0400 (EDT)
Message-ID: <520BECDF.8060501@sr71.net>
Date: Wed, 14 Aug 2013 13:47:27 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] drivers: base: dynamic memory block creation
References: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1376508705-3188-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/14/2013 12:31 PM, Seth Jennings wrote:
> There was a significant amount of refactoring to allow for this but
> IMHO, the code is much easier to understand now.
...
>  drivers/base/memory.c  | 248 +++++++++++++++++++++++++++++++++++++------------
>  include/linux/memory.h |   1 -
>  2 files changed, 188 insertions(+), 61 deletions(-)

Adding 120 lines of code made it easier to understand? ;)

> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 2b7813e..392ccd3 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -30,7 +30,7 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
>  
>  #define MEMORY_CLASS_NAME	"memory"
>  
> -static int sections_per_block;
> +static int sections_per_block __read_mostly;
>  
>  static inline int base_memory_block_id(int section_nr)
>  {
> @@ -47,6 +47,9 @@ static struct bus_type memory_subsys = {
>  	.offline = memory_subsys_offline,
>  };
>  
> +static unsigned long *memblock_present;
> +static bool largememory_enable __read_mostly;

How would you see this getting used in practice?  Are you just going to
set this by default on ppc?  Or, would you ask the distros to put it on
the command-line by default?  Would it only affect machines larger than
a certain size?

This approach breaks the ABI, right?.  An existing tool would not work
with this patch (plus boot option) since it would not know how to
show/hide things.  It lets _part_ of those existing tools get reused
since they only have to be taught how to show/hide things.

I'd find this really intriguing if you found a way to keep even the old
tools working.  Instead of having an explicit show/hide, why couldn't
you just create the entries on open(), for instance?

>  int register_memory_notifier(struct notifier_block *nb)
> @@ -565,16 +568,13 @@ static const struct attribute_group *memory_memblk_attr_groups[] = {
>  static
>  int register_memory(struct memory_block *memory)
>  {
> -	int error;
> -
>  	memory->dev.bus = &memory_subsys;
>  	memory->dev.id = memory->start_section_nr / sections_per_block;
>  	memory->dev.release = memory_block_release;
>  	memory->dev.groups = memory_memblk_attr_groups;
>  	memory->dev.offline = memory->state == MEM_OFFLINE;
>  
> -	error = device_register(&memory->dev);
> -	return error;
> +	return device_register(&memory->dev);
>  }

This kind of simplification could surely stand in its own patch.

>  static int init_memory_block(struct memory_block **memory,
> @@ -582,67 +582,72 @@ static int init_memory_block(struct memory_block **memory,
>  {
>  	struct memory_block *mem;
>  	unsigned long start_pfn;
> -	int scn_nr;
> -	int ret = 0;
> +	int scn_nr, ret, memblock_id;
>  
> +	*memory = NULL;
>  	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>  	if (!mem)
>  		return -ENOMEM;
>  
>  	scn_nr = __section_nr(section);
> +	memblock_id = base_memory_block_id(scn_nr);
>  	mem->start_section_nr =
>  			base_memory_block_id(scn_nr) * sections_per_block;
>  	mem->end_section_nr = mem->start_section_nr + sections_per_block - 1;
>  	mem->state = state;
> -	mem->section_count++;
>  	mutex_init(&mem->state_mutex);
>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>  	mem->phys_device = arch_get_memory_phys_device(start_pfn);
>  
>  	ret = register_memory(mem);
> +	if (ret) {
> +		kfree(mem);
> +		return ret;
> +	}
>  
>  	*memory = mem;
> -	return ret;
> +	return 0;
>  }

memblock_id doesn't appear to ever get used.  This also appears to
change the conventions about where the 'memory_block' is allocated and
freed.  It isn't immediately clear why it needed to be changed.

Looking at the rest, this _really_ needs to get refactored before it's
reviewable.

> +static ssize_t memory_present_show(struct device *dev,
> +				  struct device_attribute *attr, char *buf)
> +{
> +	int n_bits, ret;
> +
> +	n_bits = NR_MEM_SECTIONS / sections_per_block;
> +	ret = bitmap_scnlistprintf(buf, PAGE_SIZE - 2,
> +				memblock_present, n_bits);
> +	buf[ret++] = '\n';
> +	buf[ret] = '\0';
> +
> +	return ret;
> +}

Doesn't this break the one-value-per-file rule?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
