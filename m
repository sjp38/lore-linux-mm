Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA68F6B0035
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 15:03:22 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id uo5so18359pbc.10
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 12:03:22 -0800 (PST)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id m9si15260183pab.293.2014.03.04.12.03.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 12:03:20 -0800 (PST)
Received: by mail-pb0-f53.google.com with SMTP id rp16so14021pbb.26
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 12:03:17 -0800 (PST)
Date: Tue, 4 Mar 2014 12:02:15 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/1] mm: implement ->map_pages for shmem/tmpfs
In-Reply-To: <alpine.LSU.2.11.1402281657520.976@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1403041143530.1739@eggly.anvils>
References: <1393625931-2858-1-git-send-email-quning@google.com> <1393625931-2858-2-git-send-email-quning@google.com> <alpine.LSU.2.11.1402281657520.976@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 28 Feb 2014, Hugh Dickins wrote:
> On Fri, 28 Feb 2014, Ning Qu wrote:
> 
> > In shmem/tmpfs, we also use the generic filemap_map_pages,
> > seems the additional checking is not worth a separate version
> > of map_pages for it.
> > 
> > Signed-off-by: Ning Qu <quning@google.com>

Acked-by: Hugh Dickins <hughd@google.com>

> > ---
> >  mm/shmem.c | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index 1f18c9d..2ea4e89 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -2783,6 +2783,7 @@ static const struct super_operations shmem_ops = {
> >  
> >  static const struct vm_operations_struct shmem_vm_ops = {
> >  	.fault		= shmem_fault,
> > +	.map_pages	= filemap_map_pages,
> >  #ifdef CONFIG_NUMA
> >  	.set_policy     = shmem_set_policy,
> >  	.get_policy     = shmem_get_policy,
> > -- 
> 
> (There's no need for a 0/1, all the info should go into the one patch.)
> 
> I expect this will prove to be a very sensible and adequate patch,
> thank you: it probably wouldn't be worth more effort to give shmem
> anything special of its own, and filemap_map_pages() is already
> (almost) coping with exceptional entries.

I haven't looked at performance at all: I'm just glad that you and
Kirill have it working correctly as on other filesystems, without
any need for special treatment in filemap_map_pages() - thanks.

> 
> But I can't Ack it until I've tested it some more, won't be able to
> do so until Sunday; and even then some doubt, since this and Kirill's
> are built upon mmotm/next, which after a while gives me spinlock
> lockups under load these days, yet to be investigated.

Other test machines didn't give me those lockups at the weekend, and
overnight it looks like yesterday's mmotm has fixed the freezes on my
laptop (PeterZ's "sched: Guarantee task priority in pick_next_task()"
probably fixed them, but it's old history now, so I've not verified).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
