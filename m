Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id E44D46B0255
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 17:52:19 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id g19so3753825igv.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 14:52:19 -0800 (PST)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id n10si17460925ige.30.2015.12.09.14.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 14:52:19 -0800 (PST)
Received: by mail-ig0-x22e.google.com with SMTP id mv3so3788696igc.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 14:52:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151209082638.GA3137@quack.suse.cz>
References: <20151203000342.GA30015@www.outflux.net>
	<B4520E53-6DD9-44D7-A064-9F405FBAA793@gmail.com>
	<CAGXu5jJaY9WeR-NiZXfAu=hM6U7DaPD_d8ZZTAdo_EkS3WDxCw@mail.gmail.com>
	<CAGXu5jKtj89bgyLaYt6hMBXc+rWD9CWxE2nZP9xbSWyXBvf5qw@mail.gmail.com>
	<20151209082638.GA3137@quack.suse.cz>
Date: Wed, 9 Dec 2015 14:52:19 -0800
Message-ID: <CAGXu5j+i9JNqYrv+ze8f9GRZ7ZnjLwfgmN4roGpVrok4KNe-bw@mail.gmail.com>
Subject: Re: [PATCH v2] clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: yalin wang <yalin.wang2010@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Dec 9, 2015 at 12:26 AM, Jan Kara <jack@suse.cz> wrote:
> On Mon 07-12-15 16:40:14, Kees Cook wrote:
>> On Mon, Dec 7, 2015 at 2:42 PM, Kees Cook <keescook@chromium.org> wrote:
>> > On Thu, Dec 3, 2015 at 5:45 PM, yalin wang <yalin.wang2010@gmail.com> =
wrote:
>> >>
>> >>> On Dec 2, 2015, at 16:03, Kees Cook <keescook@chromium.org> wrote:
>> >>>
>> >>> Normally, when a user can modify a file that has setuid or setgid bi=
ts,
>> >>> those bits are cleared when they are not the file owner or a member
>> >>> of the group. This is enforced when using write and truncate but not
>> >>> when writing to a shared mmap on the file. This could allow the file
>> >>> writer to gain privileges by changing a binary without losing the
>> >>> setuid/setgid/caps bits.
>> >>>
>> >>> Changing the bits requires holding inode->i_mutex, so it cannot be d=
one
>> >>> during the page fault (due to mmap_sem being held during the fault).
>> >>> Instead, clear the bits if PROT_WRITE is being used at mmap time.
>> >>>
>> >>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> >>> Cc: stable@vger.kernel.org
>> >>> =E2=80=94
>> >>
>> >> is this means mprotect() sys call also need add this check?
>> >> mprotect() can change to PROT_WRITE, then it can write to a
>> >> read only map again , also a secure hole here .
>> >
>> > Yes, good point. This needs to be added. I will send a new patch. Than=
ks!
>>
>> This continues to look worse and worse.
>>
>> So... to check this at mprotect time, I have to know it's MAP_SHARED,
>> but that's in the vma_flags, which I can only see after holding
>> mmap_sem.
>>
>> The best I can think of now is to strip the bits at munmap time, since
>> you can't execute an mmapped file until it closes.
>>
>> Jan, thoughts on this?
>
> Umm, so we actually refuse to execute a file while someone has it open fo=
r
> writing (deny_write_access() in do_open_execat()). So dropping the suid /
> sgid bits when closing file for writing could be plausible. Grabbing
> i_mutex from __fput() context is safe (it gets called from task_work
> context when returning to userspace).
>
> That way we could actually remove the checks done for each write. To avoi=
d
> unexpected removal of suid/sgid bits when someone just opens & closes the
> file, we could mark the file as needing suid/sgid treatment by a flag in
> inode->i_flags when file gets written to or mmaped and then check for thi=
s
> in __fput().

Yeah, this is ultimately where I ended up for the v4 (and fixed up in
v5). I added the flag to file, though, not inode. Sending v5 now...

-Kees

>
> I've added Al Viro to CC just in case he is aware of some issues with
> this...
>
>                                                                 Honza
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR



--=20
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
