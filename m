Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 27CC56B0070
	for <linux-mm@kvack.org>; Mon, 31 Dec 2012 11:11:51 -0500 (EST)
Date: Mon, 31 Dec 2012 17:11:35 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/3] mm: Update file times when inodes are written
 after mmaped writes
Message-ID: <20121231161135.GH7564@quack.suse.cz>
References: <cover.1356124965.git.luto@amacapital.net>
 <6b22b806806b21af02b70a2fa860a9d10304fc16.1356124965.git.luto@amacapital.net>
 <20121222082933.GA26477@infradead.org>
 <CALCETrX423Au=Q0SgdpFp7hcVBAw0t4FprO18Wk9j0K=j8fg_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrX423Au=Q0SgdpFp7hcVBAw0t4FprO18Wk9j0K=j8fg_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>

On Sat 22-12-12 00:43:30, Andy Lutomirski wrote:
> On Sat, Dec 22, 2012 at 12:29 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > NAK, we went through great trouble to get rid of the nasty layering
> > violation where the VM called file_update_time directly just a short
> > while ago, reintroducing that is a massive step back.
> >
> > Make sure whatever "solution" for your problem you come up with keeps
> > the file update in the filesystem or generic helpers.
>
> 
> There's an inode operation ->update_time that is called (if it exists)
> in these patches to update the time.  Is that insufficient?
  Filesystems need more choice in when they modify time stamps because that
can mean complex work like starting a transaction which has various locking
implications. Just making a separate callback for this doesn't really solve
the problem. Although I don't see particular problem with the call sites you
chose Christoph is right we probably don't want to reintroduce updates of
time stamps from generic code because eventually someone will have problem
with that.

> I could add a new inode operation ->modified_by_mmap that would be
> called in mapping_flush_cmtime if that would be better.
  Not really. That's only uglier ;)

> The original version of this patch did the update in ->writepage and
> ->writepages, but that may have had lock ordering issues.  (I wasn't
> able to confirm that there was any actual problem.)
  Well, your call of mapping_flush_cmtime() from do_writepages() is easy to
move to generic_writepages(). Thus filesystem can easily implement it's own
->writepages() callback if time update doesn't suit it. With the call from
remove_vma() it is more problematic (and the calling context there is
harder as well because we hold mmap_sem). We could maybe leave the call
upto filesystem's ->release callback (and provide generic ->release handler
which just calls mapping_flush_cmtime()). It won't be perfect because that
gets called only after the last file descriptor for that struct file is
closed (i.e., if a process forks and child inherits mappings, ->release gets
called only after both parent and the child unmap the file) but it should
catch 99% of the real world cases. Christoph, would the be OK with
you?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
