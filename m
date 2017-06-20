Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03D796B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 18:27:47 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id s131so118588398itd.6
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:27:46 -0700 (PDT)
Received: from mail-it0-x236.google.com (mail-it0-x236.google.com. [2607:f8b0:4001:c0b::236])
        by mx.google.com with ESMTPS id k66si29246iod.85.2017.06.20.15.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 15:27:46 -0700 (PDT)
Received: by mail-it0-x236.google.com with SMTP id m47so22428744iti.1
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:27:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170620044721.GE610@zzz.localdomain>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-23-git-send-email-keescook@chromium.org> <20170620044721.GE610@zzz.localdomain>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 20 Jun 2017 15:27:44 -0700
Message-ID: <CAGXu5jLUy7SFgC_5Rze=MuDoiz7=G2n60uw8792OvjJTcKsojA@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCH 22/23] usercopy: split user-controlled
 slabs to separate caches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, David Windsor <dave@nullcore.net>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 19, 2017 at 9:47 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> On Mon, Jun 19, 2017 at 04:36:36PM -0700, Kees Cook wrote:
>> From: David Windsor <dave@nullcore.net>
>>
>> Some userspace APIs (e.g. ipc, seq_file) provide precise control over
>> the size of kernel kmallocs, which provides a trivial way to perform
>> heap overflow attacks where the attacker must control neighboring
>> allocations of a specific size. Instead, move these APIs into their own
>> cache so they cannot interfere with standard kmallocs. This is enabled
>> with CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC.
>>
>> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY_SLABS
>> code in the last public patch of grsecurity/PaX based on my understanding
>> of the code. Changes or omissions from the original code are mine and
>> don't reflect the original grsecurity/PaX code.
>>
>> Signed-off-by: David Windsor <dave@nullcore.net>
>> [kees: added SLAB_NO_MERGE flag to allow split of future no-merge Kconfig]
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>>  fs/seq_file.c        |  2 +-
>>  include/linux/gfp.h  |  9 ++++++++-
>>  include/linux/slab.h | 12 ++++++++++++
>>  ipc/msgutil.c        |  5 +++--
>>  mm/slab.h            |  3 ++-
>>  mm/slab_common.c     | 29 ++++++++++++++++++++++++++++-
>>  security/Kconfig     | 12 ++++++++++++
>>  7 files changed, 66 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/seq_file.c b/fs/seq_file.c
>> index dc7c2be963ed..5caa58a19bdc 100644
>> --- a/fs/seq_file.c
>> +++ b/fs/seq_file.c
>> @@ -25,7 +25,7 @@ static void seq_set_overflow(struct seq_file *m)
>>
>>  static void *seq_buf_alloc(unsigned long size)
>>  {
>> -     return kvmalloc(size, GFP_KERNEL);
>> +     return kvmalloc(size, GFP_KERNEL | GFP_USERCOPY);
>>  }
>>
>
> Also forgot to mention the obvious: there are way more places where GFP_USERCOPY
> would need to be (or should be) used.  Helper functions like memdup_user() and
> memdup_user_nul() would be the obvious ones.  And just a random example, some of
> the keyrings syscalls (callable with no privileges) do a kmalloc() with
> user-controlled contents and size.

Looking again at how grsecurity uses it, they have some of those call
sites a couple more (keyctl, char/mem, kcore, memdup_user). Getting
the facility in place at all is a good first step, IMO.

>
> So I think this by itself needs its own patch series.

Sounds reasonable.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
