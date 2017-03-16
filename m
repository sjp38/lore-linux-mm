Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 794DB6B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:20:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x63so99010872pfx.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:20:22 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0061.outbound.protection.outlook.com. [104.47.41.61])
        by mx.google.com with ESMTPS id i5si6049083pgh.191.2017.03.16.11.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 11:20:21 -0700 (PDT)
Subject: Re: [RFC PATCH v2 26/32] kvm: svm: Add support for SEV
 LAUNCH_UPDATE_DATA command
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846786714.2349.17724971671841396908.stgit@brijesh-build-machine>
 <14021d2a-2a94-a0c8-88db-acbc04b4daac@redhat.com>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <5fb4d24c-f070-cc22-7a47-fb55ba430011@amd.com>
Date: Thu, 16 Mar 2017 13:20:06 -0500
MIME-Version: 1.0
In-Reply-To: <14021d2a-2a94-a0c8-88db-acbc04b4daac@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net
Cc: brijesh.singh@amd.com


On 03/16/2017 05:48 AM, Paolo Bonzini wrote:
>
>
> On 02/03/2017 16:17, Brijesh Singh wrote:
>> +static struct page **sev_pin_memory(unsigned long uaddr, unsigned long ulen,
>> +				    unsigned long *n)
>> +{
>> +	struct page **pages;
>> +	int first, last;
>> +	unsigned long npages, pinned;
>> +
>> +	/* Get number of pages */
>> +	first = (uaddr & PAGE_MASK) >> PAGE_SHIFT;
>> +	last = ((uaddr + ulen - 1) & PAGE_MASK) >> PAGE_SHIFT;
>> +	npages = (last - first + 1);
>> +
>> +	pages = kzalloc(npages * sizeof(struct page *), GFP_KERNEL);
>> +	if (!pages)
>> +		return NULL;
>> +
>> +	/* pin the user virtual address */
>> +	down_read(&current->mm->mmap_sem);
>> +	pinned = get_user_pages_fast(uaddr, npages, 1, pages);
>> +	up_read(&current->mm->mmap_sem);
>
> get_user_pages_fast, like get_user_pages_unlocked, must be called
> without mmap_sem held.

Sure.

>
>> +	if (pinned != npages) {
>> +		printk(KERN_ERR "SEV: failed to pin  %ld pages (got %ld)\n",
>> +				npages, pinned);
>> +		goto err;
>> +	}
>> +
>> +	*n = npages;
>> +	return pages;
>> +err:
>> +	if (pinned > 0)
>> +		release_pages(pages, pinned, 0);
>> +	kfree(pages);
>> +
>> +	return NULL;
>> +}
>>
>> +	/* the array of pages returned by get_user_pages() is a page-aligned
>> +	 * memory. Since the user buffer is probably not page-aligned, we need
>> +	 * to calculate the offset within a page for first update entry.
>> +	 */
>> +	offset = uaddr & (PAGE_SIZE - 1);
>> +	len = min_t(size_t, (PAGE_SIZE - offset), ulen);
>> +	ulen -= len;
>> +
>> +	/* update first page -
>> +	 * special care need to be taken for the first page because we might
>> +	 * be dealing with offset within the page
>> +	 */
>
> No need to special case the first page; just set "offset = 0" inside the
> loop after the first iteration.
>

Will do.

-Brijesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
