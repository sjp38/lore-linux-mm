Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id ABFD56B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 23:23:26 -0400 (EDT)
Message-ID: <51FF1A4F.1050309@cn.fujitsu.com>
Date: Mon, 05 Aug 2013 11:21:51 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 RESEND 05/18] x86, ACPICA: Split acpi_boot_table_init()
 into two parts.
References: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com> <1375434877-20704-6-git-send-email-tangchen@cn.fujitsu.com> <7364455.HW1C4G1skW@vostro.rjw.lan>
In-Reply-To: <7364455.HW1C4G1skW@vostro.rjw.lan>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: robert.moore@intel.com, lv.zheng@intel.com, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hi Rafael,

On 08/02/2013 09:00 PM, Rafael J. Wysocki wrote:
......
>> This patch splits acpi_boot_table_init() into two steps:
>> 1. Parse RSDT, which cannot be overrided, and initialize
>>     acpi_gbl_root_table_list. (step 1 + 2 above)
>> 2. Install all ACPI tables into acpi_gbl_root_table_list.
>>     (step 3 + 4 above)
>>
>> In later patches, we will do step 1 + 2 earlier.
>
> Please note that Linux is not the only user of the code you're modifying, so
> you need to make it possible to use the existing functions.
>
> In particular, acpi_tb_parse_root_table() can't be modified the way you did it,
> because that would require all of the users of ACPICA to be modified.

OK, I understand it. Then how about acpi_tb_install_table() ?

acpi_tb_install_table() is also an ACPICA API. But can we split the
acpi_initrd_table_override part out ? Like the following:

1. Initialize acpi_gbl_root_table_list earlier, and install all tables
    provided by firmware.
2. Find SRAT in initrd. If no overridden SRAT, get the SRAT in 
acpi_gbl_root_table_list
    directly. And mark hotpluggable memory. (This the job I want to do.)
3. DO acpi_initrd_table_override job.

Finally it will work like the current kernel. The only difference is:
Before the patch-set, it try to do override first, and then install 
firmware tables.
After the patch-set, it installs firmware tables, and then do the override.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
