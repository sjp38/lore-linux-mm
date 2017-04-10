Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6AC6B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:51:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x61so16729434wrb.8
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:51:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r10si11170080wrc.146.2017.04.10.08.51.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 08:51:32 -0700 (PDT)
Date: Mon, 10 Apr 2017 17:51:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [patch 1/3] mm: protect set_page_dirty() from ongoing truncation
Message-ID: <20170410155129.GK3224@quack2.suse.cz>
References: <1417791166-32226-1-git-send-email-hannes@cmpxchg.org>
 <20170410022230.xe5sukvflvoh4ula@sasha-lappy>
 <20170410120638.GD3224@quack2.suse.cz>
 <20170410150755.kd2gjqyfmvschtxd@sasha-lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170410150755.kd2gjqyfmvschtxd@sasha-lappy>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alexander.levin@verizon.com
Cc: Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon 10-04-17 15:07:58, alexander.levin@verizon.com wrote:
> On Mon, Apr 10, 2017 at 02:06:38PM +0200, Jan Kara wrote:
> > On Mon 10-04-17 02:22:33, alexander.levin@verizon.com wrote:
> > > On Fri, Dec 05, 2014 at 09:52:44AM -0500, Johannes Weiner wrote:
> > > > Tejun, while reviewing the code, spotted the following race condition
> > > > between the dirtying and truncation of a page:
> > > > 
> > > > __set_page_dirty_nobuffers()       __delete_from_page_cache()
> > > >   if (TestSetPageDirty(page))
> > > >                                      page->mapping = NULL
> > > > 				     if (PageDirty())
> > > > 				       dec_zone_page_state(page, NR_FILE_DIRTY);
> > > > 				       dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> > > >     if (page->mapping)
> > > >       account_page_dirtied(page)
> > > >         __inc_zone_page_state(page, NR_FILE_DIRTY);
> > > > 	__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> > > > 
> > > > which results in an imbalance of NR_FILE_DIRTY and BDI_RECLAIMABLE.
> > > > 
> > > > Dirtiers usually lock out truncation, either by holding the page lock
> > > > directly, or in case of zap_pte_range(), by pinning the mapcount with
> > > > the page table lock held.  The notable exception to this rule, though,
> > > > is do_wp_page(), for which this race exists.  However, do_wp_page()
> > > > already waits for a locked page to unlock before setting the dirty
> > > > bit, in order to prevent a race where clear_page_dirty() misses the
> > > > page bit in the presence of dirty ptes.  Upgrade that wait to a fully
> > > > locked set_page_dirty() to also cover the situation explained above.
> > > > 
> > > > Afterwards, the code in set_page_dirty() dealing with a truncation
> > > > race is no longer needed.  Remove it.
> > > > 
> > > > Reported-by: Tejun Heo <tj@kernel.org>
> > > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > > Cc: <stable@vger.kernel.org>
> > > > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > 
> > > Hi Johannes,
> > > 
> > > I'm seeing the following while fuzzing with trinity on linux-next (I've changed
> > > the WARN to a VM_BUG_ON_PAGE for some extra page info).
> > 
> > But this looks more like a bug in 9p which allows v9fs_write_end() to dirty
> > a !Uptodate page?
> 
> I thought that 77469c3f5 ("9p: saner ->write_end() on failing copy into
> non-uptodate page") prevented from that happening, but that's actually the
> change that's causing it (I ended up misreading it last night).
> 
> Will fix it as follows:

Yep, this looks good to me, although I'd find it more future-proof if we
had that SetPageUptodate() additionally guarded a by len == PAGE_SIZE
check.

								Honza

> 
> diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c 
> index adaf6f6..be84c0c 100644 
> --- a/fs/9p/vfs_addr.c 
> +++ b/fs/9p/vfs_addr.c 
> @@ -310,9 +310,13 @@ static int v9fs_write_end(struct file *filp, struct address_space *mapping, 
>   
>         p9_debug(P9_DEBUG_VFS, "filp %p, mapping %p\n", filp, mapping); 
>   
> -       if (unlikely(copied < len && !PageUptodate(page))) { 
> -               copied = 0; 
> -               goto out; 
> +       if (!PageUptodate(page)) { 
> +               if (unlikely(copied < len)) { 
> +                       copied = 0;
> +                       goto out; 
> +               } else { 
> +                       SetPageUptodate(page); 
> +               } 
>         } 
>         /* 
>          * No need to use i_size_read() here, the i_size
>  
> -- 
> 
> Thanks,
> Sasha
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
