Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0136B0010
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 11:40:44 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u56-v6so8974448wrf.18
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:40:44 -0700 (PDT)
Received: from SMTP.EU.CITRIX.COM (smtp.eu.citrix.com. [185.25.65.24])
        by mx.google.com with ESMTPS id c11si5263516edm.289.2018.04.20.08.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 08:40:42 -0700 (PDT)
Subject: Re: [Xen-devel] [Bug 198497] handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
From: Andrew Cooper <andrew.cooper3@citrix.com>
References: <bug-198497-200779@https.bugzilla.kernel.org/>
 <bug-198497-200779-43rwxa1kcg@https.bugzilla.kernel.org/>
 <CAKf6xpuYvCMUVHdP71F8OWm=bQGFxeRd7SddH-5DDo-AQjbbQg@mail.gmail.com>
 <20180420133951.GC10788@bombadil.infradead.org>
 <CAKf6xpuVrPwc=AxYruPVfdxx1Yv7NF7NKiGx7vT2WKLogUoqfA@mail.gmail.com>
 <76a4ee3b-e00a-5032-df90-07d8e207f707@citrix.com>
Message-ID: <691aee9e-b82f-b1d2-3419-46c78135688a@citrix.com>
Date: Fri, 20 Apr 2018 16:40:16 +0100
MIME-Version: 1.0
In-Reply-To: <76a4ee3b-e00a-5032-df90-07d8e207f707@citrix.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Andryuk <jandryuk@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: Juergen Gross <jgross@suse.com>, bugzilla-daemon@bugzilla.kernel.org, xen-devel@lists.xen.org, linux-mm@kvack.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, labbott@redhat.com, akpm@linux-foundation.org

On 20/04/18 16:25, Andrew Cooper wrote:
> On 20/04/18 16:20, Jason Andryuk wrote:
>> Adding xen-devel and the Linux Xen maintainers.
>>
>> Summary: Some Xen users (and maybe others) are hitting a BUG in
>> __radix_tree_lookup() under do_swap_page() - example backtrace is
>> provided at the end.  Matthew Wilcox provided a band-aid patch that
>> prints errors like the following instead of triggering the bug.
>>
>> Skylake 32bit PAE Dom0:
>> Bad swp_entry: 80000000
>> mm/swap_state.c:683: bad pte d3a39f1c(8000000400000000)
>>
>> Ivy Bridge 32bit PAE Dom0:
>> Bad swp_entry: 40000000
>> mm/swap_state.c:683: bad pte d3a05f1c(8000000200000000)
>>
>> Other 32bit DomU:
>> Bad swp_entry: 4000000
>> mm/swap_state.c:683: bad pte e2187f30(8000000200000000)
>>
>> Other 32bit:
>> Bad swp_entry: 2000000
>> mm/swap_state.c:683: bad pte ef3a3f38(8000000100000000)
>>
>> The Linux bugzilla has more info
>> https://bugzilla.kernel.org/show_bug.cgi?id=198497
>>
>> This may not be exclusive to Xen Linux, but most of the reports are on
>> Xen.  Matthew wonders if Xen might be stepping on the upper bits of a
>> pte.
> Yes - Xen does use the upper bits of a PTE, but only 1 in release
> builds, and a second in debug builds.A  I don't understand where you're
> getting the 3rd bit in there.
>
> The use of these bits are dubious, and not adequately described in the
> ABI, and attempts to improve the state of play has come to nothing in
> the past.

Sorry - hit send too early.A  To be rather more helpful:

For 64bit guests only, we use one bit to distinguish between guest
kernel and guest user pages.A  This is because both guest user and kernel
run in ring3, and have to have _PAGE_USER set on them.A  We use bit 52 to
tag guest kernel mappings, which is seeded from the guest kernels choice
of _PAGE_USER.

In debug builds of the hypervisor only, we use bit 62 to tag grant
mappings.A  This is to help spot API errors in the guest, and results in
an instant crash if we spot misuse.

~Andrew
