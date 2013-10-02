Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3776B004D
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 15:39:37 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so1350519pbc.2
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 12:39:36 -0700 (PDT)
Date: Wed, 2 Oct 2013 21:39:33 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 16/26] mm: Provide get_user_pages_unlocked()
Message-ID: <20131002193933.GC16998@quack.suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-17-git-send-email-jack@suse.cz>
 <524C499B.9090707@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <524C499B.9090707@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 02-10-13 12:28:11, KOSAKI Motohiro wrote:
> (10/2/13 10:27 AM), Jan Kara wrote:
> > Provide a wrapper for get_user_pages() which takes care of acquiring and
> > releasing mmap_sem. Using this function reduces amount of places in
> > which we deal with mmap_sem.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >   include/linux/mm.h | 14 ++++++++++++++
> >   1 file changed, 14 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 8b6e55ee8855..70031ead06a5 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1031,6 +1031,20 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> >   		    struct vm_area_struct **vmas);
> >   int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >   			struct page **pages);
> > +static inline long
> > +get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> > +		 	unsigned long start, unsigned long nr_pages,
> > +			int write, int force, struct page **pages)
> > +{
> > +	long ret;
> > +
> > +	down_read(&mm->mmap_sem);
> > +	ret = get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
> > +			     NULL);
> > +	up_read(&mm->mmap_sem);
> > +	return ret;
> > +}
> 
> Hmmm. I like the idea, but I really dislike this name. I don't like xx_unlocked 
> function takes a lock. It is a source of confusing, I believe. 
  Sure, I'm not very happy about the name either. As Christoph wrote
probably renaming all get_user_pages() variants might be appropriate. I'll
think about names some more.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
