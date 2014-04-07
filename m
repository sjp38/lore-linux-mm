Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2BC986B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 15:48:00 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so7002272pdi.16
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 12:47:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f1si8830318pbn.317.2014.04.07.12.47.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 12:47:59 -0700 (PDT)
Message-ID: <5342FF3E.6030306@oracle.com>
Date: Mon, 07 Apr 2014 15:40:46 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <515D882E.6040001@oracle.com> <533F09F0.1050206@oracle.com> <20140407144835.GA17774@node.dhcp.inet.fi>
In-Reply-To: <20140407144835.GA17774@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

It also breaks fairly quickly under testing because:

On 04/07/2014 10:48 AM, Kirill A. Shutemov wrote:
> +	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
> +		spin_lock(ptl);

^ We go into atomic

> +		if (unlikely(!pmd_same(*pmd, orig_pmd)))
> +			goto out_race;
> +	}
> +
>  	if (!page)
>  		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
>  	else
>  		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);

copy_user_huge_page() doesn't like running in atomic state,
and asserts might_sleep().


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
