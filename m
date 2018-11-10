Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64C846B079B
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 13:45:23 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id w206so1952238vsc.2
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 10:45:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e24sor6438765uah.50.2018.11.10.10.45.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 10:45:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20181110182405.GB242356@google.com>
References: <20181108041537.39694-1-joel@joelfernandes.org>
 <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
 <CAG48ez0kQ4d566bXTFOYANDgii-stL-Qj-oyaBzvfxdV=PU-7g@mail.gmail.com>
 <20181110032005.GA22238@google.com> <69CE06CC-E47C-4992-848A-66EB23EE6C74@amacapital.net>
 <20181110182405.GB242356@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Sat, 10 Nov 2018 10:45:19 -0800
Message-ID: <CAKOZuesQXRtthJTEr86LByH3gPpAdT-PQM0d1jqr131=zZNRKw@mail.gmail.com>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Jann Horn <jannh@google.com>, kernel list <linux-kernel@vger.kernel.org>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, Valdis Kletnieks <valdis.kletnieks@vt.edu>, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

On Sat, Nov 10, 2018 at 10:24 AM, Joel Fernandes <joel@joelfernandes.org> w=
rote:
> Thanks Andy for your thoughts, my comments below:
>
> On Fri, Nov 09, 2018 at 10:05:14PM -0800, Andy Lutomirski wrote:
>>
>>
>> > On Nov 9, 2018, at 7:20 PM, Joel Fernandes <joel@joelfernandes.org> wr=
ote:
>> >
>> >> On Fri, Nov 09, 2018 at 10:19:03PM +0100, Jann Horn wrote:
>> >>> On Fri, Nov 9, 2018 at 10:06 PM Jann Horn <jannh@google.com> wrote:
>> >>> On Fri, Nov 9, 2018 at 9:46 PM Joel Fernandes (Google)
>> >>> <joel@joelfernandes.org> wrote:
>> >>>> Android uses ashmem for sharing memory regions. We are looking forw=
ard
>> >>>> to migrating all usecases of ashmem to memfd so that we can possibl=
y
>> >>>> remove the ashmem driver in the future from staging while also
>> >>>> benefiting from using memfd and contributing to it. Note staging dr=
ivers
>> >>>> are also not ABI and generally can be removed at anytime.
>> >>>>
>> >>>> One of the main usecases Android has is the ability to create a reg=
ion
>> >>>> and mmap it as writeable, then add protection against making any
>> >>>> "future" writes while keeping the existing already mmap'ed
>> >>>> writeable-region active.  This allows us to implement a usecase whe=
re
>> >>>> receivers of the shared memory buffer can get a read-only view, whi=
le
>> >>>> the sender continues to write to the buffer.
>> >>>> See CursorWindow documentation in Android for more details:
>> >>>> https://developer.android.com/reference/android/database/CursorWind=
ow
>> >>>>
>> >>>> This usecase cannot be implemented with the existing F_SEAL_WRITE s=
eal.
>> >>>> To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE s=
eal
>> >>>> which prevents any future mmap and write syscalls from succeeding w=
hile
>> >>>> keeping the existing mmap active.
>> >>>
>> >>> Please CC linux-api@ on patches like this. If you had done that, I
>> >>> might have criticized your v1 patch instead of your v3 patch...
>> >>>
>> >>>> The following program shows the seal
>> >>>> working in action:
>> >>> [...]
>> >>>> Cc: jreck@google.com
>> >>>> Cc: john.stultz@linaro.org
>> >>>> Cc: tkjos@google.com
>> >>>> Cc: gregkh@linuxfoundation.org
>> >>>> Cc: hch@infradead.org
>> >>>> Reviewed-by: John Stultz <john.stultz@linaro.org>
>> >>>> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
>> >>>> ---
>> >>> [...]
>> >>>> diff --git a/mm/memfd.c b/mm/memfd.c
>> >>>> index 2bb5e257080e..5ba9804e9515 100644
>> >>>> --- a/mm/memfd.c
>> >>>> +++ b/mm/memfd.c
>> >>> [...]
>> >>>> @@ -219,6 +220,25 @@ static int memfd_add_seals(struct file *file, =
unsigned int seals)
>> >>>>                }
>> >>>>        }
>> >>>>
>> >>>> +       if ((seals & F_SEAL_FUTURE_WRITE) &&
>> >>>> +           !(*file_seals & F_SEAL_FUTURE_WRITE)) {
>> >>>> +               /*
>> >>>> +                * The FUTURE_WRITE seal also prevents growing and =
shrinking
>> >>>> +                * so we need them to be already set, or requested =
now.
>> >>>> +                */
>> >>>> +               int test_seals =3D (seals | *file_seals) &
>> >>>> +                                (F_SEAL_GROW | F_SEAL_SHRINK);
>> >>>> +
>> >>>> +               if (test_seals !=3D (F_SEAL_GROW | F_SEAL_SHRINK)) =
{
>> >>>> +                       error =3D -EINVAL;
>> >>>> +                       goto unlock;
>> >>>> +               }
>> >>>> +
>> >>>> +               spin_lock(&file->f_lock);
>> >>>> +               file->f_mode &=3D ~(FMODE_WRITE | FMODE_PWRITE);
>> >>>> +               spin_unlock(&file->f_lock);
>> >>>> +       }
>> >>>
>> >>> So you're fiddling around with the file, but not the inode? How are
>> >>> you preventing code like the following from re-opening the file as
>> >>> writable?
>> >>>
>> >>> $ cat memfd.c
>> >>> #define _GNU_SOURCE
>> >>> #include <unistd.h>
>> >>> #include <sys/syscall.h>
>> >>> #include <printf.h>
>> >>> #include <fcntl.h>
>> >>> #include <err.h>
>> >>> #include <stdio.h>
>> >>>
>> >>> int main(void) {
>> >>>  int fd =3D syscall(__NR_memfd_create, "testfd", 0);
>> >>>  if (fd =3D=3D -1) err(1, "memfd");
>> >>>  char path[100];
>> >>>  sprintf(path, "/proc/self/fd/%d", fd);
>> >>>  int fd2 =3D open(path, O_RDWR);
>> >>>  if (fd2 =3D=3D -1) err(1, "reopen");
>> >>>  printf("reopen successful: %d\n", fd2);
>> >>> }
>> >>> $ gcc -o memfd memfd.c
>> >>> $ ./memfd
>> >>> reopen successful: 4
>> >>> $
>> >>>
>> >>> That aside: I wonder whether a better API would be something that
>> >>> allows you to create a new readonly file descriptor, instead of
>> >>> fiddling with the writability of an existing fd.
>> >>
>> >> My favorite approach would be to forbid open() on memfds, hope that
>> >> nobody notices the tiny API break, and then add an ioctl for "reopen
>> >> this memfd with reduced permissions" - but that's just my personal
>> >> opinion.
>> >
>> > I did something along these lines and it fixes the issue, but I forbid=
 open
