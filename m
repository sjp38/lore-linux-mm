Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 900826B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 07:44:26 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id y20so2461132ier.36
        for <linux-mm@kvack.org>; Mon, 19 May 2014 04:44:26 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id eo10si9941870icb.68.2014.05.19.04.44.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 04:44:25 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so2448080iec.40
        for <linux-mm@kvack.org>; Mon, 19 May 2014 04:44:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1405141456420.2268@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
	<alpine.LSU.2.11.1405132118330.4401@eggly.anvils>
	<537396A2.9090609@cybernetics.com>
	<alpine.LSU.2.11.1405141456420.2268@eggly.anvils>
Date: Mon, 19 May 2014 13:44:25 +0200
Message-ID: <CANq1E4QgSbD9G70H7W4QeXbZ77_Kn1wV7edwzN4k4NjQJS=36A@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tony Battersby <tonyb@cybernetics.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

Hi

On Thu, May 15, 2014 at 12:35 AM, Hugh Dickins <hughd@google.com> wrote:
> The aspect which really worries me is this: the maintenance burden.
> This approach would add some peculiar new code, introducing a rare
> special case: which we might get right today, but will very easily
> forget tomorrow when making some other changes to mm.  If we compile
> a list of danger areas in mm, this would surely belong on that list.

I tried doing the page-replacement in the last 4 days, but honestly,
it's far more complex than I thought. So if no-one more experienced
with mm/ comes up with a simple implementation, I'll have to delay
this for some more weeks.

However, I still wonder why we try to fix this as part of this
patchset. Using FUSE, a DIRECT-IO call can be delayed for an arbitrary
amount of time. Same is true for network block-devices, NFS, iscsi,
maybe loop-devices, ... This means, _any_ once mapped page can be
written to after an arbitrary delay. This can break any feature that
makes FS objects read-only (remounting read-only, setting S_IMMUTABLE,
sealing, ..).

Shouldn't we try to fix the _cause_ of this?

Isn't there a simple way to lock/mark/.. affected vmas in
get_user_pages(_fast)() and release them once done? We could increase
i_mmap_writable on all affected address_space and decrease it on
release. This would at least prevent sealing and could be check on
other operations, too (like setting S_IMMUTABLE).
This should be as easy as checking page_mapping(page) != NULL and then
adjusting ->i_mmap_writable in
get_writable_user_pages/put_writable_user_pages, right?

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
