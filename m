Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AFE286B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 04:42:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 192so186402090itm.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 01:42:19 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id r133si13225377oig.44.2016.09.13.01.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 01:42:18 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id o7so7600894oif.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 01:42:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160909194239.GA16056@cmpxchg.org>
References: <CAB3-ZyQ4Mbj2g6b6Zt4pGLhE7ew9O==rNbUgAaPLYSwdRK3Czw@mail.gmail.com>
 <CAJfpeguMfoK+foKxUeSLOw0aD=U+ya6BgpRm2XnFfKx3w2Nfpg@mail.gmail.com> <20160909194239.GA16056@cmpxchg.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 13 Sep 2016 10:42:17 +0200
Message-ID: <CAJfpegv3Hk3WtGG0gQ+TGpyoH0CoTf=um8gUdV8KA-ZneQ8+JA@mail.gmail.com>
Subject: Re: [fuse-devel] Kernel panic under load
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Antonio SJ Musumeci <trapexit@spawn.link>, fuse-devel <fuse-devel@lists.sourceforge.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 9, 2016 at 9:42 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Hi Miklos,
>
> On Fri, Sep 09, 2016 at 04:32:49PM +0200, Miklos Szeredi wrote:
>> On Fri, Sep 9, 2016 at 3:34 PM, Antonio SJ Musumeci <trapexit@spawn.link> wrote:
>> > https://gist.github.com/bauruine/3bc00075c4d0b5b3353071d208ded30f
>> > https://github.com/trapexit/mergerfs/issues/295
>> >
>> > I've some users which are having issues with my filesystem where the
>> > system's load increases and then the kernel panics.
>> >
>> > Has anyone seen this before?
>>
>> Quite possibly this is caused by fuse, but the BUG is deep in mm
>> territory and I have zero clue about what it means.
>>
>> Hannes,  can you please look a the above crash in mm/workingset.c?
>
> The MM maintains a reclaimable list of page cache tree nodes that have
> gone empty (all pages evicted) except for the shadow entries reclaimed
> pages leave behind. When faulting a regular page back into such a node
> the code in page_cache_tree_insert() removes it from the list again:
>
>                 workingset_node_pages_inc(node);
>                 /*
>                  * Don't track node that contains actual pages.
>                  *
>                  * Avoid acquiring the list_lru lock if already
>                  * untracked.  The list_empty() test is safe as
>                  * node->private_list is protected by
>                  * mapping->tree_lock.
>                  */
>                 if (!list_empty(&node->private_list))
>                         list_lru_del(&workingset_shadow_nodes,
>                                      &node->private_list);
>
> The BUG_ON() triggers when we later walk the reclaimable list and find
> a radix tree node that has actual pages in it. This could happen when
> pages are inserted into a mapping without using add_to_page_cache and
> related functions. Does that maybe ring a bell?

Fuse allows pages to be spliced into the page cache when reading the
file.  It does this with replace_page_cache_page(), which is an atomic
version of delete_from_page_cache()+add_to_page_cache().

Fuse is the only user of replace_page_cache_page(), so I imagine bugs
can more easily escape notice than the more commonly used variants.

Could you please take a look at this function.  "git blame" shows that
it's older than the add/remove variants, but I haven't gone into the
details.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