>> > of memfd only when the F_SEAL_FUTURE_WRITE seal is in place. So then i=
ts not
>> > an ABI break because this is a brand new seal. That seems the least in=
trusive
>> > solution and it works. Do you mind testing it and I'll add your and Te=
sted-by
>> > to the new fix? The patch is based on top of this series.
>> >
>> > ---8<-----------
>> > From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
>> > Subject: [PATCH] mm/memfd: Fix possible promotion to writeable of seal=
ed memfd
>> >
>> > Jann Horn found that reopening an F_SEAL_FUTURE_WRITE sealed memfd
>> > through /proc/self/fd/N symlink as writeable succeeds. The simplest fi=
x
>> > without causing ABI breakages and ugly VFS hacks is to simply deny all
>> > opens on F_SEAL_FUTURE_WRITE sealed fds.
>> >
>> > Reported-by: Jann Horn <jannh@google.com>
>> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
>> > ---
>> > mm/shmem.c | 18 ++++++++++++++++++
>> > 1 file changed, 18 insertions(+)
>> >
>> > diff --git a/mm/shmem.c b/mm/shmem.c
>> > index 446942677cd4..5b378c486b8f 100644
>> > --- a/mm/shmem.c
>> > +++ b/mm/shmem.c
>> > @@ -3611,7 +3611,25 @@ static const struct address_space_operations sh=
mem_aops =3D {
>> >    .error_remove_page =3D generic_error_remove_page,
>> > };
>> >
>> > +/* Could arrive here for memfds opened through /proc/ */
>> > +int shmem_open(struct inode *inode, struct file *file)
>> > +{
>> > +    struct shmem_inode_info *info =3D SHMEM_I(inode);
>> > +
>> > +    /*
>> > +     * memfds for which future writes have been prevented
>> > +     * should not be reopened, say, through /proc/pid/fd/N
>> > +     * symlinks otherwise it can cause a sealed memfd to be
>> > +     * promoted to writable.
>> > +     */
>> > +    if (info->seals & F_SEAL_FUTURE_WRITE)
>> > +        return -EACCES;
>> > +
>> > +    return 0;
>> > +}
>>
>> The result of this series is very warty. We have a concept of seals, and=
 they all work similarly, except the new future write seal. That one:
