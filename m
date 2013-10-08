Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id AD0346B003B
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 02:24:29 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so8051973pbb.20
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 23:24:29 -0700 (PDT)
Date: Tue, 8 Oct 2013 08:06:23 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/26] get_user_pages() cleanup
Message-ID: <20131008060623.GA9907@quack.suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <20131002162009.GA5778@infradead.org>
 <20131002202941.GF16998@quack.suse.cz>
 <524F2592.1040305@gmail.com>
 <524F282B.2080809@gmail.com>
 <20131007211822.GF30441@quack.suse.cz>
 <52535164.30201@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52535164.30201@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <andreas.dilger@intel.com>, Andy Walls <awalls@md.metrocast.net>, Arnd Bergmann <arnd@arndb.de>, Benjamin LaHaise <bcrl@kvack.org>, ceph-devel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Gleb Natapov <gleb@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, hpdd-discuss@ml01.01.org, Jarod Wilson <jarod@wilsonet.com>, Jayant Mangalampalli <jayant.mangalampalli@intel.com>, Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Kai Makisara <Kai.Makisara@kolumbus.fi>, kvm@vger.kernel.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-aio@kvack.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-media@vger.kernel.org, linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org, Manu Abraham <abraham.manu@gmail.com>, Mark Allyn <mark.a.allyn@intel.com>, Mikael Starvik <starvik@axis.com>, Mike Marciniszyn <infinipath@intel.com>, Naren Sankar <nsankar@broadcom.com>, Paolo Bonzini <pbonzini@redhat.com>, Peng Tao <tao.peng@emc.com>, Roland Dreier <roland@kernel.org>, Sage Weil <sage@inktank.com>, Scott Davilla <davilla@4pi.com>, Timur Tabi <timur@freescale.com>, Tomi Valkeinen <tomi.valkeinen@ti.com>, Tony Luck <tony.luck@intel.com>, Trond Myklebust <Trond.Myklebust@netapp.com>

On Mon 07-10-13 20:27:16, KOSAKI Motohiro wrote:
> (10/7/13 5:18 PM), Jan Kara wrote:
> >On Fri 04-10-13 16:42:19, KOSAKI Motohiro wrote:
> >>(10/4/13 4:31 PM), KOSAKI Motohiro wrote:
> >>>(10/2/13 4:29 PM), Jan Kara wrote:
> >>>>On Wed 02-10-13 09:20:09, Christoph Hellwig wrote:
> >>>>>On Wed, Oct 02, 2013 at 04:27:41PM +0200, Jan Kara wrote:
> >>>>>>    Hello,
> >>>>>>
> >>>>>>    In my quest for changing locking around page faults to make things easier for
> >>>>>>filesystems I found out get_user_pages() users could use a cleanup.  The
> >>>>>>knowledge about necessary locking for get_user_pages() is in tons of places in
> >>>>>>drivers and quite a few of them actually get it wrong (don't have mmap_sem when
> >>>>>>calling get_user_pages() or hold mmap_sem when calling copy_from_user() in the
> >>>>>>surrounding code). Rather often this actually doesn't seem necessary. This
> >>>>>>patch series converts lots of places to use either get_user_pages_fast()
> >>>>>>or a new simple wrapper get_user_pages_unlocked() to remove the knowledge
> >>>>>>of mmap_sem from the drivers. I'm still looking into converting a few remaining
> >>>>>>drivers (most notably v4l2) which are more complex.
> >>>>>
> >>>>>Even looking over the kerneldoc comment next to it I still fail to
> >>>>>understand when you'd want to use get_user_pages_fast and when not.
> >>>>    AFAIU get_user_pages_fast() should be used
> >>>>1) if you don't need any special get_user_pages() arguments (like calling
> >>>>     it for mm of a different process, forcing COW, or similar).
> >>>>2) you don't expect pages to be unmapped (then get_user_pages_fast() is
> >>>>actually somewhat slower because it walks page tables twice).
> >>>
> >>>If target page point to anon or private mapping pages, get_user_pages_fast()
> >>>is fork unsafe. O_DIRECT man pages describe a bit about this.
> >>>
> >>>
> >>>see http://man7.org/linux/man-pages/man2/open.2.html
> >>>
> >>>>       O_DIRECT I/Os should never be run concurrently with the fork(2)
> >>>>       system call, if the memory buffer is a private mapping (i.e., any
> >>>>       mapping created with the mmap(2) MAP_PRIVATE flag; this includes
> >>>>       memory allocated on the heap and statically allocated buffers).  Any
> >>>>       such I/Os, whether submitted via an asynchronous I/O interface or
> >>>>       from another thread in the process, should be completed before
> >>>>       fork(2) is called.  Failure to do so can result in data corruption
> >>>>       and undefined behavior in parent and child processes.  This
> >>>>       restriction does not apply when the memory buffer for the O_DIRECT
> >>>>       I/Os was created using shmat(2) or mmap(2) with the MAP_SHARED flag.
> >>>>       Nor does this restriction apply when the memory buffer has been
> >>>>       advised as MADV_DONTFORK with madvise(2), ensuring that it will not
> >>>>       be available to the child after fork(2).
> >>
> >>IMHO, get_user_pages_fast() should be renamed to get_user_pages_quirk(). Its
> >>semantics is not equal to get_user_pages(). When someone simply substitute
> >>get_user_pages() to get_user_pages_fast(), they might see huge trouble.
> >   I forgot about this speciality (and actually comments didn't remind me
> >:(). But thinking about this some more get_user_pages_fast() seems as save
> >as get_user_pages() in presence of threads sharing mm, doesn't it?
> 
> It depends.
> 
> If there is any guarantee that other threads don't touch the same page which
> retrieved get_user_pages(), get_user_pages_fast() give us brilliant fast way.
> Example, as far as I heard form IB guys, the userland library of the infiniband
> stack uses madvise(MADV_DONTFORK), and then they don't need to care COW issue
> and can choose fastest way. An another example is a futex. futex doesn't use
> the contents of the pages, it uses vaddr only for looking up key. Then, it
> also doesn't have COW issue.
> 
> I don't know other cases. But as far as I know, everything is case-by-case.
> 
> >Because
> >while get_user_pages() are working, other thread can happilly trigger COW
> >on some of the pages and thus get_user_pages() can return pages some of
> >which are invisible in our mm by the time get_user_pages() returns.
> 
> If you are talking about get_user_pages() instead of get_user_pages_fast(), this
> can't be happen because page-fault takes mmap_sem too.
  But both take mmap_sem for reading, so they won't exclude each other...

> I would say, mmap_sem has too fat responsibility really.
  I heartily agree with this. And that makes any changes to it really hard.
I've once went through all the places in kernel which acquired mmap_sem.
If I remember right, there were close to two hundreds of them! Basic use
is the protection of vma tree but then we have less obvious stuff like
protection of some other fields in mm_struct, fork exclusion, and god knows
what...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
