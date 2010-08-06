Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BAB936B02A8
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 14:50:44 -0400 (EDT)
Date: Fri, 6 Aug 2010 12:34:08 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests -
 second fully working version - once again
Message-ID: <20100806163408.GA8678@phenom.dumpdata.com>
References: <20100806111147.GA31683@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100806111147.GA31683@router-fw-old.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
To: Daniel Kiper <dkiper@net-space.pl>
Cc: jeremy@goop.org, stefano.stabellini@eu.citrix.com, linux-mm@kvack.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru
List-ID: <linux-mm.kvack.org>

On Fri, Aug 06, 2010 at 01:11:47PM +0200, Daniel Kiper wrote:
> Hi,
> 
> I am sending this e-mail once again because it probably
> has been lost in abyss of Xen-devel/LKLM list.
> 
> Here is the second version of memory hotplug support
> for Xen guests patch. This one cleanly applies to
> git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen.git
> repository, xen/memory-hotplug head.
> 
> Changes:
>   - /sys/devices/system/memory/probe interface has been removed;
>     /sys/devices/system/xen_memory/xen_memory0/{target,target_kb}
>     are much better (I forgot about them),
>   - most of the code have been moved to drivers/xen/balloon.c,
>   - this changes forced me to export hotadd_new_pgdat and
>     rollback_node_hotadd function from mm/memory_hotplug.c;
>     could it be accepted by mm/memory_hotplug.c maintainers ???
>   - PV on HVM mode is supported now; it was tested on
>     git://xenbits.xen.org/people/sstabellini/linux-pvhvm.git
>     repository, 2.6.34-pvhvm head,
>   - most of Jeremy suggestions have been applied.
> 
> On Wed, Jul 28, 2010 at 11:36:29AM +0400, Vasiliy G Tolstov wrote:
> [...]
> > Work's fine with opensuse 11.3 (dom0 and domU)
> 
> Thx.
> 
> On Thu, Jul 29, 2010 at 12:39:52PM -0700, Jeremy Fitzhardinge wrote:
> >  On 07/26/2010 05:41 PM, Daniel Kiper wrote:
> > >Hi,
> > >
> > >Currently there is fully working version.
> > >It has been tested on Xen Ver. 4.0.0 in PV
> > >guest i386/x86_64 with Linux kernel Ver. 2.6.32.16
> > >and Ver. 2.6.34.1. This patch cleanly applys
> > >to Ver. 2.6.34.1
> >
> > Thanks.  I've pushed this into xen.git as xen/memory-hotplug so people
> > can play with it more easily (but I haven't merged it into any of the
> > other branches yet).
> 
> Thx.
> 
> > >+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> > >+static inline unsigned long current_target(void)
> > >+{
> > >+	return balloon_stats.target_pages;
> >
> > Why does this need its own version?
> 
> Because original version return values not bigger
> then initial memory allocation which does not allow
> memory hotplug to function.
> 
> > >+int __ref xen_add_memory(int nid, u64 start, u64 size)
> > >+{
> > >+	pg_data_t *pgdat = NULL;
> > >+	int new_pgdat = 0, ret;
> > >+
> > >+	lock_system_sleep();
> > >+
> > >+	if (!node_online(nid)) {
> > >+		pgdat = hotadd_new_pgdat(nid, start);
> > >+		ret = -ENOMEM;
> > >+		if (!pgdat)
> > >+			goto out;
> > >+		new_pgdat = 1;
> > >+	}
> > >+
> > >+	/* call arch's memory hotadd */
> > >+	ret = arch_add_memory(nid, start, size);
> > >+
> > >+	if (ret<  0)
> > >+		goto error;
> > >+
> > >+	/* we online node here. we can't roll back from here. */
> > >+	node_set_online(nid);
> > >+
> > >+	if (new_pgdat) {
> > >+		ret = register_one_node(nid);
> > >+		/*
> > >+		 * If sysfs file of new node can't create, cpu on the node
> > >+		 * can't be hot-added. There is no rollback way now.
> > >+		 * So, check by BUG_ON() to catch it reluctantly..
> > >+		 */
> > >+		BUG_ON(ret);
> > >+	}
> >
> > This doesn't seem to be doing anything particularly xen-specific.
> 
> In general it could be generic however I do not know
> it will be useful for others. If this function would
> be accepted by mm/memory_hotplug.c maintainers we could
> move it there. I removed from original add_memory funtion
> resource allocation (and deallocation after error), which
> must be done before XENMEM_populate_physmap in Xen. xen_add_memory
> is called after physmap is fully populated.
> 
> If you have a questions please drop me a line.



Can you repost a patch that is on top of a virgin tree please?


> 
> Daniel
> 
> Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
> ---
>  arch/x86/Kconfig               |    2 +-
>  drivers/base/memory.c          |   23 ---
>  drivers/xen/Kconfig            |    2 +-
>  drivers/xen/balloon.c          |  416 ++++++++++++++++++++++------------------
>  include/linux/memory_hotplug.h |   10 +-
>  include/xen/balloon.h          |    6 -
>  mm/Kconfig                     |    9 -
>  mm/memory_hotplug.c            |  146 +--------------
>  8 files changed, 240 insertions(+), 374 deletions(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 38434da..beb1aa7 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1273,7 +1273,7 @@ config ARCH_SELECT_MEMORY_MODEL
>  	depends on ARCH_SPARSEMEM_ENABLE
>  
>  config ARCH_MEMORY_PROBE
> -	def_bool y
> +	def_bool X86_64 && !XEN


Why?
>  	depends on MEMORY_HOTPLUG
>  
>  config ILLEGAL_POINTER_VALUE
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 709457b..933442f 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -27,14 +27,6 @@
>  #include <asm/atomic.h>
>  #include <asm/uaccess.h>
>  
> -#ifdef CONFIG_XEN_MEMORY_HOTPLUG
> -#include <xen/xen.h>
> -#endif
> -
> -#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
> -#include <xen/balloon.h>
> -#endif
> -
>  #define MEMORY_CLASS_NAME	"memory"
>  
>  static struct sysdev_class memory_sysdev_class = {
> @@ -223,10 +215,6 @@ memory_block_action(struct memory_block *mem, unsigned long action)
>  		case MEM_ONLINE:
>  			start_pfn = page_to_pfn(first_page);
>  			ret = online_pages(start_pfn, PAGES_PER_SECTION);
> -#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
> -			if (xen_domain() && !ret)
> -				balloon_update_stats(PAGES_PER_SECTION);
> -#endif
>  			break;
>  		case MEM_OFFLINE:
>  			mem->state = MEM_GOING_OFFLINE;
> @@ -237,10 +225,6 @@ memory_block_action(struct memory_block *mem, unsigned long action)
>  				mem->state = old_state;
>  				break;
>  			}
> -#if defined(CONFIG_XEN_MEMORY_HOTPLUG) && defined(CONFIG_XEN_BALLOON)
> -			if (xen_domain())
> -				balloon_update_stats(-PAGES_PER_SECTION);
> -#endif
>  			break;
>  		default:
>  			WARN(1, KERN_WARNING "%s(%p, %ld) unknown action: %ld\n",
> @@ -357,13 +341,6 @@ memory_probe_store(struct class *class, struct class_attribute *attr,
>  
>  	phys_addr = simple_strtoull(buf, NULL, 0);
>  
> -#ifdef CONFIG_XEN_MEMORY_HOTPLUG
> -	if (xen_domain()) {
> -		ret = xen_memory_probe(phys_addr);
> -		return ret ? ret : count;
> -	}
> -#endif
> -
>  	nid = memory_add_physaddr_to_nid(phys_addr);
>  	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
>  
> diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
> index 9713048..4f35eaf 100644
> --- a/drivers/xen/Kconfig
> +++ b/drivers/xen/Kconfig
> @@ -11,8 +11,8 @@ config XEN_BALLOON
>  
>  config XEN_BALLOON_MEMORY_HOTPLUG
>  	bool "Xen memory balloon driver with memory hotplug support"
> -	depends on EXPERIMENTAL && XEN_BALLOON && MEMORY_HOTPLUG
>  	default n
> +	depends on XEN_BALLOON && MEMORY_HOTPLUG
>  	help
>  	  Xen memory balloon driver with memory hotplug support allows expanding
>  	  memory available for the system above limit declared at system startup.
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index f80bba0..31edc26 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -45,6 +45,8 @@
>  #include <linux/list.h>
>  #include <linux/sysdev.h>
>  #include <linux/gfp.h>
> +#include <linux/memory.h>
> +#include <linux/suspend.h>
>  
>  #include <asm/page.h>
>  #include <asm/pgalloc.h>
> @@ -62,10 +64,6 @@
>  #include <xen/features.h>
>  #include <xen/page.h>
>  
> -#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> -#include <linux/memory.h>
> -#endif
> -
>  #define PAGES2KB(_p) ((_p)<<(PAGE_SHIFT-10))
>  
>  #define BALLOON_CLASS_NAME "xen_memory"
> @@ -199,6 +197,196 @@ static inline unsigned long current_target(void)
>  {
>  	return balloon_stats.target_pages;
>  }
> +
> +static inline u64 is_memory_resource_reserved(void)
> +{
> +	return balloon_stats.hotplug_start_paddr;
> +}
> +
> +/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
> +static int __ref xen_add_memory(int nid, u64 start, u64 size)
> +{
> +	pg_data_t *pgdat = NULL;
> +	int new_pgdat = 0, ret;
> +
> +	lock_system_sleep();
> +
> +	if (!node_online(nid)) {
> +		pgdat = hotadd_new_pgdat(nid, start);
> +		ret = -ENOMEM;
> +		if (!pgdat)
> +			goto out;
> +		new_pgdat = 1;
> +	}
> +
> +	/* call arch's memory hotadd */
> +	ret = arch_add_memory(nid, start, size);
> +
> +	if (ret < 0)
> +		goto error;
> +
> +	/* we online node here. we can't roll back from here. */
> +	node_set_online(nid);
> +
> +	if (new_pgdat) {
> +		ret = register_one_node(nid);
> +		/*
> +		 * If sysfs file of new node can't create, cpu on the node
> +		 * can't be hot-added. There is no rollback way now.
> +		 * So, check by BUG_ON() to catch it reluctantly..
> +		 */
> +		BUG_ON(ret);
> +	}
> +
> +	goto out;
> +
> +error:
> +	/* rollback pgdat allocation */
> +	if (new_pgdat)
> +		rollback_node_hotadd(nid, pgdat);
> +
> +out:
> +	unlock_system_sleep();
> +	return ret;
> +}
> +
> +static int allocate_additional_memory(unsigned long nr_pages)
> +{
> +	long rc;
> +	resource_size_t r_min, r_size;
> +	struct resource *r;
> +	struct xen_memory_reservation reservation = {
> +		.address_bits = 0,
> +		.extent_order = 0,
> +		.domid        = DOMID_SELF
> +	};
> +	unsigned long flags, i, pfn;
> +
> +	if (nr_pages > ARRAY_SIZE(frame_list))
> +		nr_pages = ARRAY_SIZE(frame_list);
> +
> +	spin_lock_irqsave(&balloon_lock, flags);
> +
> +	if (!is_memory_resource_reserved()) {
> +
> +		/*
> +		 * Look for first unused memory region starting at page
> +		 * boundary. Skip last memory section created at boot time
> +		 * becuase it may contains unused memory pages with PG_reserved
> +		 * bit not set (online_pages require PG_reserved bit set).
> +		 */
> +
> +		r = kzalloc(sizeof(struct resource), GFP_KERNEL);



You are holding a spinlock here. Kzalloc can sleep
> +
> +		if (!r) {
> +			rc = -ENOMEM;
> +			goto out;
> +		}
> +
> +		r->name = "System RAM";
> +		r->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +		r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));
> +		r_size = (balloon_stats.target_pages - balloon_stats.current_pages) << PAGE_SHIFT;
> +
> +		rc = allocate_resource(&iomem_resource, r, r_size, r_min,
> +					ULONG_MAX, PAGE_SIZE, NULL, NULL);



Ditto here. This can sleep and with a spinlock in place. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