>>
>
> I don't see it as warty, different seals will work differently. It works
> quite well for our usecase, and since Linux is all about solving real
> problems in the real work, it would be useful to have it.
>
>> - causes a probably-observable effect in the file mode in F_GETFL.
>
> Wouldn't that be the right thing to observe anyway?
>
>> - causes reopen to fail.
>
> So this concern isn't true anymore if we make reopen fail only for WRITE
> opens as Daniel suggested. I will make this change so that the security f=
ix
> is a clean one.
>
>> - does *not* affect other struct files that may already exist on the sam=
e inode.
>
> TBH if you really want to block all writes to the file, then you want
> F_SEAL_WRITE, not this seal. The usecase we have is the fd is sent over I=
PC
> to another process and we want to prevent any new writes in the receiver
> side. There is no way this other receiving process can have an existing f=
d
> unless it was already sent one without the seal applied.  The proposed se=
al
> could be renamed to F_SEAL_FD_WRITE if that is preferred.
>
>> - mysteriously malfunctions if you try to set it again on another struct
>> file that already exists
>>
>
> I didn't follow this, could you explain more?
>
>> - probably is insecure when used on hugetlbfs.
>
> The usecase is not expected to prevent all writes, indeed the usecase
> requires existing mmaps to continue to be able to write into the memory m=
ap.
> So would you call that a security issue too? The use of the seal wants to
> allow existing mmap regions to be continue to be written into (I mentione=
d
> more details in the cover letter).
>
>> I see two reasonable solutions:
>>
>> 1. Don=E2=80=99t fiddle with the struct file at all. Instead make the in=
ode flag
>> work by itself.
>
> Currently, the various VFS paths check only the struct file's f_mode to d=
eny
> writes of already opened files. This would mean more checking in all thos=
e
> paths (and modification of all those paths).
>
> Anyway going with that idea, we could
> 1. call deny_write_access(file) from the memfd's seal path which decremen=
ts
> the inode::i_writecount.
> 2. call get_write_access(inode) in the various VFS paths in addition to
> checking for FMODE_*WRITE and deny the write (incase i_writecount is nega=
tive)
>
> That will prevent both reopens, and writes from succeeding. However I wor=
ry a
> bit about 2 not being too familiar with VFS internals, about what the
> consequences of doing that may be.

IMHO, modifying both the inode and the struct file separately is fine,
since they mean different things. In regular filesystems, it's fine to
have a read-write open file description for a file whose inode grants
write permission to nobody. Speaking of which: is fchmod enough to
prevent this attack?

>> 2. Don=E2=80=99t call it a =E2=80=9Cseal=E2=80=9D.  Instead fix the /pro=
c hole and add an API to
>> drop write access on an existing struct file.
>>
>> I personally prefer #2.
>
> So I don't think proc has a hole looking at the code yesterday. As I was
> saying in other thread, its just how symlinks work. If we were to apply t=
his
> API to files in general, and we had symlinks to files and we tried to reo=
pen the
> file, we would run into the same issue - that's why I believe it has noth=
ing
> to do with proc, and the fix has to be in the underlying inode being poin=
ted
> to. Does that make sense or did I miss something?

+1. Another point to consider is that even if we did somehow fix the
"proc hole", any other means (perhaps in the future) of obtaining an
inode reference would then be insecure, perhaps silently. For example
--- is there a way to use open_by_handle_at(2) to open a memfd file?
