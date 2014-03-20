Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14F966B0248
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 11:40:20 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so811268eek.38
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:40:20 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id d5si3508598eei.208.2014.03.20.08.40.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Mar 2014 08:40:19 -0700 (PDT)
Date: Thu, 20 Mar 2014 15:39:48 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Message-ID: <20140320153948.7e420229@alan.etchedpixels.co.uk>
In-Reply-To: <20140320153250.GC20618@thunk.org>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<20140320153250.GC20618@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tytso@mit.edu
Cc: David Herrmann <dh.herrmann@gmail.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, Kristian@thunk.org, =?UTF-8?B?SMO4Z3NiZXJn?= <krh@bitplanet.net>, ""@thunk.org, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Thu, 20 Mar 2014 11:32:51 -0400
tytso@mit.edu wrote:

> On Wed, Mar 19, 2014 at 08:06:45PM +0100, David Herrmann wrote:
> > 
> > This series introduces the concept of "file sealing". Sealing a file restricts
> > the set of allowed operations on the file in question. Multiple seals are
> > defined and each seal will cause a different set of operations to return EPERM
> > if it is set. The following seals are introduced:
> > 
> >  * SEAL_SHRINK: If set, the inode size cannot be reduced
> >  * SEAL_GROW: If set, the inode size cannot be increased
> >  * SEAL_WRITE: If set, the file content cannot be modified
> 
> Looking at your patches, and what files you are modifying, you are
> enforcing this in the low-level file system.
> 
> Why not make sealing an attribute of the "struct file", and enforce it
> at the VFS layer?  That way all file system objects would have access
> to sealing interface, and for memfd_shmem, you can't get another
> struct file pointing at the object, the security properties would be
> identical.

Would it be more sensible to have a "sealer" which is a "device" which
you give a file handle too and it gives you back a sealable one.

So for the memfd case you'd create a private handle, pass it to the
sealer, and then pass the sealer handles to everyone else.

You have to implicitly trust the creator of the object has
- handed you the object you expect
- sealed it

so that appears no weaker but means you can meaningfully created sealed
versions of arbitary objects and if you want have non-sealed ones around
with it being up to the creator if they want for example to simply close
the unsealed one immediately afterwards.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
