Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 737546B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 06:32:19 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id n3so405114wiv.3
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 03:32:18 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id fq9si1293261wib.81.2014.10.22.03.32.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 03:32:18 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 11:32:16 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id E78E32190043
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:31:48 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9MAWCcr15729130
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 10:32:12 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9MAWBcW012821
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:32:12 -0600
Date: Wed, 22 Oct 2014 12:32:08 +0200
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] s390/mm: prevent and break zero page mappings in
 case of storage keys
Message-ID: <20141022123208.3bcb6cfb@BR9TG4T3.de.ibm.com>
In-Reply-To: <5447825B.5040608@redhat.com>
References: <1413966624-12447-1-git-send-email-dingel@linux.vnet.ibm.com>
	<1413966624-12447-4-git-send-email-dingel@linux.vnet.ibm.com>
	<5447825B.5040608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar
 K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, 22 Oct 2014 12:09:31 +0200
Paolo Bonzini <pbonzini@redhat.com> wrote:

> On 10/22/2014 10:30 AM, Dominik Dingel wrote:
> > As use_skey is already the condition on which we call s390_enable_skey
> > we need to introduce a new flag for the mm->context on which we decide
> > if zero page mapping is allowed.
> 
> Can you explain better why "mm->context.use_skey = 1" cannot be done
> before the walk_page_range?  Where does the walk or __s390_enable_skey
> or (after the next patch) ksm_madvise rely on
> "mm->context.forbids_zeropage && !mm->context.use_skey"?

I can't, my reasoning there is wrong.
I remembered incorrectly that we use mm_use_skey in arch/s390/kvm/priv.c to
check if we need to call s390_enable_skey, but that does happen
with the interception bits.

So every vCPU which get the a interception for a storage key instruction
will call s390_enable_skey and wait there for the mmap_sem.

> The only reason I can think of, is that the next patch does not reset
> "mm->context.forbids_zeropage" to 0 if the ksm_madvise fails.  Why
> doesn't it do that---or is it a bug?

You are right, this is a bug, where we will drop to userspace with -ENOMEM.

I will fix this as well. 


> Thanks, and sorry for the flurry of questions! :)

I really appreciate your questions and remarks. Thank you!

> Paolo
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
