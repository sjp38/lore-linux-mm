Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 062EC6B0005
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 20:15:20 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o66-v6so5083187iof.17
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 17:15:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r64-v6sor2475715ith.89.2018.04.21.17.15.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Apr 2018 17:15:19 -0700 (PDT)
Date: Sat, 21 Apr 2018 19:15:13 -0500
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [PATCH v2] KASAN: prohibit KASAN+STRUCTLEAK combination
Message-ID: <20180422001513.GA45355@big-sky.restechservices.net>
References: <20180419172451.104700-1-dvyukov@google.com>
 <CAGXu5jK0fWnyQUYP3H5e8hP-6QbtmeC102a-2Mab4CSqj4bpgg@mail.gmail.com>
 <20180420053329.GA37680@big-sky.local>
 <CACT4Y+ZZZvHDbiCXXWNVzACU25QZT0j-TbpMpSetuUQFb8Km=Q@mail.gmail.com>
 <20180421210629.GA44181@big-sky.restechservices.net>
 <CAGXu5j+CnH4+6GQ4jsv=4ZZTYgh960QsV69iDpXr56FABzFE_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+CnH4+6GQ4jsv=4ZZTYgh960QsV69iDpXr56FABzFE_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Sat, Apr 21, 2018 at 02:13:30PM -0700, Kees Cook wrote:
> Does this mean we end up with redundant initializers, or are they
> optimized away in later passes?

I believe the plugin results in redundant initializers because the early
inline phase puts the appropriate declarations in the caller's scope.
I guess updating the inline function to have an initializer propagates
the duplicate initializer. I don't understand the complete interactions
here, but this is what I'm seeing. I also can't comment on why they
aren't being optimized out, but I assume it's because they live in
different basic blocks.

By waiting to do it after inlining is done, the inlined functions are
not modified to have initializers as the function that uses the inlined
function should have the initializing code.

Thanks,
Dennis
