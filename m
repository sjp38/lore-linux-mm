Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 95C7C6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 00:34:01 -0400 (EDT)
Received: by mail-qk0-f173.google.com with SMTP id s68so74519949qkh.3
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 21:34:01 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id v3si10191032qka.22.2016.03.20.21.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 20 Mar 2016 21:34:00 -0700 (PDT)
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 20 Mar 2016 22:33:59 -0600
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D07203E4004F
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 22:33:56 -0600 (MDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2L4XuTc19136654
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 04:33:56 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2L4Xtsb001699
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 00:33:56 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 08/25] thp: support file pages in zap_huge_pmd()
In-Reply-To: <20160319010239.GB29883@node.shutemov.name>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com> <1457737157-38573-9-git-send-email-kirill.shutemov@linux.intel.com> <87a8lvao4a.fsf@linux.vnet.ibm.com> <20160319010239.GB29883@node.shutemov.name>
Date: Mon, 21 Mar 2016 10:03:29 +0530
Message-ID: <87a8lsv49y.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> [ text/plain ]
> On Fri, Mar 18, 2016 at 07:23:41PM +0530, Aneesh Kumar K.V wrote:
>> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
>> 
>> > [ text/plain ]
>> > split_huge_pmd() for file mappings (and DAX too) is implemented by just
>> > clearing pmd entry as we can re-fill this area from page cache on pte
>> > level later.
>> >
>> > This means we don't need deposit page tables when file THP is mapped.
>> > Therefore we shouldn't try to withdraw a page table on zap_huge_pmd()
>> > file THP PMD.
>> 
>> Archs like ppc64 use deposited page table to track the hardware page
>> table slot information. We probably may want to add hooks which arch can
>> use to achieve the same even with file THP 
>
> Could you describe more on what kind of information you're talking about?
>

Hardware page table in ppc64 requires us to map each subpage of the huge
page. This is needed because at low level we use segment base page size
to find the hash slot and on TLB miss, we use the faulting address and
base page size (which is 64k even with THP) to find whether we have
the page mapped in hash page table. Since we use base page size of 64K,
we need to make sure that subpages are mapped (on demand) in hash page
table. If we have then mapped we also need to track their hash table
slot information so that we can clear it on invalidate of hugepage.

With THP we used the deposited page table to store the hash slot
information.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
