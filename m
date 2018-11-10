Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB0FE6B079C
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 14:11:29 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id u29so1990984vsj.1
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 11:11:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k140sor5246236vka.12.2018.11.10.11.11.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 11:11:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKOZuesQXRtthJTEr86LByH3gPpAdT-PQM0d1jqr131=zZNRKw@mail.gmail.com>
References: <20181108041537.39694-1-joel@joelfernandes.org>
 <CAG48ez1h=v-JYnDw81HaYJzOfrNhwYksxmc2r=cJvdQVgYM+NA@mail.gmail.com>
 <CAG48ez0kQ4d566bXTFOYANDgii-stL-Qj-oyaBzvfxdV=PU-7g@mail.gmail.com>
 <20181110032005.GA22238@google.com> <69CE06CC-E47C-4992-848A-66EB23EE6C74@amacapital.net>
 <20181110182405.GB242356@google.com> <CAKOZuesQXRtthJTEr86LByH3gPpAdT-PQM0d1jqr131=zZNRKw@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Sat, 10 Nov 2018 11:11:27 -0800
Message-ID: <CAKOZueum8MtNvJ5P=W7_pRw62TdQdCgyjCwwbG1wezNboC1cxQ@mail.gmail.com>
Subject: Re: [PATCH v3 resend 1/2] mm: Add an F_SEAL_FUTURE_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Jann Horn <jannh@google.com>, kernel list <linux-kernel@vger.kernel.org>, John Reck <jreck@google.com>, John Stultz <john.stultz@linaro.org>, Todd Kjos <tkjos@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Bruce Fields <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Lei.Yang@windriver.com, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>, Valdis Kletnieks <valdis.kletnieks@vt.edu>, Hugh Dickins <hughd@google.com>, Linux API <linux-api@vger.kernel.org>

On Sat, Nov 10, 2018 at 10:45 AM, Daniel Colascione <dancol@google.com> wro=
te:
> On Sat, Nov 10, 2018 at 10:24 AM, Joel Fernandes <joel@joelfernandes.org>=
 wrote:
>> Thanks Andy for your thoughts, my comments below:
[snip]
>> I don't see it as warty, different seals will work differently. It works
>> quite well for our usecase, and since Linux is all about solving real
>> problems in the real work, it would be useful to have it.
>>
>>> - causes a probably-observable effect in the file mode in F_GETFL.
>>
>> Wouldn't that be the right thing to observe anyway?
>>
>>> - causes reopen to fail.
>>
>> So this concern isn't true anymore if we make reopen fail only for WRITE
>> opens as Daniel suggested. I will make this change so that the security =
fix
>> is a clean one.
>>
>>> - does *not* affect other struct files that may already exist on the sa=
me inode.
>>
>> TBH if you really want to block all writes to the file, then you want
>> F_SEAL_WRITE, not this seal. The usecase we have is the fd is sent over =
IPC
>> to another process and we want to prevent any new writes in the receiver
>> side. There is no way this other receiving process can have an existing =
fd
>> unless it was already sent one without the seal applied.  The proposed s=
eal
>> could be renamed to F_SEAL_FD_WRITE if that is preferred.
>>
>>> - mysteriously malfunctions if you try to set it again on another struc=
t
>>> file that already exists
>>>
>>
>> I didn't follow this, could you explain more?
>>
>>> - probably is insecure when used on hugetlbfs.
>>
>> The usecase is not expected to prevent all writes, indeed the usecase
>> requires existing mmaps to continue to be able to write into the memory =
map.
>> So would you call that a security issue too? The use of the seal wants t=
o
>> allow existing mmap regions to be continue to be written into (I mention=
ed
>> more details in the cover letter).
>>
>>> I see two reasonable solutions:
>>>
>>> 1. Don=E2=80=99t fiddle with the struct file at all. Instead make the i=
node flag
>>> work by itself.
>>
>> Currently, the various VFS paths check only the struct file's f_mode to =
deny
>> writes of already opened files. This would mean more checking in all tho=
se
>> paths (and modification of all those paths).
>>
>> Anyway going with that idea, we could
>> 1. call deny_write_access(file) from the memfd's seal path which decreme=
nts
>> the inode::i_writecount.
>> 2. call get_write_access(inode) in the various VFS paths in addition to
>> checking for FMODE_*WRITE and deny the write (incase i_writecount is neg=
ative)
>>
>> That will prevent both reopens, and writes from succeeding. However I wo=
rry a
>> bit about 2 not being too familiar with VFS internals, about what the
>> consequences of doing that may be.
>
> IMHO, modifying both the inode and the struct file separately is fine,
> since they mean different things. In regular filesystems, it's fine to
> have a read-write open file description for a file whose inode grants
> write permission to nobody. Speaking of which: is fchmod enough to
> prevent this attack?

Well, yes and no. fchmod does prevent reopening the file RW, but
anyone with permissions (owner, CAP_FOWNER) can just fchmod it back. A
seal is supposed to be irrevocable, so fchmod-as-inode-seal probably
isn't sufficient by itself. While it might be good enough for Android
(in the sense that it'll prevent RW-reopens from other security
contexts to which we send an open memfd file), it's still conceptually
ugly, IMHO. Let's go with the original approach of just tweaking the
inode so that open-for-write is permanently blocked.
