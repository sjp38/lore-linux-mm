Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C59D96B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 10:35:09 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s70so22258161qks.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 07:35:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r23sor4004934qtn.39.2018.11.05.07.35.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 07:35:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20181105090114.GD6953@quack2.suse.cz>
References: <20181102153138.1399758-1-arnd@arndb.de> <20181105090114.GD6953@quack2.suse.cz>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 5 Nov 2018 16:35:08 +0100
Message-ID: <CAK8P3a0sC1p5dHBpc8ktWEt59Q0FVRUZGiX4bn6v0kOhbbYyvg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix uninitialized variable warnings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wang Long <wanglong19@meituan.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

On 11/5/18, Jan Kara <jack@suse.cz> wrote:
> On Fri 02-11-18 16:31:06, Arnd Bergmann wrote:
>> In a rare randconfig build, I got a warning about possibly uninitialized
>> variables:
>>
>> mm/page-writeback.c: In function 'balance_dirty_pages':
>> mm/page-writeback.c:1623:16: error: 'writeback' may be used uninitialized
>> in this function [-Werror=maybe-uninitialized]
>>     mdtc->dirty += writeback;
>>                 ^~
>> mm/page-writeback.c:1624:4: error: 'filepages' may be used uninitialized
>> in this function [-Werror=maybe-uninitialized]
>>     mdtc_calc_avail(mdtc, filepages, headroom);
>>     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>> mm/page-writeback.c:1624:4: error: 'headroom' may be used uninitialized in
>> this function [-Werror=maybe-uninitialized]
>>
>> The compiler evidently fails to notice that the usage is in dead code
>> after 'mdtc' is set to NULL when CONFIG_CGROUP_WRITEBACK is disabled.
>> Adding an IS_ENABLED() check makes this clear to the compiler.
>>
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>
> I'm surprised the compiler was not able to infer this since:
>
> struct dirty_throttle_control * const mdtc = mdtc_valid(&mdtc_stor) ?
>                                                      &mdtc_stor : NULL;
>
> and if CONFIG_CGROUP_WRITEBACK is disabled, mdtc_valid() is defined to
> 'false'.  But possibly the function is just too big and the problematic
> condition is in the loop so maybe it all confuses the compiler too much.

On second thought, I suspect this started with the introduction of
CONFIG_NO_AUTO_INLINE in linux-next. That also caused a similar
issue in 28 other files that I patched later. I wrote this patch before I
saw the others, and then didn't make the connection.

Let's drop the patch for now, and decide what we want to do for the
others. I fixed those by adding 'inline' markers for whatever
function needed it.

       Arnd
