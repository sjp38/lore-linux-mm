Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 55AF36B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 16:49:56 -0400 (EDT)
Received: by mail-ye0-f172.google.com with SMTP id l14so44823yen.17
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 13:49:55 -0700 (PDT)
Date: Tue, 23 Jul 2013 16:49:49 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 13/21] x86, acpi: Try to find SRAT in firmware earlier.
Message-ID: <20130723204949.GR21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-14-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374220774-29974-14-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, Jul 19, 2013 at 03:59:26PM +0800, Tang Chen wrote:
> +/*

/**

> + * acpi_get_table_desc - Get the acpi table descriptor of a specific table.
> + * @signature: The signature of the table to be found.
> + * @out_desc: The out returned descriptor.
> + *
> + * This function iterates acpi_gbl_root_table_list and find the specified
> + * table's descriptor.
> + *
> + * NOTE: The caller has the responsibility to allocate memory for @out_desc.
> + *
> + * Return AE_OK on success, AE_NOT_FOUND if the table is not found.
> + */
> +acpi_status acpi_get_table_desc(char *signature,
> +				struct acpi_table_desc *out_desc)
> +{
> +	int pos;
> +
> +	for (pos = 0;
> +	     pos < acpi_gbl_root_table_list.current_table_count;
> +	     pos++) {
> +		if (!ACPI_COMPARE_NAME
> +		    (&(acpi_gbl_root_table_list.tables[pos].signature),
> +		    signature))

Hohumm... creative formatting.  Can't you just cache the tables
pointer in a local variable with short name and avoid the creativity?

> +			continue;
> +
> +		memcpy(out_desc, &acpi_gbl_root_table_list.tables[pos],
> +		       sizeof(struct acpi_table_desc));
> +
> +		return_ACPI_STATUS(AE_OK);
> +	}
> +
> +	return_ACPI_STATUS(AE_NOT_FOUND);

Also, if we already know that SRAT is what we want, I wonder whether
it'd be simpler to store the location of SRAT somewhere instead of
trying to be generic with the early processing.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
