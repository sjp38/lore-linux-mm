Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 03D816B0071
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 12:08:08 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so79895656wiw.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 09:08:07 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id gb6si15528167wic.42.2015.06.15.09.08.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 09:08:06 -0700 (PDT)
Received: by wifx6 with SMTP id x6so83624981wif.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 09:08:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <557EDBA2.9090308@redhat.com>
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
 <1434294283-8699-3-git-send-email-ebru.akagunduz@gmail.com> <557EDBA2.9090308@redhat.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 15 Jun 2015 19:07:45 +0300
Message-ID: <CALq1K=JhxwLf-pWSd0LJ6A45E-EZGYUhNaUQtpi6q4WRNGUBnQ@mail.gmail.com>
Subject: Re: [RFC 2/3] mm: make optimistic check for swapin readahead
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi <n-horiguchi@ah.jp.nec.com>, aarcange <aarcange@redhat.com>, "iamjoonsoo.kim" <iamjoonsoo.kim@lge.com>, Xiexiuqi <xiexiuqi@huawei.com>, gorcunov <gorcunov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, "aneesh.kumar" <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, mhocko <mhocko@suse.cz>, boaz <boaz@plexistor.com>, raindel <raindel@mellanox.com>

On Mon, Jun 15, 2015 at 5:05 PM, Rik van Riel <riel@redhat.com> wrote:
>
> On 06/14/2015 11:04 AM, Ebru Akagunduz wrote:
> > This patch makes optimistic check for swapin readahead
> > to increase thp collapse rate. Before getting swapped
> > out pages to memory, checks them and allows up to a
> > certain number. It also prints out using tracepoints
> > amount of unmapped ptes.
> >
> > Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
>
> > @@ -2639,11 +2640,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
> >  {
> >       pmd_t *pmd;
> >       pte_t *pte, *_pte;
> > -     int ret = 0, none_or_zero = 0;
> > +     int ret = 0, none_or_zero = 0, unmapped = 0;
> >       struct page *page;
> >       unsigned long _address;
> >       spinlock_t *ptl;
> > -     int node = NUMA_NO_NODE;
> > +     int node = NUMA_NO_NODE, max_ptes_swap = HPAGE_PMD_NR/8;
> >       bool writable = false, referenced = false;
>
> This has the effect of only swapping in 4kB pages to form a THP
> if 7/8th of the THP is already resident in memory.
Thanks for clarifing it to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
