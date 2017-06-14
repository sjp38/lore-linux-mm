Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28C926B0315
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:06:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k30so437837wrc.9
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 07:06:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q81si106737wmb.65.2017.06.14.07.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 07:06:47 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5EE5i8K087188
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:06:46 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b341the6p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:06:46 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 14 Jun 2017 15:06:43 +0100
Date: Wed, 14 Jun 2017 16:06:36 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [HELP-NEEDED, PATCH 0/3] Do not loose dirty bit on THP pages
In-Reply-To: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20170614160636.43647f26@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S.
 Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kirill,

On Wed, 14 Jun 2017 16:51:40 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Vlastimil noted that pmdp_invalidate() is not atomic and we can loose
> dirty and access bits if CPU sets them after pmdp dereference, but
> before set_pmd_at().
> 
> The bug doesn't lead to user-visible misbehaviour in current kernel, but
> fixing this would be critical for future work on THP: both huge-ext4 and THP
> swap out rely on proper dirty tracking.
> 
> Unfortunately, there's no way to address the issue in a generic way. We need to
> fix all architectures that support THP one-by-one.
> 
> All architectures that have THP supported have to provide atomic
> pmdp_invalidate(). If generic implementation of pmdp_invalidate() is used,
> architecture needs to provide atomic pmdp_mknonpresent().
> 
> I've fixed the issue for x86, but I need help with the rest.
> 
> So far THP is supported on 8 architectures. Power and S390 already provides
> atomic pmdp_invalidate(). x86 is fixed by this patches, so 5 architectures
> left:

For s390 the pmdp_invalidate() is atomic only in regard to the dirty and
referenced bits because we use a fault driven approach for this, no?

More specifically the update via the pmdp_xchg_direct() function is protected
by the page table lock, the update on the pmd entry itself does *not* have
to be atomic (for s390).

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
