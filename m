Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5DEC0829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 13:01:38 -0400 (EDT)
Received: by wizk4 with SMTP id k4so53684889wiz.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 10:01:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wd8si4671037wjc.143.2015.05.22.10.01.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 May 2015 10:01:36 -0700 (PDT)
Message-ID: <1432314077.2185.4.camel@stgolabs.net>
Subject: Re: [RFC v3 PATCH 04/10] mm/hugetlb: expose hugetlb fault mutex for
 use by fallocate
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 22 May 2015 10:01:17 -0700
In-Reply-To: <1432223264-4414-5-git-send-email-mike.kravetz@oracle.com>
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
	 <1432223264-4414-5-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On Thu, 2015-05-21 at 08:47 -0700, Mike Kravetz wrote:
> +/*
> + * Interfaces to the fault mutex routines for use by hugetlbfs
> + * fallocate code.  Faults must be synchronized with page adds or
> + * deletes by fallocate.  fallocate only deals with shared mappings.
> + */
> +u32 hugetlb_fault_mutex_shared_hash(struct address_space *mapping, pgoff_t idx)
> +{
> +	return fault_mutex_hash(NULL, NULL, NULL, mapping, idx, 0);
> +}
> +
> +void hugetlb_fault_mutex_lock(u32 hash)
> +{
> +	mutex_lock(&htlb_fault_mutex_table[hash]);
> +}
> +
> +void hugetlb_fault_mutex_unlock(u32 hash)
> +{
> +	mutex_unlock(&htlb_fault_mutex_table[hash]);
> +}+

These should really be inlined -- maybe add them to hugetlb.h along with
the mutex hashtable bits.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
