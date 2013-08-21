Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id CA0B56B0032
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 16:40:46 -0400 (EDT)
Received: by mail-qe0-f49.google.com with SMTP id k5so579127qej.22
        for <linux-mm@kvack.org>; Wed, 21 Aug 2013 13:40:45 -0700 (PDT)
Date: Wed, 21 Aug 2013 16:40:41 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
Message-ID: <20130821204041.GC2436@htj.dyndns.org>
References: <1377080143-28455-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130821130647.GB19286@mtj.dyndns.org>
 <5214D60A.2090309@gmail.com>
 <20130821153639.GA17432@htj.dyndns.org>
 <1377113503.10300.492.camel@misato.fc.hp.com>
 <20130821195410.GA2436@htj.dyndns.org>
 <1377116968.10300.514.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377116968.10300.514.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello, Toshi.

On Wed, Aug 21, 2013 at 02:29:28PM -0600, Toshi Kani wrote:
> Platforms vendors (which care Linux) need to support the existing Linux
> features.  This means that they have to implement legacy interfaces on
> x86 until the kernel supports an alternative method.  For instance, some
> platforms are legacy-free and do not have legacy COM ports.  These ACPI
> tables were defined so that non-legacy COM ports can be described and
> informed to the OS.  Without this support, such platforms may have to
> emulate the legacy COM ports for Linux, or drop Linux support.

Are you seriously saying that vendors are gonna drop linux support for
lacking ACPI earlyprintk support?  Please...

Please take a look at the existing earlyprintk code and how compact
and self-contained they are.  If you want to add ACPI earlyprintk, do
similar stuff.  Forget about firmware blob override from initrd or
ACPICA.  Just implement the bare minimum to get the thing working.  Do
not add dependency to large body of code from earlyboot.  It's a bad
idea through and through.

> I think the kernel boot-up sequence should be designed in such a way
> that can support legacy-free and/or NUMA platforms properly.

Blanket statements like the above don't mean much.  There are many
separate stages of boot and you're talking about one of the very first
stages where we traditionally have always depended upon only the very
bare minimum of the platform both in hardware itself and configuration
information.  We've been doing that for *very* good reasons.  If you
screw up there, it's mighty tricky to figure out what went wrong
especially on the machines that you can't physically kick.  You're now
suggesting to add whole ACPI parsing including overloading from initrd
into that stage with pretty weak rationale.

Seriously, if you want ACPI based earlyprintk, implement it in a
discrete minimal code which is easy to verify and won't get affected
when the rest of ACPI machinery is updated.  We really don't want
earlyboot to fail because someone screwed up ACPI or initrd handling.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
