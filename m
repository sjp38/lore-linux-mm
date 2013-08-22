Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 5DB796B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 11:53:38 -0400 (EDT)
Message-ID: <1377186729.10300.643.camel@misato.fc.hp.com>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 22 Aug 2013 09:52:09 -0600
In-Reply-To: <20130822033234.GA2413@htj.dyndns.org>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
	 <20130821130647.GB19286@mtj.dyndns.org> <5214D60A.2090309@gmail.com>
	 <20130821153639.GA17432@htj.dyndns.org>
	 <1377113503.10300.492.camel@misato.fc.hp.com>
	 <20130821195410.GA2436@htj.dyndns.org>
	 <1377116968.10300.514.camel@misato.fc.hp.com>
	 <20130821204041.GC2436@htj.dyndns.org>
	 <1377124595.10300.594.camel@misato.fc.hp.com>
	 <20130822033234.GA2413@htj.dyndns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello Tejun,

On Wed, 2013-08-21 at 23:32 -0400, Tejun Heo wrote:
> On Wed, Aug 21, 2013 at 04:36:35PM -0600, Toshi Kani wrote:
> > I agree that ACPI is rather complicated stuff.  But in my experience,
> > the majority complication comes from ACPI namespace and methods, not
> > from ACPI tables.  Do you really think ACPI table init is that risky?  I
> > consider ACPI tables are part of the minimum config info, esp. for
> > legacy-free platforms.
> 
> It's just that we're talking about the very first stage of boot.  We
> really don't do much there and pulling in ACPI code into that stage is
> a lot by comparison.  If that's gonna happen, it needs pretty strong
> justification.

It moves up the ACPI table init code, which itself is simple.  And ACPI
tables are defined to be pursed at early boot-time, which is why they
exist in addition to ACPI namespace/methods.  They are similar to EFI
memory table.  Firmware publishes tables in one way or the other.

I understand that you are concerned about stability of the ACPI stuff,
which I think is a valid point, but most of (if not all) of the
ACPI-related issues come from ACPI namespace/methods, which is a very
different thing.  Please do not mix up those two.  The ACPI
namespace/methods stuff remains the same and continues to be initialized
at very late in the boot sequence.

What's making the patchset complicated is acpi_initrd_override(), which
is intended for developers and allows overwriting ACPI bits at their own
risk.  This feature won't be used by regular users. 

> > earlyprintk is just another example to this SRAT issue.  The local page
> > table is yet another example.  My hope here is for us to be able to
> > utilize ACPI tables properly without hitting this kind of ordering
> > issues again and again, which requires considerable time & effort to
> > address.
> 
> So, the two things brought up at this point are early parsing of SRAT,
> which can't really solve the problem at hand anyway, 

If you are referring the issue of kernel image location, it is a
limitation in the current implementation, not a technical limitation.  I
know other OS that supports movable memory and puts the kernel image
into a movable memory with SRAT by changing the bootloader.

Also, how do you support local page tables without pursing SRAT early?

> and earlyprintk
> which should be implemented in minimal way which is not activated
> unless specifically enabled with earlyprintk boot param.  Neither
> seems to justify pulling in full ACPI into early boot, right?

Initializing page tables on large systems may take a long time, and I do
think that earlyprink needs to be available before that point.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
