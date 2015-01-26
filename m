Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B38926B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 09:38:22 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so12230157pdj.7
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 06:38:22 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id qc5si12432590pdb.147.2015.01.26.06.38.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 06:38:21 -0800 (PST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 27 Jan 2015 00:38:16 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 6C2412BB0040
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 01:38:12 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0QEc3Lc50135168
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 01:38:12 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0QEbcBO002840
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 01:37:38 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V4] mm/thp: Allocate transparent hugepages on local node
In-Reply-To: <54C62803.8010105@suse.cz>
References: <1421753671-16793-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150120164832.abe2e47b760e1a8d7bb6055b@linux-foundation.org> <54C62803.8010105@suse.cz>
Date: Mon, 26 Jan 2015 20:07:18 +0530
Message-ID: <8761btvc9t.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Vlastimil Babka <vbabka@suse.cz> writes:

> On 01/21/2015 01:48 AM, Andrew Morton wrote:
>> On Tue, 20 Jan 2015 17:04:31 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>> + * Should be called with the mm_sem of the vma hold.
>> 
>> That's a pretty cruddy sentence, isn't it?  Copied from
>> alloc_pages_vma().  "vma->vm_mm->mmap_sem" would be better.
>> 
>> And it should tell us whether mmap_sem required a down_read or a
>> down_write.  What purpose is it serving?
>
> This is already said for mmap_sem further above this comment line, which
> should be just deleted (and from alloc_hugepage_vma comment too).
>
>>> + *
>>> + */
>>> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>>> +				unsigned long addr, int order)
>> 
>> This pointlessly bloats the kernel if CONFIG_TRANSPARENT_HUGEPAGE=n?
>> 
>> 
>> 
>> --- a/mm/mempolicy.c~mm-thp-allocate-transparent-hugepages-on-local-node-fix
>> +++ a/mm/mempolicy.c
>
> How about this cleanup on top? I'm not fully decided on the GFP_TRANSHUGE test.
> This is potentially false positive, although I doubt anything else uses the same
> gfp mask bits.

IMHO I found that to be more complex.

>
> Should "hugepage" be extra bool parameter instead? Should I #ifdef the parameter
> only for CONFIG_TRANSPARENT_HUGEPAGE, or is it not worth the ugliness?
>

I guess if we really want to consolidate both the functions, we should
try the above, without all those #ifdef. It is just one extra arg.  But
then is the reason to consolidate that strong ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
