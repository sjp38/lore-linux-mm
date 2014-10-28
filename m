Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6C0900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 16:27:32 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id ey11so1536439pad.21
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 13:27:32 -0700 (PDT)
Received: from homiemail-a10.g.dreamhost.com (homie.mail.dreamhost.com. [208.97.132.208])
        by mx.google.com with ESMTP id s5si2340505pdc.27.2014.10.28.13.27.31
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 13:27:31 -0700 (PDT)
Message-ID: <1414528039.10092.21.camel@linux-t7sj.site>
Subject: Re: [PATCH 03/10] mm: convert i_mmap_mutex to rwsem
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Tue, 28 Oct 2014 13:27:19 -0700
In-Reply-To: <20141024224537.GA21108@node.dhcp.inet.fi>
References: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
	 <1414188380-17376-4-git-send-email-dave@stgolabs.net>
	 <20141024224537.GA21108@node.dhcp.inet.fi>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2014-10-25 at 01:45 +0300, Kirill A. Shutemov wrote:
> On Fri, Oct 24, 2014 at 03:06:13PM -0700, Davidlohr Bueso wrote:
> > diff --git a/mm/fremap.c b/mm/fremap.c
> > index 72b8fa3..11ef7ec 100644
> > --- a/mm/fremap.c
> > +++ b/mm/fremap.c
> > @@ -238,13 +238,13 @@ get_write_lock:
> >  			}
> >  			goto out_freed;
> >  		}
> > -		mutex_lock(&mapping->i_mmap_mutex);
> > +		i_mmap_lock_write(mapping);
> >  		flush_dcache_mmap_lock(mapping);
> >  		vma->vm_flags |= VM_NONLINEAR;
> >  		vma_interval_tree_remove(vma, &mapping->i_mmap);
> >  		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
> >  		flush_dcache_mmap_unlock(mapping);
> > -		mutex_unlock(&mapping->i_mmap_mutex);
> > +		i_mmap_unlock_write(mapping);
> >  	}
> >  
> >  	if (vma->vm_flags & VM_LOCKED) {
> 
> This should go to previous patch.

Indeed. I had forgotten I snuck that change in as when I was writing the
patch there was a conflict with that fremap. However you removed
mm/fremap.c altogether in -next (mm: replace remap_file_pages() syscall
with emulation) so I'll just update accordingly.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
