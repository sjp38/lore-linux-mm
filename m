Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A083BC282DE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 06:06:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1772320870
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 06:06:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ji7NkpUR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1772320870
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C6506B0289; Mon,  8 Apr 2019 02:06:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 775586B028A; Mon,  8 Apr 2019 02:06:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63C2E6B028B; Mon,  8 Apr 2019 02:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 386776B0289
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 02:06:18 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id d198so5205229oih.6
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 23:06:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=O8fhP7MTrb7vcIfbq/cK/Nbd62lMw4Pjk4U5VIIsmiw=;
        b=Z3IOpt7Xy/ZX0R+79723PSgAmL4s59agO+K3vU7WqmSvcyxz/XyBVfUcYSn+H8kGeX
         OCIxhqtWbyUWzF0Fl6GdPnNzplFqPXSe3onQCNroO1Y3V+r1yoFLCbwSjV5yZ7c1x1z1
         3utoAEcDWlBRsKQfRHHueju3PEci7dM8IJfCKtB2OndPVeHltacvVvxfopzCE6F7YsYH
         vVQP2VDgDpHN/4fkj4SvlYQXiUhzw9FVP/QlWKRmCkkYN+OQZavjSVWzCENBRdoDjYxm
         C8tnwZ3CyajAj13CNsyAgBafhUo61r5bOdeE4GCNtAN3J8/+UPaYMrQsYyESHBRMc9GN
         t2Fw==
X-Gm-Message-State: APjAAAUD8fkJDxs0B9o+K2wwhcvMqRi4Nc8gCG/UlsQdjZjfDMcfN8HQ
	p+TKQfdajW1UQX7P32dp7a1d3LrvoPTxp4Yl04+wow0CFXm3PJd2PKMyO/wJwj0LkkIp426DdQV
	VON81FMb1OnTTi9NJJLf62L5Uj4ji4pjhH7RY414vXSnQ9mO38pr8WK4wIrDLwhaVyQ==
X-Received: by 2002:aca:5108:: with SMTP id f8mr14511741oib.55.1554703577776;
        Sun, 07 Apr 2019 23:06:17 -0700 (PDT)
X-Received: by 2002:aca:5108:: with SMTP id f8mr14511698oib.55.1554703576700;
        Sun, 07 Apr 2019 23:06:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554703576; cv=none;
        d=google.com; s=arc-20160816;
        b=KAsuwElxcQAAIeY2NnD1PwbB55DjbnfIJFqFhjMYOtrLF/ZCUAAaXZC8zJaPgF0pmO
         wm5X8wRq2OVr3EqFybxnFnXNgc/b+nA+bdrhfcYFOqp5ehpjGQT2HO/PZ5fWQyEfxvIG
         5Zc+sJj9INoJa+TRSq55aKuWXzxrGLroTJlC5FWfkne5HV9tHWt05YO1lDT3DvV4rPXR
         Nl5ZQBXblQRZXtea+AsN1/0w7RGujBKwZXCpJokfAAG9ID3aey6Bq4mbaVlMtacD+Z0m
         PDRHvaQG2QICQHVxSYf4Lud/XKO4ozHuTtW4gR2ZbvqcxMgZRuj1556lNh5i1BhYAyi0
         UkdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=O8fhP7MTrb7vcIfbq/cK/Nbd62lMw4Pjk4U5VIIsmiw=;
        b=wKufef+9mk618Daw4P1vEnTDtE5ZvfY9K61e6Q2Ib95EQrh85DmoUeg3PX0ByjxC7A
         vTQwIQa6E1yhcM50e/mK6MGGH8hwFw6IJNifYqXKDC2sLFFEqdpEVgJ2LipQdWwHXQDw
         OLA+7EAQSM5PX4zQ1VwaMRum4ZfUcNXuA6oU5S5gzTPUJJfjopNxahdrCvF/AbQAh21n
         7XxjhrT1IE3Iqa+IMyK+OtPfLxvjXpegnmqaPnG9kCyUFtyxYbWZ0gBQOO29IeHPBZeF
         8BcMPI/JVjjJmUE/hRuaz52T4icdSHWpjrt8JiwfeWX/zOI4yrO4SgOz7AViiMziI9Zh
         OB9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ji7NkpUR;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b201sor16412074oii.81.2019.04.07.23.06.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Apr 2019 23:06:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ji7NkpUR;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=O8fhP7MTrb7vcIfbq/cK/Nbd62lMw4Pjk4U5VIIsmiw=;
        b=Ji7NkpURfAytc1eTHOw2wlMgME+/bV9nlNon9Gf52i3a8gH+fzUX0ZaSihzSLtFTPF
         RrJG25mn002IO/2FBD23MAssgSM1LBV3w6S5ONEXqR4hPEGpMKsdaCuMPuTU9etiRJ1f
         Fp9b7tfVBc7Y/AODAa8RUbAhd2Zf2dHPaNyYqJ5yzELe5ru8eOoevxXtQaAoc1fidzWf
         Q3npjmwWUkjN7apsfw3YslegAFGUuQ46r2CLm+1Xf3pKaHnMVseZCoJXgDSDYuNINZq9
         SIi3asRejBRm7QnwI1oslUKhOq5ZKx2BcmX9kGF9wvpFOFKDiHQt1dR/IPMOvtBj8pAh
         5l2A==
