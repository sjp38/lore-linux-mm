Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 60F256B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 07:08:24 -0400 (EDT)
Date: Wed, 24 Apr 2013 13:08:17 +0200 (CEST)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH v3 17/18] ext4: make punch hole code path work with
 bigalloc
In-Reply-To: <20130423091928.GA5321@gmail.com>
Message-ID: <alpine.LFD.2.00.1304241303560.24669@localhost>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com> <1365498867-27782-18-git-send-email-lczerner@redhat.com> <20130420134241.GA2461@quack.suse.cz> <20130423091928.GA5321@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue, 23 Apr 2013, Zheng Liu wrote:

> Date: Tue, 23 Apr 2013 17:19:28 +0800
> From: Zheng Liu <gnehzuil.liu@gmail.com>
> To: Jan Kara <jack@suse.cz>
> Cc: Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org,
>     linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
>     linux-ext4@vger.kernel.org
> Subject: Re: [PATCH v3 17/18] ext4: make punch hole code path work with
>     bigalloc
> 
> On Sat, Apr 20, 2013 at 03:42:41PM +0200, Jan Kara wrote:
> > On Tue 09-04-13 11:14:26, Lukas Czerner wrote:
> > > Currently punch hole is disabled in file systems with bigalloc
> > > feature enabled. However the recent changes in punch hole patch should
> > > make it easier to support punching holes on bigalloc enabled file
> > > systems.
> > > 
> > > This commit changes partial_cluster handling in ext4_remove_blocks(),
> > > ext4_ext_rm_leaf() and ext4_ext_remove_space(). Currently
> > > partial_cluster is unsigned long long type and it makes sure that we
> > > will free the partial cluster if all extents has been released from that
> > > cluster. However it has been specifically designed only for truncate.
> > > 
> > > With punch hole we can be freeing just some extents in the cluster
> > > leaving the rest untouched. So we have to make sure that we will notice
> > > cluster which still has some extents. To do this I've changed
> > > partial_cluster to be signed long long type. The only scenario where
> > > this could be a problem is when cluster_size == block size, however in
> > > that case there would not be any partial clusters so we're safe. For
> > > bigger clusters the signed type is enough. Now we use the negative value
> > > in partial_cluster to mark such cluster used, hence we know that we must
> > > not free it even if all other extents has been freed from such cluster.
> > > 
> > > This scenario can be described in simple diagram:
> > > 
> > > |FFF...FF..FF.UUU|
> > >  ^----------^
> > >   punch hole
> > > 
> > > . - free space
> > > | - cluster boundary
> > > F - freed extent
> > > U - used extent
> > > 
> > > Also update respective tracepoints to use signed long long type for
> > > partial_cluster.
> >   The patch looks OK. You can add:
> > Reviewed-by: Jan Kara <jack@suse.cz>
> > 
> >   Just a minor nit - sometimes you use 'signed long long', sometimes 'long
> > long int', sometimes just 'long long'. In kernel we tend to always use just
> > 'long long' so it would be good to clean that up.
> 
> Another question is that in patch 01/18 invalidatepage signature is
> changed from
>   int (*invalidatepage) (struct page *, unsigned long);
> to
>   void (*invalidatepage) (struct page *, unsigned int, unsigned int);
> 
> The argument type is changed from 'unsigned long' to 'unsigned int'.  My
> question is why we need to change it.
> 
> Thanks,
>                                                 - Zheng
> 

Hi Zheng,

this was changed on Hugh Dickins request because it makes it clearer
that those args are indeed intended to be offsets within a page
(0..PAGE_CACHE_SIZE).

Even though PAGE_CACHE_SIZE can be defined as unsigned long, this is
only for convenience. Here is quote from Hugh:

  "
  They would be defined as unsigned long so that they can be used in
  masks like ~(PAGE_SIZE - 1), and behave as expected on addresses,
  without needing casts to be added all over.

  We do not (currently!) expect PAGE_SIZE or PAGE_CACHE_SIZE to grow
  beyond an unsigned int - but indeed they can be larger than what's
  held in an unsigned short (look no further than ia64 or ppc64).

  For more reassurance, see include/linux/highmem.h, which declares
  zero_user_segments() and others: unsigned int (well, unsigned with
  the int implicit) for offsets within a page.

  Hugh
  "

I should probably mention that in the description.

Thanks!
-Lukas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
