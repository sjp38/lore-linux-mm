Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 411816B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 07:48:32 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p7-v6so5931631qkb.5
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 04:48:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o55-v6sor1953784qtk.75.2018.07.04.04.48.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 04:48:31 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Date: Wed, 04 Jul 2018 07:48:27 -0400
Message-ID: <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
In-Reply-To: <20180704111731.GJ22503@dhcp22.suse.cz>
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
 <20180704111731.GJ22503@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_CF325058-D4FD-44D7-AD04-99EA9433D140_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_CF325058-D4FD-44D7-AD04-99EA9433D140_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 4 Jul 2018, at 7:17, Michal Hocko wrote:

> On Wed 04-07-18 19:01:51, Tetsuo Handa wrote:
>> +Michal Hocko
>>
>> On 2018/07/04 13:19, syzbot wrote:
>>> Hello,
>>>
>>> syzbot found the following crash on:
>>>
>>> HEAD commit:    d3bc0e67f852 Merge tag 'for-4.18-rc2-tag' of git://gi=
t.ker..
>>> git tree:       upstream
>>> console output: https://syzkaller.appspot.com/x/log.txt?x=3D1000077c4=
00000
>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=3Da63be0c83=
e84d370
>>> dashboard link: https://syzkaller.appspot.com/bug?extid=3D5dcb560fe12=
aa5091c06
>>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>>> userspace arch: i386
>>> syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=3D158577a=
2400000
>>
>> Here is C reproducer made from syz reproducer. mlockall(MCL_FUTURE) is=
 involved.
>>
>> This problem is triggerable by an unprivileged user.
>> Shows different result on x86_64 (crash) and x86_32 (stall).
>>
>> ------------------------------------------------------------
>> /* Need to compile using "-m32" option if host is 64bit. */
>> #include <sys/types.h>
>> #include <sys/stat.h>
>> #include <fcntl.h>
>> #include <unistd.h>
>> #include <sys/mman.h>
>> int uselib(const char *library);
>>
>> int main(int argc, char *argv[])
>> {
>> 	int fd =3D open("file", O_WRONLY | O_CREAT, 0644);
>> 	write(fd, "\x7f\x45\x4c\x46\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x=
00\x00\x02"
>> 	      "\x00\x06\x00\xca\x3f\x8b\xca\x00\x00\x00\x00\x38\x00\x00\x00\x=
00\x00"
>> 	      "\x00\xf7\xff\xff\xff\xff\xff\xff\x1f\x00\x02\x00\x00\x00\x00\x=
00\x00"
>> 	      "\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x=
f8\x7b"
>> 	      "\x66\xff\x00\x00\x05\x00\x00\x00\x76\x86\x00\x00\x00\x00\x00\x=
00\x00"
>> 	      "\x00\x00\x00\x31\x0f\xf3\xee\xc1\xb0\x00\x0c\x08\x53\x55\xbe\x=
88\x47"
>> 	      "\xc2\x2e\x30\xf5\x62\x82\xc6\x2c\x95\x72\x3f\x06\x8f\xe4\x2d\x=
27\x96"
>> 	      "\xcc", 120);
>> 	fchmod(fd, 0755);
>> 	close(fd);
>> 	mlockall(MCL_FUTURE); /* Removing this line avoids the bug. */
>> 	uselib("file");
>> 	return 0;
>> }
>> ------------------------------------------------------------
>>
>> ------------------------------------------------------------
>> CentOS Linux 7 (Core)
>> Kernel 4.18.0-rc3 on an x86_64
>>
>> localhost login: [   81.210241] emacs (9634) used greatest stack depth=
: 10416 bytes left
>> [  140.099935] ------------[ cut here ]------------
>> [  140.101904] kernel BUG at mm/gup.c:1242!
>
> Is this
> 	VM_BUG_ON(len !=3D PAGE_ALIGN(len));
> in __mm_populate? I do not really get why we should VM_BUG_ON when the
> len is not page aligned to be honest. The library is probably containin=
g
> some funky setup but if we simply cannot round up to the next PAGE_SIZE=

> boundary then we should probably just error out and fail. This is an
> area I am really familiar with so I cannot really judge.

A strange thing is that __mm_populate() is only called by do_mlock() from=
 mm/mlock.c,
which makes len PAGE_ALIGN already. That VM_BUG_ON should not be triggere=
d.

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_CF325058-D4FD-44D7-AD04-99EA9433D140_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAls8tAsWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzI7iB/9Ie3GF1tCCmjH2QLzGTxLjNGj8
UoGbpVufgnoRVKaWmgUefCsK3Mby7qiC1BedfRL7IZcsETAAqEaPxNo+5puN7Pp4
83bX8lbye6DDD5fU9IhTtqSQNQJzLSSwupRZwjzZ4+3zi4XmPigKmHYUjJnqfdK0
gkyo7tQZUyUIRENjMgJny6CkYpXqYJry7/FOjgTrdzlyX4osPJplRJGhytD+Oe9T
4FU6I7YXUA4YfrFha+bL+Nv333y9G1TLvr3tCWwJH49LE8ZoKTRSPMO+Jhxv31dt
JyBNnuP9bZJH8eVCLOp47tie9hwsENNev1hOaqsErZf+DUlgwNKZYgVf5n7i
=Wh6w
-----END PGP SIGNATURE-----

--=_MailMate_CF325058-D4FD-44D7-AD04-99EA9433D140_=--
