Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D6EFD6B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:00:10 -0500 (EST)
Date: Mon, 20 Feb 2012 12:00:06 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 09/11] sysfs: Push file_update_time() into
 bin_page_mkwrite()
Message-ID: <20120220110006.GA6799@quack.suse.cz>
References: <1329399979-3647-1-git-send-email-jack@suse.cz>
 <1329399979-3647-10-git-send-email-jack@suse.cz>
 <1329419084.3121.39.camel@doink>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1329419084.3121.39.camel@doink>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Elder <elder@dreamhost.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Eric Sandeen <sandeen@redhat.com>, Dave Chinner <david@fromorbit.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu 16-02-12 13:04:44, Alex Elder wrote:
> On Thu, 2012-02-16 at 14:46 +0100, Jan Kara wrote:
> > CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/sysfs/bin.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/sysfs/bin.c b/fs/sysfs/bin.c
> > index a475983..6ceb16f 100644
> > --- a/fs/sysfs/bin.c
> > +++ b/fs/sysfs/bin.c
> > @@ -225,6 +225,8 @@ static int bin_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> >  	if (!sysfs_get_active(attr_sd))
> >  		return VM_FAULT_SIGBUS;
> >  
> > +	file_update_time(file);
> > +
> >  	ret = 0;
> >  	if (bb->vm_ops->page_mkwrite)
> >  		ret = bb->vm_ops->page_mkwrite(vma, vmf);
> 
> If the filesystem's page_mkwrite() function is responsible
> for updating the time, can't the call to file_update_time()
> here be conditional?
> 
> I.e:
> 	ret = 0;
> 	if (bb->vm_ops->page_mkwrite)
>  		ret = bb->vm_ops->page_mkwrite(vma, vmf);
> 	else
> 		file_update_time(file);
  Hmm, I didn't look previously where do we get bb->vm_ops. It seems they
are inherited from vma->vm_ops so what you suggest should be safe without
any further changes. So I can do that if someone who understands the sysfs
code likes it more.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
