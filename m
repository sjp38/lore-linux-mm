Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1156B0038
	for <linux-mm@kvack.org>; Mon, 19 May 2014 12:09:48 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so3757426eek.35
        for <linux-mm@kvack.org>; Mon, 19 May 2014 09:09:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si15510895eeq.317.2014.05.19.09.09.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 09:09:47 -0700 (PDT)
Date: Mon, 19 May 2014 18:09:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 0/3] File Sealing & memfd_create()
Message-ID: <20140519160942.GD3427@quack.suse.cz>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
 <alpine.LSU.2.11.1405132118330.4401@eggly.anvils>
 <537396A2.9090609@cybernetics.com>
 <alpine.LSU.2.11.1405141456420.2268@eggly.anvils>
 <CANq1E4QgSbD9G70H7W4QeXbZ77_Kn1wV7edwzN4k4NjQJS=36A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANq1E4QgSbD9G70H7W4QeXbZ77_Kn1wV7edwzN4k4NjQJS=36A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

On Mon 19-05-14 13:44:25, David Herrmann wrote:
> Hi
> 
> On Thu, May 15, 2014 at 12:35 AM, Hugh Dickins <hughd@google.com> wrote:
> > The aspect which really worries me is this: the maintenance burden.
> > This approach would add some peculiar new code, introducing a rare
> > special case: which we might get right today, but will very easily
> > forget tomorrow when making some other changes to mm.  If we compile
> > a list of danger areas in mm, this would surely belong on that list.
> 
> I tried doing the page-replacement in the last 4 days, but honestly,
> it's far more complex than I thought. So if no-one more experienced
> with mm/ comes up with a simple implementation, I'll have to delay
> this for some more weeks.
> 
> However, I still wonder why we try to fix this as part of this
> patchset. Using FUSE, a DIRECT-IO call can be delayed for an arbitrary
> amount of time. Same is true for network block-devices, NFS, iscsi,
> maybe loop-devices, ... This means, _any_ once mapped page can be
> written to after an arbitrary delay. This can break any feature that
> makes FS objects read-only (remounting read-only, setting S_IMMUTABLE,
> sealing, ..).
> 
> Shouldn't we try to fix the _cause_ of this?
> 
> Isn't there a simple way to lock/mark/.. affected vmas in
> get_user_pages(_fast)() and release them once done? We could increase
> i_mmap_writable on all affected address_space and decrease it on
> release. This would at least prevent sealing and could be check on
> other operations, too (like setting S_IMMUTABLE).
> This should be as easy as checking page_mapping(page) != NULL and then
> adjusting ->i_mmap_writable in
> get_writable_user_pages/put_writable_user_pages, right?
  Doing this would be quite a bit of work. Currently references returned by
get_user_pages() are page references like any other and thus are released
by put_page() or similar. Now you would make them special and they need
special releasing and there are lots of places in kernel where
get_user_pages() is used that would need changing.

Another aspect is that it could have performance implications - if there
are several processes using get_user_pages[_fast]() on a file, they would
start contending on modifying i_mmap_writeable.

One somewhat crazy idea I have is that maybe we could delay unmapping of a
page if this was last VMA referencing it until all extra page references of
pages in there are dropped. That would make i_mmap_writeable reliable for
you and it would also close those races with remount. Hugh, do you think
this might be viable?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
