Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id B2B604402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 19:09:16 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id p130so39772163yka.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 16:09:16 -0800 (PST)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com. [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id s130si9759758ywb.193.2015.12.17.16.09.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 16:09:15 -0800 (PST)
Received: by mail-yk0-x22b.google.com with SMTP id v6so39655363ykc.2
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 16:09:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hRmMJBBWr6dTjX05KFUE8sv6WQa0Co9h-ukHn=_8p6Ag@mail.gmail.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<20151210023916.30368.94401.stgit@dwillia2-desk3.jf.intel.com>
	<20151215161438.e971fc9b98814513bbacb3ed@linux-foundation.org>
	<CAPcyv4hRmMJBBWr6dTjX05KFUE8sv6WQa0Co9h-ukHn=_8p6Ag@mail.gmail.com>
Date: Thu, 17 Dec 2015 16:09:15 -0800
Message-ID: <CAPcyv4ixWnGnwhZLC88+VgDghZWH_vAqRTaynRJu8oSvZ4DX1g@mail.gmail.com>
Subject: Re: [-mm PATCH v2 23/25] mm, x86: get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Peter Zijlstra <peterz@infradead.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Logan Gunthorpe <logang@deltatee.com>

On Tue, Dec 15, 2015 at 6:18 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Tue, Dec 15, 2015 at 4:14 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
[..]
>> And again, this is bloating up the kernel for not-widely-used stuff.
>
> I suspect the ability to compile it out is little comfort since we're
> looking to get CONFIG_ZONE_DEVICE enabled by default in major distros.
> If that's the case I'm wiling to entertain the coarse pinning route.
> We can always circle back for the finer grained option if a problem
> arises, but let me know if CONFIG_ZONE_DEVICE=n was all you were
> looking for...

I chatted with Dave Hansen a bit and we're thinking that just moving
the zone_device count updates out of line and marking the branch
unlikely should address this concern.

In fact my initial numbers are showing that moving the call to
"percpu_ref_get(page->pgmap->ref)" out of line saves nearly 24K of
text!

If that's not enough there's always jump labels, but that's likely to
show diminishing returns compared to the size reduction of moving the
percpu_refcount update out of line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
