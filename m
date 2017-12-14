Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6B986B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 23:53:44 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e26so3566447pfi.15
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 20:53:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u191si2322470pgd.674.2017.12.13.20.53.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 20:53:43 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBE4nCK3042602
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 23:53:42 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2eucbkcyxk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 23:53:41 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 14 Dec 2017 04:53:39 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
In-Reply-To: <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com>
References: <20171212173221.496222173@linutronix.de> <20171212173333.669577588@linutronix.de> <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com> <20171213122211.bxcb7xjdwla2bqol@hirez.programming.kicks-ass.net> <20171213125739.fllckbl3o4nonmpx@node.shutemov.name> <b303fac7-34af-5065-f996-4494fb8c09a2@intel.com> <20171213153202.qtxnloxoc66lhsbf@hirez.programming.kicks-ass.net> <e6ef40c8-8966-c973-3ae4-ac9475699e40@intel.com> <20171213155427.p24i2xdh2s65e4d2@hirez.programming.kicks-ass.net> <CA+55aFw0JTRDXked3_OJ+cFx59BE18yDWOt7-ZRTzFS10zYnrg@mail.gmail.com>
Date: Thu, 14 Dec 2017 10:23:21 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87ind9di66.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Wed, Dec 13, 2017 at 7:54 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>>
>> Which is why get_user_pages() _should_ enforce this.
>>
>> What use are protection keys if you can trivially circumvent them?
>
> No, we will *not* worry about protection keys in get_user_pages().
>
> They are not "security". They are a debug aid and safety against random mis-use.
>
> In particular, they are very much *NOT* about "trivially circumvent
> them". The user could just change their mapping thing, for chrissake!
>
> We already allow access to PROT_NONE for gdb and friends, very much on purpose.
>

Can you clarify this? We recently did fix read access on PROT_NONE via
gup here for ppc64 https://lkml.kernel.org/r/20171204021912.25974-2-aneesh.kumar@linux.vnet.ibm.com

What is the expected behaviour against gup and get_user_pages for
PROT_NONE. 

Another issue is we end up behaving differently with PROT_NONE mapping
based on whether autonuma is enabled or not. For a PROT_NONE mapping we
return true with pte_protnone().

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
