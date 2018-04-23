Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6956B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 07:37:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i137so10317602pfe.0
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 04:37:27 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z1si9908413pgs.132.2018.04.23.04.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 04:37:25 -0700 (PDT)
Subject: Re: [PATCH 5/5] x86, pti: filter at vma->vm_page_prot population
References: <20180420222018.E7646EE1@viggo.jf.intel.com>
 <20180420222028.99D72858@viggo.jf.intel.com>
 <295DB0D1-CDFB-482C-93DF-63DAA36DAE22@vmware.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <30d4fd5a-a82f-2a94-e8cb-ad9b7d2dc5e7@linux.intel.com>
Date: Mon, 23 Apr 2018 04:37:24 -0700
MIME-Version: 1.0
In-Reply-To: <295DB0D1-CDFB-482C-93DF-63DAA36DAE22@vmware.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Fengguang Wu <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dan Williams <dan.j.williams@intel.com>, David Woodhouse <dwmw2@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "hughd@google.com" <hughd@google.com>, "jpoimboe@redhat.com" <jpoimboe@redhat.com>, "jgross@suse.com" <jgross@suse.com>, "keescook@google.com" <keescook@google.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@kernel.org" <mingo@kernel.org>

On 04/20/2018 06:21 PM, Nadav Amit wrote:
>> pgprot_t vm_get_page_prot(unsigned long vm_flags)
>> {
>> -	return __pgprot(pgprot_val(protection_map[vm_flags &
>> +	pgprot_t ret = __pgprot(pgprot_val(protection_map[vm_flags &
>> 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
>> 			pgprot_val(arch_vm_get_page_prot(vm_flags)));
>> +
>> +	return arch_filter_pgprot(ret);
>> }
>> EXPORT_SYMBOL(vm_get_page_prot);
> Wouldna??t it be simpler or at least cleaner to change the protection map if
> NX is not supported? I presume it can be done paging_init() similarly to the
> way other archs (e.g., arm, mips) do.

I thought about it, but doing it there requires getting the _timing_
right.  You have to do it before the protection map gets used but after
__supported_pte_mask is totally initialized.  This seemed more
straightforward, especially as a bug fix.

What you are talking about might be a good cleanup, though.
