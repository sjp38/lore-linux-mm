Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2766B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 15:46:05 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id r20so2167573wiv.2
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 12:46:04 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id gn9si98119wib.62.2014.10.22.12.46.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 12:46:03 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 20:46:02 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 034EA219005C
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 20:45:37 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9MJk0KS15991114
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 19:46:00 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9MJjwIG020080
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 13:46:00 -0600
Date: Wed, 22 Oct 2014 21:45:52 +0200
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] mm: introduce mm_forbids_zeropage function
Message-ID: <20141022214552.0c954692@BR9TG4T3.de.ibm.com>
In-Reply-To: <20141022122223.f3bef0f497941fa8e0805dbf@linux-foundation.org>
References: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
	<1413976170-42501-3-git-send-email-dingel@linux.vnet.ibm.com>
	<20141022122223.f3bef0f497941fa8e0805dbf@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paolo Bonzini <pbonzini@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar
 K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

On Wed, 22 Oct 2014 12:22:23 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 22 Oct 2014 13:09:28 +0200 Dominik Dingel <dingel@linux.vnet.ibm.com> wrote:
> 
> > Add a new function stub to allow architectures to disable for
> > an mm_structthe backing of non-present, anonymous pages with
> > read-only empty zero pages.
> > 
> > ...
> >
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -56,6 +56,10 @@ extern int sysctl_legacy_va_layout;
> >  #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
> >  #endif
> >  
> > +#ifndef mm_forbids_zeropage
> > +#define mm_forbids_zeropage(X)  (0)
> > +#endif
> 
> Can we document this please?  What it does, why it does it.  We should
> also specify precisely which arch header file is responsible for
> defining mm_forbids_zeropage.
> 

I will add a comment like:

/*
 * To prevent common memory management code establishing
 * a zero page mapping on a read fault.
 * This function should be implemented within <asm/pgtable.h>.
 * s390 does this to prevent multiplexing of hardware bits
 * related to the physical page in case of virtualization.
 */

Okay?


> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
