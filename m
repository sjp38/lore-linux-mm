Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D932F6B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 18:38:03 -0400 (EDT)
Message-ID: <1377124595.10300.594.camel@misato.fc.hp.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 21 Aug 2013 16:36:35 -0600
In-Reply-To: <20130821204041.GC2436@htj.dyndns.org>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
	 <20130821130647.GB19286@mtj.dyndns.org> <5214D60A.2090309@gmail.com>
	 <20130821153639.GA17432@htj.dyndns.org>
	 <1377113503.10300.492.camel@misato.fc.hp.com>
	 <20130821195410.GA2436@htj.dyndns.org>
	 <1377116968.10300.514.camel@misato.fc.hp.com>
	 <20130821204041.GC2436@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello Tejun,

On Wed, 2013-08-21 at 16:40 -0400, Tejun Heo wrote:
> On Wed, Aug 21, 2013 at 02:29:28PM -0600, Toshi Kani wrote:
> > Platforms vendors (which care Linux) need to support the existing Linux
> > features.  This means that they have to implement legacy interfaces on
> > x86 until the kernel supports an alternative method.  For instance, some
> > platforms are legacy-free and do not have legacy COM ports.  These ACPI
> > tables were defined so that non-legacy COM ports can be described and
> > informed to the OS.  Without this support, such platforms may have to
> > emulate the legacy COM ports for Linux, or drop Linux support.
> 
> Are you seriously saying that vendors are gonna drop linux support for
> lacking ACPI earlyprintk support?  Please...

earlyprintk is an example of the issues.  The point is that vendors are
required to support legacy stuff for Linux.

> Please take a look at the existing earlyprintk code and how compact
> and self-contained they are.  If you want to add ACPI earlyprintk, do
> similar stuff.  Forget about firmware blob override from initrd or
> ACPICA.  Just implement the bare minimum to get the thing working.  Do
> not add dependency to large body of code from earlyboot.  It's a bad
> idea through and through.

I am not saying that ACPI earlyprintk must be available at exactly the
same point.  How early it can reasonably be is a subject of discussion.

> > I think the kernel boot-up sequence should be designed in such a way
> > that can support legacy-free and/or NUMA platforms properly.
> 
> Blanket statements like the above don't mean much.  There are many
> separate stages of boot and you're talking about one of the very first
> stages where we traditionally have always depended upon only the very
> bare minimum of the platform both in hardware itself and configuration
> information.  We've been doing that for *very* good reasons.  If you
> screw up there, it's mighty tricky to figure out what went wrong
> especially on the machines that you can't physically kick.  You're now
> suggesting to add whole ACPI parsing including overloading from initrd
> into that stage with pretty weak rationale.

I agree that ACPI is rather complicated stuff.  But in my experience,
the majority complication comes from ACPI namespace and methods, not
from ACPI tables.  Do you really think ACPI table init is that risky?  I
consider ACPI tables are part of the minimum config info, esp. for
legacy-free platforms.

> Seriously, if you want ACPI based earlyprintk, implement it in a
> discrete minimal code which is easy to verify and won't get affected
> when the rest of ACPI machinery is updated.  We really don't want
> earlyboot to fail because someone screwed up ACPI or initrd handling.

earlyprintk is just another example to this SRAT issue.  The local page
table is yet another example.  My hope here is for us to be able to
utilize ACPI tables properly without hitting this kind of ordering
issues again and again, which requires considerable time & effort to
address.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
