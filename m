Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id E06966B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 18:50:16 -0500 (EST)
Received: by wesw62 with SMTP id w62so8287640wes.9
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 15:50:16 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id bk1si49306693wjb.171.2015.02.20.15.50.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 15:50:15 -0800 (PST)
Date: Fri, 20 Feb 2015 23:50:12 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] fs: avoid locking sb_lock in grab_super_passive()
Message-ID: <20150220235012.GS29656@ZenIV.linux.org.uk>
References: <20150219171934.20458.30175.stgit@buzz>
 <20150220150731.e79cd30dc6ecf3c7a3f5caa3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150220150731.e79cd30dc6ecf3c7a3f5caa3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>

On Fri, Feb 20, 2015 at 03:07:31PM -0800, Andrew Morton wrote:

> - It no longer "acquires a reference".  All it does is to acquire an rwsem.
> 
> - What the heck is a "passive reference" anyway?  It appears to be
>   the situation where we increment s_count without incrementing s_active.

Reference to struct super_block that guarantees only that its memory won't
be freed until we drop it.

>   After your patch, this superblock state no longer exists(?),

Yes, it does.  The _only_ reason why that patch isn't outright bogus is that
we do only down_read_trylock() on ->s_umount - try to pull off the same thing
with down_read() and you'll get a nasty race.  Take a look at e.g.
get_super().  Or user_get_super().  Or iterate_supers()/iterate_supers_type(),
where we don't return such references, but pass them to a callback instead.
In all those cases we end up with passive reference taken, ->s_umount
taken shared (_NOT_ with trylock) and fs checked for being still alive.
Then it's guaranteed to stay alive until we do drop_super().

I agree that the name blows, BTW - something like try_get_super() might have
been more descriptive, but with this change it actually becomes a bad name
as well, since after it we need a different way to release the obtained ref;
not the same as after get_super().  Your variant might be OK, but I'd
probably make it trylock_super(), to match the verb-object order of the
rest of identifiers in that area...

> so
>   perhaps the entire "passive reference" concept and any references to
>   it can be expunged from the kernel.

Nope.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
