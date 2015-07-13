Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3246B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 09:21:45 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so207513939pac.2
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 06:21:44 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id nw8si27717040pbb.84.2015.07.13.06.21.44
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 06:21:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20150713130812.GA8115@cmpxchg.org>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436784852-144369-6-git-send-email-kirill.shutemov@linux.intel.com>
 <20150713130812.GA8115@cmpxchg.org>
Subject: Re: [PATCH 5/5] mm, memcontrol: use vma_is_anonymous() to check for
 anon VMA
Content-Transfer-Encoding: 7bit
Message-Id: <20150713132056.D0CDAA4@black.fi.intel.com>
Date: Mon, 13 Jul 2015 16:20:56 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>

Johannes Weiner wrote:
> On Mon, Jul 13, 2015 at 01:54:12PM +0300, Kirill A. Shutemov wrote:
> > !vma->vm_file is not reliable to detect anon VMA, because not all
> > drivers bother set it. Let's use vma_is_anonymous() instead.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/memcontrol.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index acb93c554f6e..a624709f0dd7 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4809,7 +4809,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
> >  	struct address_space *mapping;
> >  	pgoff_t pgoff;
> >  
> > -	if (!vma->vm_file) /* anonymous vma */
> > +	if (vma_is_anonymous(vma)) /* anonymous vma */
> >  		return NULL;
> >  	if (!(mc.flags & MOVE_FILE))
> >  		return NULL;
> 
> The next line does vma->vm_file->f_mapping, so it had better be !NULL.
> 
> It's not about reliably detecting anonymous vs. file, it is about
> whether there is a mapping against which we can do find_get_page().

You're right. This patch is totally broken.

-- 
 Kirill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
