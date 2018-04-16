Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 939756B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 15:30:31 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id i18-v6so11038446ota.13
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 12:30:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e15-v6sor5825959oiy.304.2018.04.16.12.30.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 12:30:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180416191805.GS17484@dhcp22.suse.cz>
References: <CAG48ez085cASur3kZTRkdJY20dFZ4Yqc1KVOHxnCAn58_NtW8w@mail.gmail.com>
 <cfbbbe06-5e63-e43c-fb28-c5afef9e1e1d@nvidia.com> <9c714917-fc29-4d12-b5e8-cff28761a2c1@gmail.com>
 <20180413064917.GC17484@dhcp22.suse.cz> <CAG48ez2w+3FDh9LM3+P2EHowicjM2Xw6giR6uq=26JfWHYsTAQ@mail.gmail.com>
 <20180413160435.GA17484@dhcp22.suse.cz> <CAG48ez3-xtmAt2EpRFR8GNKKPcsDsyg7XdwQ=D5w3Ym6w4Krjw@mail.gmail.com>
 <CAG48ez1PdzMs8hkatbzSLBWYucjTc75o8ovSmeC66+e9mLvSfA@mail.gmail.com>
 <20180416100736.GG17484@dhcp22.suse.cz> <CAG48ez3DwRXMtiinUWKnan6hAppLYLdx-w+VzXG6ubioZUacQg@mail.gmail.com>
 <20180416191805.GS17484@dhcp22.suse.cz>
From: Jann Horn <jannh@google.com>
Date: Mon, 16 Apr 2018 21:30:09 +0200
Message-ID: <CAG48ez1nf96nHj8a+aZy22RwqYTUZBGrsGFcz=ZhZBUWzaEZ9w@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been reserved
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, John Hubbard <jhubbard@nvidia.com>, linux-man <linux-man@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Apr 16, 2018 at 9:18 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 16-04-18 15:55:36, Jann Horn wrote:
>> On Mon, Apr 16, 2018 at 12:07 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Fri 13-04-18 18:17:36, Jann Horn wrote:
>> >> On Fri, Apr 13, 2018 at 6:05 PM, Jann Horn <jannh@google.com> wrote:
>> >> > On Fri, Apr 13, 2018 at 6:04 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> >> >> On Fri 13-04-18 17:04:09, Jann Horn wrote:
>> >> >>> On Fri, Apr 13, 2018 at 8:49 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> >> >>> > On Fri 13-04-18 08:43:27, Michael Kerrisk wrote:
>> >> >>> > [...]
>> >> >>> >> So, you mean remove this entire paragraph:
>> >> >>> >>
>> >> >>> >>               For cases in which the specified memory region has not been
>> >> >>> >>               reserved using an existing mapping,  newer  kernels  (Linux
>> >> >>> >>               4.17  and later) provide an option MAP_FIXED_NOREPLACE that
>> >> >>> >>               should be used instead; older kernels require the caller to
>> >> >>> >>               use addr as a hint (without MAP_FIXED) and take appropriate
>> >> >>> >>               action if the kernel places the new mapping at a  different
>> >> >>> >>               address.
>> >> >>> >>
>> >> >>> >> It seems like some version of the first half of the paragraph is worth
>> >> >>> >> keeping, though, so as to point the reader in the direction of a remedy.
>> >> >>> >> How about replacing that text with the following:
>> >> >>> >>
>> >> >>> >>               Since  Linux 4.17, the MAP_FIXED_NOREPLACE flag can be used
>> >> >>> >>               in a multithreaded program to avoid  the  hazard  described
>> >> >>> >>               above.
>> >> >>> >
>> >> >>> > Yes, that sounds reasonable to me.
>> >> >>>
>> >> >>> But that kind of sounds as if you can't avoid it before Linux 4.17,
>> >> >>> when actually, you just have to call mmap() with the address as hint,
>> >> >>> and if mmap() returns a different address, munmap() it and go on your
>> >> >>> normal error path.
>> >> >>
>> >> >> This is still racy in multithreaded application which is the main point
>> >> >> of the whole section, no?
>> >> >
>> >> > No, it isn't.
>> >
>> > I could have been more specific, sorry.
>> >
>> >> mmap() with a hint (without MAP_FIXED) will always non-racily allocate
>> >> a memory region for you or return an error code. If it does allocate a
>> >> memory region, it belongs to you until you deallocate it. It might be
>> >> at a different address than you requested -
>> >
>> > Yes, this all is true. Except the atomicity is guaranteed only for the
>> > syscall. Once you return to the userspace any error handling is error
>> > prone and racy because your mapping might change under you feet. So...
>>
>> Can you please elaborate on why you think anything could change the
>> mapping returned by mmap() under the caller's feet?
>
> Because as soon as the mmap_sem is dropped then any other thread can
> modify the shared address space.
>
>> When mmap() returns a memory area to the caller, that memory area
>> belongs to the caller. No unrelated code will touch it, unless that
>> code is buggy.
>
> Yes, reasonably well written application will not have this problem.
> That, however, requires an external synchronization and that's why
> called it error prone and racy. I guess that was the main motivation for
> that part of the man page.

What requires external synchronization? I still don't understand at
all what you're talking about.

The following code:

void *try_to_alloc_addr(void *hint, size_t len) {
  char *x = mmap(hint, len, ...);
  if (x == MAP_FAILED) return NULL;
  if (x == hint) return x;
  munmap(x, len);
  return NULL;
}

has no need for any form of external synchronization. You can call it
in library code, you can call it in a multithreaded process, you can
call it wherever and it should be safe.

mmap() atomically reserves previously unallocated memory, and nothing
else should be touching that memory until it is released again using
munmap(). (Just like malloc(): When you call malloc(), you get a chunk
of memory that is reserved just for you, and nobody else will scribble
over it until you call free().)
