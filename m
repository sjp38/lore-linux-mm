Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8672C6B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 21:06:50 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so161048736pac.2
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 18:06:50 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id pr9si24242562pbc.59.2015.09.27.18.06.48
        for <linux-mm@kvack.org>;
        Sun, 27 Sep 2015 18:06:49 -0700 (PDT)
Date: Mon, 28 Sep 2015 11:06:29 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: fix cpu hangs on truncating last page of a 16t
 sparse file
Message-ID: <20150928010629.GZ19114@dastard>
References: <560723F8.3010909@gmail.com>
 <alpine.LSU.2.11.1509261835360.9917@eggly.anvils>
 <560752C7.80605@gmail.com>
 <alpine.LSU.2.11.1509270953460.1024@eggly.anvils>
 <20150927232645.GW3902@dastard>
 <20150927195655.18e20003@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150927195655.18e20003@tlielax.poochiereds.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Hugh Dickins <hughd@google.com>, angelo <angelo70@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Eryu Guan <eguan@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, Sep 27, 2015 at 07:56:55PM -0400, Jeff Layton wrote:
> On Mon, 28 Sep 2015 09:26:45 +1000 Dave Chinner <david@fromorbit.com> wrote:
> > On Sun, Sep 27, 2015 at 10:59:33AM -0700, Hugh Dickins wrote:
> > > > But if s_maxbytes doesn't have to be greater than MAX_LFS_FILESIZE,
> > > > i agree the issue should be fixed in layers above.
> > > 
> > > There is a "filesystems should never set s_maxbytes larger than
> > > MAX_LFS_FILESIZE" comment in fs/super.c, but unfortunately its
> > > warning is written with just 64-bit in mind (testing for negative).
> > 
> > Yup, introduced here:
> > 
> > commit 42cb56ae2ab67390da34906b27bedc3f2ff1393b
> > Author: Jeff Layton <jlayton@redhat.com>
> > Date:   Fri Sep 18 13:05:53 2009 -0700
> > 
> >     vfs: change sb->s_maxbytes to a loff_t
> >     
> >     sb->s_maxbytes is supposed to indicate the maximum size of a file that can
> >     exist on the filesystem.  It's declared as an unsigned long long.
> > 
> > And yes, that will never fire on a 32bit filesystem, because loff_t
> > is a "long long" type....
> > 
> 
> Hmm...should we change that to something like this instead?
> 
>     WARN(((unsigned long long)sb->s_maxbytes > (unsigned long long)MAX_LFS_FILESIZE,
> 	"%s set sb->s_maxbytes to too large a value (0x%llx)\n", type->name, sb->s_maxbytes);

Well, it doesn't change the fact that we've actually been supporting
sb->s_maxbytes > MAX_LFS_FILESIZE for a long time on 32 bit systems.
And it's pretty unfriendly to start issuing warnings on every mount
of every XFS filesystem on every 32 bit system in existence for
something we've explicitly supported since 2.4 kernels...

I suspect the warning should have been removed back in 2.6.34 like
was originally intended. :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
