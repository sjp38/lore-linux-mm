Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id DAD7E6B0083
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 04:12:47 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id em10so1050204wid.7
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 01:12:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m12si11254476wiv.58.2014.10.21.01.12.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 01:12:43 -0700 (PDT)
Message-ID: <5446153F.6030407@redhat.com>
Date: Tue, 21 Oct 2014 10:11:43 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: introduce new VM_NOZEROPAGE flag
References: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>	<1413554990-48512-3-git-send-email-dingel@linux.vnet.ibm.com>	<54419265.9000000@intel.com>	<20141018164928.2341415f@BR9TG4T3.de.ibm.com>	<54429521.80402@intel.com>	<5445511D.1090603@redhat.com> <20141021081131.641c6104@mschwide>
In-Reply-To: <20141021081131.641c6104@mschwide>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>



On 10/21/2014 08:11 AM, Martin Schwidefsky wrote:
>> I agree with Dave (I thought I disagreed, but I changed my mind while
>> writing down my thoughts).  Just define mm_forbids_zeropage in
>> arch/s390/include/asm, and make it return mm->context.use_skey---with a
>> comment explaining how this is only for processes that use KVM, and then
>> only for guests that use storage keys.
>
> The mm_forbids_zeropage() sure will work for now, but I think a vma flag
> is the better solution. This is analog to VM_MERGEABLE or VM_NOHUGEPAGE,
> the best solution would be to only mark those vmas that are mapped to
> the guest. That we have not found a way to do that yet in a sensible way
> does not change the fact that "no-zero-page" is a per-vma property, no?

I agree it should be per-VMA.  However, right now the code is 
complicated unnecessarily by making it a per-VMA flag.  Also, setting 
the flag per VMA should probably be done in 
kvm_arch_prepare_memory_region together with some kind of storage key 
notifier.  This is not very much like Dominik's patch.  All in all, 
mm_forbids_zeropage() provides a non-intrusive and non-controversial way 
to fix the bug.  Later on, switching to vma_forbids_zeropage() will be 
trivial as far as mm/ code is concerned.

> But if you insist we go with the mm_forbids_zeropage() until we find a
> clever way to distinguish the guest vmas from the qemu ones.

Yeah, I think it is simpler for now.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
