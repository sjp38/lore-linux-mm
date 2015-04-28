Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id A7ABC6B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 19:23:52 -0400 (EDT)
Received: by lbcga7 with SMTP id ga7so7942782lbc.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:23:52 -0700 (PDT)
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com. [209.85.217.172])
        by mx.google.com with ESMTPS id j8si18101767lah.14.2015.04.28.16.23.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 16:23:51 -0700 (PDT)
Received: by lbbqq2 with SMTP id qq2so7867548lbb.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 16:23:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFz6CfnVgGABpGZ4ywqaOyt2E3KFO9zY_H_nH1R=nria-A@mail.gmail.com>
References: <20150428221553.GA5770@node.dhcp.inet.fi> <55400CA7.3050902@redhat.com>
 <CALCETrUYc0W49-CVFpsj33CQx0N_ssaQeree3S7Zh3aisr3kNw@mail.gmail.com> <CA+55aFz6CfnVgGABpGZ4ywqaOyt2E3KFO9zY_H_nH1R=nria-A@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 28 Apr 2015 16:23:29 -0700
Message-ID: <CALCETrXEP+00uezAo5dYTRFLFH0hfk9KxgDTd2zSusUgJz8NDg@mail.gmail.com>
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Tue, Apr 28, 2015 at 4:16 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Apr 28, 2015 at 3:54 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>
>> I had a totally different implementation idea in mind.  It goes
>> something like this:
>>
>> For each CPU, we allocate a fixed number of PCIDs, e.g. 0-7.  We have
>> a per-cpu array of the mm [1] that owns each PCID. [...]
>
> We've done this before on other architectures.  See for example alpha.
> Look up "__get_new_mm_context()" and friends. I think sparc does the
> same (and I think sparc copied a lot of it from the alpha
> implementation).
>
> Iirc, the alpha version just generates a (per-cpu) asid one at a time,
> and has a generation counter so that when you run out of ASID's you do
> a global TLB invalidate on that CPU and start from 0 again. Actually,
> I think the generation number is just the high bits of the asid
> counter (alpha calls them "asn", intel calls them "pcid", and I tend
> to prefer "asid", but it's all the same thing).
>
> Then each thread just has a per-thread ASID. We don't try to make that
> be per-thread and per-cpu, but instead just force a new allocation
> when a thread moves to another CPU.

Alpha appears to have a per-thread per-cpu id of some sort:

/* The alpha MMU context is one "unsigned long" bitmap per CPU */
typedef unsigned long mm_context_t[NR_CPUS];

I think we can do it without that by keeping the mapping in reverse as
I sort of outlined -- for each cpu, store a mapping from mm to pcid.
When things fall out of the list, no big deal.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
