Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5785B6B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 05:23:09 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so38553882wic.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 02:23:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s9si4037264wju.150.2015.08.26.02.23.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 02:23:07 -0700 (PDT)
Date: Wed, 26 Aug 2015 11:23:02 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/backing-dev: Check return value of the
 debugfs_create_dir()
Message-ID: <20150826092302.GB3871@quack.suse.cz>
References: <1440489263-3547-1-git-send-email-kuleshovmail@gmail.com>
 <20150825140858.8185db77fed42cf5df5faeb5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150825140858.8185db77fed42cf5df5faeb5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Kuleshov <kuleshovmail@gmail.com>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 25-08-15 14:08:58, Andrew Morton wrote:
> On Tue, 25 Aug 2015 13:54:23 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:
> 
> > The debugfs_create_dir() function may fail and return error. If the
> > root directory not created, we can't create anything inside it. This
> > patch adds check for this case.
> > 
> > ...
> >
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -117,15 +117,21 @@ static const struct file_operations bdi_debug_stats_fops = {
> >  
> >  static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
> >  {
> > -	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> > -	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
> > -					       bdi, &bdi_debug_stats_fops);
> > +	if (bdi_debug_root) {
> > +		bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> > +		if (bdi->debug_dir)
> > +			bdi->debug_stats = debugfs_create_file("stats", 0444,
> > +							bdi->debug_dir, bdi,
> > +							&bdi_debug_stats_fops);
> > +	}
> 
> If debugfs_create_dir() fails, debugfs_create_file() will go ahead and
> attempt to create the debugfs file in the debugfs root directory:
> 
> : static struct dentry *start_creating(const char *name, struct dentry *parent)
> : {
> : ...
> : 	/* If the parent is not specified, we create it in the root.
> : 	 * We need the root dentry to do this, which is in the super
> : 	 * block. A pointer to that is in the struct vfsmount that we
> : 	 * have around.
> : 	 */
> : 	if (!parent)
> : 		parent = debugfs_mount->mnt_root;
> 
> I'm not sure that this is very useful behaviour, and putting the files
> in the wrong place is a very obscure way of informing the user that
> debugfs_create_dir() failed :(

But this patch actually makes sure that we don't call debugfs_create_dir()
and debugfs_create_file() with parent == NULL so this patch avoids creation
of entries in debugfs root. So IMHO it really improves the situation. And I
agree with you that falling back to debugfs root is just broken...

> I don't think it's worth making little changes such as this - handling
> debugfs failures needs a deeper rethink.

Well, handling debugfs failures like in this patch is the right way to go,
isn't it? Or what else would you imagine than checking for errors and
bailing out instead of trying to create entries in non-existent dirs?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
