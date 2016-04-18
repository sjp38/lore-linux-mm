Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3926B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 11:59:59 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o126so415990224iod.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 08:59:59 -0700 (PDT)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id m27si5016385otd.12.2016.04.18.08.59.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 08:59:58 -0700 (PDT)
Received: by mail-ob0-x233.google.com with SMTP id n10so35958844obb.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 08:59:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJcbSZFoVjdcfKjoajL8mmSfz=BPRALx7=0gw3faE2o-hu1RqQ@mail.gmail.com>
References: <1460741159-51752-1-git-send-email-thgarnie@google.com>
	<20160415150026.65abbdd5b2ef741cd070c769@linux-foundation.org>
	<1460759160.19090.50.camel@perches.com>
	<CAJcbSZFoVjdcfKjoajL8mmSfz=BPRALx7=0gw3faE2o-hu1RqQ@mail.gmail.com>
Date: Mon, 18 Apr 2016 08:59:57 -0700
Message-ID: <CAJcbSZGLABr5xEFeopKTj34bL2P-ss=rChs+AYAP_49r1r0NfA@mail.gmail.com>
Subject: Re: [PATCH] mm: SLAB freelist randomization
From: Thomas Garnier <thgarnie@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kees Cook <keescook@chromium.org>, Greg Thelen <gthelen@google.com>, Laura Abbott <labbott@fedoraproject.org>, kernel-hardening@lists.openwall.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

I will send the next version today. Note that I get_random_bytes_arch
is used because at that stage we have 0 bits of entropy. It seemed
like a better idea to use the arch version that will fallback on
get_random_bytes sub API in the worse case.

On Fri, Apr 15, 2016 at 3:47 PM, Thomas Garnier <thgarnie@google.com> wrote:
> Thanks for the comments. I will address them in a v2 early next week.
>
> If anyone has other comments, please let me know.
>
> Thomas
>
> On Fri, Apr 15, 2016 at 3:26 PM, Joe Perches <joe@perches.com> wrote:
>> On Fri, 2016-04-15 at 15:00 -0700, Andrew Morton wrote:
>>> On Fri, 15 Apr 2016 10:25:59 -0700 Thomas Garnier <thgarnie@google.com> wrote:
>>> > Provide an optional config (CONFIG_FREELIST_RANDOM) to randomize the
>>> > SLAB freelist. The list is randomized during initialization of a new set
>>> > of pages. The order on different freelist sizes is pre-computed at boot
>>> > for performance. This security feature reduces the predictability of the
>>> > kernel SLAB allocator against heap overflows rendering attacks much less
>>> > stable.
>>
>> trivia:
>>
>>> > @@ -1229,6 +1229,61 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
>> []
>>> > + */
>>> > +static freelist_idx_t master_list_2[2];
>>> > +static freelist_idx_t master_list_4[4];
>>> > +static freelist_idx_t master_list_8[8];
>>> > +static freelist_idx_t master_list_16[16];
>>> > +static freelist_idx_t master_list_32[32];
>>> > +static freelist_idx_t master_list_64[64];
>>> > +static freelist_idx_t master_list_128[128];
>>> > +static freelist_idx_t master_list_256[256];
>>> > +static struct m_list {
>>> > +   size_t count;
>>> > +   freelist_idx_t *list;
>>> > +} master_lists[] = {
>>> > +   { ARRAY_SIZE(master_list_2), master_list_2 },
>>> > +   { ARRAY_SIZE(master_list_4), master_list_4 },
>>> > +   { ARRAY_SIZE(master_list_8), master_list_8 },
>>> > +   { ARRAY_SIZE(master_list_16), master_list_16 },
>>> > +   { ARRAY_SIZE(master_list_32), master_list_32 },
>>> > +   { ARRAY_SIZE(master_list_64), master_list_64 },
>>> > +   { ARRAY_SIZE(master_list_128), master_list_128 },
>>> > +   { ARRAY_SIZE(master_list_256), master_list_256 },
>>> > +};
>>
>> static const struct m_list?
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
