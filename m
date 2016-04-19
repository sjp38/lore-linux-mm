Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9A46B0253
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 19:48:50 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id zy2so41561175pac.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 16:48:50 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id v11si14667804par.167.2016.04.19.16.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 16:48:49 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id c20so11542691pfc.1
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 16:48:49 -0700 (PDT)
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
 <571565F0.9070203@linaro.org> <20160419165024.GB24312@redhat.com>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <5716C3DF.5060002@linaro.org>
Date: Tue, 19 Apr 2016 16:48:47 -0700
MIME-Version: 1.0
In-Reply-To: <20160419165024.GB24312@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 4/19/2016 9:50 AM, Andrea Arcangeli wrote:
> Hello,
>
> On Mon, Apr 18, 2016 at 03:55:44PM -0700, Shi, Yang wrote:
>> Hi Kirill,
>>
>> Finally, I got some time to look into and try yours and Hugh's patches,
>> got two problems.
>
> One thing that come to mind to test is this: qemu with -machine
> accel=kvm -mem-path=/dev/shm/,share=on .

Thanks for the suggestion, I will definitely have a try with KVM.

It would be better if Kirill and Hugh could share what benchmark they 
ran and how much they got improved since my test case is very simple and 
may just cover a small part of it.

Yang

>
> The THP Compound approach in tmpfs may just happen to work already
> with KVM (or at worst it'd require minor adjustments) because it uses
> the exact same model KVM is already aware about from THP in anonymous
> memory, example from arch/x86/kvm/mmu.c:
>
> static void transparent_hugepage_adjust(struct kvm_vcpu *vcpu,
> 					gfn_t *gfnp, kvm_pfn_t *pfnp,
> 					int *levelp)
> {
> 	kvm_pfn_t pfn = *pfnp;
> 	gfn_t gfn = *gfnp;
> 	int level = *levelp;
>
> 	/*
> 	 * Check if it's a transparent hugepage. If this would be an
> 	 * hugetlbfs page, level wouldn't be set to
> 	 * PT_PAGE_TABLE_LEVEL and there would be no adjustment done
> 	 * here.
> 	 */
> 	if (!is_error_noslot_pfn(pfn) && !kvm_is_reserved_pfn(pfn) &&
> 	    level == PT_PAGE_TABLE_LEVEL &&
> 	    PageTransCompound(pfn_to_page(pfn)) &&
> 	    !mmu_gfn_lpage_is_disallowed(vcpu, gfn, PT_DIRECTORY_LEVEL)) {
>
> Not using two different models between THP in tmpfs and THP in anon is
> essential not just to significantly reduce the size of the kernel
> code, but also because THP knowledge can't be self contained in the
> mm/shmem.c file. Having to support two different models would
> complicate things for secondary MMU drivers (i.e. mmu notifer users)
> like KVM who also need to create huge mapping in the shadow pagetable
> layer in arch/x86/kvm if the primary MMU allows for it.
>
>> x86-64 and ARM64 with yours and Hugh's patches (linux-next tree), I got
>> the program execution time reduced by ~12% on x86-64, it looks very
>> impressive.
>
> Agreed, both patchset are impressive works and achieving amazing
> results!
>
> My view is that in terms of long-lived computation from userland point
> of view, both models are malleable enough and could achieve everything
> we need in the end, but as far as the overall kernel efficiency is
> concerned the compound model will always retain a slight advantage in
> performance by leveraging a native THP compound refcounting that
> requires just one atomic_inc/dec per THP mapcount instead of 512 of
> them. Other advantages of the compound model is that it's half in code
> size despite already including khugepaged (i.e. the same
> split_huge_page works for both tmpfs and anon) and like said above it
> won't introduce much complications for drivers like KVM as the model
> didn't change.
>
> Thanks,
> Andrea
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
