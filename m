Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 467926B025E
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 14:24:39 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i89so2985361pfj.9
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 11:24:39 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t128si16176349pgc.68.2017.11.14.11.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 11:24:38 -0800 (PST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C50842190F
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 19:24:37 +0000 (UTC)
Received: by mail-it0-f41.google.com with SMTP id n134so6385607itg.3
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 11:24:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1711141057510.2433@eggly.anvils>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193139.B039E97B@viggo.jf.intel.com>
 <20171114182009.jbhobwxlkfjb2t6i@hirez.programming.kicks-ass.net>
 <30655167-963f-09e3-f88f-600bb95407e8@linux.intel.com> <alpine.LSU.2.11.1711141057510.2433@eggly.anvils>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 14 Nov 2017 11:24:16 -0800
Message-ID: <CALCETrUtnkhURucGJzUsaWP_8mJ1X_axQFfwHmM7gZydP-j+=Q@mail.gmail.com>
Subject: Re: [PATCH 18/30] x86, kaiser: map virtually-addressed performance
 monitoring buffers
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, X86 ML <x86@kernel.org>

On Tue, Nov 14, 2017 at 11:10 AM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 14 Nov 2017, Dave Hansen wrote:
>> On 11/14/2017 10:20 AM, Peter Zijlstra wrote:
>> > On Fri, Nov 10, 2017 at 11:31:39AM -0800, Dave Hansen wrote:
>> >>  static int alloc_ds_buffer(int cpu)
>> >>  {
>> >> +  struct debug_store *ds = per_cpu_ptr(&cpu_debug_store, cpu);
>> >>
>> >> +  memset(ds, 0, sizeof(*ds));
>> > Still wondering about that memset...
>
> Sorry, my attention is far away at the moment.
>
>>
>> My guess is that it was done to mirror the zeroing done by the original
>> kzalloc().
>
> You guess right.
>
>> But, I think you're right that it's zero'd already by virtue
>> of being static:
>>
>> static
>> DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct debug_store,
>> cpu_debug_store);
>>
>> I'll queue a cleanup, or update it if I re-post the set.
>
> I was about to agree, but now I'm not so sure.  I don't know much
> about these PMC things, but at a glance it looks like what is reserved
> by x86_reserve_hardware() may later be released by x86_release_hardware(),
> and then later reserved again by x86_reserve_hardware().  And although
> the static per-cpu area would be zeroed the first time, the second time
> it will contain data left over from before, so really needs the memset?
>

For an upstream solution, I would really really like to see
DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED and friends completely gone
and to use cpu_entry_area instead.  I don't know whether this has any
material impact on this particular discussion, though.

--Andy

> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
