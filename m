Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 918FF6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 18:46:16 -0400 (EDT)
Received: by wgez8 with SMTP id z8so12706653wge.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:46:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb3si3762976wjc.44.2015.06.11.15.46.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 15:46:14 -0700 (PDT)
Message-ID: <1434062766.3165.103.camel@stgolabs.net>
Subject: Re: [RFC v4 PATCH 2/9] mm/hugetlb: expose hugetlb fault mutex for
 use by fallocate
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Thu, 11 Jun 2015 15:46:06 -0700
In-Reply-To: <1434056500-2434-3-git-send-email-mike.kravetz@oracle.com>
References: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>
	 <1434056500-2434-3-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On Thu, 2015-06-11 at 14:01 -0700, Mike Kravetz wrote:
>  /* Forward declaration */
>  static int hugetlb_acct_memory(struct hstate *h, long delta);
> @@ -3324,7 +3324,8 @@ static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
>  	unsigned long key[2];
>  	u32 hash;
>  
> -	if (vma->vm_flags & VM_SHARED) {
> +	/* !vma implies this was called from hugetlbfs fallocate code */
> +	if (!vma || vma->vm_flags & VM_SHARED) {

That !vma is icky, and really no need for it: hugetlbfs_fallocate(), for
example, already passes [pseudo]vma->vm_flags with VM_SHARED, and you
say it yourself in the comment. Do you see any reason why we cannot just
keep the vma->vm_flags & VM_SHARED check?

> +/*
> + * Interface for use by hugetlbfs fallocate code.  Faults must be
> + * synchronized with page adds or deletes by fallocate.  fallocate
> + * only deals with shared mappings.  See also hugetlb_fault_mutex_lock
> + * and hugetlb_fault_mutex_unlock.
> + */
> +u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff_t idx)
> +{
> +	return fault_mutex_hash(NULL, NULL, NULL, mapping, idx, 0);
> +}

It strikes me that this too should be static inlined. But I really
dislike the nil params thing, which should be addressed by my comment
above.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
