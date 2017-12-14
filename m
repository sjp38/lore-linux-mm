Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C31C6B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 15:48:36 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w125so10789926itf.0
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 12:48:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i205sor3135097ita.85.2017.12.14.12.48.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 12:48:34 -0800 (PST)
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <B2D7B916-14FA-4822-8EE4-3133CEF0475F@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_2B23CB69-D919-4E75-9607-7E867F5E6F06";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] mm: save/restore current->journal_info in handle_mm_fault
Date: Thu, 14 Dec 2017 13:48:24 -0700
In-Reply-To: <CAAM7YA=ThWbBpOe1wgeYjGt3ogr9kT6uy3UpqSn94XqbhjOHJw@mail.gmail.com>
References: <20171214105527.5885-1-zyan@redhat.com>
 <20171214134338.GA1474@quack2.suse.cz>
 <CAAM7YA=ThWbBpOe1wgeYjGt3ogr9kT6uy3UpqSn94XqbhjOHJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yan, Zheng" <ukernel@gmail.com>
Cc: Jan Kara <jack@suse.cz>, "Yan, Zheng" <zyan@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, ceph-devel <ceph-devel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>


--Apple-Mail=_2B23CB69-D919-4E75-9607-7E867F5E6F06
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

[remove stable@ as this is not really a stable patch]

On Dec 14, 2017, at 7:30 AM, Yan, Zheng <ukernel@gmail.com> wrote:
>=20
> On Thu, Dec 14, 2017 at 9:43 PM, Jan Kara <jack@suse.cz> wrote:
>> On Thu 14-12-17 18:55:27, Yan, Zheng wrote:
>>> We recently got an Oops report:
>>>=20
>>> BUG: unable to handle kernel NULL pointer dereference at (null)
>>> IP: jbd2__journal_start+0x38/0x1a2
>>> [...]
>>> Call Trace:
>>>  ext4_page_mkwrite+0x307/0x52b
>>>  _ext4_get_block+0xd8/0xd8
>>>  do_page_mkwrite+0x6e/0xd8
>>>  handle_mm_fault+0x686/0xf9b
>>>  mntput_no_expire+0x1f/0x21e
>>>  __do_page_fault+0x21d/0x465
>>>  dput+0x4a/0x2f7
>>>  page_fault+0x22/0x30
>>>  copy_user_generic_string+0x2c/0x40
>>>  copy_page_to_iter+0x8c/0x2b8
>>>  generic_file_read_iter+0x26e/0x845
>>>  timerqueue_del+0x31/0x90
>>>  ceph_read_iter+0x697/0xa33 [ceph]
>>>  hrtimer_cancel+0x23/0x41
>>>  futex_wait+0x1c8/0x24d
>>>  get_futex_key+0x32c/0x39a
>>>  __vfs_read+0xe0/0x130
>>>  vfs_read.part.1+0x6c/0x123
>>>  handle_mm_fault+0x831/0xf9b
>>>  __fget+0x7e/0xbf
>>>  SyS_read+0x4d/0xb5
>>>=20
>>> ceph_read_iter() uses current->journal_info to pass context info to
>>> ceph_readpages(). Because ceph_readpages() needs to know if its =
caller
>>> has already gotten capability of using page cache (distinguish read
>>> from readahead/fadvise). ceph_read_iter() set current->journal_info,
>>> then calls generic_file_read_iter().
>>>=20
>>> In above Oops, page fault happened when copying data to userspace.
>>> Page fault handler called ext4_page_mkwrite(). Ext4 code read
>>> current->journal_info and assumed it is journal handle.
>>>=20
>>> I checked other filesystems, btrfs probably suffers similar problem
>>> for its readpage. (page fault happens when write() copies data from
>>> userspace memory and the memory is mapped to a file in btrfs.
>>> verify_parent_transid() can be called during readpage)
>>>=20
>>> Cc: stable@vger.kernel.org
>>> Signed-off-by: "Yan, Zheng" <zyan@redhat.com>
>>=20
>> I agree with the analysis but the patch is too ugly too live. Ceph =
just
>> should not be abusing current->journal_info for passing information =
between
>> two random functions or when it does a hackery like this, it should =
just
>> make sure the pieces hold together. Poluting generic code to =
accommodate
>> this hack in Ceph is not acceptable. Also bear in mind there are =
likely
>> other code paths (e.g. memory reclaim) which could recurse into =
another
>> filesystem confusing it with non-NULL current->journal_info in the =
same
>> way.
>=20
> But ...
>=20
> some filesystem set journal_info in its write_begin(), then clear it
> in write_end(). If buffer for write is mapped to another filesystem,
> current->journal can leak to the later filesystem's page_readpage().
> The later filesystem may read current->journal and treat it as its own
> journal handle.  Besides, most filesystem's vm fault handle is
> filemap_fault(), filemap also may tigger memory reclaim.

