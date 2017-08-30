Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 43B332803A5
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:04:16 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 83so10568422pgb.1
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 22:04:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t68si3599391pfa.102.2017.08.29.22.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 22:04:14 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7U54Ewa134826
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:04:14 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cnk8xctph-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:04:13 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 30 Aug 2017 15:04:04 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v7U542XH31260910
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:04:02 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v7U53rgD007153
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:03:53 +1000
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
 <507e79d5-59df-c5b5-106d-970c9353d9bc@linux.vnet.ibm.com>
 <20170829120426.4ar56rbmiupbqmio@hirez.programming.kicks-ass.net>
 <848fa2c6-dbda-9a1e-2efd-3ce9b083365e@linux.vnet.ibm.com>
 <20170829134550.t7du5zdssvlzemtk@hirez.programming.kicks-ass.net>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 30 Aug 2017 10:33:50 +0530
MIME-Version: 1.0
In-Reply-To: <20170829134550.t7du5zdssvlzemtk@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <ab0634c4-274d-208f-fc4b-43991986bacf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 08/29/2017 07:15 PM, Peter Zijlstra wrote:
> On Tue, Aug 29, 2017 at 03:18:25PM +0200, Laurent Dufour wrote:
>> On 29/08/2017 14:04, Peter Zijlstra wrote:
>>> On Tue, Aug 29, 2017 at 09:59:30AM +0200, Laurent Dufour wrote:
>>>> On 27/08/2017 02:18, Kirill A. Shutemov wrote:
>>>>>> +
>>>>>> +	if (unlikely(!vma->anon_vma))
>>>>>> +		goto unlock;
>>>>>
>>>>> It deserves a comment.
>>>>
>>>> You're right I'll add it in the next version.
>>>> For the record, the root cause is that __anon_vma_prepare() requires the
>>>> mmap_sem to be held because vm_next and vm_prev must be safe.
>>>
>>> But should that test not be:
>>>
>>> 	if (unlikely(vma_is_anonymous(vma) && !vma->anon_vma))
>>> 		goto unlock;
>>>
>>> Because !anon vmas will never have ->anon_vma set and you don't want to
>>> exclude those.
>>
>> Yes in the case we later allow non anonymous vmas to be handled.
>> Currently only anonymous vmas are supported so the check is good enough,
>> isn't it ?
> 
> That wasn't at all clear from reading the code. This makes it clear
> ->anon_vma is only ever looked at for anonymous.
> 
> And like Kirill says, we _really_ should start allowing some (if not
> all) vm_ops. Large file based mappings aren't particularly rare.
> 
> I'm not sure we want to introduce a white-list or just bite the bullet
> and audit all ->fault() implementations. But either works and isn't
> terribly difficult, auditing all is more work though.

filemap_fault() is used as vma-vm_ops->fault() for most of the file
systems. Changing it can enable speculative fault support for all of
them. It will still exclude other driver based vma-vm_ops->fault()
implementation. AFAICS, __lock_page_or_retry() function can drop
mm->mmap_sem if the page could not be locked right away. As suggested
by Peterz, making it understand FAULT_FLAG_SPECULATIVE should be good
enough. The patch is lightly tested for file mappings on top of this
series.

diff --git a/mm/filemap.c b/mm/filemap.c
index a497024..08f3042 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1181,6 +1181,18 @@ int __lock_page_killable(struct page *__page)
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
                         unsigned int flags)
 {
+       if (flags & FAULT_FLAG_SPECULATIVE) {
+               if (flags & FAULT_FLAG_KILLABLE) {
+                       int ret;
+
+                       ret = __lock_page_killable(page);
+                       if (ret)
+                               return 0;
+               } else
+                       __lock_page(page);
+               return 1;
+       }
+
        if (flags & FAULT_FLAG_ALLOW_RETRY) {
                /*
                 * CAUTION! In this case, mmap_sem is not released
diff --git a/mm/memory.c b/mm/memory.c
index 549d235..02347f3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3836,8 +3836,6 @@ static int handle_pte_fault(struct vm_fault *vmf)
        if (!vmf->pte) {
                if (vma_is_anonymous(vmf->vma))
                        return do_anonymous_page(vmf);
-               else if (vmf->flags & FAULT_FLAG_SPECULATIVE)
-                       return VM_FAULT_RETRY;
                else
                        return do_fault(vmf);
        }
@@ -4012,17 +4010,7 @@ int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
                goto unlock;
        }

-       /*
-        * Can't call vm_ops service has we don't know what they would do
-        * with the VMA.
-        * This include huge page from hugetlbfs.
-        */
-       if (vma->vm_ops) {
-               trace_spf_vma_notsup(_RET_IP_, vma, address);
-               goto unlock;
-       }
-
-       if (unlikely(!vma->anon_vma)) {
+       if (unlikely(vma_is_anonymous(vma) && !vma->anon_vma)) {
                trace_spf_vma_notsup(_RET_IP_, vma, address);
                goto unlock;
        }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
