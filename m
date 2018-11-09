Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEE166B072E
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 17:42:20 -0500 (EST)
Received: by mail-vk1-f199.google.com with SMTP id e3so767982vkd.14
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 14:42:20 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r6sor4603479uak.12.2018.11.09.14.42.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 14:42:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <BB64C995-F374-49EB-8469-4820231D8152@amacapital.net>
References: <20181108041537.39694-1-joel@joelfernandes.org>
 <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
 <CAKOZuesw1wG-YynWL7bVb+4BWtYp0Ei62vweWF+mqF1Ln-_2Tg@mail.gmail.com> <BB64C995-F374-49EB-8469-4820231D8152@amacapital.net>
From: Daniel Colascione <dancol@google.com>
Date: Fri, 9 Nov 2018 14:42:18 -0800
Message-ID: <CAKOZuetZrL10zWwn4Jzzg0QL2nd3Fm0JxGtzC79SZAfOK525Ag@mail.gmail.com>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Jann Horn <jannh@google.com>, Joel Fernandes <joel@joelfernandes.org>, kernel list <linux-kernel@vger.kernel.org>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, valdis.kletnieks@vt.edu, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Nov 9, 2018 at 2:37 PM, Andy Lutomirski <luto@amacapital.net> wrote=
:
>> Another, more general fix might be to prevent /proc/pid/fd/N opens
>> from "upgrading" access modes. But that'd be a bigger ABI break.
>
> I think we should fix that, too.  I consider it a bug fix, not an ABI bre=
ak, personally.

Someone, somewhere is probably relying on it though, and that means
that we probably can't change it unless it's actually causing
problems.

<mumble>spacebar heating</mumble>

>>> That aside: I wonder whether a better API would be something that
>>> allows you to create a new readonly file descriptor, instead of
>>> fiddling with the writability of an existing fd.
>>
>> That doesn't work, unfortunately. The ashmem API we're replacing with
>> memfd requires file descriptor continuity. I also looked into opening
>> a new FD and dup2(2)ing atop the old one, but this approach doesn't
>> work in the case that the old FD has already leaked to some other
>> context (e.g., another dup, SCM_RIGHTS). See
>> https://developer.android.com/ndk/reference/group/memory. We can't
>> break ASharedMemory_setProt.
>
>
> Hmm.  If we fix the general reopen bug, a way to drop write access from a=
n existing struct file would do what Android needs, right?  I don=E2=80=99t=
 know if there are general VFS issues with that.

I also proposed that. :-) Maybe it'd work best as a special case of
the perennial revoke(2) that people keep proposing. You'd be able to
selectively revoke all access or just write access.
