Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2AC6B030E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:49:00 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id v84so118392338oie.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:49:00 -0800 (PST)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id o57si12164220oto.107.2016.11.15.16.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 16:48:59 -0800 (PST)
Received: by mail-oi0-x22d.google.com with SMTP id z62so44757440oiz.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:48:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1c6d61ef-2331-e517-d0d8-d4eefea8b18a@intel.com>
References: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
 <1c6d61ef-2331-e517-d0d8-d4eefea8b18a@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 15 Nov 2016 16:48:58 -0800
Message-ID: <CAPcyv4gGWxpntc141nDJ6Lwg=17e30O8=xDTpHBpJ=79+fT=VQ@mail.gmail.com>
Subject: Re: [PATCH] mm: add ZONE_DEVICE statistics to smaps
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, Nov 15, 2016 at 4:15 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 11/10/2016 02:11 PM, Dan Williams wrote:
>> @@ -774,6 +778,8 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>>                  "ShmemPmdMapped: %8lu kB\n"
>>                  "Shared_Hugetlb: %8lu kB\n"
>>                  "Private_Hugetlb: %7lu kB\n"
>> +                "Device:         %8lu kB\n"
>> +                "DeviceHugePages: %7lu kB\n"
>>                  "Swap:           %8lu kB\n"
>>                  "SwapPss:        %8lu kB\n"
>>                  "KernelPageSize: %8lu kB\n"
>
> So, a couple of nits...
>
> smaps is getting a bit big, and the fields that get added in this patch
> are going to be pretty infrequently used.  Is it OK if smaps grows
> forever, even if most of them items are "0 kB"?
>
> IOW, Could we make it output Device* only for DAX VMAs?  All the parsers
> have to handle that field being there or not (for old kernels).

How about just hiding the field if it is zero?  That way it's not an
backdoor way to leak vma_is_dax() which was Christoph's concern.

> The other thing missing for DAX is the page size.  DAX mappings support
> mixed page sizes, so MMUPageSize in this context is pretty worthless.
> What will we do in here for 1GB DAX pages?

I was thinking that would be yet another field "DeviceGiganticPages?"
when we eventually add 1GB support (not there today).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
