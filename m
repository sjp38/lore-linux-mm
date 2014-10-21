Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2B24B6B0069
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 02:11:44 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so484854wgg.32
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 23:11:43 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id q9si10923159wiz.17.2014.10.20.23.11.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 23:11:42 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 21 Oct 2014 07:11:41 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7055A1B08023
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 07:11:38 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9L6BcbF15401406
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 06:11:38 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9L6BZkg013845
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 00:11:38 -0600
Date: Tue, 21 Oct 2014 08:11:31 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 2/4] mm: introduce new VM_NOZEROPAGE flag
Message-ID: <20141021081131.641c6104@mschwide>
In-Reply-To: <5445511D.1090603@redhat.com>
References: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>
	<1413554990-48512-3-git-send-email-dingel@linux.vnet.ibm.com>
	<54419265.9000000@intel.com>
	<20141018164928.2341415f@BR9TG4T3.de.ibm.com>
	<54429521.80402@intel.com>
	<5445511D.1090603@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar
 K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

On Mon, 20 Oct 2014 20:14:53 +0200
Paolo Bonzini <pbonzini@redhat.com> wrote:

> On 10/18/2014 06:28 PM, Dave Hansen wrote:
> > > Currently it is an all or nothing thing, but for a future change we might want to just
> > > tag the guest memory instead of the complete user address space.
> >
> > I think it's a bad idea to reserve a flag for potential future use.  If
> > you_need_  it in the future, let's have the discussion then.  For now, I
> > think it should probably just be stored in the mm somewhere.
> 
> I agree with Dave (I thought I disagreed, but I changed my mind while 
> writing down my thoughts).  Just define mm_forbids_zeropage in 
> arch/s390/include/asm, and make it return mm->context.use_skey---with a 
> comment explaining how this is only for processes that use KVM, and then 
> only for guests that use storage keys.

The mm_forbids_zeropage() sure will work for now, but I think a vma flag
is the better solution. This is analog to VM_MERGEABLE or VM_NOHUGEPAGE,
the best solution would be to only mark those vmas that are mapped to
the guest. That we have not found a way to do that yet in a sensible way
does not change the fact that "no-zero-page" is a per-vma property, no?

But if you insist we go with the mm_forbids_zeropage() until we find a
clever way to distinguish the guest vmas from the qemu ones.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
