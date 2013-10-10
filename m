Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 965766B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 18:19:54 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so3252556pdi.5
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 15:19:54 -0700 (PDT)
Received: by mail-qa0-f52.google.com with SMTP id k4so156706qaq.4
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 15:19:51 -0700 (PDT)
Date: Thu, 10 Oct 2013 18:19:47 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
Message-ID: <20131010221947.GA14030@mtj.dyndns.org>
References: <20131010010029.GA10900@mtj.dyndns.org>
 <1381415809.24268.40.camel@misato.fc.hp.com>
 <20131010153518.GB13276@htj.dyndns.org>
 <1381422249.24268.68.camel@misato.fc.hp.com>
 <20131010164623.GD13276@htj.dyndns.org>
 <1381423840.24268.70.camel@misato.fc.hp.com>
 <20131010165522.GE13276@htj.dyndns.org>
 <1381424390.26234.1.camel@misato.fc.hp.com>
 <5256E01B.9050802@zytor.com>
 <1381432630.26234.6.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381432630.26234.6.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "imtangchen@gmail.com" <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Thu, Oct 10, 2013 at 01:17:10PM -0600, Toshi Kani wrote:
> In earlier discussions, Tejun pointed out that huge mappings dismiss the
> benefit of local page tables.
> 
> https://lkml.org/lkml/2013/8/23/245

This is going nowhere.  If we're assuming use of large mappings, none
of this matters.  The pagetable is gonna be small no matter what and
locating it near kernel image doesn't really impact anything whether
hotplug is gonna be per-node or per-device.  Short of the ability to
relocate kernel image itself, parsing or not parsing SRAT early
doesn't lead to anything of consequence.  What are we even arguing
about?  That's what bothers me about this effort.  Nobody seems to
have actually thought it through.

To summarize,

* To do local page table, full ACPI device hierarchy should be parsed.

* Local page table is pointless if you assume huge mappings and the
  plan is to assume huge mappings so that only SRAT is necessary
  before allocating page tables.

* But if you assume huge mappings, it doesn't make material difference
  whether the page table is after the kernel image or near the top of
  non-hotpluggable memory.  It's tiny anyway.

* So, what's the point of pulling SRAT parsing into early boot?  If we
  assume huge mappings, it doesn't make any material difference for
  either per-node or per-device unplug - it's tiny.  If we don't
  assume huge mappings, we're talking about parsing full ACPI device
  tree before building pagetable.  Let's say that's something we can
  accept.  Is the benefit worthwhile?  Doing all that just for debug
  configs?  Is that something people are actually arguing for?  Sure,
  if it works without too much effort, it's great, but do we really
  wanna do all that and update page table allocation so that
  everything is per-device just to support debug configs, for real?

I'm not asking for super concrete plan but right now people working on
this don't seem to have much idea of what the goals are or why they
want certain things and the discussions naturally repeat themselves.
FWIW, I'm getting to a point where I think nacking the whole series is
the right thing to do here.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
