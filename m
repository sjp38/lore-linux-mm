Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5406B0258
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 02:45:00 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id xx9so14459171obc.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 23:45:00 -0800 (PST)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id ps8si20528527obb.57.2016.02.28.23.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 23:44:59 -0800 (PST)
Received: by mail-oi0-x233.google.com with SMTP id m82so99351080oif.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 23:44:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1602282042110.1472@eggly.anvils>
References: <alpine.LSU.2.11.1602282042110.1472@eggly.anvils>
Date: Mon, 29 Feb 2016 16:44:59 +0900
Message-ID: <CAAmzW4PAxFLN7GveeU11HQG1WQJa_VF0tO0YJ0hvCbredK6wag@mail.gmail.com>
Subject: Re: [PATCH] mm: __delete_from_page_cache WARN_ON(page_mapped)
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sasha Levin <sasha.levin@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-02-29 13:49 GMT+09:00 Hugh Dickins <hughd@google.com>:
> Commit e1534ae95004 ("mm: differentiate page_mapped() from page_mapcount()
> for compound pages") changed the famous BUG_ON(page_mapped(page)) in
> __delete_from_page_cache() to VM_BUG_ON_PAGE(page_mapped(page)): which
> gives us more info when CONFIG_DEBUG_VM=y, but nothing at all when not.
>
> Although it has not usually been very helpul, being hit long after the
> error in question, we do need to know if it actually happens on users'
> systems; but reinstating a crash there is likely to be opposed :)
>
> In the non-debug case, use WARN_ON() plus dump_page() and add_taint() -
> I don't really believe LOCKDEP_NOW_UNRELIABLE, but that seems to be the
> standard procedure now.  Move that, or the VM_BUG_ON_PAGE(), up before
> the deletion from tree: so that the unNULLified page->mapping gives a
> little more information.
>
> If the inode is being evicted (rather than truncated), it won't have
> any vmas left, so it's safe(ish) to assume that the raised mapcount is
> erroneous, and we can discount it from page_count to avoid leaking the
> page (I'm less worried by leaking the occasional 4kB, than losing a
> potential 2MB page with each 4kB page leaked).
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> I think this should go into v4.5, so I've written it with an atomic_sub
> on page->_count; but Joonsoo will probably want some page_ref thingy.

Okay. I will do it after this patch is merged.

Thanks for notification.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
