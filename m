Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B82336B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 12:27:51 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so2950466pab.40
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 09:27:51 -0700 (PDT)
Message-ID: <1381422249.24268.68.camel@misato.fc.hp.com>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 10 Oct 2013 10:24:09 -0600
In-Reply-To: <20131010153518.GB13276@htj.dyndns.org>
References: <5251F9AB.6000203@zytor.com> <525442A4.9060709@gmail.com>
	 <20131009164449.GG22495@htj.dyndns.org> <52558EEF.4050009@gmail.com>
	 <20131009192040.GA5592@mtj.dyndns.org>
	 <1381352311.5429.115.camel@misato.fc.hp.com>
	 <20131009211136.GH5592@mtj.dyndns.org>
	 <1381363135.5429.138.camel@misato.fc.hp.com>
	 <20131010010029.GA10900@mtj.dyndns.org>
	 <1381415809.24268.40.camel@misato.fc.hp.com>
	 <20131010153518.GB13276@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J .
 Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "imtangchen@gmail.com" <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello Tejun,

On Thu, 2013-10-10 at 11:35 -0400, Tejun Heo wrote:
 :
> > > Are firmware writers gonna be
> > > required to split SRAT entries into multiple sub-nodes to support it?
> > 
> > Yes, and that's part of the ACPI spec.  That's not something the OS
> > requests to do.  If a memory range has different attribute, firmware has
> > to put it in a separate entry.
> 
> I was referring to having to segment a contiguous hotplug memory area
> further to support finer granularity.  This is represented by separate
> mem devices rather than segmented SRAT entries, right?  Hmmm... so we
> should parse device nodes before setting up page tables?

Yes, a memory device object is the finest granularity of performing
memory hotplug on ACPI based platforms.  SRAT must be consistent with
the memory device object info, but its entry does not have to be
segmented by the device granularity.  It only needs to be segmented when
memory attribute is different.  For instance, SRAT may have a single
entry for Case A), but Case B) must have two separate entries.  In both
cases, MEMA & MEMB represent a contiguous memory range.

Case A) Both MEMA and MEMB devices are hotpluggable

 MEMA:  _CRS: 0x0000-0x0fff  _EJ0: hotpluggable
 MEMB:  _CRS: 0x1000-0x1fff  _EJ0: hotpluggable

 SRAT: 0x0000-0x1ffff hotpluggable

Case B) Only MEMB is hotpluggable

 MEMA:  _CRS: 0x0000-0x0fff
 MEMB:  _CRS: 0x1000-0x1fff  _EJ0: hotpluggable

 SRAT: 0x0000-0x0fff
       0x1000-0x1fff  hotpluggable

> > SRAT and _EJ0 method are the only interfaces that define ejectability in
> > the standard spec.  Are you suggesting us to change the e820 spec or not
> > to comply with the spec?  I do not think such approaches work.    
> 
> It's slower but standards get revised and updated over time.  Have no
> idea whether there'd be a sane way to do that for e820 tho.

I am familiar with the process.  Yes, it is slow, but most importantly,
it needs some standard group or company to actively maintain the spec in
order to update it.  I do not think e820 is in such state.

> > I think memory hotplug was originally implemented on ia64 with the node
> > granularity.  I share your concerns, but that's been done a long time
> > ago.  It's too late to complain the past.  This SRAT work is not
> > introducing such restriction.
> 
> We're going round and round.  You're saying that using SRAT isn't
> worse than what came before while failing to illustrate how committing
> to invasive changes would eventually lead to something better.  "it
> isn't worse" isn't much of an argument.

We did avoid moving up the ACPI table init function per your suggestion.
I guess I do not understand why you still concerned about using SRAT...

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
