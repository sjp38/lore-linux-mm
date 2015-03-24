Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 763D66B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 00:36:33 -0400 (EDT)
Received: by obcxo2 with SMTP id xo2so139164640obc.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 21:36:33 -0700 (PDT)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id t3si1615630obf.73.2015.03.23.21.36.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 21:36:32 -0700 (PDT)
Received: by obcxo2 with SMTP id xo2so139164536obc.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 21:36:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <550E6D9D.1060507@gmail.com>
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>
	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>
	<550A5FF8.90504@gmail.com>
	<CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>
	<550E6D9D.1060507@gmail.com>
Date: Mon, 23 Mar 2015 21:36:32 -0700
Message-ID: <CADpJO7wP+dvXyxP7SW7F12jra_cWrEba7orRXMJGytvgOJfHkA@mail.gmail.com>
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
From: Aliaksey Kandratsenka <alkondratenko@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

Hi.

First of all, I'd like to apologize for messing up formatting of my
past email. I've learned my lesson.

On Sun, Mar 22, 2015 at 12:22 AM, Daniel Micay <danielmicay@gmail.com> wrote:
>> My initial thinking was that we'd likely use mremap in all cases where
>> we know
>> that touching destination would cause minor page faults (i.e. when
>> destination
>> chunk was MADV_DONTNEED-ed or is brand new mapping). And then also
>> always when
>> size is large enough, i.e. because "teleporting" large count of pages is
>> likely
>> to be faster than copying them.
>>
>> But now I realize that it is more interesting than that. I.e. because as
>> Daniel
>> pointed out, mremap holds mmap_sem exclusively, while page faults are
>> holding it
>> for read. That could be optimized of course. Either by separate
>> "teleport ptes"
>> syscall (again, as noted by Daniel), or by having mremap drop mmap_sem
>> for write
>> and retaking it for read for "moving pages" part of work. Being not really
>> familiar with kernel code I have no idea if that's doable or not. But it
>> looks
>> like it might be quite important.
>
> I think it's doable but it would pessimize the case where the dest VMA
> isn't reusable. It would need to optimistically take the reader lock to
> find out and then drop it. However, userspace knows when this is surely
> going to work and could give it a hint.
>
> I have a good idea about what the *ideal* API for the jemalloc/tcmalloc
> case would be. It would be extremely specific though... they want the
> kernel to move pages from a source VMA to a destination VMA where both
> are anon/private with identical flags so only the reader lock is
> necessary. On top of that, they really want to keep around as many
> destination pages as possible, maybe by swapping as many as possible
> back to the source.
>
> That's *extremely* specific though and I now think the best way to get
> there is by landing this feature and then extending it as necessary down
> the road. An allocator may actually want to manage other kinds of
> mappings itself and it would want the mmap_sem optimization to be an
> optional hint.

Interesting. But what might be other users of MREMAP_NOHOLE/MREMAP_RETAIN ?

I believe it can be argued that "exchange vmas/pages" as separate
syscall is actually more general and thus possibly more useful thing
to have. Regardless of locking. And MREMAP_NOHOLE/MREMAP_RETAIN
functionality can be built on top of that syscall in userspace if
needed (with more than one syscall naturally, but maybe still with
relatively small overhead).

I'm not saying this is good idea, but just asking.

And here is another observation just to make sure that more options
are considered.

Given that mremap is holding mmap_sem exclusively, how about userspace
malloc implementation taking some exclusive malloc lock and doing
normal mremap followed by mmap with MAP_FIXED to fill the hole ? It
might end up having largely same overhead. Well, modulo some extra TLB
flushing. But arguably, reducing TLB flushes for sequence of page
table updates could be usefully addressed separately (e.g. maybe by
matching those syscalls, maybe via syslets).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
