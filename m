Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A104B6B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 17:08:07 -0400 (EDT)
Message-ID: <1377205598.10300.715.camel@misato.fc.hp.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 22 Aug 2013 15:06:38 -0600
In-Reply-To: <20130822202158.GD3490@mtj.dyndns.org>
References: <20130821153639.GA17432@htj.dyndns.org>
	 <1377113503.10300.492.camel@misato.fc.hp.com>
	 <20130821195410.GA2436@htj.dyndns.org>
	 <1377116968.10300.514.camel@misato.fc.hp.com>
	 <20130821204041.GC2436@htj.dyndns.org>
	 <1377124595.10300.594.camel@misato.fc.hp.com>
	 <20130822033234.GA2413@htj.dyndns.org>
	 <1377186729.10300.643.camel@misato.fc.hp.com>
	 <20130822183130.GA3490@mtj.dyndns.org>
	 <1377202292.10300.693.camel@misato.fc.hp.com>
	 <20130822202158.GD3490@mtj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, 2013-08-22 at 16:21 -0400, Tejun Heo wrote:
> On Thu, Aug 22, 2013 at 02:11:32PM -0600, Toshi Kani wrote:
> > It's too late for the kernel image itself, but it prevents allocating
> > kernel memory from movable ranges after that.  I'd say it solves a half
> > of the issue this time.
> 
> That works if such half solution eventually leads to the full
> solution.  This is just a distraction.  You are already too late in
> the boot sequence.  It doesn't even qualify as a half solution.  It's
> like obsessing about a speck on your shirt without your trousers on.
> If you want to solve this, do that from a place where it actually is
> solvable.

Since some node(s) won't be ejectable, this solution is reasonable as
the first step.  I do not think it is a distraction.  I view your
suggestion as a distraction of supporting local page tables, though.

> > > > Also, how do you support local page tables without pursing SRAT early?
> > > 
> > > Does it even matter with huge mappings?  It's gonna be contained in a
> > > single page anyway, right?
> > 
> > Are the huge mappings always used?  We cannot force user programs to use
> > huge pages, can we?
> 
> Everything is a trade-off.  Should we do all this just to support the
> off chance someone tries to use memory hotplug on a machine which
> doesn't support huge mapping when virtually all CPUs on market
> supports it?

Local page table and memory hotplug are two separate things.  That is,
local page tables can be supported on all NUMA platforms without hotplug
support.  Are you sure huge mapping will solve everything for all types
of applications, and therefore local page tables won't be needed at all?

> > As for the maintainability, I am far more concerned with your suggestion
> > of having a separate page table init code when SRAT is used.  This kind
> > of divergence is a recipe of breakage.
> 
> I don't buy that.  The only thing which needs to change is the
> directionality of allocation and we probably don't even need to do
> that if huge mapping is in use.

When someone changes the page table init code, who will test it with the
special allocation code?

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
