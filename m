Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id A92E36B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 10:50:54 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id l137so252709927ywe.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 07:50:54 -0700 (PDT)
Received: from mail-yw0-x231.google.com (mail-yw0-x231.google.com. [2607:f8b0:4002:c05::231])
        by mx.google.com with ESMTPS id o125si4345164ywf.219.2016.04.29.07.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 07:50:53 -0700 (PDT)
Received: by mail-yw0-x231.google.com with SMTP id o66so193178267ywc.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 07:50:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160429053740.GA2431@bbox>
References: <1461857808-11030-1-git-send-email-ddstreet@ieee.org>
 <20160428150709.2eef0506d84cd37ac6b61d12@linux-foundation.org>
 <20160429003824.GC4920@swordfish> <20160429053740.GA2431@bbox>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 29 Apr 2016 10:50:13 -0400
Message-ID: <CALZtONCq2QCcg+5S5f-yHiNp6FBPD9sUHjNiFuhJjm-uc6smtg@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: don't fail if can't create debugfs info
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Fri, Apr 29, 2016 at 1:37 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Fri, Apr 29, 2016 at 09:38:24AM +0900, Sergey Senozhatsky wrote:
>> On (04/28/16 15:07), Andrew Morton wrote:
>> > Needed a bit of tweaking due to
>> > http://ozlabs.org/~akpm/mmotm/broken-out/zsmalloc-reordering-function-parameter.patch
>>
>> Thanks.
>>
>> > From: Dan Streetman <ddstreet@ieee.org>
>> > Subject: mm/zsmalloc: don't fail if can't create debugfs info
>> >
>> > Change the return type of zs_pool_stat_create() to void, and
>> > remove the logic to abort pool creation if the stat debugfs
>> > dir/file could not be created.
>> >
>> > The debugfs stat file is for debugging/information only, and doesn't
>> > affect operation of zsmalloc; there is no reason to abort creating
>> > the pool if the stat file can't be created.  This was seen with
>> > zswap, which used the same name for all pool creations, which caused
>> > zsmalloc to fail to create a second pool for zswap if
>> > CONFIG_ZSMALLOC_STAT was enabled.
>>
>> no real objections from me. given that both zram and zswap now provide
>> unique names for zsmalloc stats dir, this patch does not fix any "real"
>> (observed) problem /* ENOMEM in debugfs_create_dir() is a different
>> case */.  so it's more of a cosmetic patch.
>>
>
> Logically, I agree with Dan that debugfs is just optional so it
> shouldn't affect the module running *but* practically, debugfs_create_dir
> failure with no memory would be rare. Rather than it, we would see
> error from same entry naming like Dan's case.
>
> If we removes such error propagation logic in case of same naming,
> how do zsmalloc user can notice that debugfs entry was not created
> although zs_creation was successful returns success?

Does it actually matter to the caller?

Since there's no way for zsmalloc to know if the stats dir/file
creation failed because of EEXIST or because of ENOMEM, there's no way
for it to let the caller know why it failed, either.  Thus all
zsmalloc can do is return a generic error, or possibly-wrong ENOMEM.
In that case what will the caller do?  Change the name and try again?
How does the caller know what name to change it to, maybe the new name
is taken too?

The point of debugfs is to provide debug; failures should be ignored,
because it's just debug.  It should never prevent actual operation of
the driver.

>
> Otherwise, future user of zsmalloc can miss it easily if they repeates
> same mistakes. So, what's the gain with this patch in real practice?

Well as far as future users, zs_create_pool doesn't document 'name' at
all, and certainly doesn't clarify that 'name' should be unique across
*all* zs pools that exist.  And zsmalloc behavior should not be
different depending on whether the ZSMALLOC_STAT param - which appears
to be a debug/info only param - is enabled or not.

But after any future driver using zsmalloc is created, if it did use
an already-existing name - either because it was not coded to use
unique names, or because of a bug that reused an existing name - which
is worse?
1) driver suddenly stops working because new zs pools can't be created?
2) statistics information isn't available for some of the pools created?

And, even though zswap is now patched to provide a unique name, why
does zswap have to bear the burden of that?  zswap doesn't care at all
about the pool name, and there's no way for users to tell which
zsmalloc pool corresponds to which zswap pool parameters.  Future
users of zsmalloc (from a code point of view, not person) probably
will also not care about the zsmalloc pool name.  And zsmalloc still
logs the failure - so anyone looking for the stats and not finding it
can easily check the logs to see the reason.

The other alternative that I mentioned before, is for zsmalloc to take
care of the problem itself.  If the debugfs dir creation fails, it
should change the name and retry; or zsmalloc can keep a list of
active pool names so it knows if a new pool's name exists already or
not.  But neither expecting the calling code to retry with a different
name, nor failing pool creation, seem like a good response when the
only failure is providing debug/stats information.


>
>
>> FWIW,
>> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
>>
>>       -ss
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
