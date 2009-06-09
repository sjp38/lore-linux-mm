Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 12EAF6B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 02:06:24 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
	<m1oct739xu.fsf@fess.ebiederm.org>
	<20090606080334.GA15204@ZenIV.linux.org.uk>
	<E1MDbLz-0003wm-Db@pomaz-ex.szeredi.hu>
	<20090608162913.GL8633@ZenIV.linux.org.uk>
	<E1MDhxh-0004nz-Qm@pomaz-ex.szeredi.hu>
	<20090608175018.GM8633@ZenIV.linux.org.uk>
	<E1MDuEI-0006BC-1C@pomaz-ex.szeredi.hu>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 08 Jun 2009 23:31:16 -0700
In-Reply-To: <E1MDuEI-0006BC-1C@pomaz-ex.szeredi.hu> (Miklos Szeredi's message of "Tue\, 09 Jun 2009 07\:50\:38 +0200")
Message-ID: <m1tz2pyl3f.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [PATCH 0/23] File descriptor hot-unplug support v2
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: viro@ZenIV.linux.org.uk, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hugh@veritas.com, tj@kernel.org, adobriyan@gmail.com, torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk, gregkh@suse.de, npiggin@suse.de, akpm@linux-foundation.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi <miklos@szeredi.hu> writes:

> On Mon, 8 Jun 2009, Al Viro wrote:
>> On Mon, Jun 08, 2009 at 06:44:41PM +0200, Miklos Szeredi wrote:
>> 
>> > I'm still not getting what the problem is.  AFAICS file operations are
>> > either
>> > 
>> >  a) non-interruptible but finish within a short time or
>> >  b) may block indefinitely but are interruptible (or at least killable).
>> > 
>> > Anything else is already problematic, resulting in processes "stuck in
>> > D state".
>> 
>> Welcome to reality...
>> 
>> * bread() is non-interruptible
>> * so's copy_from_user()/copy_to_user()
>
> And why should revoke(2) care?  Just wait for the damn thing to
> finish.  Why exactly do these need to be interruptible?

Agreed.  I expect the data size is going to be a page or less.  Which
is at most 64K on some weird architectures.  I think that counts as a
short time waiting for disk I/O.  Baring thrashing.

> Okay, if we want revoke or umount -f to be instantaneous then all that
> needs to be taken care of.  But does it *need* to be?

Good question.  I wonder what umount -f needs when we yank out a usb drive.

> My idea of revoke is something like below:
>
>   - make sure no new operations are started on the file
>   - check state of tasks for ongoing operations, if interruptible send signal

    Figuring out who to send a signal to is tricky.  Still it should be doable
    in the common case.

>   - wait for all pending operations to finish
>   - kill file

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
