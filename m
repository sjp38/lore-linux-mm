Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CAB846B03D2
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 17:46:16 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u195so5681567pgb.1
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 14:46:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 63si10051288pgi.231.2017.04.11.14.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 14:46:16 -0700 (PDT)
Date: Tue, 11 Apr 2017 14:46:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/migrate: check for null vma before dereferencing it
Message-Id: <20170411144613.d652d974d2b673b3d3f498c0@linux-foundation.org>
In-Reply-To: <c105740f-4430-c0fe-28fe-8bc4ef8ac64d@canonical.com>
References: <20170411125102.19497-1-colin.king@canonical.com>
	<20170411142633.d01ba0aaeb3e6075d517208c@linux-foundation.org>
	<c105740f-4430-c0fe-28fe-8bc4ef8ac64d@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Ian King <colin.king@canonical.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 11 Apr 2017 22:31:12 +0100 Colin Ian King <colin.king@canonical.com> wrote:

> On 11/04/17 22:26, Andrew Morton wrote:
> > On Tue, 11 Apr 2017 13:51:02 +0100 Colin King <colin.king@canonical.com> wrote:
> > 
> >> From: Colin Ian King <colin.king@canonical.com>
> >>
> >> check if vma is null before dereferencing it, this avoiding any
> >> potential null pointer dereferences on vma via the is_vm_hugetlb_page
> >> call or the direct vma->vm_flags reference.
> >>
> >> Detected with CoverityScan, CID#1427995 ("Dereference before null check")
> >>
> >> ...
> >>
> >> --- a/mm/migrate.c
> >> +++ b/mm/migrate.c
> >> @@ -2757,10 +2757,10 @@ int migrate_vma(const struct migrate_vma_ops *ops,
> >>  	/* Sanity check the arguments */
> >>  	start &= PAGE_MASK;
> >>  	end &= PAGE_MASK;
> >> -	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
> >> -		return -EINVAL;
> >>  	if (!vma || !ops || !src || !dst || start >= end)
> >>  		return -EINVAL;
> >> +	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
> >> +		return -EINVAL;
> >>  	if (start < vma->vm_start || start >= vma->vm_end)
> >>  		return -EINVAL;
> >>  	if (end <= vma->vm_start || end > vma->vm_end)
> > 
> > I don't know what kernel version this is against but I don't think it's
> > anything recent?
> 
> I should have said it was against linux-next

ah, it modifies an HMM patch which I dropped a couple of hours ago.  One
for Jerome, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
