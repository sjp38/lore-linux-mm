Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB62B6B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:25:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h48-v6so13485058edh.22
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 01:25:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 40-v6si9982985edq.257.2018.10.16.01.25.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 01:25:41 -0700 (PDT)
Date: Tue, 16 Oct 2018 10:25:40 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181016082540.GA18918@quack2.suse.cz>
References: <20181002100531.GC4135@quack2.suse.cz>
 <x49woqqykgi.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49woqqykgi.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Hi Jeff,

On Tue 09-10-18 15:43:41, Jeff Moyer wrote:
> Jan Kara <jack@suse.cz> writes:
> > commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and device dax" has
> > removed VM_MIXEDMAP flag from DAX VMAs. Now our testing shows that in the
> > mean time certain customer of ours started poking into /proc/<pid>/smaps
> > and looks at VMA flags there and if VM_MIXEDMAP is missing among the VMA
> > flags, the application just fails to start complaining that DAX support is
> > missing in the kernel. The question now is how do we go about this?
> >
> > Strictly speaking, this is a userspace visible regression (as much as I
> > think that application poking into VMA flags at this level is just too
> > bold). Is there any precedens in handling similar issues with smaps which
> > really exposes a lot of information that is dependent on kernel
> > implementation details?
> >
> > I have attached a patch that is an obvious "fix" for the issue - just fake
> > VM_MIXEDMAP flag in smaps. But I'm open to other suggestions...
> 
> I'm intrigued by the use case.  Do I understand you correctly that the
> database in question does not intend to make data persistent from
> userspace?  In other words, fsync/msync system calls are being issued by
> the database?

Yes, at least at the initial stage, they use fsync / msync to persist data.

> I guess what I'm really after is a statement of requirements or
> expectations.  It would be great if you could convince the database
> developer to engage in this discussion directly.

So I talked to them and what they really look after is the control over the
amount of memory needed by the kernel. And they are right that if your
storage needs page cache, the amount of memory you need to set aside for the
kernel is larger.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
