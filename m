Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9666B0008
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 16:05:05 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id n195-v6so1570084yba.5
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:05:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a2-v6sor1044855yba.156.2018.10.23.13.05.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 13:05:04 -0700 (PDT)
Received: from mail-yb1-f175.google.com (mail-yb1-f175.google.com. [209.85.219.175])
        by smtp.gmail.com with ESMTPSA id y206-v6sm526637ywg.57.2018.10.23.13.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 13:05:02 -0700 (PDT)
Received: by mail-yb1-f175.google.com with SMTP id e16-v6so1108372ybk.8
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:05:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <15247f54-53f3-83d4-6706-e9264b90ca7a@yandex-team.ru>
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
 <c57bcc584b3700c483b0311881ec3ae8786f88b1.camel@perches.com> <15247f54-53f3-83d4-6706-e9264b90ca7a@yandex-team.ru>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 23 Oct 2018 13:04:59 -0700
Message-ID: <CAGXu5j+NsDHRWA5PKAKeJCO_oiGkFAUeWE8O-1fEBQX80MDu1A@mail.gmail.com>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Joe Perches <joe@perches.com>, Arun KS <arunks@codeaurora.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Arun Sudhilal <getarunks@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 22, 2018 at 10:11 PM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> On 23.10.2018 7:15, Joe Perches wrote:> On Mon, 2018-10-22 at 22:53 +0530,
> Arun KS wrote:
>>> Remove managed_page_count_lock spinlock and instead use atomic
>>> variables.
>>
>> Perhaps better to define and use macros for the accesses
>> instead of specific uses of atomic_long_<inc/dec/read>
>>
>> Something like:
>>
>> #define totalram_pages()      (unsigned
>> long)atomic_long_read(&_totalram_pages)
>
> or proper static inline
> this code isn't so low level for breaking include dependencies with macro

BTW, I noticed a few places in the patch that did multiple evaluations
of totalram_pages. It might be worth fixing those prior to doing the
conversion, too. e.g.:

if (totalram_pages > something)
   foobar(totalram_pages); <- value may have changed here

should, instead, be:

var = totalram_pages; <- get stable view of the value
if (var > something)
    foobar(var);

-Kees

> [dropped bloated cc - my server rejects this mess]

Thank you -- I was struggling to figure out the best way to reply to this. :)

-Kees

-- 
Kees Cook
