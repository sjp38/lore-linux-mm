Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D04A76B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 22:10:09 -0400 (EDT)
Message-ID: <520D89A7.7060802@cn.fujitsu.com>
Date: Fri, 16 Aug 2013 10:08:39 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130812145016.GI15892@htj.dyndns.org> <5208FBBC.2080304@zytor.com> <20130812152343.GK15892@htj.dyndns.org> <52090D7F.6060600@gmail.com> <20130812164650.GN15892@htj.dyndns.org> <5209CEC1.8070908@cn.fujitsu.com> <520A02DE.1010908@cn.fujitsu.com> <CAE9FiQV2-OOvHZtPYSYNZz+DfhvL0e+h2HjMSW3DyqeXXvdJkA@mail.gmail.com> <520ADBBA.10501@cn.fujitsu.com> <1376593564.10300.446.camel@misato.fc.hp.com> <CAE9FiQVeMHAqZETP3d1PsPMk9-ZOXD=BD5HaTGFFO3dZenR0CA@mail.gmail.com>
In-Reply-To: <CAE9FiQVeMHAqZETP3d1PsPMk9-ZOXD=BD5HaTGFFO3dZenR0CA@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Toshi Kani <toshi.kani@hp.com>, Tejun Heo <tj@kernel.org>, Tang Chen <imtangchen@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Luck, Tony (tony.luck@intel.com)" <tony.luck@intel.com>

On 08/16/2013 04:28 AM, Yinghai Lu wrote:
......
>>
>> So, we still need reordering, and put a new requirement that all earlier
>> allocations must be small...
>>
>> I think the root of this issue is that ACPI init point is not early
>> enough in the boot sequence.  If it were much earlier already, the whole
>> thing would have been very simple.  We are now trying to workaround this
>> issue in the mblock code (which itself is a fine idea), but this ACPI
>> issue still remains and similar issues may come up again in future.
>>
>> For instance, ACPI SCPR/DBGP/DBG2 tables allow the OS to initialize
>> serial console/debug ports at early boot time.  The earlier it can be
>> initialized, the better this feature will be.  These tables are not
>> currently used by Linux due to a licensing issue, but it could be
>> addressed some time soon.  As platforms becoming more complex&  legacy
>> free, the needs of ACPI tables will increase.
>>
>> I think moving up the ACPI init point earlier is a good direction.
>
> Good point.
>
> If we put acpi_initrd_override in BRK, and can more acpi_boot_table_init()
> much early.

Hi yinghai, toshi,

Since I brought up this issue, it has been a long time. And there were a 
lot
of different solutions came up. No solution is perfect enough for everyone.
I have tried a lot, and most of them failed. But I think most of the things
cannot be seen clearly without a real patch posted. Many good ideas came up
during patch reviewing.

So I think I'm going to try as many ways as possible.  :)


Parsing SRAT earlier is what I want to do in the very beginning indeed. And
now, seems that moving the whole acpi table installation and overriding 
earlier
will bring us much more benefits. I have tried this without moving up
acpi_initrd_override in my part1 patch-set. But not in the way Yinghai 
mentioned
above.

Seeing from the code, there are 5 pages in BRK for page tables.

   81 /* need 4 4k for initial PMD_SIZE, 4k for 0-ISA_END_ADDRESS */
   82 #define INIT_PGT_BUF_SIZE       (5 * PAGE_SIZE)
   83 RESERVE_BRK(early_pgt_alloc, INIT_PGT_BUF_SIZE);

By "put acpi_initrd_override in BRK", do you mean increase the BRK by 
default ?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
