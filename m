Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 258BE6B026C
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:40:14 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id b67so52462740qgb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 18:40:14 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id n74si757382qgn.12.2016.02.18.18.40.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 18:40:13 -0800 (PST)
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 18 Feb 2016 19:40:12 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 1C7253E4003E
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 19:40:07 -0700 (MST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1J2e6cY32899172
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 02:40:06 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1J2aREp030807
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:36:28 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 01/30] mm: Make vm_get_page_prot arch specific.
In-Reply-To: <20160218231546.GC2765@fergus.ozlabs.ibm.com>
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1455814254-10226-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160218231546.GC2765@fergus.ozlabs.ibm.com>
Date: Fri, 19 Feb 2016 08:10:00 +0530
Message-ID: <87egc9e83j.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@ozlabs.org> writes:

> On Thu, Feb 18, 2016 at 10:20:25PM +0530, Aneesh Kumar K.V wrote:
>> With next generation power processor, we are having a new mmu model
>> [1] that require us to maintain a different linux page table format.
>> 
>> Inorder to support both current and future ppc64 systems with a single
>> kernel we need to make sure kernel can select between different page
>> table format at runtime. With the new MMU (radix MMU) added, we will
>> have to dynamically switch between different protection map. Hence
>> override vm_get_page_prot instead of using arch_vm_get_page_prot. We
>> also drop arch_vm_get_page_prot since only powerpc used it.
>
> This seems like unnecessary churn to me.  Let's just make hash use the
> same values as radix for things like _PAGE_RW, _PAGE_EXEC etc., and
> then we don't need any of this.
>

I was hoping to do that after this series. Something similar to

https://github.com/kvaneesh/linux/commit/0c2ac1328b678a6e187d1f2644a007204c59a047

"
powerpc/mm: Add helper for page flag access in ioremap_at

Instead of using variables we use static inline which get patched during
boot to either hash or radix version.
"

That gives us a base to revert patches if we find issues with hash and
still have a working radix base. So idea is to introduce radix with minimal
changes to hash and then consolidate hash and radix as much as we can by
updating hash linux format.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
