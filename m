Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E63526B0038
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:09:19 -0400 (EDT)
Message-ID: <51EFA873.9050300@cn.fujitsu.com>
Date: Wed, 24 Jul 2013 18:12:03 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/21] x86, acpi: Try to find SRAT in firmware earlier.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-14-git-send-email-tangchen@cn.fujitsu.com> <20130723204949.GR21100@mtj.dyndns.org>
In-Reply-To: <20130723204949.GR21100@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/24/2013 04:49 AM, Tejun Heo wrote:
> On Fri, Jul 19, 2013 at 03:59:26PM +0800, Tang Chen wrote:
......
>> +	for (pos = 0;
>> +	     pos<  acpi_gbl_root_table_list.current_table_count;
>> +	     pos++) {
>> +		if (!ACPI_COMPARE_NAME
>> +		    (&(acpi_gbl_root_table_list.tables[pos].signature),
>> +		    signature))
>
> Hohumm... creative formatting.  Can't you just cache the tables
> pointer in a local variable with short name and avoid the creativity?

OK, followed.

>
>> +			continue;
>> +
>> +		memcpy(out_desc,&acpi_gbl_root_table_list.tables[pos],
>> +		       sizeof(struct acpi_table_desc));
>> +
>> +		return_ACPI_STATUS(AE_OK);
>> +	}
>> +
>> +	return_ACPI_STATUS(AE_NOT_FOUND);
>
> Also, if we already know that SRAT is what we want, I wonder whether
> it'd be simpler to store the location of SRAT somewhere instead of
> trying to be generic with the early processing.

Do you mean get the SRAT's address without touching any ACPI global
variables, such as acpi_gbl_root_table_list ?

The physical addresses of all tables is stored in RSDT (Root System
Description Table), which is the root table. We need to parse RSDT
to get SRAT address.

Using acpi_gbl_root_table_list is very convenient. The initialization
of acpi_gbl_root_table_list is using acpi_os_map_memory(), so it can be
done before init_mem_mapping() and relocate_initrd().

With acpi_gbl_root_table_list initialized, we can iterate it and find
SRAT easily. Otherwise, we have to do the same procedure to parse RSDT,
and find SRAT, which I don't think could be any simpler. I think reuse
the existing acpi_gbl_root_table_list code is better.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
