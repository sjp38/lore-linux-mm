Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 3103A6B0033
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 05:02:09 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id 10so304871pdc.28
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 02:02:08 -0700 (PDT)
Date: Tue, 23 Apr 2013 17:19:28 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: [PATCH v3 17/18] ext4: make punch hole code path work with
 bigalloc
Message-ID: <20130423091928.GA5321@gmail.com>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com>
 <1365498867-27782-18-git-send-email-lczerner@redhat.com>
 <20130420134241.GA2461@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130420134241.GA2461@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Sat, Apr 20, 2013 at 03:42:41PM +0200, Jan Kara wrote:
> On Tue 09-04-13 11:14:26, Lukas Czerner wrote:
> > Currently punch hole is disabled in file systems with bigalloc
> > feature enabled. However the recent changes in punch hole patch should
> > make it easier to support punching holes on bigalloc enabled file
> > systems.
> > 
> > This commit changes partial_cluster handling in ext4_remove_blocks(),
> > ext4_ext_rm_leaf() and ext4_ext_remove_space(). Currently
> > partial_cluster is unsigned long long type and it makes sure that we
> > will free the partial cluster if all extents has been released from that
> > cluster. However it has been specifically designed only for truncate.
> > 
> > With punch hole we can be freeing just some extents in the cluster
> > leaving the rest untouched. So we have to make sure that we will notice
> > cluster which still has some extents. To do this I've changed
> > partial_cluster to be signed long long type. The only scenario where
> > this could be a problem is when cluster_size == block size, however in
> > that case there would not be any partial clusters so we're safe. For
> > bigger clusters the signed type is enough. Now we use the negative value
> > in partial_cluster to mark such cluster used, hence we know that we must
> > not free it even if all other extents has been freed from such cluster.
> > 
> > This scenario can be described in simple diagram:
> > 
> > |FFF...FF..FF.UUU|
> >  ^----------^
> >   punch hole
> > 
> > . - free space
> > | - cluster boundary
> > F - freed extent
> > U - used extent
> > 
> > Also update respective tracepoints to use signed long long type for
> > partial_cluster.
>   The patch looks OK. You can add:
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
>   Just a minor nit - sometimes you use 'signed long long', sometimes 'long
> long int', sometimes just 'long long'. In kernel we tend to always use just
> 'long long' so it would be good to clean that up.

Another question is that in patch 01/18 invalidatepage signature is
changed from
  int (*invalidatepage) (struct page *, unsigned long);
to
  void (*invalidatepage) (struct page *, unsigned int, unsigned int);

The argument type is changed from 'unsigned long' to 'unsigned int'.  My
question is why we need to change it.

Thanks,
                                                - Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
