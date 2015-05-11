Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4423D6B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 04:54:24 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so105007719pab.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 01:54:24 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id nt2si17117631pbc.28.2015.05.11.01.54.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 01:54:23 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 11 May 2015 14:24:19 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 5BFBB394004E
	for <linux-mm@kvack.org>; Mon, 11 May 2015 14:24:16 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4B8sFPQ64618546
	for <linux-mm@kvack.org>; Mon, 11 May 2015 14:24:16 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4B8sFJh032747
	for <linux-mm@kvack.org>; Mon, 11 May 2015 14:24:15 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V3] powerpc/thp: Serialize pmd clear against a linux page table walk.
In-Reply-To: <20150511074631.GA10974@node.dhcp.inet.fi>
References: <1431325561-21396-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150511074631.GA10974@node.dhcp.inet.fi>
Date: Mon, 11 May 2015 14:24:14 +0530
Message-ID: <87twvj4hqh.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Mon, May 11, 2015 at 11:56:01AM +0530, Aneesh Kumar K.V wrote:
>> Serialize against find_linux_pte_or_hugepte which does lock-less
>> lookup in page tables with local interrupts disabled. For huge pages
>> it casts pmd_t to pte_t. Since format of pte_t is different from
>> pmd_t we want to prevent transit from pmd pointing to page table
>> to pmd pointing to huge page (and back) while interrupts are disabled.
>> We clear pmd to possibly replace it with page table pointer in
>> different code paths. So make sure we wait for the parallel
>> find_linux_pte_or_hugepage to finish.
>> 
>> Without this patch, a find_linux_pte_or_hugepte running in parallel to
>> __split_huge_zero_page_pmd or do_huge_pmd_wp_page_fallback or zap_huge_pmd
>> can run into the above issue. With __split_huge_zero_page_pmd and
>> do_huge_pmd_wp_page_fallback we clear the hugepage pte before inserting
>> the pmd entry with a regular pgtable address. Such a clear need to
>> wait for the parallel find_linux_pte_or_hugepte to finish.
>> 
>> With zap_huge_pmd, we can run into issues, with a hugepage pte
>> getting zapped due to a MADV_DONTNEED while other cpu fault it
>> in as small pages.
>> 
>> Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>
> CC: stable@ ?

Yes, We also need to pick,


dac5657067919161eb3273ca787d8ae9814801e7
691e95fd7396905a38d98919e9c150dbc3ea21a3
7d6e7f7ffaba4e013c7a0589140431799bc17985


But that may need me to a backport, because we have dependencies in kvm
and a cherry-pick may not work.

Will work with Michael Ellerman to find out what needs to be done.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
