Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DA4306B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 16:00:04 -0400 (EDT)
Received: by mail-gh0-f169.google.com with SMTP id r1so3635036ghr.28
        for <linux-mm@kvack.org>; Mon, 24 Jun 2013 13:00:03 -0700 (PDT)
Date: Mon, 24 Jun 2013 12:59:56 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
Message-ID: <20130624195956.GG1918@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130618020357.GZ32663@mtj.dyndns.org>
 <51BFF464.809@cn.fujitsu.com>
 <20130618172129.GH2767@htj.dyndns.org>
 <51C298B2.9060900@cn.fujitsu.com>
 <20130620061719.GA16114@mtj.dyndns.org>
 <51C41AB4.9070500@cn.fujitsu.com>
 <20130621182511.GA1763@htj.dyndns.org>
 <51C7C258.8070906@cn.fujitsu.com>
 <51C7F4A3.6060307@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51C7F4A3.6060307@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: yinghai@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Tang.

On Mon, Jun 24, 2013 at 03:26:27PM +0800, Tang Chen wrote:
> >My box is x86_64, and the memory layout is:
> >[ 0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
> >[ 0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x307ffffff]
> >[ 0.000000] SRAT: Node 1 PXM 2 [mem 0x308000000-0x587ffffff] Hot Pluggable
> >[ 0.000000] SRAT: Node 2 PXM 3 [mem 0x588000000-0x7ffffffff] Hot Pluggable
> >
> >
> >I marked ranges reserved by memblock before we parse SRAT with flag 0x4.
> >There are about 14 ranges which is persistent after boot.

You can also record the caller address or short backtrace with each
allocation (maybe controlled by some debug parameter).  It'd be a nice
capability to keep around anyway.

> This range is allocated by init_mem_mapping() in setup_arch(), it calls
> alloc_low_pages() to allocate pagetable pages.
> 
> I think if we do the local device pagetable, we can solve this problem
> without any relocation.

Yeah, I really can't think of many places which would allocate
permanent piece of memory before memblock is fully initialized.  Just
in case I wasn't clear, I don't have anything fundamentally against
reordering operations if that's cleaner, but we really should at least
find out what needs to be reordered and have a mechanism to verify and
track them down, and of course if relocating / reloading / whatever is
cleaner and/or more robust, that's what we should do.

> I will make a patch trying to do this. But I'm not sure if there are any
> other relocation problems on other architectures.
> 
> But even if not, I still think this could be dangerous if someone modifies
> the boot path and allocates some persistent memory before SRAT parsed in
> the future. He has to be aware of memory hotplug things and do the
> necessary relocation himself.

As I wrote above, I think it'd be nice to have a way to track memblock
allocations.  It can be a debug thing but we can just do it by
default, e.g., for allocations before memblock is fully initialized.
It's not like there are a ton of them.  Those extra allocations can be
freed on boot completion anyway, so they won't affect NUMA hotplug
either and we'll be able to continuously watch, and thus properly
maintain, the early boot hotplug issue on most configurations whether
they actually support and perform hotplug or not, which will be
multiple times more robust than trying to tweak boot sequence once and
hoping that it doesn't deteriorate over time.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
