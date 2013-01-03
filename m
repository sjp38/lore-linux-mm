Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 9253A6B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 12:49:58 -0500 (EST)
Received: by mail-vc0-f175.google.com with SMTP id fy7so15506730vcb.20
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 09:49:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121231161135.GH7564@quack.suse.cz>
References: <cover.1356124965.git.luto@amacapital.net> <6b22b806806b21af02b70a2fa860a9d10304fc16.1356124965.git.luto@amacapital.net>
 <20121222082933.GA26477@infradead.org> <CALCETrX423Au=Q0SgdpFp7hcVBAw0t4FprO18Wk9j0K=j8fg_w@mail.gmail.com>
 <20121231161135.GH7564@quack.suse.cz>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 3 Jan 2013 09:49:37 -0800
Message-ID: <CALCETrUXVQooGt+10zDzK1HLoEOPc+1KH41mFewjxMjjUPNvMA@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] mm: Update file times when inodes are written
 after mmaped writes
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>

On Mon, Dec 31, 2012 at 8:11 AM, Jan Kara <jack@suse.cz> wrote:
> On Sat 22-12-12 00:43:30, Andy Lutomirski wrote:
>> On Sat, Dec 22, 2012 at 12:29 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> > NAK, we went through great trouble to get rid of the nasty layering
>> > violation where the VM called file_update_time directly just a short
>> > while ago, reintroducing that is a massive step back.
>> >

[...]

>
>> The original version of this patch did the update in ->writepage and
>> ->writepages, but that may have had lock ordering issues.  (I wasn't
>> able to confirm that there was any actual problem.)
>   Well, your call of mapping_flush_cmtime() from do_writepages() is easy to
> move to generic_writepages(). Thus filesystem can easily implement it's own
> ->writepages() callback if time update doesn't suit it.

That sounds fine to me.  Updating the handful of filesystems in there
isn't a big deal.

>With the call from
> remove_vma() it is more problematic (and the calling context there is
> harder as well because we hold mmap_sem). We could maybe leave the call
> upto filesystem's ->release callback (and provide generic ->release handler
> which just calls mapping_flush_cmtime()). It won't be perfect because that
> gets called only after the last file descriptor for that struct file is
> closed (i.e., if a process forks and child inherits mappings, ->release gets
> called only after both parent and the child unmap the file) but it should
> catch 99% of the real world cases. Christoph, would the be OK with
> you?

I'm not sure that 99% is good enough -- I'd be nervous about breaking
some build or versioning system.

vm_ops->close is almost a good place for this, except that it's called
on some failure paths and it will mess up is_mergeable_vma if lots of
filesystems suddenly have a ->close operation.  What about adding
vm_ops->flush, which would be called in remove_vma and possibly
msync(MS_ASYNC)?  I think that all real filesystems (i.e. things that
care about cmtime updates) have vm_operations.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
