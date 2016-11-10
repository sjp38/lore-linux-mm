Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0894A6B027E
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:08:40 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i88so99071318pfk.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:08:40 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id 12si486626pfi.251.2016.11.10.01.08.37
        for <linux-mm@kvack.org>;
        Thu, 10 Nov 2016 01:08:39 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 07/12] mm: thp: check pmd migration entry in common path
Date: Thu, 10 Nov 2016 17:08:07 +0800
Message-ID: <013801d23b31$f47a7cb0$dd6f7610$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Dave Hansen' <dave.hansen@intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Michal Hocko' <mhocko@kernel.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Zi Yan' <zi.yan@cs.rutgers.edu>, 'Balbir Singh' <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, 'Naoya Horiguchi' <nao.horiguchi@gmail.com>, 'Anshuman Khandual' <khandual@linux.vnet.ibm.com>

On Tuesday, November 08, 2016 7:32 AM Naoya Horiguchi wrote:
> 
> @@ -1013,6 +1027,9 @@ int do_huge_pmd_wp_page(struct fault_env *fe, pmd_t orig_pmd)
>  	if (unlikely(!pmd_same(*fe->pmd, orig_pmd)))
>  		goto out_unlock;
> 
> +	if (unlikely(!pmd_present(orig_pmd)))
> +		goto out_unlock;
> +

Can we encounter a migration entry after acquiring ptl ?

>  	page = pmd_page(orig_pmd);
>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>  	/*
[...]
> @@ -3591,6 +3591,10 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  		int ret;
> 
>  		barrier();
> +		if (unlikely(is_pmd_migration_entry(orig_pmd))) {
> +			pmd_migration_entry_wait(mm, fe.pmd);
> +			return 0;
> +		}
>  		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
>  			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
>  				return do_huge_pmd_numa_page(&fe, orig_pmd);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
