Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B9EEA6B02FA
	for <linux-mm@kvack.org>; Wed, 17 May 2017 13:34:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 62so13909842pft.3
        for <linux-mm@kvack.org>; Wed, 17 May 2017 10:34:07 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q77si2643623pfa.229.2017.05.17.10.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 10:34:07 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: avoid spurious 'bad pmd' warning messages
References: <20170517171639.14501-1-ross.zwisler@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9c45c769-2f5e-9327-c39e-1df7744fa633@intel.com>
Date: Wed, 17 May 2017 10:33:58 -0700
MIME-Version: 1.0
In-Reply-To: <20170517171639.14501-1-ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pawel Lebioda <pawel.lebioda@intel.com>, Dave Jiang <dave.jiang@intel.com>, Xiong Zhou <xzhou@redhat.com>, Eryu Guan <eguan@redhat.com>, stable@vger.kernel.org

On 05/17/2017 10:16 AM, Ross Zwisler wrote:
> @@ -3061,7 +3061,7 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
>  	 * through an atomic read in C, which is what pmd_trans_unstable()
>  	 * provides.
>  	 */
> -	if (pmd_trans_unstable(vmf->pmd) || pmd_devmap(*vmf->pmd))
> +	if (pmd_devmap(*vmf->pmd) || pmd_trans_unstable(vmf->pmd))
>  		return VM_FAULT_NOPAGE;

I'm worried we are very unlikely to get this right in the future.  It's
totally not obvious what the ordering requirement is here.

Could we move pmd_devmap() and pmd_trans_unstable() into a helper that
gets the ordering right and also spells out the ordering requirement?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