X-Google-Smtp-Source: APXvYqz+1gD/54t0vj1R5QABNnonT215Zq9LtLVrxaztGiUDtZoDbzv8XW3STUfI5WLiXm1sfkLEqw==
X-Received: by 2002:aca:3e05:: with SMTP id l5mr14003535oia.22.1554703576057;
        Sun, 07 Apr 2019 23:06:16 -0700 (PDT)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id b51sm14395562otc.8.2019.04.07.23.06.14
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 07 Apr 2019 23:06:15 -0700 (PDT)
Date: Sun, 7 Apr 2019 23:05:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
cc: Hugh Dickins <hughd@google.com>, "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Kelley Nielsen <kelleynnn@gmail.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: shmem_recalc_inode: unable to handle kernel NULL pointer
 dereference
In-Reply-To: <56deb587-8cd6-317a-520f-209207468c55@yandex-team.ru>
Message-ID: <alpine.LSU.2.11.1904072206030.1769@eggly.anvils>
References: <1553440122.7s759munpm.astroid@alex-desktop.none> <CANaguZB8szw13MkaiT9kcN8Fux6hYZnuD-p6_OPve6n2fOTuoQ@mail.gmail.com> <1554048843.jjmwlalntd.astroid@alex-desktop.none> <alpine.LSU.2.11.1903311146040.2667@eggly.anvils> <alpine.LSU.2.11.1904021701270.5045@eggly.anvils>
 <alpine.LSU.2.11.1904041836030.25100@eggly.anvils> <56deb587-8cd6-317a-520f-209207468c55@yandex-team.ru>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Apr 2019, Konstantin Khlebnikov wrote:
