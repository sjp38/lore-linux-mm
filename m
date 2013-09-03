Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 830D26B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 06:31:11 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id k11so2902135eaj.14
        for <linux-mm@kvack.org>; Tue, 03 Sep 2013 03:31:09 -0700 (PDT)
Date: Tue, 3 Sep 2013 12:31:32 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 10/16] fuse: Implement writepages callback
Message-ID: <20130903103132.GA7191@tucsk.piliscsaba.szeredi.hu>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
 <20130629174525.20175.18987.stgit@maximpc.sw.ru>
 <20130719165037.GA18358@tucsk.piliscsaba.szeredi.hu>
 <51FBD2DF.50506@parallels.com>
 <CAJfpegtr4+vv_ZzuM7EE7MkHPqNi4brQamg4ZOWb2Me+iG87JQ@mail.gmail.com>
 <52050474.8040608@parallels.com>
 <20130830101207.GD19636@tucsk.piliscsaba.szeredi.hu>
 <5220B12A.1060008@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5220B12A.1060008@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <mpatlasov@parallels.com>
Cc: riel@redhat.com, Kirill Korotaev <dev@parallels.com>, Pavel Emelianov <xemul@parallels.com>, fuse-devel <fuse-devel@lists.sourceforge.net>, Brian Foster <bfoster@redhat.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>, linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, fengguang.wu@intel.com, devel@openvz.org, Mel Gorman <mgorman@suse.de>

On Fri, Aug 30, 2013 at 06:50:18PM +0400, Maxim Patlasov wrote:
> Hi Miklos,
> 
> 08/30/2013 02:12 PM, Miklos Szeredi D?D,N?DuN?:
> >On Fri, Aug 09, 2013 at 07:02:12PM +0400, Maxim Patlasov wrote:
> >>08/06/2013 08:25 PM, Miklos Szeredi D?D,N?DuN?:
> >>>Hmm.  Direct IO on an mmaped file will do get_user_pages() which will
> >>>do the necessary page fault magic and ->page_mkwrite() will be called.
> >>>At least AFAICS.
> >>Yes, I agree.
> >>
> >>>The page cannot become dirty through a memory mapping without first
> >>>switching the pte from read-only to read-write first.  Page accounting
> >>>logic relies on this too.  The other way the page can become dirty is
> >>>through write(2) on the fs.  But we do get notified about that too.
> >>Yes, that's correct, but I don't understand why you disregard two
> >>other cases of marking page dirty (both related to direct AIO read
> >>from a file to a memory region mmap-ed to a fuse file):
> >>
> >>1. dio_bio_submit() -->
> >>       bio_set_pages_dirty() -->
> >>         set_page_dirty_lock()
> >>
> >>2. dio_bio_complete() -->
> >>       bio_check_pages_dirty() -->
> >>          bio_dirty_fn() -->
> >>             bio_set_pages_dirty() -->
> >>                set_page_dirty_lock()
> >>
> >>As soon as a page became dirty through a memory mapping (exactly as
> >>you explained), nothing would prevent it to be written-back. And
> >>fuse will call end_page_writeback almost immediately after copying
> >>the real page to a temporary one. Then dio_bio_submit may re-dirty
> >>page speculatively w/o notifying fuse. And again, since then nothing
> >>would prevent it to be written-back once more. Hence we can end up
> >>in more then one temporary page in fuse write-back. And similar
> >>concern for dio_bio_complete() re-dirty.
> >>
> >>This make me think that we do need fuse_page_is_writeback() in
> >>fuse_writepages_fill(). But it shouldn't be harmful because it will
> >>no-op practically always due to waiting for fuse writeback in
> >>->page_mkwrite() and in course of handling write(2).
> >The problem is: if we need it in ->writepages, we need it in ->writepage too.
> >And that's where we can't have it because it would deadlock in reclaim.
> 
> I thought we're protected from the deadlock by the following chunk
> (in the very beginning of fuse_writepage):
> 
> >+	if (fuse_page_is_writeback(inode, page->index)) {
> >+		if (wbc->sync_mode != WB_SYNC_ALL) {
> >+			redirty_page_for_writepage(wbc, page);
> >+			return 0;
> >+		}
> >+		fuse_wait_on_page_writeback(inode, page->index);
> >+	}
> 
> Because reclaimer will never call us with WB_SYNC_ALL. Did I miss
> something?

Yeah, we could have that in ->writepage() too.  And apparently that would work,
reclaim would just leave us alone.

Then there's sync(2) which does do WB_SYNC_ALL. Yet for an unprivileged fuse
mount we don't want ->writepages() to block because that's a quite clear DoS
issue.

So we are left with this:

> >There's a way to work around this:
> >
> >    - if the request is still in queue, just update it with the contents of
> >      the new page
> >
> >    - if the request already in userspace, create a new reqest, but only let
> >      userspace have it once the previous request for the same page
> >      completes, so the ordering is not messed up
> >
> >But that's a lot of hairy code.
> 
> Is it exactly how NFS solves similar problem?

NFS will apparently just block if there's a request outstanding and we are in
WB_SYNC_ALL mode.  Which is somewhat simpler.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
