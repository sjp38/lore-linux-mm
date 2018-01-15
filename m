Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8ECD76B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 12:42:25 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id p141so460901qke.4
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 09:42:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v22si146353qtc.308.2018.01.15.09.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jan 2018 09:42:24 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0FHdG0Z048202
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 12:42:24 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fgy4yd6gh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 12:42:23 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 15 Jan 2018 17:42:21 -0000
Subject: Re: [PATCH v6 16/24] mm: Protect mm_rb tree with a rwlock
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1515777968-867-17-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180112184821.GB7590@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 15 Jan 2018 18:42:11 +0100
MIME-Version: 1.0
In-Reply-To: <20180112184821.GB7590@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <9c21cf88-84bd-c951-59eb-c0a5b31dadb3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi Matthew,

Thanks for reviewing this series.

On 12/01/2018 19:48, Matthew Wilcox wrote:
> On Fri, Jan 12, 2018 at 06:26:00PM +0100, Laurent Dufour wrote:
>> -static void __vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
>> +static void __vma_rb_erase(struct vm_area_struct *vma, struct mm_struct *mm)
>>  {
>> +	struct rb_root *root = &mm->mm_rb;
>>  	/*
>>  	 * Note rb_erase_augmented is a fairly large inline function,
>>  	 * so make sure we instantiate it only once with our desired
>>  	 * augmented rbtree callbacks.
>>  	 */
>> +#ifdef CONFIG_SPF
>> +	write_lock(&mm->mm_rb_lock);
>> +#endif
>>  	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
>> +#ifdef CONFIG_SPF
>> +	write_unlock(&mm->mm_rb_lock); /* wmb */
>> +#endif
> 
> I can't say I love this.  Have you considered:
> 
> #ifdef CONFIG_SPF
> #define vma_rb_write_lock(mm)	write_lock(&mm->mm_rb_lock)
> #define vma_rb_write_unlock(mm)	write_unlock(&mm->mm_rb_lock)
> #else
> #define vma_rb_write_lock(mm)	do { } while (0)
> #define vma_rb_write_unlock(mm)	do { } while (0)
> #endif

I haven't consider this, but this sounds to be smarter. I'll do that.

> Also, SPF is kind of uninformative.  CONFIG_MM_SPF might be better?
> Or perhaps even CONFIG_SPECULATIVE_PAGE_FAULT, just to make it really
> painful to do these one-liner ifdefs that make the code so hard to read.

Thomas also complained about that, and I agree, SPF is quite cryptic. This
being said, I don't think that CONFIG_MM_SPF will be far better, so I'll
change this define to CONFIG_SPECULATIVE_PAGE_FAULT, even if it's longer,
it should not be too much present in the code.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
