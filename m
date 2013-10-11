Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 241D36B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 01:27:15 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so3862091pab.4
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 22:27:14 -0700 (PDT)
Received: by mail-ie0-f177.google.com with SMTP id e14so3817895iej.22
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 22:27:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131009192356.GB5592@mtj.dyndns.org>
References: <524E2032.4020106@gmail.com>
	<524E2127.4090904@gmail.com>
	<5251F9AB.6000203@zytor.com>
	<525442A4.9060709@gmail.com>
	<20131009164449.GG22495@htj.dyndns.org>
	<CAE9FiQXhW2BacXUjQLK8TpcvhHAediuCntVR13sKGUuq_+=ymw@mail.gmail.com>
	<20131009192356.GB5592@mtj.dyndns.org>
Date: Thu, 10 Oct 2013 22:27:11 -0700
Message-ID: <CAE9FiQWpwp4bTEWEYw3-CW9xF5s_zJAayJrBC_buBC7-nd=7KA@mail.gmail.com>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>
Cc: Zhang Yanfei <zhangyanfei.yes@gmail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Chen Tang <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On Wed, Oct 9, 2013 at 12:23 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Yinghai.
>
> On Wed, Oct 09, 2013 at 12:10:34PM -0700, Yinghai Lu wrote:
>> > I still feel quite uneasy about pulling SRAT parsing and ACPI initrd
>> > overriding into early boot.
>>
>> for your reconsidering to parse srat early, I refresh that old patchset
>> at
>>
>> https://git.kernel.org/cgit/linux/kernel/git/yinghai/linux-yinghai.git/log/?h=for-x86-mm-3.13
>>
>> actually looks one-third or haf patches already have your ack.
>
> Yes, but those acks assume that the overall approach is a good idea.
> The biggest issue that I have with the approach is that it is invasive
> and modifies basic structure for an inherently kludgy solution for a
> quite niche problem.  The benefit / cost ratio still seems quite off
> to me - we're making a lot of general changes to serve something very
> specialized, which might not even stay relevant for long time.
>

I really hate adding another the code path.

Now with v7 from Yanfei, will have movable_node boot command parameter and
if that is specified  kernel would allocate ram early in different way.

Parse srat early patchset add about 217 lines, (from x86, ACPI, NUMA,
ia64: split SLIT handling out)

 arch/ia64/kernel/setup.c                |   4 +-
 arch/x86/include/asm/acpi.h             |   3 +-
 arch/x86/include/asm/page_types.h       |   2 +-
 arch/x86/include/asm/pgtable.h          |   2 +-
 arch/x86/include/asm/setup.h            |   9 ++
 arch/x86/kernel/head64.c                |   2 +
 arch/x86/kernel/head_32.S               |   4 +
 arch/x86/kernel/microcode_intel_early.c |   8 +-
 arch/x86/kernel/setup.c                 |  86 ++++++-----
 arch/x86/mm/init.c                      | 101 ++++++++-----
 arch/x86/mm/numa.c                      | 244 +++++++++++++++++++++++++-------
 arch/x86/mm/numa_emulation.c            |   2 +-
 arch/x86/mm/numa_internal.h             |   2 +
 arch/x86/mm/srat.c                      |  11 +-
 drivers/acpi/numa.c                     |  13 +-
 drivers/acpi/osl.c                      | 131 ++++++++++++-----
 include/linux/acpi.h                    |  20 +--
 include/linux/mm.h                      |   3 -
 mm/page_alloc.c                         |  52 +------
 19 files changed, 458 insertions(+), 241 deletions(-)

if I drop last two, aka does not allocate page table on local code.
will only keep page table on first node, will only need to have add 137 lines.

 arch/ia64/kernel/setup.c                |   4 +-
 arch/x86/include/asm/acpi.h             |   3 +-
 arch/x86/include/asm/page_types.h       |   2 +-
 arch/x86/include/asm/setup.h            |   9 ++
 arch/x86/kernel/head64.c                |   2 +
 arch/x86/kernel/head_32.S               |   4 +
 arch/x86/kernel/microcode_intel_early.c |   8 +-
 arch/x86/kernel/setup.c                 |  85 +++++++++------
 arch/x86/mm/init.c                      |  10 +-
 arch/x86/mm/numa.c                      | 188 +++++++++++++++++++++++---------
 arch/x86/mm/numa_emulation.c            |   2 +-
 arch/x86/mm/numa_internal.h             |   2 +
 arch/x86/mm/srat.c                      |  11 +-
 drivers/acpi/numa.c                     |  13 ++-
 drivers/acpi/osl.c                      | 131 +++++++++++++++-------
 include/linux/acpi.h                    |  20 ++--
 include/linux/mm.h                      |   3 -
 mm/page_alloc.c                         |  52 +--------
 18 files changed, 343 insertions(+), 206 deletions(-)

and Yanfei's add about 265 lines

 Documentation/kernel-
parameters.txt |    3 +
 arch/x86/kernel/setup.c             |    9 ++-
 arch/x86/mm/init.c                  |  122 ++++++++++++++++++++++++++++------
 arch/x86/mm/numa.c                  |   11 +++
 include/linux/memblock.h            |   24 +++++++
 include/linux/mm.h                  |    4 +
 mm/Kconfig                          |   17 +++--
 mm/memblock.c                       |  126 +++++++++++++++++++++++++++++++----
 mm/memory_hotplug.c                 |   31 +++++++++
 9 files changed, 306 insertions(+), 41 deletions(-)

For long term to keep the code more maintainable, We really should go
though parse srat table early.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
