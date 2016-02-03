Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7802282963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 17:40:21 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id u30so27889556qge.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 14:40:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x143si7507937qka.122.2016.02.03.14.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 14:40:20 -0800 (PST)
Date: Wed, 3 Feb 2016 14:40:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] rmap: introduce rmap_walk_locked()
Message-Id: <20160203144019.9b58b1ba496371a11cc86568@linux-foundation.org>
In-Reply-To: <1454512459-94334-2-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1454512459-94334-2-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed,  3 Feb 2016 18:14:16 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> rmap_walk_locked() is the same as rmap_walk(), but caller takes care
> about relevant rmap lock. It only supports anonymous pages for now.
> 
> It's preparation to switch THP splitting from custom rmap walk in
> freeze_page()/unfreeze_page() to generic one.
> 
> ...
>
> +/* Like rmap_walk, but caller holds relevant rmap lock */
> +int rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc)
> +{
> +	/* only for anon pages for now */
> +	VM_BUG_ON_PAGE(!PageAnon(page) || PageKsm(page), page);
> +	return rmap_walk_anon(page, rwc, true);
> +}

Should be rmap_walk_anon_locked()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
