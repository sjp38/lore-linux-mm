Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17C71828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 14:25:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 143so251616152pfx.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 11:25:18 -0700 (PDT)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id hj10si5234457pac.0.2016.07.01.11.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 11:25:17 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
	<20160701001218.3D316260@viggo.jf.intel.com>
	<CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
	<5775F418.2000803@sr71.net>
	<CA+55aFydq3kpT-mzPqcU1_1h=+vSUj6RmQwiz5NVnfY4HfSjXw@mail.gmail.com>
	<874m89cu61.fsf@x220.int.ebiederm.org> <57769188.9060708@sr71.net>
Date: Fri, 01 Jul 2016 13:12:55 -0500
In-Reply-To: <57769188.9060708@sr71.net> (Dave Hansen's message of "Fri, 1 Jul
	2016 08:51:36 -0700")
Message-ID: <878txlb520.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

Dave Hansen <dave@sr71.net> writes:

> On 07/01/2016 07:25 AM, Eric W. Biederman wrote:
>> Linus Torvalds <torvalds@linux-foundation.org> writes:
>>> > On Thu, Jun 30, 2016 at 9:39 PM, Dave Hansen <dave@sr71.net> wrote:
>>>> >>
>>>> >> I think what you suggest will work if we don't consider A/D in
>>>> >> pte_none().  I think there are a bunch of code path where assume that
>>>> >> !pte_present() && !pte_none() means swap.
>>> >
>>> > Yeah, we would need to change pte_none() to mask off D/A, but I think
>>> > that might be the only real change needed (other than making sure that
>>> > we don't use the bits in the swap entries, I didn't look at that part
>>> > at all)
>> It looks like __pte_to_swp_entry also needs to be changed to mask out
>> those bits when the swap code reads pte entries.  For all of the same
>> reasons as pte_none.
>
> I guess that would be nice, but isn't it redundant?
>
> static inline swp_entry_t pte_to_swp_entry(pte_t pte)
> {
> 	...
>         arch_entry = __pte_to_swp_entry(pte);
> 	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
> }
>
> As long as __swp_type() and __swp_offset() don't let A/D through, then
> we should be OK.  This site is the only call to __pte_to_swp_entry()
> that I can find in the entire codebase.
>
> Or am I missing something?

Given that __pte_to_swp_entry on x86_64 is just __pte_val or pte.pte it
does no filtering.  Similarly __swp_type(arch_entry) is a >> and
swp_entry(type, ...) is a << of what appears to be same amount
for the swap type.

So any corruption in the upper bits of the pte will be preserved as a
swap type.

In fact I strongly suspect that the compiler can optimize out all of the
work done by "swp_entry(__swp_type(arch_entry), _swp_offset(arch_entry))".

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
