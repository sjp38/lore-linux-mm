Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECD8C6B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 05:26:44 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 11so16682642pge.4
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:26:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si4316809pgq.697.2017.09.18.02.26.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Sep 2017 02:26:43 -0700 (PDT)
Date: Mon, 18 Sep 2017 11:26:34 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 2/3] mm: introduce MAP_VALIDATE a mechanism for adding
 new mmap flags
Message-ID: <20170918092634.GE32516@quack2.suse.cz>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150277753660.23945.11500026891611444016.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170815122701.GF27505@quack2.suse.cz>
 <CAA9_cmc0vejxCsc1NWp5b4C0CSsO5xetF3t6LCoCuEYB6yPiwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmc0vejxCsc1NWp5b4C0CSsO5xetF3t6LCoCuEYB6yPiwQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Sat 16-09-17 20:44:14, Dan Williams wrote:
> On Tue, Aug 15, 2017 at 5:27 AM, Jan Kara <jack@suse.cz> wrote:
> > On Mon 14-08-17 23:12:16, Dan Williams wrote:
> >> The mmap syscall suffers from the ABI anti-pattern of not validating
> >> unknown flags. However, proposals like MAP_SYNC and MAP_DIRECT need a
> >> mechanism to define new behavior that is known to fail on older kernels
> >> without the feature. Use the fact that specifying MAP_SHARED and
> >> MAP_PRIVATE at the same time is invalid as a cute hack to allow a new
> >> set of validated flags to be introduced.
> >>
> >> This also introduces the ->fmmap() file operation that is ->mmap() plus
> >> flags. Each ->fmmap() implementation must fail requests when a locally
> >> unsupported flag is specified.
> > ...
> >> diff --git a/include/linux/fs.h b/include/linux/fs.h
> >> index 1104e5df39ef..bbe755d0caee 100644
> >> --- a/include/linux/fs.h
> >> +++ b/include/linux/fs.h
> >> @@ -1674,6 +1674,7 @@ struct file_operations {
> >>       long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
> >>       long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
> >>       int (*mmap) (struct file *, struct vm_area_struct *);
> >> +     int (*fmmap) (struct file *, struct vm_area_struct *, unsigned long);
> >>       int (*open) (struct inode *, struct file *);
> >>       int (*flush) (struct file *, fl_owner_t id);
> >>       int (*release) (struct inode *, struct file *);
> >> @@ -1748,6 +1749,12 @@ static inline int call_mmap(struct file *file, struct vm_area_struct *vma)
> >>       return file->f_op->mmap(file, vma);
> >>  }
> >>
> >> +static inline int call_fmmap(struct file *file, struct vm_area_struct *vma,
> >> +             unsigned long flags)
> >> +{
> >> +     return file->f_op->fmmap(file, vma, flags);
> >> +}
> >> +
> >
> > Hum, I dislike a new file op for this when the only problem with ->mmap is
> > that it misses 'flags' argument. I understand there are lots of ->mmap
> > implementations out there and modifying prototype of them all is painful
> > but is it so bad? Coccinelle patch for this should be rather easy...
> 
> So it wasn't all that easy, and Linus declined to take it. I think we
> should add a new ->mmap_validate() file operation and save the
> tree-wide cleanup until later.

Well, we don't even strictly need the flags passed to ->mmap callback if we
are willing to use VMA flags. I want to use it for MAP_SYNC anyway... So
bumping vma->flags to u64 and using a flag is also an option (and frankly
I'd personally just go for that).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