> On 05.04.2019 5:12, Hugh Dickins wrote:
> > Hi Alex, could you please give the patch below a try? It fixes a
> > problem, but I'm not sure that it's your problem - please let us know.
> > 
> > I've not yet written up the commit description, and this should end up
> > as 4/4 in a series fixing several new swapoff issues: I'll wait to post
> > the finished series until heard back from you.
> > 
> > I did first try following the suggestion Konstantin had made back then,
> > for a similar shmem_writepage() case: atomic_inc_not_zero(&sb->s_active).
> > 
> > But it turned out to be difficult to get right in shmem_unuse(), because
> > of the way that relies on the inode as a cursor in the list - problem
> > when you've acquired an s_active reference, but fail to acquire inode
> > reference, and cannot safely release the s_active reference while still
> > holding the swaplist mutex.
> > 
> > If VFS offered an isgrab(inode), like igrab() but acquiring s_active
> > reference while holding i_lock, that would drop very easily into the
> > current shmem_unuse() as a replacement there for igrab(). But the rest
> > of the world has managed without that for years, so I'm disinclined to
> > add it just for this. And the patch below seems good enough without it.
> > 
> > Thanks,
> > Hugh
> > 
> > ---
> > 
> >   include/linux/shmem_fs.h |    1 +
> >   mm/shmem.c               |   39 ++++++++++++++++++---------------------
> >   2 files changed, 19 insertions(+), 21 deletions(-)
> > 
> > --- 5.1-rc3/include/linux/shmem_fs.h	2019-03-17 16:18:15.181820820 -0700
> > +++ linux/include/linux/shmem_fs.h	2019-04-04 16:18:08.193512968 -0700
> > @@ -21,6 +21,7 @@ struct shmem_inode_info {
> >   	struct list_head	swaplist;	/* chain of maybes on swap */
> >   	struct shared_policy	policy;		/* NUMA memory alloc policy
> > */
> >   	struct simple_xattrs	xattrs;		/* list of xattrs */
> > +	atomic_t		stop_eviction;	/* hold when working on inode
> > */
> >   	struct inode		vfs_inode;
> >   };
> >   --- 5.1-rc3/mm/shmem.c	2019-03-17 16:18:15.701823872 -0700
> > +++ linux/mm/shmem.c	2019-04-04 16:18:08.193512968 -0700
> > @@ -1081,9 +1081,15 @@ static void shmem_evict_inode(struct ino
> >   			}
> >   			spin_unlock(&sbinfo->shrinklist_lock);
> >   		}
> > -		if (!list_empty(&info->swaplist)) {
> > +		while (!list_empty(&info->swaplist)) {
> > +			/* Wait while shmem_unuse() is scanning this inode...
> > */
> > +			wait_var_event(&info->stop_eviction,
> > +				       !atomic_read(&info->stop_eviction));
> >   			mutex_lock(&shmem_swaplist_mutex);
> >   			list_del_init(&info->swaplist);
> > +			/* ...but beware of the race if we peeked too early
> > */
> > +			if (!atomic_read(&info->stop_eviction))
> > +				list_del_init(&info->swaplist);
> >   			mutex_unlock(&shmem_swaplist_mutex);
> >   		}
> >   	}
> > @@ -1227,36 +1233,27 @@ int shmem_unuse(unsigned int type, bool
> >   		unsigned long *fs_pages_to_unuse)
> >   {
> >   	struct shmem_inode_info *info, *next;
> > -	struct inode *inode;
> > -	struct inode *prev_inode = NULL;
> >   	int error = 0;
> >     	if (list_empty(&shmem_swaplist))
> >   		return 0;
> >     	mutex_lock(&shmem_swaplist_mutex);
> > -
> > -	/*
> > -	 * The extra refcount on the inode is necessary to safely dereference
> > -	 * p->next after re-acquiring the lock. New shmem inodes with swap
> > -	 * get added to the end of the list and we will scan them all.
> > -	 */
> >   	list_for_each_entry_safe(info, next, &shmem_swaplist, swaplist) {
> >   		if (!info->swapped) {
> >   			list_del_init(&info->swaplist);
> >   			continue;
> >   		}
> > -
> > -		inode = igrab(&info->vfs_inode);
> > -		if (!inode)
> > -			continue;
> > -
> > +		/*
> > +		 * Drop the swaplist mutex while searching the inode for
> > swap;
> > +		 * but before doing so, make sure shmem_evict_inode() will
> > not
> > +		 * remove placeholder inode from swaplist, nor let it be
> > freed
> > +		 * (igrab() would protect from unlink, but not from unmount).
> > +		 */
> > +		atomic_inc(&info->stop_eviction);
> >   		mutex_unlock(&shmem_swaplist_mutex);
> > -		if (prev_inode)
> > -			iput(prev_inode);
> > -		prev_inode = inode;
> This seems too ad hoc solution.

I see what you mean by "ad hoc", but disagree with "too" ad hoc:
it's an appropriate solution, and a general one - I didn't invent it
for this, but for the huge tmpfs recoveries work items four years ago;
just changed the name from "info->recoveries" to "info->stop_eviction"
to let it be generalized to this swapoff case.

I prefer mine, since it simplifies shmem_unuse() (no igrab!), and has
the nice (but admittedly not essential) property of letting swapoff
proceed without delay and without unnecessary locking on unmounting
filesystems and evicting inodes.  (Would I prefer to use the s_umount
technique for my recoveries case? I think not.)

But yours should work too, with a slight change - see comments below,
where I've inlined yours. I'd better get on and post my four fixes
tomorrow, whether or not they fix Alex's case; then if people prefer
yours to my 4/4, yours can be swapped in instead.

> shmem: fix race between shmem_unuse and umount
> 
> From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> Function shmem_unuse could race with generic_shutdown_super.
> Inode reference is not enough for preventing umount and freeing superblock.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  mm/shmem.c |   24 +++++++++++++++++++++++-
>  1 file changed, 23 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index b3db3779a30a..2018a9a96bb7 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1218,6 +1218,10 @@ static int shmem_unuse_inode(struct inode *inode, unsigned int type,
>  	return ret;
>  }
>  
> +static void shmem_synchronize_umount(struct super_block *sb, void *arg)
> +{
> +}
> +

I think this can go away, see below.

>  /*
>   * Read all the shared memory data that resides in the swap
>   * device 'type' back into memory, so the swap device can be
> @@ -1229,6 +1233,7 @@ int shmem_unuse(unsigned int type, bool frontswap,
>  	struct shmem_inode_info *info, *next;
>  	struct inode *inode;
>  	struct inode *prev_inode = NULL;
> +	struct super_block *sb;
>  	int error = 0;
>  
>  	if (list_empty(&shmem_swaplist))
> @@ -1247,9 +1252,22 @@ int shmem_unuse(unsigned int type, bool frontswap,
>  			continue;
>  		}
>  
> +		/*
> +		 * Lock superblock to prevent umount and freeing it under us.
> +		 * If umount in progress it will free swap enties.
> +		 *
> +		 * Must be done before grabbing inode reference, otherwise
> +		 * generic_shutdown_super() will complain about busy inodes.
> +		 */
> +		sb = info->vfs_inode.i_sb;
> +		if (!trylock_super(sb))

Right, trylock important there.

> +			continue;
> +
>  		inode = igrab(&info->vfs_inode);
> -		if (!inode)
> +		if (!inode) {
> +			up_read(&sb->s_umount);

Yes, that indeed avoids the difficulty I had with when to call
deactivate_super(), that put me off trying to use s_active.

>  			continue;
> +		}
>  
>  		mutex_unlock(&shmem_swaplist_mutex);
>  		if (prev_inode)
> @@ -1258,6 +1276,7 @@ int shmem_unuse(unsigned int type, bool frontswap,
>  
>  		error = shmem_unuse_inode(inode, type, frontswap,
>  					  fs_pages_to_unuse);
> +		up_read(&sb->s_umount);

No, not here. I think you have to note prev_sb, and then only
up_read(&prev_sb->s_umount) after each iput(prev_inode): otherwise
there's still a risk of "Self-destruct in 5 seconds", isn't there?

>  		cond_resched();
>  
>  		mutex_lock(&shmem_swaplist_mutex);
> @@ -1272,6 +1291,9 @@ int shmem_unuse(unsigned int type, bool frontswap,
>  	if (prev_inode)
>  		iput(prev_inode);
>  
> +	/* Wait for umounts, this grabs s_umount for each superblock. */
> +	iterate_supers_type(&shmem_fs_type, shmem_synchronize_umount, NULL);
> +

I guess that's an attempt to compensate for the somewhat unsatisfactory
trylock above (bearing in mind the SWAP_UNUSE_MAX_TRIES 3, but I remove
that in my 2/4). Nice idea, and if it had the effect of never needing to
retry shmem_unuse(), I'd say yes; but since you're still passing over
un-igrab()-able inodes without an equivalent synchronization, I think
this odd iterate_supers_type() just delays swapoff without buying any
guarantee: better just deleted to keep your patch simpler.

>  	return error;
>  }
>  

Thanks,
Hugh

