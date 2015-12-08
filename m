Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id D9ABA6B027A
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 19:40:15 -0500 (EST)
Received: by igl9 with SMTP id 9so86096649igl.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 16:40:15 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id i86si1515267ioo.118.2015.12.07.16.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 16:40:15 -0800 (PST)
Received: by igcmv3 with SMTP id mv3so91012434igc.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 16:40:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJaY9WeR-NiZXfAu=hM6U7DaPD_d8ZZTAdo_EkS3WDxCw@mail.gmail.com>
References: <20151203000342.GA30015@www.outflux.net>
	<B4520E53-6DD9-44D7-A064-9F405FBAA793@gmail.com>
	<CAGXu5jJaY9WeR-NiZXfAu=hM6U7DaPD_d8ZZTAdo_EkS3WDxCw@mail.gmail.com>
Date: Mon, 7 Dec 2015 16:40:14 -0800
Message-ID: <CAGXu5jKtj89bgyLaYt6hMBXc+rWD9CWxE2nZP9xbSWyXBvf5qw@mail.gmail.com>
Subject: Re: [PATCH v2] clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 7, 2015 at 2:42 PM, Kees Cook <keescook@chromium.org> wrote:
> On Thu, Dec 3, 2015 at 5:45 PM, yalin wang <yalin.wang2010@gmail.com> wro=
te:
>>
>>> On Dec 2, 2015, at 16:03, Kees Cook <keescook@chromium.org> wrote:
>>>
>>> Normally, when a user can modify a file that has setuid or setgid bits,
>>> those bits are cleared when they are not the file owner or a member
>>> of the group. This is enforced when using write and truncate but not
>>> when writing to a shared mmap on the file. This could allow the file
>>> writer to gain privileges by changing a binary without losing the
>>> setuid/setgid/caps bits.
>>>
>>> Changing the bits requires holding inode->i_mutex, so it cannot be done
>>> during the page fault (due to mmap_sem being held during the fault).
>>> Instead, clear the bits if PROT_WRITE is being used at mmap time.
>>>
>>> Signed-off-by: Kees Cook <keescook@chromium.org>
>>> Cc: stable@vger.kernel.org
>>> =E2=80=94
>>
>> is this means mprotect() sys call also need add this check?
>> mprotect() can change to PROT_WRITE, then it can write to a
>> read only map again , also a secure hole here .
>
> Yes, good point. This needs to be added. I will send a new patch. Thanks!

This continues to look worse and worse.

So... to check this at mprotect time, I have to know it's MAP_SHARED,
but that's in the vma_flags, which I can only see after holding
mmap_sem.

The best I can think of now is to strip the bits at munmap time, since
you can't execute an mmapped file until it closes.

Jan, thoughts on this?

-Kees

--=20
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
