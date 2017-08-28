Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62C136B04B6
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:57:16 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id y7so2119011oia.7
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:57:16 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id g137si1011374oib.293.2017.08.28.14.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:57:15 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id k22so8446716iod.2
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:57:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170828214957.GJ4757@magnolia>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org> <20170828214957.GJ4757@magnolia>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 28 Aug 2017 14:57:14 -0700
Message-ID: <CAGXu5j+pvxRjASUuBE49+uH34Mw26a4mtcWrZd=CEqcRHjetvA@mail.gmail.com>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, linux-xfs@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Mon, Aug 28, 2017 at 2:49 PM, Darrick J. Wong
<darrick.wong@oracle.com> wrote:
> On Mon, Aug 28, 2017 at 02:34:56PM -0700, Kees Cook wrote:
>> From: David Windsor <dave@nullcore.net>
>>
>> The XFS inline inode data, stored in struct xfs_inode_t field
>> i_df.if_u2.if_inline_data and therefore contained in the xfs_inode slab
>> cache, needs to be copied to/from userspace.
>>
>> cache object allocation:
>>     fs/xfs/xfs_icache.c:
>>         xfs_inode_alloc(...):
>>             ...
>>             ip = kmem_zone_alloc(xfs_inode_zone, KM_SLEEP);
>>
>>     fs/xfs/libxfs/xfs_inode_fork.c:
>>         xfs_init_local_fork(...):
>>             ...
>>             if (mem_size <= sizeof(ifp->if_u2.if_inline_data))
>>                     ifp->if_u1.if_data = ifp->if_u2.if_inline_data;
>
> Hmm, what happens when mem_size > sizeof(if_inline_data)?  A slab object
> will be allocated for ifp->if_u1.if_data which can then be used for
> readlink in the same manner as the example usage trace below.  Does
> that allocated object have a need for a usercopy annotation like
> the one we're adding for if_inline_data?  Or is that already covered
> elsewhere?

Yeah, the xfs helper kmem_alloc() is used in the other case, which
ultimately boils down to a call to kmalloc(), which is entirely
whitelisted by an earlier patch in the series:

https://lkml.org/lkml/2017/8/28/1026

(It's possible that at some future time we can start segregating
kernel-only kmallocs from usercopy-able kmallocs, but for now, there
are no plans for this.)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
