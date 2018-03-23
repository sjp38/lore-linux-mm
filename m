Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 271396B002E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 15:26:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g66so7158621pfj.11
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 12:26:31 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c5-v6si8845406pll.90.2018.03.23.12.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 12:26:30 -0700 (PDT)
Subject: Re: [PATCH 05/11] x86/mm: do not auto-massage page protections
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <20180323174454.CD00F614@viggo.jf.intel.com>
 <224464E0-1D3A-4ED8-88E0-A8E84C4265FC@vmware.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <ed72b04d-de86-113e-ab45-e1577e5c4226@linux.intel.com>
Date: Fri, 23 Mar 2018 12:26:28 -0700
MIME-Version: 1.0
In-Reply-To: <224464E0-1D3A-4ED8-88E0-A8E84C4265FC@vmware.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "keescook@google.com" <keescook@google.com>, "hughd@google.com" <hughd@google.com>, "jgross@suse.com" <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>

On 03/23/2018 12:15 PM, Nadav Amit wrote:
>> A PTE is constructed from a physical address and a pgprotval_t.
>> __PAGE_KERNEL, for instance, is a pgprot_t and must be converted
>> into a pgprotval_t before it can be used to create a PTE.  This is
>> done implicitly within functions like set_pte() by massage_pgprot().
>>
>> However, this makes it very challenging to set bits (and keep them
>> set) if your bit is being filtered out by massage_pgprot().
>>
>> This moves the bit filtering out of set_pte() and friends.  For
> 
> I dona??t see that set_pte() filters the bits, so I am confused by this
> sentence...

This was a typo/thinko.  It should be pfn_pte().

>> +static inline pgprotval_t check_pgprot(pgprot_t pgprot)
>> +{
>> +	pgprotval_t massaged_val = massage_pgprot(pgprot);
>> +
>> +	/* mmdebug.h can not be included here because of dependencies */
>> +#ifdef CONFIG_DEBUG_VM
>> +	WARN_ONCE(pgprot_val(pgprot) != massaged_val,
>> +		  "attempted to set unsupported pgprot: %016lx "
>> +		  "bits: %016lx supported: %016lx\n",
>> +		  pgprot_val(pgprot),
>> +		  pgprot_val(pgprot) ^ massaged_val,
>> +		  __supported_pte_mask);
>> +#endif
> Why not to use VM_WARN_ON_ONCE() and avoid the ifdef?

I wanted a message.  VM_WARN_ON_ONCE() doesn't let you give a message.
