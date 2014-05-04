Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1FEFB6B0037
	for <linux-mm@kvack.org>; Sun,  4 May 2014 16:39:08 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id q58so6762846wes.34
        for <linux-mm@kvack.org>; Sun, 04 May 2014 13:39:07 -0700 (PDT)
Received: from mail-we0-x22a.google.com (mail-we0-x22a.google.com [2a00:1450:400c:c03::22a])
        by mx.google.com with ESMTPS id ht5si3452573wjb.236.2014.05.04.13.39.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 04 May 2014 13:39:06 -0700 (PDT)
Received: by mail-we0-f170.google.com with SMTP id u57so168942wes.1
        for <linux-mm@kvack.org>; Sun, 04 May 2014 13:39:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140502200152.GA18670@cerebellum.variantweb.net>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
 <1397922764-1512-3-git-send-email-ddstreet@ieee.org> <CAL1ERfMPcfyUeACnmZ2QF5WxJUQ2PaKbtRzis8sPbQsjnvf_GQ@mail.gmail.com>
 <20140502200152.GA18670@cerebellum.variantweb.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Sun, 4 May 2014 16:38:45 -0400
Message-ID: <CALZtOND53YUquVgSQKnuojAan=4m4-LaR53v1dFo2RmJ0L3UWw@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm: zpool: implement zsmalloc shrinking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Weijie Yang <weijie.yang.kh@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijie.yang@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, May 2, 2014 at 4:01 PM, Seth Jennings <sjennings@variantweb.net> wrote:
> On Sat, Apr 26, 2014 at 04:37:31PM +0800, Weijie Yang wrote:
>> On Sat, Apr 19, 2014 at 11:52 PM, Dan Streetman <ddstreet@ieee.org> wrote:
>> > Add zs_shrink() and helper functions to zsmalloc.  Update zsmalloc
>> > zs_create_pool() creation function to include ops param that provides
>> > an evict() function for use during shrinking.  Update helper function
>> > fix_fullness_group() to always reinsert changed zspages even if the
>> > fullness group did not change, so they are updated in the fullness
>> > group lru.  Also update zram to use the new zsmalloc pool creation
>> > function but pass NULL as the ops param, since zram does not use
>> > pool shrinking.
>> >
>>
>> I only review the code without test, however, I think this patch is
>> not acceptable.
>>
>> The biggest problem is it will call zswap_writeback_entry() under lock,
>> zswap_writeback_entry() may sleep, so it is a bug. see below
>>
>> The 3/4 patch has a lot of #ifdef, I don't think it's a good kind of
>> abstract way.
>>
>> What about just disable zswap reclaim when using zsmalloc?
>
> I agree here.  Making a generic allocator layer and zsmalloc reclaim
> support should be two different efforts, since zsmalloc reclaim is
> fraught with peril.

fair enough - I'm fairly sure it's doable with only minimal changes to
the current patch, but it's certainly true that there's no reason it
has to be done in the same patchset as the generic layer.

I'll remove it from the v2 patchset.

> The generic layer can be done though, as long as you provide a way for
> the backend to indicate that it doesn't support reclaim, which just
> results in lru-inverse overflow to the swap device at the zswap layer.
> Hopefully, if the user overrides the default to use zsmalloc, they
> understand the implications and have sized their workload properly.
>
> Also, the fallback logic shouldn't be in this generic layer.  It should
> not be transparent to the user.  The user (in this case zswap) should
> implement the fallback if they care to have it.  The generic allocator
> layer makes it trivial for the user to implement.

ok, makes sense, certainly when there's currently only 1 user and 2 backends ;-)

>
> Thanks,
> Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
