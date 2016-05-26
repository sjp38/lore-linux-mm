Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f70.google.com (mail-qg0-f70.google.com [209.85.192.70])
	by kanga.kvack.org (Postfix) with ESMTP id C50386B025F
	for <linux-mm@kvack.org>; Thu, 26 May 2016 14:50:32 -0400 (EDT)
Received: by mail-qg0-f70.google.com with SMTP id k63so145286284qgf.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 11:50:32 -0700 (PDT)
Received: from mail-yw0-x22c.google.com (mail-yw0-x22c.google.com. [2607:f8b0:4002:c05::22c])
        by mx.google.com with ESMTPS id w70si3147833yww.392.2016.05.26.11.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 11:50:32 -0700 (PDT)
Received: by mail-yw0-x22c.google.com with SMTP id o16so85251154ywd.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 11:50:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160526010951.GC9302@js1304-P5Q-DELUXE>
References: <1464124523-43051-1-git-send-email-thgarnie@google.com>
 <1464124523-43051-2-git-send-email-thgarnie@google.com> <20160526010951.GC9302@js1304-P5Q-DELUXE>
From: Thomas Garnier <thgarnie@google.com>
Date: Thu, 26 May 2016 11:50:31 -0700
Message-ID: <CAJcbSZHgEr-vJ=yN+hwEzdc1ZpsLG2ZLfOo53yB8sB8e5wy+NA@mail.gmail.com>
Subject: Re: [RFC v2 1/2] mm: Reorganize SLAB freelist randomization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, kernel-hardening@lists.openwall.com

On Wed, May 25, 2016 at 6:09 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Tue, May 24, 2016 at 02:15:22PM -0700, Thomas Garnier wrote:
>> This commit reorganizes the previous SLAB freelist randomization to
>> prepare for the SLUB implementation. It moves functions that will be
>> shared to slab_common. It also move the definition of freelist_idx_t in
>> the slab_def header so a similar type can be used for all common
>> functions. The entropy functions are changed to align with the SLUB
>> implementation, now using get_random_* functions.
>
> Could you explain more what's the difference between get_random_*
> and get_random_bytes_arch() and why this change is needed?
>
> And, I think that it should be another patch.
>

Sure. From my test (limited scenario), get_random_bytes_arch was much
slower than get_random_int when the random instructions were not
available. It also seems from looking at both implementation that
get_random_int may provide a bit more entropy at this early stage.

>>
>> Signed-off-by: Thomas Garnier <thgarnie@google.com>
>> ---
>> Based on 0e01df100b6bf22a1de61b66657502a6454153c5
>> ---
>>  include/linux/slab_def.h | 11 +++++++-
>>  mm/slab.c                | 68 ++----------------------------------------------
>>  mm/slab.h                | 16 ++++++++++++
>>  mm/slab_common.c         | 48 ++++++++++++++++++++++++++++++++++
>>  4 files changed, 76 insertions(+), 67 deletions(-)
>>
>> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
>> index 8694f7a..e05a871 100644
>> --- a/include/linux/slab_def.h
>> +++ b/include/linux/slab_def.h
>> @@ -3,6 +3,15 @@
>>
>>  #include <linux/reciprocal_div.h>
>>
>> +#define FREELIST_BYTE_INDEX (((PAGE_SIZE >> BITS_PER_BYTE) \
>> +                             <= SLAB_OBJ_MIN_SIZE) ? 1 : 0)
>> +
>> +#if FREELIST_BYTE_INDEX
>> +typedef unsigned char freelist_idx_t;
>> +#else
>> +typedef unsigned short freelist_idx_t;
>> +#endif
>> +
>
> This is a SLAB specific index size definition and I don't want to export
> it to SLUB. Please use 'void *random_seq' and allocate sizeof(void *)
> memory for each entry. And, then do type casting when suffling in
> SLAB. There is some memory waste but not that much so we can tolerate
> it.
>
> Others look fine to me.
>

Ok, will do. Thanks.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
