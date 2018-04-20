Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E01FC6B0010
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 11:52:12 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l19-v6so1310605lfg.23
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:52:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n198-v6sor1729994lfn.100.2018.04.20.08.52.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Apr 2018 08:52:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5ADA0A6D02000078001BD177@prv1-mh.provo.novell.com>
References: <bug-198497-200779@https.bugzilla.kernel.org/> <bug-198497-200779-43rwxa1kcg@https.bugzilla.kernel.org/>
 <CAKf6xpuYvCMUVHdP71F8OWm=bQGFxeRd7SddH-5DDo-AQjbbQg@mail.gmail.com>
 <20180420133951.GC10788@bombadil.infradead.org> <CAKf6xpuVrPwc=AxYruPVfdxx1Yv7NF7NKiGx7vT2WKLogUoqfA@mail.gmail.com>
 <76a4ee3b-e00a-5032-df90-07d8e207f707@citrix.com> <5ADA0A6D02000078001BD177@prv1-mh.provo.novell.com>
From: Jason Andryuk <jandryuk@gmail.com>
Date: Fri, 20 Apr 2018 11:52:10 -0400
Message-ID: <CAKf6xps4RiC48zCie0o7VzTOCDu8ik1hmFP=b_qMx8qTo8F3TQ@mail.gmail.com>
Subject: Re: [Xen-devel] [Bug 198497] handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: Andrew Cooper <andrew.cooper3@citrix.com>, bugzilla-daemon@bugzilla.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, akpm@linux-foundation.org, xen-devel@lists.xen.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, labbott@redhat.com, Juergen Gross <jgross@suse.com>

On Fri, Apr 20, 2018 at 11:42 AM, Jan Beulich <JBeulich@suse.com> wrote:
>>>> On 20.04.18 at 17:25, <andrew.cooper3@citrix.com> wrote:
>> On 20/04/18 16:20, Jason Andryuk wrote:
>>> Adding xen-devel and the Linux Xen maintainers.
>>>
>>> Summary: Some Xen users (and maybe others) are hitting a BUG in
>>> __radix_tree_lookup() under do_swap_page() - example backtrace is
>>> provided at the end.  Matthew Wilcox provided a band-aid patch that
>>> prints errors like the following instead of triggering the bug.
>>>
>>> Skylake 32bit PAE Dom0:
>>> Bad swp_entry: 80000000
>>> mm/swap_state.c:683: bad pte d3a39f1c(8000000400000000)
>>>
>>> Ivy Bridge 32bit PAE Dom0:
>>> Bad swp_entry: 40000000
>>> mm/swap_state.c:683: bad pte d3a05f1c(8000000200000000)
>>>
>>> Other 32bit DomU:
>>> Bad swp_entry: 4000000
>>> mm/swap_state.c:683: bad pte e2187f30(8000000200000000)
>>>
>>> Other 32bit:
>>> Bad swp_entry: 2000000
>>> mm/swap_state.c:683: bad pte ef3a3f38(8000000100000000)
>>>
>>> The Linux bugzilla has more info
>>> https://bugzilla.kernel.org/show_bug.cgi?id=198497
>>>
>>> This may not be exclusive to Xen Linux, but most of the reports are on
>>> Xen.  Matthew wonders if Xen might be stepping on the upper bits of a
>>> pte.
>>
>> Yes - Xen does use the upper bits of a PTE, but only 1 in release
>> builds, and a second in debug builds.  I don't understand where you're
>> getting the 3rd bit in there.
>
> The former supposedly is _PAGE_GUEST_KERNEL, which we use for 64-bit
> guests only. Above talk is of 32-bit guests only.
>
> In addition both this and _PAGE_GNTTAB are used on present PTEs only,
> while above talk is about swap entries.

This hits a BUG going through do_swap_page, but it seems like users
don't think they are actually using swap at the time.  One reporter
didn't have any swap configured.  Some of this information was further
down in my original message.

I'm wondering if somehow we have a PTE that should be empty and should
be lazily filled.  For some reason, the entry has some bits set and is
causing the trouble.  Would Xen mess with the PTEs in that case?

Thanks,
Jason
