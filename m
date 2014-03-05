Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f172.google.com (mail-ve0-f172.google.com [209.85.128.172])
	by kanga.kvack.org (Postfix) with ESMTP id C8D866B0092
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:16:43 -0500 (EST)
Received: by mail-ve0-f172.google.com with SMTP id jx11so448861veb.31
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:16:43 -0800 (PST)
Received: from mail-ve0-x236.google.com (mail-ve0-x236.google.com [2607:f8b0:400c:c01::236])
        by mx.google.com with ESMTPS id sq4si318571vdc.15.2014.03.04.19.16.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:16:42 -0800 (PST)
Received: by mail-ve0-f182.google.com with SMTP id jw12so444038veb.41
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:16:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140227150313.3BA27E0098@blue.fi.intel.com>
References: <530F3F0A.5040304@oracle.com>
	<20140227150313.3BA27E0098@blue.fi.intel.com>
Date: Wed, 5 Mar 2014 11:16:41 +0800
Message-ID: <CAA_GA1c02iSmkmCLHFkrK4b4W+JppZ4CSMUJ-Wn1rCs-c=dV6g@mail.gmail.com>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:2785!
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Feb 27, 2014 at 11:03 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Sasha Levin wrote:
>> Hi all,
>>
>> While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled on the
>> following spew:
>>
>> [ 1428.146261] kernel BUG at mm/huge_memory.c:2785!
>
> Hm, interesting.
>
> It seems we either failed to split huge page on vma split or it
> materialized from under us. I don't see how it can happen:
>
>   - it seems we do the right thing with vma_adjust_trans_huge() in
>     __split_vma();
>   - we hold ->mmap_sem all the way from vm_munmap(). At least I don't see
>     a place where we could drop it;
>

Enable CONFIG_DEBUG_VM may show some useful information, at least we
can confirm weather rwsem_is_locked(&tlb->mm->mmap_sem) before
split_huge_page_pmd().

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
