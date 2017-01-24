Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E36B6B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:15:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so26717201wmi.6
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 05:15:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x70si18344150wmd.7.2017.01.24.05.15.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 05:15:53 -0800 (PST)
Date: Tue, 24 Jan 2017 14:15:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: do not export ioremap_page_range symbol for
 external module
Message-ID: <20170124131548.GJ6867@dhcp22.suse.cz>
References: <1485173220-29010-1-git-send-email-zhongjiang@huawei.com>
 <20170124102319.GD6867@dhcp22.suse.cz>
 <58874FE8.1070100@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58874FE8.1070100@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, jhubbard@nvidia.com, linux-mm@kvack.org, minchan@kernel.org

On Tue 24-01-17 21:00:24, zhong jiang wrote:
> On 2017/1/24 18:23, Michal Hocko wrote:
> > On Mon 23-01-17 20:07:00, zhongjiang wrote:
> >> From: zhong jiang <zhongjiang@huawei.com>
> >>
> >> Recently, I've found cases in which ioremap_page_range was used
> >> incorrectly, in external modules, leading to crashes. This can be
> >> partly attributed to the fact that ioremap_page_range is lower-level,
> >> with fewer protections, as compared to the other functions that an
> >> external module would typically call. Those include:
> >>
> >>      ioremap_cache
> >>      ioremap_nocache
> >>      ioremap_prot
> >>      ioremap_uc
> >>      ioremap_wc
> >>      ioremap_wt
> >>
> >> ...each of which wraps __ioremap_caller, which in turn provides a
> >> safer way to achieve the mapping.
> >>
> >> Therefore, stop EXPORT-ing ioremap_page_range.
> >>
> >> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> >> Reviewed-by: John Hubbard <jhubbard@nvidia.com> 
> >> Suggested-by: John Hubbard <jhubbard@nvidia.com>
> > git grep says that there are few direct users of this API in the tree.
> > Have you checked all of them? The export has been added by 81e88fdc432a
> > ("ACPI, APEI, Generic Hardware Error Source POLL/IRQ/NMI notification
> > type support").
>   I have checked more than one times.  and John also have looked through the whole own kernel.

OK, it seems you are right. Both PCI_TEGRA and ACPI_APEI_GHES are either
disabled or compiled in. The same applies for drivers/pci/pci.c.
This wasn't the case at the time when the export was introduced as
ACPI_APEI_GHES used to be tristate until 86cd47334b00 ("ACPI, APEI,
GHES, Prevent GHES to be built as module").

You can add
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
