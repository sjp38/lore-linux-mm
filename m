Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED4AF6B072C
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 17:38:03 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 87-v6so2558150pfq.8
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 14:38:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6-v6sor7391097pls.18.2018.11.09.14.38.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Nov 2018 14:38:02 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CAKOZuesw1wG-YynWL7bVb+4BWtYp0Ei62vweWF+mqF1Ln-_2Tg@mail.gmail.com>
Date: Fri, 9 Nov 2018 14:37:58 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <BB64C995-F374-49EB-8469-4820231D8152@amacapital.net>
References: <20181108041537.39694-1-joel@joelfernandes.org> <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com> <CAKOZuesw1wG-YynWL7bVb+4BWtYp0Ei62vweWF+mqF1Ln-_2Tg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: Jann Horn <jannh@google.com>, Joel Fernandes <joel@joelfernandes.org>, kernel list <linux-kernel@vger.kernel.org>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, valdis.kletnieks@vt.edu, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>



> On Nov 9, 2018, at 2:20 PM, Daniel Colascione <dancol@google.com> wrote:
>=20
>> On Fri, Nov 9, 2018 at 1:06 PM, Jann Horn <jannh@google.com> wrote:
>>=20
>> +linux-api for API addition
>> +hughd as FYI since this is somewhat related to mm/shmem
>>=20
>> On Fri, Nov 9, 2018 at 9:46 PM Joel Fernandes (Google)
>> <joel@joelfernandes.org> wrote:
>>> Android uses ashmem for sharing memory regions. We are looking forward
>>> to migrating all usecases of ashmem to memfd so that we can possibly
>>> remove the ashmem driver in the future from staging while also
>>> benefiting from using memfd and contributing to it. Note staging drivers=

>>> are also not ABI and generally can be removed at anytime.
>>>=20
>>> One of the main usecases Android has is the ability to create a region
>>> and mmap it as writeable, then add protection against making any
>>> "future" writes while keeping the existing already mmap'ed
>>> writeable-region active.  This allows us to implement a usecase where
>>> receivers of the shared memory buffer can get a read-only view, while
>>> the sender continues to write to the buffer.
>>> See CursorWindow documentation in Android for more details:
>>> https://developer.android.com/reference/android/database/CursorWindow
>>>=20
>>> This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
>>> To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE seal
>>> which prevents any future mmap and write syscalls from succeeding while
>>> keeping the existing mmap active.
>>=20
>> Please CC linux-api@ on patches like this. If you had done that, I
>> might have criticized your v1 patch instead of your v3 patch...
>>=20
>>> The following program shows the seal
>>> working in action:
>> [...]
>>> Cc: jreck@google.com
>>> Cc: john.stultz@linaro.org
>>> Cc: tkjos@google.com
>>> Cc: gregkh@linuxfoundation.org
>>> Cc: hch@infradead.org
>>> Reviewed-by: John Stultz <john.stultz@linaro.org>
>>> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
>>> ---
>> [...]
>>> diff --git a/mm/memfd.c b/mm/memfd.c
>>> index 2bb5e257080e..5ba9804e9515 100644
>>> --- a/mm/memfd.c
>>> +++ b/mm/memfd.c
>> [...]
>>> @@ -219,6 +220,25 @@ static int memfd_add_seals(struct file *file, unsig=
ned int seals)
>>>                }
>>>        }
>>>=20
>>> +       if ((seals & F_SEAL_FUTURE_WRITE) &&
>>> +           !(*file_seals & F_SEAL_FUTURE_WRITE)) {
>>> +               /*
>>> +                * The FUTURE_WRITE seal also prevents growing and shrin=
king
>>> +                * so we need them to be already set, or requested now.
>>> +                */
>>> +               int test_seals =3D (seals | *file_seals) &
>>> +                                (F_SEAL_GROW | F_SEAL_SHRINK);
>>> +
>>> +               if (test_seals !=3D (F_SEAL_GROW | F_SEAL_SHRINK)) {
>>> +                       error =3D -EINVAL;
>>> +                       goto unlock;
>>> +               }
>>> +
>>> +               spin_lock(&file->f_lock);
>>> +               file->f_mode &=3D ~(FMODE_WRITE | FMODE_PWRITE);
>>> +               spin_unlock(&file->f_lock);
>>> +       }
>>=20
>> So you're fiddling around with the file, but not the inode? How are
>> you preventing code like the following from re-opening the file as
>> writable?
>=20
> Good catch. That's fixable too though, isn't it, just by fiddling with
> the inode, right?

True.

>=20
> Another, more general fix might be to prevent /proc/pid/fd/N opens
> from "upgrading" access modes. But that'd be a bigger ABI break.

I think we should fix that, too.  I consider it a bug fix, not an ABI break,=
 personally.

>=20
>> That aside: I wonder whether a better API would be something that
>> allows you to create a new readonly file descriptor, instead of
>> fiddling with the writability of an existing fd.
>=20
> That doesn't work, unfortunately. The ashmem API we're replacing with
> memfd requires file descriptor continuity. I also looked into opening
> a new FD and dup2(2)ing atop the old one, but this approach doesn't
> work in the case that the old FD has already leaked to some other
> context (e.g., another dup, SCM_RIGHTS). See
> https://developer.android.com/ndk/reference/group/memory. We can't
> break ASharedMemory_setProt.


Hmm.  If we fix the general reopen bug, a way to drop write access from an e=
xisting struct file would do what Android needs, right?  I don=E2=80=99t kno=
w if there are general VFS issues with that.
