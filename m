Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 350376B030B
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:15:08 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so123253450pgc.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:15:08 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k13si12272573pgp.108.2016.11.15.16.15.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 16:15:07 -0800 (PST)
Subject: Re: [PATCH] mm: add ZONE_DEVICE statistics to smaps
References: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <1c6d61ef-2331-e517-d0d8-d4eefea8b18a@intel.com>
Date: Tue, 15 Nov 2016 16:15:05 -0800
MIME-Version: 1.0
In-Reply-To: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/10/2016 02:11 PM, Dan Williams wrote:
> @@ -774,6 +778,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  		   "ShmemPmdMapped: %8lu kB\n"
>  		   "Shared_Hugetlb: %8lu kB\n"
>  		   "Private_Hugetlb: %7lu kB\n"
> +		   "Device:         %8lu kB\n"
> +		   "DeviceHugePages: %7lu kB\n"
>  		   "Swap:           %8lu kB\n"
>  		   "SwapPss:        %8lu kB\n"
>  		   "KernelPageSize: %8lu kB\n"

So, a couple of nits...

smaps is getting a bit big, and the fields that get added in this patch
are going to be pretty infrequently used.  Is it OK if smaps grows
forever, even if most of them items are "0 kB"?

IOW, Could we make it output Device* only for DAX VMAs?  All the parsers
have to handle that field being there or not (for old kernels).

The other thing missing for DAX is the page size.  DAX mappings support
mixed page sizes, so MMUPageSize in this context is pretty worthless.
What will we do in here for 1GB DAX pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
