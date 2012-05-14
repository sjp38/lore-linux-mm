Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id EB6826B0081
	for <linux-mm@kvack.org>; Mon, 14 May 2012 15:48:34 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9423238pbb.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 12:48:34 -0700 (PDT)
Date: Mon, 14 May 2012 12:48:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/10] tmpfs: enable NOSEC optimization
In-Reply-To: <4FB0D1C6.7090801@gmail.com>
Message-ID: <alpine.LSU.2.00.1205141242530.1623@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils> <alpine.LSU.2.00.1205120500040.28861@eggly.anvils> <4FB0D1C6.7090801@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 14 May 2012, Cong Wang wrote:
> On 05/12/2012 08:02 PM, Hugh Dickins wrote:
> > Let tmpfs into the NOSEC optimization (avoiding file_remove_suid()
> > overhead on most common writes): set MS_NOSEC on its superblocks.
> > 
> > Signed-off-by: Hugh Dickins<hughd@google.com>
> > ---
> >   mm/shmem.c |    1 +
> >   1 file changed, 1 insertion(+)
> > 
> > --- 3045N.orig/mm/shmem.c	2012-05-05 10:45:17.888060878 -0700
> > +++ 3045N/mm/shmem.c	2012-05-05 10:46:05.732062006 -0700
> > @@ -2361,6 +2361,7 @@ int shmem_fill_super(struct super_block
> >   		}
> >   	}
> >   	sb->s_export_op =&shmem_export_ops;
> > +	sb->s_flags |= MS_NOSEC;
> 
> Isn't setting the flag on inode better? Something like:

I don't think so.  The MS_NOSEC S_NOSEC business is fairly subtle,
and easy to miss if it's gone wrong, so I would much rather follow
the established pattern in local block filesystems: which is to set
MS_NOSEC in superblock flags, and leave S_NOSEC to file_remove_suid().

Hugh

> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index f99ff3e..7d98fb5 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2325,6 +2325,7 @@ static void shmem_init_inode(void *foo)
>  {
>         struct shmem_inode_info *info = foo;
>         inode_init_once(&info->vfs_inode);
> +       info->vfs_inode.i_flags |= S_NOSEC;
>  }
> 
>  static int shmem_init_inodecache(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
