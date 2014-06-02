Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f169.google.com (mail-ve0-f169.google.com [209.85.128.169])
	by kanga.kvack.org (Postfix) with ESMTP id C9EEE6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 13:51:16 -0400 (EDT)
Received: by mail-ve0-f169.google.com with SMTP id jx11so5695079veb.28
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 10:51:16 -0700 (PDT)
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
        by mx.google.com with ESMTPS id wg9si8344267vcb.30.2014.06.02.10.51.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 10:51:16 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id ij19so1001229vcb.2
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 10:51:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1406020331100.1259@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
 <1397587118-1214-3-git-send-email-dh.herrmann@gmail.com> <alpine.LSU.2.11.1405191916300.2970@eggly.anvils>
 <CANq1E4TORuZU7frtR167P-GNPzEuvbjXXEfi9KdvTwGojqGruA@mail.gmail.com> <alpine.LSU.2.11.1406020331100.1259@eggly.anvils>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 2 Jun 2014 10:50:55 -0700
Message-ID: <CALCETrUp+3h7aW=FUoB2fng0gNF_Fi3K-WYPR8bNXoXR5968PA@mail.gmail.com>
Subject: Re: [PATCH v2 2/3] shm: add memfd_create() syscall
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: David Herrmann <dh.herrmann@gmail.com>, Tony Battersby <tonyb@cybernetics.com>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

On Mon, Jun 2, 2014 at 3:59 AM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 23 May 2014, David Herrmann wrote:
>> On Tue, May 20, 2014 at 4:20 AM, Hugh Dickins <hughd@google.com> wrote:
>> >
>> > What is a front-FD?
>>
>> With 'front-FD' I refer to things like dma-buf: They allocate a
>> file-descriptor which is just a wrapper around a kernel-internal FD.
>> For instance, DRM-gem buffers exported as dma-buf. fops on the dma-buf
>> are forwarded to the shmem-fd of the given gem-object, but any access
>> to the inode of the dma-buf fd is a no-op as the dma-buf fd uses
>> anon-inode, not the shmem-inode.
>>
>> A previous revision of memfd used something like that, but that was
>> inherently racy.
>
> Thanks for explaining: then I guess you can leave "front-FD" out of the
> description next time around, in case there are others like me who are
> more mystified than enlightened by it.
>
>> > But this does highlight how the "size" arg to memfd_create() is
>> > perhaps redundant.  Why give a size there, when size can be changed
>> > afterwards?  I expect your answer is that many callers want to choose
>> > the size at the beginning, and would prefer to avoid the extra call.
>> > I'm not sure if that's a good enough reason for a redundant argument.
>>
>> At one point in time we might be required to support atomic-sealing.
>> So a memfd_create() call takes the initial seals as upper 32bits in
>> "flags" and sets them before returning the object. If these seals
>> contain SEAL_GROW/SHRINK, we must pass the size during setup (think
>> CLOEXEC with fork()).
>
> That does sound like over-design to me.  You stop short of passing
> in an optional buffer of the data it's to contain, good.
>
> I think it would be a clearer interface without the size, but really
> that's an issue for the linux-api people you'll be Cc'ing next time.

I agree that the interface is more orthogonal without size, but I
suspect that every single user of memfd_create will follow up with an
immediate ftruncate for fallocate.  That being said, maybe it's better
to leave size out so that users have to think about whether to use
ftruncate or fallocate.

>
> You say "think CLOEXEC with fork()": you have thought about this, I
> have not, please spell out for me what the atomic size guards against.
> Do you want an fd that's not shared across fork?
>
>>
>> Note that we spent a lot of time discussing whether such
>> atomic-sealing is necessary and no-one came up with a real race so
>> far. Therefore, I didn't include that. But especially if we add new
>> seals (like SHMEM_SEAL_OPEN, which I still think is not needed and
>> just hides real problems), we might at one point be required to
>> support that. That's also the reason why "flags" is 64bits.
>>
>> One might argue that we can just add memfd_create2() once that
>> happens, but I didn't see any harm in including "size" and making them
>> 64bit.
>
> I've not noticed another system call with 64-bit flags, it does seem
> over the top to me: the familiar ones all use int.  But again,
> a matter for linux-api not for me.

I think that 64-bit flags are barely better than just having two flags
arguments: 64-bit syscall arguments take up two slots on 32-bit
architectures, so they don't save any space.  (They save a tiny amount
of time on 64-bit architectures.)

>
> Hugh



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
