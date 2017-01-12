Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB066B0253
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 12:21:37 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id x49so18672993qtc.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:21:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b34si5300735qta.277.2017.01.12.09.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 09:21:36 -0800 (PST)
Date: Thu, 12 Jan 2017 18:21:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v1 1/1] mm/ksm: improve deduplication of zero pages with
 colouring
Message-ID: <20170112172132.GM4947@redhat.com>
References: <1484237834-15803-1-git-send-email-imbrenda@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484237834-15803-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, borntraeger@de.ibm.com, hughd@google.com, izik.eidus@ravellosystems.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Hello Claudio,

On Thu, Jan 12, 2017 at 05:17:14PM +0100, Claudio Imbrenda wrote:
> +#ifdef __HAVE_COLOR_ZERO_PAGE
> +	/*
> +	 * Same checksum as an empty page. We attempt to merge it with the
> +	 * appropriate zero page.
> +	 */
> +	if (checksum == zero_checksum) {
> +		struct vm_area_struct *vma;
> +
> +		vma = find_mergeable_vma(rmap_item->mm, rmap_item->address);
> +		err = try_to_merge_one_page(vma, page,
> +					    ZERO_PAGE(rmap_item->address));

So the objective is not to add the zero pages to the stable tree but
just convert them to readonly zerpages?

Maybe this could be a standard option for all archs to disable
enable/disable with a new sysfs control similarly to the NUMA aware
deduplication. The question is if it should be enabled by default in
those archs where page coloring matters a lot. Probably yes.

There are guest OS creating lots of zero pages, not linux though, for
linux guests this is just overhead. Also those guests creating zero
pages wouldn't constantly read from them so again for KVM usage this
is unlikely to help. For certain guest OS it'll create less KSM
metadata with this approach, but it's debatable if it's worth one more
memcpy for every merge-candidate page to save some metadata, it's very
guest-workload dependent too. Of course your usage is not KVM but
number crunching with uninitialized tables, it's different and the
zero page read speed matters.

On the implementation side I think the above is going to call
page_add_anon_rmap(kpage, vma, addr, false) and get_page by mistake,
and it should use pte_mkspecial not mk_pte. I think you need to pass
up a zeropage bool into replace_page and change replace_page to create
a proper zeropage in place of the old page or it'll eventually
overflow the page count crashing etc...

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
