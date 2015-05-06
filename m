Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id E269A6B006C
	for <linux-mm@kvack.org>; Wed,  6 May 2015 08:00:11 -0400 (EDT)
Received: by wizk4 with SMTP id k4so199156543wiz.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 05:00:11 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id bs17si33689207wjb.12.2015.05.06.05.00.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 05:00:10 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 6 May 2015 13:00:08 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id DC0931B08067
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:00:48 +0100 (BST)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46C06HL9765184
	for <linux-mm@kvack.org>; Wed, 6 May 2015 12:00:06 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46C05EY022674
	for <linux-mm@kvack.org>; Wed, 6 May 2015 06:00:06 -0600
Date: Wed, 6 May 2015 14:00:02 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: TLB flushes on s390
Message-ID: <20150506140002.6f9e4e5d@mschwide>
In-Reply-To: <20150506112939.GA17739@node.dhcp.inet.fi>
References: <20150506112939.GA17739@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org

On Wed, 6 May 2015 14:29:39 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> I'm looking though s390 code around page table handling and I found that
> in many places s390 does tlb flush before changing page table entry.

Uhh, have fun with that.. it is complicated :-/
 
> Let's look for instance on pmdp_clear_flush() implementation on s390.
> It's implemented with pmdp_get_and_clear() which does pmdp_flush_direct()
> *before* pmd_clear(). That's invert order comparing to generic
> pmdp_flush_direct().
> 
> The question is what prevents tlb from being re-fill between flushing tlb
> and clearing page table entry?
 
Look again at pmdp_flush_direct(), either __pmdp_idte_local or __pmdp_idte is
called. Both functions use the IDTE instruction but in two different flavors.
The mnemonic IDTE stands for invalidate-dat-table-entry, the instruction sets
the invalid bit in the PMD and flushes all TLB entries on all CPUs that are
affected by the now invalid PMD. The pmd_clear after the pmdp_flush_direct is
done to set all the other bits of the PMD to the "empty" state. The invalid
bit is already set prior to pmd_clear.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
