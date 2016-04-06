Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id E72A66B007E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 06:28:41 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id f105so8350055qge.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 03:28:41 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0059.outbound.protection.outlook.com. [157.55.234.59])
        by mx.google.com with ESMTPS id u10si1553001qgd.2.2016.04.06.03.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 03:28:41 -0700 (PDT)
Subject: Re: [PATCH 23/31] huge tmpfs recovery: framework for reconstituting
 huge pages
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051451430.5965@eggly.anvils>
From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Message-ID: <5704E4D2.5020808@nextfour.com>
Date: Wed, 6 Apr 2016 13:28:34 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604051451430.5965@eggly.anvils>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/06/2016 12:53 AM, Hugh Dickins wrote:



> +static void shmem_recovery_work(struct work_struct *work)
> +{
> +	struct recovery *recovery;
> +	struct shmem_inode_info *info;
> +	struct address_space *mapping;
> +	struct page *page;
> +	struct page *head = NULL;
> +	int error = -ENOENT;
> +
> +	recovery = container_of(work, struct recovery, work);
> +	info = SHMEM_I(recovery->inode);
> +	if (!shmem_work_still_useful(recovery)) {
> +		shr_stats(work_too_late);
> +		goto out;
> +	}
> +
> +	/* Are we resuming from an earlier partially successful attempt? */
> +	mapping = recovery->inode->i_mapping;
> +	spin_lock_irq(&mapping->tree_lock);
> +	page = shmem_clear_tag_hugehole(mapping, recovery->head_index);
> +	if (page)
> +		head = team_head(page);
> +	spin_unlock_irq(&mapping->tree_lock);
> +	if (head) {
> +		/* Serialize with shrinker so it won't mess with our range */
> +		spin_lock(&shmem_shrinklist_lock);
> +		spin_unlock(&shmem_shrinklist_lock);
> +	}
> +
> +	/* If team is now complete, no tag and head would be found above */
> +	page = recovery->page;
> +	if (PageTeam(page))
> +		head = team_head(page);
> +
> +	/* Get a reference to the head of the team already being assembled */
> +	if (head) {
> +		if (!get_page_unless_zero(head))
> +			head = NULL;
> +		else if (!PageTeam(head) || head->mapping != mapping ||
> +				head->index != recovery->head_index) {
> +			put_page(head);
> +			head = NULL;
> +		}
> +	}
> +
> +	if (head) {
> +		/* We are resuming work from a previous partial recovery */
> +		if (PageTeam(page))
> +			shr_stats(resume_teamed);
> +		else
> +			shr_stats(resume_tagged);
> +	} else {
> +		gfp_t gfp = mapping_gfp_mask(mapping);
> +		/*
> +		 * XXX: Note that with swapin readahead, page_to_nid(page) will
> +		 * often choose an unsuitable NUMA node: something to fix soon,
> +		 * but not an immediate blocker.
> +		 */
> +		head = __alloc_pages_node(page_to_nid(page),
> +			gfp | __GFP_NOWARN | __GFP_THISNODE, HPAGE_PMD_ORDER);   
> +		if (!head) {
> +			shr_stats(huge_failed);
> +			error = -ENOMEM;
> +			goto out;
> +		}

Should this head marked PageTeam? Because in patch 27/31 when given as a hint to shmem_getpage_gfp() :

 		hugehint = NULL;
+		if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+		    sgp == SGP_TEAM && *pagep) {
+			struct page *head;
+
+			if (!get_page_unless_zero(*pagep)) {
+				error = -ENOENT;
+				goto decused;
+			}
+			page = *pagep;
+			lock_page(page);
+			head = page - (index & (HPAGE_PMD_NR-1));     

we fail always because :
+			if (!PageTeam(head)) {
+				error = -ENOENT;
+				goto decused;
+			}


> +		if (!shmem_work_still_useful(recovery)) {
> +			__free_pages(head, HPAGE_PMD_ORDER);
> +			shr_stats(huge_too_late);
> +			goto out;
> +		}
> +		split_page(head, HPAGE_PMD_ORDER);
> +		get_page(head);
> +		shr_stats(huge_alloced);
> +	}


Thanks,
Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
