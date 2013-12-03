Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id CA2336B003A
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 04:23:04 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id ep20so9047825lab.31
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 01:23:04 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si21078963lby.112.2013.12.03.01.23.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 01:23:03 -0800 (PST)
Message-ID: <529DA2F5.1040602@parallels.com>
Date: Tue, 3 Dec 2013 13:23:01 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 05/18] fs: do not use destroy_super() in alloc_super()
 fail path
References: <cover.1385974612.git.vdavydov@parallels.com> <af90b79aebe9cd9f6e1d35513f2618f4e9888e9b.1385974612.git.vdavydov@parallels.com> <20131203090041.GB8803@dastard>
In-Reply-To: <20131203090041.GB8803@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, Al Viro <viro@zeniv.linux.org.uk>

On 12/03/2013 01:00 PM, Dave Chinner wrote:
> On Mon, Dec 02, 2013 at 03:19:40PM +0400, Vladimir Davydov wrote:
>> Using destroy_super() in alloc_super() fail path is bad, because:
>>
>> * It will trigger WARN_ON(!list_empty(&s->s_mounts)) since s_mounts is
>>   initialized after several 'goto fail's.
> So let's fix that.
>
>> * It will call kfree_rcu() to free the super block although kfree() is
>>   obviously enough there.
>> * The list_lru structure was initially implemented without the ability
>>   to destroy an uninitialized object in mind.
>>
>> I'm going to replace the conventional list_lru with per-memcg lru to
>> implement per-memcg slab reclaim. This new structure will fail
>> destruction of objects that haven't been properly initialized so let's
>> inline appropriate snippets from destroy_super() to alloc_super() fail
>> path instead of using the whole function there.
> You're basically undoing the change made in commit 7eb5e88 ("uninline
> destroy_super(), consolidate alloc_super()") which was done less
> than a month ago. :/
>
> The code as it stands works just fine - the list-lru structures in
> the superblock are actually initialised (to zeros) - and so calling
> list_lru_destroy() on it works just fine in that state as the
> pointers that are freed are NULL. Yes, unexpected, but perfectly
> valid code.
>
> I haven't looked at the internals of the list_lru changes you've
> made yet, but it surprises me that we can't handle this case
> internally to list_lru_destroy().

Actually, I'm not going to modify the list_lru structure, because I
think it's good as it is. I'd like to substitute it with a new
structure, memcg_list_lru, only in those places where this functionality
(per-memcg scanning) is really needed. This new structure would look
like this:

struct memcg_list_lru {
    struct list_lru global_lru;
    struct list_lru **memcg_lrus;
    struct list_head list;
    void *old_lrus;
}

Since old_lrus and memcg_lrus can be NULL under normal operation, in
memcg_list_lru_destroy() I'd have to check either the list or the
global_lru field, i.e. it would look like:

if (!list.next)
    /* has not been initialized */
    return;

or

if (!global_lru.node)
    /* has not been initialized */
    return;

I find both of these checks ugly :-(

Personally, I think that's calling destroy() w/o init() is OK only for
simple structures where destroy/init are inline functions or macros,
otherwise one can forget to "fix" destroy() after it extends a structure.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
