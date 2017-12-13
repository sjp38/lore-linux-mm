Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AFC06B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 10:47:50 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i14so1714200pgf.13
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:47:50 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r7si1531145ple.403.2017.12.13.07.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 07:47:48 -0800 (PST)
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
References: <20171212173221.496222173@linutronix.de>
 <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com>
 <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net>
 <20171213125739.fllckbl3o4nonmpx@node.shutemov.name>
 <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com>
 <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e6ef40c8-8966-c973-3ae4-ac9475699e40@intel.com>
Date: Wed, 13 Dec 2017 07:47:46 -0800
MIME-Version: 1.0
In-Reply-To: <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com

On 12/13/2017 07:32 AM, Peter Zijlstra wrote:
>> This will fault writing a byte to 'addr':
>>
>> 	char *addr = malloc(PAGE_SIZE);
>> 	pkey_mprotect(addr, PAGE_SIZE, 13);
>> 	pkey_deny_access(13);
>> 	*addr[0] = 'f';
>>
>> But this will write one byte to addr successfully (if it uses the kernel
>> mapping of the physical page backing 'addr'):
>>
>> 	char *addr = malloc(PAGE_SIZE);
>> 	pkey_mprotect(addr, PAGE_SIZE, 13);
>> 	pkey_deny_access(13);
>> 	read(fd, addr, 1);
>>
> This seems confused to me; why are these two cases different?

Protection keys doesn't work in the kernel direct map, so if the read()
was implemented by writing to the direct map alias of 'addr' then this
would bypass protection keys.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
