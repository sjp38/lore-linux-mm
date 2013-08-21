Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 841A76B0033
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 15:33:13 -0400 (EDT)
Message-ID: <1377113503.10300.492.camel@misato.fc.hp.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 21 Aug 2013 13:31:43 -0600
In-Reply-To: <20130821153639.GA17432@htj.dyndns.org>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
	 <20130821130647.GB19286@mtj.dyndns.org> <5214D60A.2090309@gmail.com>
	 <20130821153639.GA17432@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Wed, 2013-08-21 at 11:36 -0400, Tejun Heo wrote:
> Hello,
> 
> On Wed, Aug 21, 2013 at 11:00:26PM +0800, Zhang Yanfei wrote:
> > In current boot order, before we get the SRAT, we have a big consumer of early
> > allocations: we are setting up the page table in top-down (The idea was proposed by HPA,
> > Link: https://lkml.org/lkml/2012/10/4/701). That said, this kind of page table
> > setup will make the page tables as high as possible in memory, since memory at low 
> > addresses is precious (for stupid DMA devices, for things like  kexec/kdump, and so on.)
> 
> With huge mappings, they are fairly small, right?  And this whole
> thing needs a kernel param anyway at this point, so the allocation
> direction can be made dependent on that or huge mapping availability
> and, even with 4k mappings, we aren't talking about gigabytes of
> memory, are we?
> 
> > So if we are trying to make early allocations close to kernel image, we should
> > rewrite the way we are setting up page table totally. That is not a easy thing
> > to do.
> 
> It has been a while since I looked at the code so can you please
> elaborate why that is not easy?  It's pretty simple conceptually.
> 
> > * For memory hotplug, we need ACPI SRAT at early time to be aware of which memory
> >   ranges are hotpluggable, and tell the kernel to try to stay away from hotpluggable
> >   nodes.
> > 
> > This one is the current requirement of us but may be very helpful for future change:
> > 
> > * As suggested by Yinghai, we should allocate page tables in local node. This also
> >   needs SRAT before direct mapping page tables are setup.
> 
> Does this even matter for huge mappings?
> 
> > * As mentioned by Toshi Kani <toshi.kani@hp.com>, ACPI SCPR/DBGP/DBG2 tables
> >   allow the OS to initialize serial console/debug ports at early boot time. The
> >   earlier it can be initialized, the better this feature will be.  These tables
> >   are not currently used by Linux due to a licensing issue, but it could be
> >   addressed some time soon.
> > 
> > So we decided to firstly make ACPI override earlier and use BRK (this is obviously
> > near the kernel image range) to store the found ACPI tables.
> 
> I don't know.  The whole effort seems way overcomplicated compared to
> the benefits it would bring.  For NUMA memory hotunplug, what's the
> point of doing all this when the kernel doesn't have any control over
> where its image is gonna be?  Some megabytes at the tail aren't gonna
> make a huge difference and if you wanna do this properly, you need to
> determine the load address of the kernel considering the node
> boundaries and hotpluggability of each node, which has to happen
> before the early kernel boot code executes.  And if there's a code
> piece which does that, that might as well place the kernel image such
> that extra allocation afterwards doesn't interfere with memory
> hotunplugging.
> 
> It looks like a lot of code changes for a mechanism which doesn't seem
> all that useful.  This code is already too late in boot sequence to be
> a proper solution so I don't see the point in pushing the coverage to
> the maximum from here.  It's kinda silly.
> 
> The last point - early init of debug facility - makes some sense but
> again how extra coverage are we talking about?  The code path between
> the two points is fairly short and the change doesn't come free.  It
> means we add more fragile firmware-specific code path before the
> execution environment is stable and get to do things like traveling
> the same code paths multiple times in different environments.  Doesn't
> seem like a win.  We want to reach stable execution environment as
> soon as possible.  Shoving whole more logic before that in the name of
> "earlier debugging" doesn't make a lot of sense.

Well, there is reason why we have earlyprintk feature today.  So, let's
not debate on this feature now.  There was previous attempt to support
this feature with ACPI tables below.  As described, it had the same
ordering issue.

https://lkml.org/lkml/2012/10/8/498

There is a basic problem that when we try to use ACPI tables that
extends or replaces legacy interfaces (ex. SRAT extending e820), we hit
this ordering issue because ACPI is not available as early as the legacy
interfaces.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
