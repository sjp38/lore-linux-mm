Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 98BB76B003D
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 15:36:35 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so1353102pbb.0
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 12:36:35 -0700 (PDT)
Date: Wed, 2 Oct 2013 21:36:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 18/26] mm: Convert process_vm_rw_pages() to use
 get_user_pages_unlocked()
Message-ID: <20131002193631.GB16998@quack.suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-19-git-send-email-jack@suse.cz>
 <524C4AA1.7000409@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524C4AA1.7000409@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 02-10-13 12:32:33, KOSAKI Motohiro wrote:
> (10/2/13 10:27 AM), Jan Kara wrote:
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >   mm/process_vm_access.c | 8 ++------
> >   1 file changed, 2 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
> > index fd26d0433509..c1bc47d8ed90 100644
> > --- a/mm/process_vm_access.c
> > +++ b/mm/process_vm_access.c
> > @@ -64,12 +64,8 @@ static int process_vm_rw_pages(struct task_struct *task,
> >   	*bytes_copied = 0;
> >   
> >   	/* Get the pages we're interested in */
> > -	down_read(&mm->mmap_sem);
> > -	pages_pinned = get_user_pages(task, mm, pa,
> > -				      nr_pages_to_copy,
> > -				      vm_write, 0, process_pages, NULL);
> > -	up_read(&mm->mmap_sem);
> > -
> > +	pages_pinned = get_user_pages_unlocked(task, mm, pa, nr_pages_to_copy,
> > +					       vm_write, 0, process_pages);
> >   	if (pages_pinned != nr_pages_to_copy) {
> >   		rc = -EFAULT;
> >   		goto end;
> 
> This is wrong because original code is wrong. In this function, page may
> be pointed to anon pages. Then, you should keep to take mmap_sem until
> finish to copying. Otherwise concurrent fork() makes nasty COW issue.
  Hum, can you be more specific? I suppose you are speaking about situation
when the remote task we are copying data from/to does fork while
process_vm_rw_pages() runs. If we are copying data from remote task, I
don't see how COW could cause any problem. If we are copying to remote task
and fork happens after get_user_pages() but before copy_to_user() then I
can see we might be having some trouble. copy_to_user() would then copy
data into both original remote process and its child thus essentially
bypassing COW. If the child process manages to COW some of the pages before
copy_to_user() happens, it can even see only some of the pages. Is that what
you mean?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
