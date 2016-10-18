Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 308FB6B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 14:33:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t25so689231pfg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:33:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f19si36946282pff.176.2016.10.18.11.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 11:33:43 -0700 (PDT)
Date: Tue, 18 Oct 2016 11:33:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb: Use the right pte val for compare in
 hugetlb_cow
Message-Id: <20161018113341.e032f26c052dd63a8dca1f09@linux-foundation.org>
In-Reply-To: <20161018154245.18023-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161018154245.18023-1-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Jan Stancek <jstancek@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, 18 Oct 2016 21:12:45 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> We cannot use the pte value used in set_pte_at for pte_same comparison,
> because archs like ppc64, filter/add new pte flag in set_pte_at. Instead
> fetch the pte value inside hugetlb_cow. We are comparing pte value to
> make sure the pte didn't change since we dropped the page table lock.
> hugetlb_cow get called with page table lock held, and we can take a copy
> of the pte value before we drop the page table lock.
> 
> With hugetlbfs, we optimize the MAP_PRIVATE write fault path with no
> previous mapping (huge_pte_none entries), by forcing a cow in the fault
> path. This avoid take an addition fault to covert a read-only mapping
> to read/write. Here we were comparing a recently instantiated pte (via
> set_pte_at) to the pte values from linux page table. As explained above
> on ppc64 such pte_same check returned wrong result, resulting in us
> taking an additional fault on ppc64.

>From my reading this is a minor performance improvement and a -stable
backport isn't needed.  But it is unclear whether the impact warrants a
4.9 merge.

Please be careful about describing end-user visible impacts when fixing
bugs, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
