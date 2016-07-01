Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30C0682958
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:51:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so243607113pfb.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:51:39 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id d20si4507602pfk.240.2016.07.01.08.51.38
        for <linux-mm@kvack.org>;
        Fri, 01 Jul 2016 08:51:38 -0700 (PDT)
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
 <20160701001218.3D316260@viggo.jf.intel.com>
 <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
 <5775F418.2000803@sr71.net>
 <CA+55aFydq3kpT-mzPqcU1_1h=+vSUj6RmQwiz5NVnfY4HfSjXw@mail.gmail.com>
 <874m89cu61.fsf@x220.int.ebiederm.org>
From: Dave Hansen <dave@sr71.net>
Message-ID: <57769188.9060708@sr71.net>
Date: Fri, 1 Jul 2016 08:51:36 -0700
MIME-Version: 1.0
In-Reply-To: <874m89cu61.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

On 07/01/2016 07:25 AM, Eric W. Biederman wrote:
> Linus Torvalds <torvalds@linux-foundation.org> writes:
>> > On Thu, Jun 30, 2016 at 9:39 PM, Dave Hansen <dave@sr71.net> wrote:
>>> >>
>>> >> I think what you suggest will work if we don't consider A/D in
>>> >> pte_none().  I think there are a bunch of code path where assume that
>>> >> !pte_present() && !pte_none() means swap.
>> >
>> > Yeah, we would need to change pte_none() to mask off D/A, but I think
>> > that might be the only real change needed (other than making sure that
>> > we don't use the bits in the swap entries, I didn't look at that part
>> > at all)
> It looks like __pte_to_swp_entry also needs to be changed to mask out
> those bits when the swap code reads pte entries.  For all of the same
> reasons as pte_none.

I guess that would be nice, but isn't it redundant?

static inline swp_entry_t pte_to_swp_entry(pte_t pte)
{
	...
        arch_entry = __pte_to_swp_entry(pte);
	return swp_entry(__swp_type(arch_entry), __swp_offset(arch_entry));
}

As long as __swp_type() and __swp_offset() don't let A/D through, then
we should be OK.  This site is the only call to __pte_to_swp_entry()
that I can find in the entire codebase.

Or am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
