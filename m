Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6E5B6B026A
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:28:08 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id d13so218471694oib.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 05:28:08 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id 8si7456583ota.263.2017.01.24.05.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 05:28:08 -0800 (PST)
Message-ID: <58875606.7090504@huawei.com>
Date: Tue, 24 Jan 2017 21:26:30 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: do not export ioremap_page_range symbol for external
 module
References: <1485173220-29010-1-git-send-email-zhongjiang@huawei.com> <20170124102319.GD6867@dhcp22.suse.cz> <58874FE8.1070100@huawei.com> <20170124131548.GJ6867@dhcp22.suse.cz>
In-Reply-To: <20170124131548.GJ6867@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, jhubbard@nvidia.com, linux-mm@kvack.org, minchan@kernel.org

On 2017/1/24 21:15, Michal Hocko wrote:
> On Tue 24-01-17 21:00:24, zhong jiang wrote:
>> On 2017/1/24 18:23, Michal Hocko wrote:
>>> On Mon 23-01-17 20:07:00, zhongjiang wrote:
>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>
>>>> Recently, I've found cases in which ioremap_page_range was used
>>>> incorrectly, in external modules, leading to crashes. This can be
>>>> partly attributed to the fact that ioremap_page_range is lower-level,
>>>> with fewer protections, as compared to the other functions that an
>>>> external module would typically call. Those include:
>>>>
>>>>      ioremap_cache
>>>>      ioremap_nocache
>>>>      ioremap_prot
>>>>      ioremap_uc
>>>>      ioremap_wc
>>>>      ioremap_wt
>>>>
>>>> ...each of which wraps __ioremap_caller, which in turn provides a
>>>> safer way to achieve the mapping.
>>>>
>>>> Therefore, stop EXPORT-ing ioremap_page_range.
>>>>
>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>>> Reviewed-by: John Hubbard <jhubbard@nvidia.com> 
>>>> Suggested-by: John Hubbard <jhubbard@nvidia.com>
>>> git grep says that there are few direct users of this API in the tree.
>>> Have you checked all of them? The export has been added by 81e88fdc432a
>>> ("ACPI, APEI, Generic Hardware Error Source POLL/IRQ/NMI notification
>>> type support").
>>   I have checked more than one times.  and John also have looked through the whole own kernel.
> OK, it seems you are right. Both PCI_TEGRA and ACPI_APEI_GHES are either
> disabled or compiled in. The same applies for drivers/pci/pci.c.
> This wasn't the case at the time when the export was introduced as
> ACPI_APEI_GHES used to be tristate until 86cd47334b00 ("ACPI, APEI,
> GHES, Prevent GHES to be built as module").
>
> You can add
> Acked-by: Michal Hocko <mhocko@suse.com>
 Thanks a lot.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
