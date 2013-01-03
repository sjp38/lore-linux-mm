Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id BB8AB6B006C
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 13:56:47 -0500 (EST)
Date: Thu, 3 Jan 2013 19:56:42 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/3] mm: Update file times when inodes are written
 after mmaped writes
Message-ID: <20130103185642.GA5699@quack.suse.cz>
References: <cover.1356124965.git.luto@amacapital.net>
 <6b22b806806b21af02b70a2fa860a9d10304fc16.1356124965.git.luto@amacapital.net>
 <20121222082933.GA26477@infradead.org>
 <CALCETrX423Au=Q0SgdpFp7hcVBAw0t4FprO18Wk9j0K=j8fg_w@mail.gmail.com>
 <20121231161135.GH7564@quack.suse.cz>
 <CALCETrUXVQooGt+10zDzK1HLoEOPc+1KH41mFewjxMjjUPNvMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUXVQooGt+10zDzK1HLoEOPc+1KH41mFewjxMjjUPNvMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>

On Thu 03-01-13 09:49:37, Andy Lutomirski wrote:
> On Mon, Dec 31, 2012 at 8:11 AM, Jan Kara <jack@suse.cz> wrote:
> > On Sat 22-12-12 00:43:30, Andy Lutomirski wrote:
> >> On Sat, Dec 22, 2012 at 12:29 AM, Christoph Hellwig <hch@infradead.org> wrote:
> >> > NAK, we went through great trouble to get rid of the nasty layering
> >> > violation where the VM called file_update_time directly just a short
> >> > while ago, reintroducing that is a massive step back.
> >> >
[...]
> >With the call from
> > remove_vma() it is more problematic (and the calling context there is
> > harder as well because we hold mmap_sem). We could maybe leave the call
> > upto filesystem's ->release callback (and provide generic ->release handler
> > which just calls mapping_flush_cmtime()). It won't be perfect because that
> > gets called only after the last file descriptor for that struct file is
> > closed (i.e., if a process forks and child inherits mappings, ->release gets
> > called only after both parent and the child unmap the file) but it should
> > catch 99% of the real world cases. Christoph, would the be OK with
> > you?
> 
> I'm not sure that 99% is good enough -- I'd be nervous about breaking
> some build or versioning system.
> 
> vm_ops->close is almost a good place for this, except that it's called
> on some failure paths and it will mess up is_mergeable_vma if lots of
> filesystems suddenly have a ->close operation.  What about adding
> vm_ops->flush, which would be called in remove_vma and possibly
> msync(MS_ASYNC)?  I think that all real filesystems (i.e. things that
> care about cmtime updates) have vm_operations.
  Yeah, that could work. I'm still somewhat nervous about updating the time
stamp under mmap_sem but in ->page_mkwrite we were in the same situation so
I guess it's fine.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
