Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id B6EEA6B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 14:31:39 -0400 (EDT)
Received: by mail-qe0-f50.google.com with SMTP id s14so1316050qeb.37
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 11:31:38 -0700 (PDT)
Date: Thu, 22 Aug 2013 14:31:30 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
Message-ID: <20130822183130.GA3490@mtj.dyndns.org>
References: <20130821130647.GB19286@mtj.dyndns.org>
 <5214D60A.2090309@gmail.com>
 <20130821153639.GA17432@htj.dyndns.org>
 <1377113503.10300.492.camel@misato.fc.hp.com>
 <20130821195410.GA2436@htj.dyndns.org>
 <1377116968.10300.514.camel@misato.fc.hp.com>
 <20130821204041.GC2436@htj.dyndns.org>
 <1377124595.10300.594.camel@misato.fc.hp.com>
 <20130822033234.GA2413@htj.dyndns.org>
 <1377186729.10300.643.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377186729.10300.643.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Thu, Aug 22, 2013 at 09:52:09AM -0600, Toshi Kani wrote:
> I understand that you are concerned about stability of the ACPI stuff,
> which I think is a valid point, but most of (if not all) of the
> ACPI-related issues come from ACPI namespace/methods, which is a very
> different thing.  Please do not mix up those two.  The ACPI

I have no objection to implementing self-conftained earlyprintk
support.  If that's all you want to do, please go ahead but do not
pull in initrd override or ACPICA into it.

> namespace/methods stuff remains the same and continues to be initialized
> at very late in the boot sequence.
> 
> What's making the patchset complicated is acpi_initrd_override(), which
> is intended for developers and allows overwriting ACPI bits at their own
> risk.  This feature won't be used by regular users. 

Yeah, please forget about that in earlyboot.  It doesn't make any
sense to fiddle with initrd that early during boot.

> If you are referring the issue of kernel image location, it is a
> limitation in the current implementation, not a technical limitation.  I
> know other OS that supports movable memory and puts the kernel image
> into a movable memory with SRAT by changing the bootloader.

I'm not saying that problem shouldn't be solved.  I'm saying what you
guys are pushing doesn't help solving it at all.  It's too late in the
boot process.  It needs to be handled either by bootloader or earlier
kernel kexecing the actual one and super-early SRAT doens't help at
all in either case, so what's the point of pulling ACPI code in when
it doesn't contribute to solving the problem properly?

> Also, how do you support local page tables without pursing SRAT early?

Does it even matter with huge mappings?  It's gonna be contained in a
single page anyway, right?

> Initializing page tables on large systems may take a long time, and I do
> think that earlyprink needs to be available before that point.

Yeah, sure, implement it in *minimal* way which doesn't affect
anything if not explicitly enabled by kernel param like other
earlyprintks.  It doens't make any sense to add dependency to acpi
from early boot for that.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
