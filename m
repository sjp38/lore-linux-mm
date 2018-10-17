Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 413C96B0008
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 06:40:03 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d63-v6so20386717pld.18
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 03:40:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8-v6sor6507744plz.7.2018.10.17.03.40.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 03:40:01 -0700 (PDT)
Date: Wed, 17 Oct 2018 03:39:58 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v2 1/2] mm: Add an F_SEAL_FS_WRITE seal to memfd
Message-ID: <20181017103958.GB230639@joelaf.mtv.corp.google.com>
References: <20181009222042.9781-1-joel@joelfernandes.org>
 <20181017095155.GA354@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181017095155.GA354@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com, jreck@google.com, john.stultz@linaro.org, tkjos@google.com, gregkh@linuxfoundation.org, Andrew Morton <akpm@linux-foundation.org>, dancol@google.com, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, minchan@google.com, Shuah Khan <shuah@kernel.org>

On Wed, Oct 17, 2018 at 02:51:55AM -0700, Christoph Hellwig wrote:
> On Tue, Oct 09, 2018 at 03:20:41PM -0700, Joel Fernandes (Google) wrote:
> > One of the main usecases Android has is the ability to create a region
> > and mmap it as writeable, then drop its protection for "future" writes
> > while keeping the existing already mmap'ed writeable-region active.
> 
> s/drop/add/ ?
> 
> Otherwise this doesn't make much sense to me.

Sure, you are right that "add" is more appropriate. I'll change it to that.

> > This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
> > To support the usecase, this patch adds a new F_SEAL_FS_WRITE seal which
> > prevents any future mmap and write syscalls from succeeding while
> > keeping the existing mmap active. The following program shows the seal
> > working in action:
> 
> Where does the FS come from?  I'd rather expect this to be implemented
> as a 'force' style flag that applies the seal even if the otherwise
> required precondition is not met.

The "FS" was meant to convey that the seal is preventing writes at the VFS
layer itself, for example vfs_write checks FMODE_WRITE and does not proceed,
it instead returns an error if the flag is not set. I could not find a better
name for it, I could call it F_SEAL_VFS_WRITE if you prefer?

> > Note: This seal will also prevent growing and shrinking of the memfd.
> > This is not something we do in Android so it does not affect us, however
> > I have mentioned this behavior of the seal in the manpage.
> 
> This seems odd, as that is otherwise split into the F_SEAL_SHRINK /
> F_SEAL_GROW flags.

I could make it such that this seal would not be allowed unless F_SEAL_SHRINK
and F_SEAL_GROW are either previously set, or they are passed along with this
seal. Would that make more sense to you?

> >  static int memfd_add_seals(struct file *file, unsigned int seals)
> >  {
> > @@ -219,6 +220,9 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
> >  		}
> >  	}
> >  
> > +	if ((seals & F_SEAL_FS_WRITE) && !(*file_seals & F_SEAL_FS_WRITE))
> > +		file->f_mode &= ~(FMODE_WRITE | FMODE_PWRITE);
> > +
> 
> This seems to lack any synchronization for f_mode.

The f_mode is set when the struct file is first created and then memfd sets
additional flags in memfd_create. Then later we are changing it here at the
time of setting the seal. I donot see any possiblity of a race since it is
impossible to set the seal before memfd_create returns. Could you provide
more details about what kind of synchronization is needed and what is the
race condition scenario you were thinking off?

thanks for the review,

 - Joel
