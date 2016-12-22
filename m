Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC16128026B
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 18:04:52 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 96so3253835uaq.7
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 15:04:52 -0800 (PST)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id 31si1399873uam.178.2016.12.22.15.04.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 15:04:48 -0800 (PST)
Received: by mail-vk0-x241.google.com with SMTP id p9so18995756vkd.1
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 15:04:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALZtONCCkp8ZhZ29f1FK5DsOyhkyM3_25ZXmr0QGfTbrBxFysw@mail.gmail.com>
References: <20161126201534.5d5e338f678b478e7a7b8dc3@gmail.com>
 <CALZtONCzseKs22189B3b+TEPKu8JPQ4WcGGB0zPj4KNuKiUAig@mail.gmail.com>
 <20161129143916.f24c141c1a264bad1220031e@linux-foundation.org>
 <CAMJBoFNDw6gpnxrk35o9OW4qLJ87RHDfbYzhA9fqWr9WnuTVWw@mail.gmail.com> <CALZtONCCkp8ZhZ29f1FK5DsOyhkyM3_25ZXmr0QGfTbrBxFysw@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 23 Dec 2016 00:04:47 +0100
Message-ID: <CAMJBoFOxh7162k942bhArikpBgyhESZGJo1+ccP-MOX12Sdd9w@mail.gmail.com>
Subject: Re: [PATCH 0/2] z3fold fixes
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Dan Carpenter <dan.carpenter@oracle.com>

On Thu, Dec 22, 2016 at 10:55 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Sun, Dec 18, 2016 at 3:15 AM, Vitaly Wool <vitalywool@gmail.com> wrote=
:
>> On Tue, Nov 29, 2016 at 11:39 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>>> On Tue, 29 Nov 2016 17:33:19 -0500 Dan Streetman <ddstreet@ieee.org> wr=
ote:
>>>
>>>> On Sat, Nov 26, 2016 at 2:15 PM, Vitaly Wool <vitalywool@gmail.com> wr=
ote:
>>>> > Here come 2 patches with z3fold fixes for chunks counting and lockin=
g. As commit 50a50d2 ("z3fold: don't fail kernel build is z3fold_header is =
too big") was NAK'ed [1], I would suggest that we removed that one and the =
next z3fold commit cc1e9c8 ("z3fold: discourage use of pages that weren't c=
ompacted") and applied the coming 2 instead.
>>>>
>>>> Instead of adding these onto all the previous ones, could you redo the
>>>> entire z3fold series?  I think it'll be simpler to review the series
>>>> all at once and that would remove some of the stuff from previous
>>>> patches that shouldn't be there.
>>>>
>>>> If that's ok with Andrew, of course, but I don't think any of the
>>>> z3fold patches have been pushed to Linus yet.
>>>
>>> Sounds good to me.  I had a few surprise rejects when merging these
>>> two, which indicates that things might be out of sync.
>>>
>>> I presently have:
>>>
>>> z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.pa=
tch
>>> z3fold-make-pages_nr-atomic.patch
>>> z3fold-extend-compaction-function.patch
>>> z3fold-use-per-page-spinlock.patch
>>> z3fold-discourage-use-of-pages-that-werent-compacted.patch
>>> z3fold-fix-header-size-related-issues.patch
>>> z3fold-fix-locking-issues.patch
>>
>> My initial suggestion was to have it the following way:
>> z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.pat=
ch
>
> this is a good one, acked by both of us; it should stay and go upstream t=
o Linus
>
>> z3fold-make-pages_nr-atomic.patch
>
> the change itself looks ok and I acked it, but as Andrew commented the
> log says nothing about why it's being changed; the atomic function is
> slower so the log should explain why it's being changed; anyone
> reviewing the log history won't know why you made the change, and the
> change all by itself is a step backwards in performance.
>
>> z3fold-extend-compaction-function.patch
>
> this explictly has a bug in it that's fixed in one of the later
> patches; instead, this should be fixed up and resent.
>
>> z3fold-use-per-page-spinlock.patch
>
> i should have explicitly nak'ed this, as not only did it add a bug
> (fixed by the the other 'fix-' patch below) but its design should be
> replaced by kref counting, which your latest patch is working
> towards...
>
>> z3fold-fix-header-size-related-issues.patch
>> z3fold-fix-locking-issues.patch
>
> and these fix the known problems in the previous patches.
>
>>
>> I would prefer to keep the fix-XXX patches separate since e. g.
>> z3fold-fix-header-size-related-issues.patch concerns also the problems
>> that have been in the code for a while now. I am ok with folding these
>> into the relevant main patches but once again, given that some fixes
>> are related to the code that is already merged, I don't see why it
>> would be better.
>
> none of those patches are "merged", the last z3fold patch in Linus'
> tree is 43afc194 from June.  Just because they're in Andrew's mmotm
> queue (and/or linux-next) doesn't mean they are going to be
> merged...(correct me please if I'm wrong there Andrew)

that I do understand, however,
z3fold-fix-header-size-related-issues.patch fixes the off-by-one issue
present in the code that is in Linus's tree too.

> So as you can see by my patch-by-patch breakdown, almost all of them
> need changes based on feedback from various people.  And they are all
> related - your goal is to improve z3fold performance, right?  IMHO
> they should be sent as a single patch series with that goal in the
> cover letter, including specific details and numbers about how the
> series does improve performance.

but that is a good idea anyway, the only thing i\m not sure about is
whether it makes sense to fold
z3fold-fix-header-size-related-issues.patch into another or not.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
