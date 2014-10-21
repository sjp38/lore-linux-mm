Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 62BF682BDA
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 07:20:39 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hi2so1500740wib.14
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 04:20:38 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id cz3si11908045wib.83.2014.10.21.04.20.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 04:20:37 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Tue, 21 Oct 2014 12:20:35 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6DA9317D8056
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 12:20:32 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9LBKWt052494414
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 11:20:32 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9LBKRaY032162
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 05:20:32 -0600
Date: Tue, 21 Oct 2014 13:20:25 +0200
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] mm: introduce new VM_NOZEROPAGE flag
Message-ID: <20141021132025.60dd3390@BR9TG4T3.de.ibm.com>
In-Reply-To: <5446153F.6030407@redhat.com>
References: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>
	<1413554990-48512-3-git-send-email-dingel@linux.vnet.ibm.com>
	<54419265.9000000@intel.com>
	<20141018164928.2341415f@BR9TG4T3.de.ibm.com>
	<54429521.80402@intel.com>
	<5445511D.1090603@redhat.com>
	<20141021081131.641c6104@mschwide>
	<5446153F.6030407@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar
 K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

On Tue, 21 Oct 2014 10:11:43 +0200
Paolo Bonzini <pbonzini@redhat.com> wrote:

> 
> 
> On 10/21/2014 08:11 AM, Martin Schwidefsky wrote:
> >> I agree with Dave (I thought I disagreed, but I changed my mind while
> >> writing down my thoughts).  Just define mm_forbids_zeropage in
> >> arch/s390/include/asm, and make it return mm->context.use_skey---with a
> >> comment explaining how this is only for processes that use KVM, and then
> >> only for guests that use storage keys.
> >
> > The mm_forbids_zeropage() sure will work for now, but I think a vma flag
> > is the better solution. This is analog to VM_MERGEABLE or VM_NOHUGEPAGE,
> > the best solution would be to only mark those vmas that are mapped to
> > the guest. That we have not found a way to do that yet in a sensible way
> > does not change the fact that "no-zero-page" is a per-vma property, no?
> 
> I agree it should be per-VMA.  However, right now the code is 
> complicated unnecessarily by making it a per-VMA flag.  Also, setting 
> the flag per VMA should probably be done in 
> kvm_arch_prepare_memory_region together with some kind of storage key 
> notifier.  This is not very much like Dominik's patch.  All in all, 
> mm_forbids_zeropage() provides a non-intrusive and non-controversial way 
> to fix the bug.  Later on, switching to vma_forbids_zeropage() will be 
> trivial as far as mm/ code is concerned.
> 

Thank you for all the feedback, will cook up a new version.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
