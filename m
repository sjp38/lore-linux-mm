Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 924106B0003
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 21:38:12 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id j1-v6so4274977pll.8
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 18:38:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r20-v6sor14980369pfk.40.2018.11.10.18.38.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 18:38:10 -0800 (PST)
Date: Sat, 10 Nov 2018 18:38:08 -0800
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to
 memfd
Message-ID: <20181111023808.GA174670@google.com>
References: <20181108041537.39694-1-joel@joelfernandes.org>
 <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
 <CAG48ez0kQ4d566bXTFOYANDgii-stL-Qj-oyaBzvfxdV=PU-7g@mail.gmail.com>
 <20181110032005.GA22238@google.com>
 <69CE06CC-E47C-4992-848A-66EB23EE6C74@amacapital.net>
 <20181110182405.GB242356@google.com>
 <CAKOZuesQXRtthJTEr86LByH3gPpAdT-PQM0d1jqr131=zZNRKw@mail.gmail.com>
 <CAKOZueum8MtNvJ5P=W7_pRw62TdQdCgyjCwwbG1wezNboC1cxQ@mail.gmail.com>
 <20181110220933.GB96924@google.com>
 <907D942E-E321-4BD7-BED7-ACD1D96A3643@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <907D942E-E321-4BD7-BED7-ACD1D96A3643@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Colascione <dancol@google.com>, Jann Horn <jannh@google.com>, kernel list <linux-kernel@vger.kernel.org>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, Valdis Kletnieks <valdis.kletnieks@vt.edu>, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

On Sat, Nov 10, 2018 at 02:18:23PM -0800, Andy Lutomirski wrote:
> 
> > On Nov 10, 2018, at 2:09 PM, Joel Fernandes <joel@joelfernandes.org> wrote:
> > 
> >> On Sat, Nov 10, 2018 at 11:11:27AM -0800, Daniel Colascione wrote:
> >>> On Sat, Nov 10, 2018 at 10:45 AM, Daniel Colascione <dancol@google.com> wrote:
> >>>> On Sat, Nov 10, 2018 at 10:24 AM, Joel Fernandes <joel@joelfernandes.org> wrote:
> >>>> Thanks Andy for your thoughts, my comments below:
> >> [snip]
> >>>> I don't see it as warty, different seals will work differently. It works
> >>>> quite well for our usecase, and since Linux is all about solving real
> >>>> problems in the real work, it would be useful to have it.
> >>>> 
> >>>>> - causes a probably-observable effect in the file mode in F_GETFL.
> >>>> 
> >>>> Wouldn't that be the right thing to observe anyway?
> >>>> 
> >>>>> - causes reopen to fail.
> >>>> 
> >>>> So this concern isn't true anymore if we make reopen fail only for WRITE
> >>>> opens as Daniel suggested. I will make this change so that the security fix
> >>>> is a clean one.
> >>>> 
> >>>>> - does *not* affect other struct files that may already exist on the same inode.
> >>>> 
> >>>> TBH if you really want to block all writes to the file, then you want
> >>>> F_SEAL_WRITE, not this seal. The usecase we have is the fd is sent over IPC
> >>>> to another process and we want to prevent any new writes in the receiver
> >>>> side. There is no way this other receiving process can have an existing fd
> >>>> unless it was already sent one without the seal applied.  The proposed seal
> >>>> could be renamed to F_SEAL_FD_WRITE if that is preferred.
> >>>> 
> >>>>> - mysteriously malfunctions if you try to set it again on another struct
> >>>>> file that already exists
> >>>>> 
> >>>> 
> >>>> I didn't follow this, could you explain more?
> >>>> 
> >>>>> - probably is insecure when used on hugetlbfs.
> >>>> 
> >>>> The usecase is not expected to prevent all writes, indeed the usecase
> >>>> requires existing mmaps to continue to be able to write into the memory map.
> >>>> So would you call that a security issue too? The use of the seal wants to
> >>>> allow existing mmap regions to be continue to be written into (I mentioned
> >>>> more details in the cover letter).
> >>>> 
> >>>>> I see two reasonable solutions:
> >>>>> 
> >>>>> 1. Dona??t fiddle with the struct file at all. Instead make the inode flag
> >>>>> work by itself.
> >>>> 
> >>>> Currently, the various VFS paths check only the struct file's f_mode to deny
> >>>> writes of already opened files. This would mean more checking in all those
> >>>> paths (and modification of all those paths).
> >>>> 
> >>>> Anyway going with that idea, we could
> >>>> 1. call deny_write_access(file) from the memfd's seal path which decrements
> >>>> the inode::i_writecount.
> >>>> 2. call get_write_access(inode) in the various VFS paths in addition to
> >>>> checking for FMODE_*WRITE and deny the write (incase i_writecount is negative)
> >>>> 
> >>>> That will prevent both reopens, and writes from succeeding. However I worry a
> >>>> bit about 2 not being too familiar with VFS internals, about what the
> >>>> consequences of doing that may be.
> >>> 
> >>> IMHO, modifying both the inode and the struct file separately is fine,
> >>> since they mean different things. In regular filesystems, it's fine to
> >>> have a read-write open file description for a file whose inode grants
> >>> write permission to nobody. Speaking of which: is fchmod enough to
> >>> prevent this attack?
> >> 
> >> Well, yes and no. fchmod does prevent reopening the file RW, but
> >> anyone with permissions (owner, CAP_FOWNER) can just fchmod it back. A
> >> seal is supposed to be irrevocable, so fchmod-as-inode-seal probably
> >> isn't sufficient by itself. While it might be good enough for Android
> >> (in the sense that it'll prevent RW-reopens from other security
> >> contexts to which we send an open memfd file), it's still conceptually
> >> ugly, IMHO. Let's go with the original approach of just tweaking the
> >> inode so that open-for-write is permanently blocked.
> > 
> > Agreed with the idea of modifying both file and inode flags. I was thinking
> > modifying i_mode may do the trick but as you pointed it probably could be
> > reverted by chmod or some other attribute setting calls.
> > 
> > OTOH, I don't think deny_write_access(file) can be reverted from any
> > user-facing path so we could do that from the seal to prevent the future
> > opens in write mode. I'll double check and test that out tomorrow.
> > 
> > 
> 
> This seems considerably more complicated and more fragile than needed. Just
> add a new F_SEAL_WRITE_FUTURE.  Grep for F_SEAL_WRITE and make the _FUTURE
> variant work exactly like it with two exceptions:
> 
> - shmem_mmap and maybe its hugetlbfs equivalent should check for it and act
> accordingly.

There's more to it than that, we also need to block future writes through
write syscall, so we have to hook into the write path too once the seal is
set, not just the mmap. That means we have to add code in mm/shmem.c to do
that in all those handlers, to check for the seal (and hope we didn't miss a
file_operations handler). Is that what you are proposing?

Also, it means we have to keep CONFIG_TMPFS enabled so that the
shmem_file_operations write handlers like write_iter are hooked up. Currently
memfd works even with !CONFIG_TMPFS.

> - add_seals wona??t need the wait_for_pins and mapping_deny_write logic.
> 
> That really should be all thata??s needed.

It seems a fair idea what you're saying. But I don't see how its less
complex.. IMO its far more simple to have VFS do the denial of the operations
based on the flags of its datastructures.. and if it works (which I will test
to be sure it will), then we should be good.

Btw by any chance, are you also coming by LPC conference next week?

thanks!

 - Joel
