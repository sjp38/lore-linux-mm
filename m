Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id ED6C46B025E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 22:05:31 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id 184so45369822pff.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 19:05:31 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id c67si8170506pfj.47.2016.04.06.19.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 19:05:31 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id 184so45369594pff.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 19:05:31 -0700 (PDT)
Date: Wed, 6 Apr 2016 19:05:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 23/31] huge tmpfs recovery: framework for reconstituting
 huge pages
In-Reply-To: <5704E4D2.5020808@nextfour.com>
Message-ID: <alpine.LSU.2.11.1604061820150.2262@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils> <alpine.LSU.2.11.1604051451430.5965@eggly.anvils> <5704E4D2.5020808@nextfour.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mika Penttila <mika.penttila@nextfour.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 6 Apr 2016, Mika Penttila wrote:
> On 04/06/2016 12:53 AM, Hugh Dickins wrote:
> > +static void shmem_recovery_work(struct work_struct *work)
...
> > +
> > +	if (head) {
> > +		/* We are resuming work from a previous partial recovery */
> > +		if (PageTeam(page))
> > +			shr_stats(resume_teamed);
> > +		else
> > +			shr_stats(resume_tagged);
> > +	} else {
> > +		gfp_t gfp = mapping_gfp_mask(mapping);
> > +		/*
> > +		 * XXX: Note that with swapin readahead, page_to_nid(page) will
> > +		 * often choose an unsuitable NUMA node: something to fix soon,
> > +		 * but not an immediate blocker.
> > +		 */
> > +		head = __alloc_pages_node(page_to_nid(page),
> > +			gfp | __GFP_NOWARN | __GFP_THISNODE, HPAGE_PMD_ORDER);
> > +		if (!head) {
> > +			shr_stats(huge_failed);
> > +			error = -ENOMEM;
> > +			goto out;
> > +		}
> 
> Should this head marked PageTeam? Because in patch 27/31 when given as a hint to shmem_getpage_gfp() :
> 
>  		hugehint = NULL;
> +		if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
> +		    sgp == SGP_TEAM && *pagep) {
> +			struct page *head;
> +
> +			if (!get_page_unless_zero(*pagep)) {
> +				error = -ENOENT;
> +				goto decused;
> +			}
> +			page = *pagep;
> +			lock_page(page);
> +			head = page - (index & (HPAGE_PMD_NR-1));     
> 
> we fail always because :
> +			if (!PageTeam(head)) {
> +				error = -ENOENT;
> +				goto decused;
> +			}

Great observation, thank you Mika.

We don't fail always, because in most cases the page wanted for the head
will either be already in memory, or read in from swap, and that SGP_TEAM
block in shmem_getpage_gfp() (with the -ENOENT you show) not come into play
on it: then shmem_recovery_populate() does its !recovery->exposed_team
SetPageTeam(head) and all is well from then on.

But I think what you point out means that the current recovery code is
incapable of assembling a hugepage if its first page was not already
instantiated earlier: not something I'd realized until you showed me.
Not a common failing, and would never be the case for an extent which had
been mapped huge in the past, but it's certainly not what I'd intended.

As to whether the head should be marked PageTeam immediately after the
hugepage allocation: I think not, especially because of the swapin case
(26/31).  Swapin may need to read data from disk into that head page,
and I've never had to think about the consequences of having a swap
page marked PageTeam.  Perhaps it would work out okay, but I'd prefer
not to go there.

At this moment I'm too tired to think what the right answer will be,
and certainly won't be able to commit to any without some testing.

So, not as incapacitating as perhaps you thought, and not any danger
to people trying out huge tmpfs, but definitely something to be fixed:
I'll mull it over in the background and let you know when I'm sure.

Thank you again,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