Shouldn't the memory reclaim be prevented from recursing into the other
filesystem by use of GFP_NOFS, or the new memalloc_nofs annotation?

I don't think that ext4 is ever using current->journal on any read =
paths,
only in case of writes.

>> In this particular case I'm not sure why does ceph pass 'filp' into
>> readpage() / readpages() handler when it already gets that pointer as =
part
>> of arguments...
>=20
> It actually a flag which tells ceph_readpages() if its caller is
> ceph_read_iter or readahead/fadvise/madvise. because when there are
> multiple clients read/write a file a the same time, page cache should
> be disabled.

I've wanted something similar for other reasons.  It would be better to
have a separate fs-specific pointer in the task struct to handle this
kind of information.  This can be used by the filesystem "upper half" to
communicate with the "lower half" (doing the writeout or other IO below
the VFS), and the "lower half" can use ->journal for handling the =
writeout.

However, some care would be needed to ensure that other processes =
accessing
this pointer would only do so if it is their own.  Something like
->fs_private_sb and ->fs_private_data would allow this sanely.  If the
->fs_private_sb !=3D sb in the filesystem then ->fs_private_data is not =
valid
for this fs and cannot be used by the current filesystem code.  =
Alternately,
we could have a single ->fs_private pointer to reduce impact on =
task_struct
so long as all filesystems used the first field of the structure to =
point to
"sb", probably with a library helper to ensure this was done =
consistently:

	data =3D current_fs_private_get(sb);
        current_fs_private_set(sb, data);
	data =3D current_fs_private_alloc(sb, size, gfp);

or whatever.

> Regards
> Yan, Zheng
>=20
>>=20
>>                                                                Honza
>>=20
>>> diff --git a/mm/memory.c b/mm/memory.c
>>> index a728bed16c20..db2a50233c49 100644
>>> --- a/mm/memory.c
>>> +++ b/mm/memory.c
>>> @@ -4044,6 +4044,7 @@ int handle_mm_fault(struct vm_area_struct =
*vma, unsigned long address,
>>>              unsigned int flags)
>>> {
>>>      int ret;
>>> +     void *old_journal_info;
>>>=20
>>>      __set_current_state(TASK_RUNNING);
>>>=20
>>> @@ -4065,11 +4066,24 @@ int handle_mm_fault(struct vm_area_struct =
*vma, unsigned long address,
>>>      if (flags & FAULT_FLAG_USER)
>>>              mem_cgroup_oom_enable();
>>>=20
>>> +     /*
>>> +      * Fault can happen when filesystem A's =
read_iter()/write_iter()
>>> +      * copies data to/from userspace. Filesystem A may have set
>>> +      * current->journal_info. If the userspace memory is =
MAP_SHARED
>>> +      * mapped to a file in filesystem B, we later may call =
filesystem
>>> +      * B's vm operation. Filesystem B may also want to read/set
>>> +      * current->journal_info.
>>> +      */
>>> +     old_journal_info =3D current->journal_info;
>>> +     current->journal_info =3D NULL;
>>> +
>>>      if (unlikely(is_vm_hugetlb_page(vma)))
>>>              ret =3D hugetlb_fault(vma->vm_mm, vma, address, flags);
>>>      else
>>>              ret =3D __handle_mm_fault(vma, address, flags);
>>>=20
>>> +     current->journal_info =3D old_journal_info;
>>> +
>>>      if (flags & FAULT_FLAG_USER) {
>>>              mem_cgroup_oom_disable();
>>>              /*
>>> --
>>> 2.13.6
>>>=20
>> --
>> Jan Kara <jack@suse.com>
>> SUSE Labs, CR


Cheers, Andreas






--Apple-Mail=_2B23CB69-D919-4E75-9607-7E867F5E6F06
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFaMuOapIg59Q01vtYRAmiEAJ9pU4r5yGA8jExQsx4RHiIkmpOrmgCg8E28
Gkm+uGqug+mpXWFlAsRuO3Y=
=qmmA
-----END PGP SIGNATURE-----

--Apple-Mail=_2B23CB69-D919-4E75-9607-7E867F5E6F06--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
