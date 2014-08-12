Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 328676B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 03:24:46 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so12134725pdj.36
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 00:24:45 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rb3si15344157pbc.190.2014.08.12.00.24.44
        for <linux-mm@kvack.org>;
        Tue, 12 Aug 2014 00:24:45 -0700 (PDT)
Message-ID: <53E9C129.2020902@linux.intel.com>
Date: Tue, 12 Aug 2014 15:24:25 +0800
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH]  export the function kmap_flush_unused.
References: <3C85A229999D6B4A89FA64D4680BA6142C7DFA@SHSMSX101.ccr.corp.intel.com> <53E4D312.5000601@codeaurora.org> <3C85A229999D6B4A89FA64D4680BA6142CAFF3@SHSMSX101.ccr.corp.intel.com> <20140811115431.GW9918@twins.programming.kicks-ass.net>
In-Reply-To: <20140811115431.GW9918@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, "Sha, Ruibin" <ruibin.sha@intel.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "mgorman@suse.de" <mgorman@suse.de>, "mingo@redhat.com" <mingo@redhat.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "He, Bo" <bo.he@intel.com>

On 2014/8/11 19:54, Peter Zijlstra wrote:
> On Mon, Aug 11, 2014 at 01:26:45AM +0000, Sha, Ruibin wrote:
>> Hi Chintan,
>> Thank you very much for your timely and kindly response and comments.
>>
>> Here is more detail about our Scenario:
>>
>>      We have a big driver on Android product. The driver allocates lots of
>>      DDR pages. When applications mmap a file exported from the driver,
>>      driver would mmap the pages to the application space, usually with
>>      uncachable prot.
>>      On ia32/x86_64 arch, we have to avoid page cache alias issue. When
>>      driver allocates the pages, it would change page original mapping in
>>      page table with uncachable prot. Sometimes, the allocated page was
>>      used by kmap/kunmap. After kunmap, the page is still mapped in KMAP
>>      space. The entries in KMAP page table are not cleaned up until a
>>      kernel thread flushes the freed KMAP pages(usually it is woken up by kunmap).
>>      It means the driver need  force to flush the KMAP page table entries before mapping pages to
>>      application space to be used. Otherwise, there is a race to create
>>      cache alias.
>>
>>      To resolve this issue, we need export function kmap_flush_unused as
>>      the driver is compiled as module. Then, the driver calls
>>      kmap_flush_unused if the allocated pages are in HIGHMEM and being
>>      used by kmap.
> A: Because it messes up the order in which people normally read text.
> Q: Why is top-posting such a bad thing?
> A: Top-posting.
> Q: What is the most annoying thing in e-mail?

Sorry, Peter. Ruibin is a new guy in LKML community. He uses outlook
to send emails. He would improve that.

>
> That said, it sounds like you want set_memory_() to call
> kmap_flush_unused(). Because this race it not at all specific to your
> usage, it could happen to any set_memory_() site, right?
No. set_memory_() assumes the memory is not in HIGHMEM.
This scenario is driver allocates HIGHMEM pages, which are kmapped before.
Kernel uses a lazy method when kunmap a HIGHMEM page.
The pages are not unmapped from KMAP page table entries immediately.
When next kmap calling uses the same entry, kernel would change pte.
Or when change_page_attr_set_clr is called.

Our big driver doesn't call change_page_attr_set_clr when mmap the
pages with UNCACHABLE prot. It need call kmap_flush_unused directly after
allocating HIGHMEM pages.

Thanks for the kind comments.

Yanmin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
