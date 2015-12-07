Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0396B027C
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 17:42:23 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so4285082igb.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 14:42:23 -0800 (PST)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id u81si938960ioi.164.2015.12.07.14.42.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 14:42:22 -0800 (PST)
Received: by ioir85 with SMTP id r85so6071536ioi.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 14:42:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <B4520E53-6DD9-44D7-A064-9F405FBAA793@gmail.com>
References: <20151203000342.GA30015@www.outflux.net>
	<B4520E53-6DD9-44D7-A064-9F405FBAA793@gmail.com>
Date: Mon, 7 Dec 2015 14:42:22 -0800
Message-ID: <CAGXu5jJaY9WeR-NiZXfAu=hM6U7DaPD_d8ZZTAdo_EkS3WDxCw@mail.gmail.com>
Subject: Re: [PATCH v2] clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 3, 2015 at 5:45 PM, yalin wang <yalin.wang2010@gmail.com> wrote=
:
>
>> On Dec 2, 2015, at 16:03, Kees Cook <keescook@chromium.org> wrote:
>>
>> Normally, when a user can modify a file that has setuid or setgid bits,
>> those bits are cleared when they are not the file owner or a member
>> of the group. This is enforced when using write and truncate but not
>> when writing to a shared mmap on the file. This could allow the file
>> writer to gain privileges by changing a binary without losing the
>> setuid/setgid/caps bits.
>>
>> Changing the bits requires holding inode->i_mutex, so it cannot be done
>> during the page fault (due to mmap_sem being held during the fault).
>> Instead, clear the bits if PROT_WRITE is being used at mmap time.
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> Cc: stable@vger.kernel.org
>> =E2=80=94
>
> is this means mprotect() sys call also need add this check?
> mprotect() can change to PROT_WRITE, then it can write to a
> read only map again , also a secure hole here .

Yes, good point. This needs to be added. I will send a new patch. Thanks!

-Kees

--=20
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
