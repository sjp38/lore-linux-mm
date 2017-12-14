Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4796B0266
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:20:28 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id r55so2278625otc.23
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 18:20:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s11si955849oif.41.2017.12.13.18.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 18:20:27 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.1 \(3445.4.7\))
Subject: Re: [PATCH] mm: save current->journal_info before calling
 fault/page_mkwrite
From: "Yan, Zheng" <zyan@redhat.com>
In-Reply-To: <20171213165923.0ea4eb3e996b7d8bf1fff72f@linux-foundation.org>
Date: Thu, 14 Dec 2017 10:20:18 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <91E1F854-7CE7-4E98-BA87-7E4E55243109@redhat.com>
References: <20171213035836.916-1-zyan@redhat.com>
 <20171213165923.0ea4eb3e996b7d8bf1fff72f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, viro@zeniv.linux.org.uk, jlayton@redhat.com, linux-mm@kvack.org


> On 14 Dec 2017, at 08:59, Andrew Morton <akpm@linux-foundation.org> =
wrote:
>=20
> On Wed, 13 Dec 2017 11:58:36 +0800 "Yan, Zheng" <zyan@redhat.com> =
wrote:
>=20
>> We recently got an Oops report:
>>=20
>> BUG: unable to handle kernel NULL pointer dereference at (null)
>> IP: jbd2__journal_start+0x38/0x1a2
>> [...]
>> Call Trace:
>>  ext4_page_mkwrite+0x307/0x52b
>>  _ext4_get_block+0xd8/0xd8
>>  do_page_mkwrite+0x6e/0xd8
>>  handle_mm_fault+0x686/0xf9b
>>  mntput_no_expire+0x1f/0x21e
>>  __do_page_fault+0x21d/0x465
>>  dput+0x4a/0x2f7
>>  page_fault+0x22/0x30
>>  copy_user_generic_string+0x2c/0x40
>>  copy_page_to_iter+0x8c/0x2b8
>>  generic_file_read_iter+0x26e/0x845
>>  timerqueue_del+0x31/0x90
>>  ceph_read_iter+0x697/0xa33 [ceph]
>>  hrtimer_cancel+0x23/0x41
>>  futex_wait+0x1c8/0x24d
>>  get_futex_key+0x32c/0x39a
>>  __vfs_read+0xe0/0x130
>>  vfs_read.part.1+0x6c/0x123
>>  handle_mm_fault+0x831/0xf9b
>>  __fget+0x7e/0xbf
>>  SyS_read+0x4d/0xb5
>>=20
>> The reason is that page fault can happen when one filesystem copies
>> data from/to userspace, the filesystem may set current->journal_info.
>> If the userspace memory is mapped to a file on another filesystem,
>> the later filesystem may also want to use current->journal_info.
>>=20
>=20
> whoops.
>=20
> A cc:stable will be needed here...
>=20
> A filesystem doesn't "copy data from/to userspace".  I assume here
> we're referring to a read() where the source is a pagecache page for
> filesystem A and the destination is a MAP_SHARED page in filesystem B?
>=20
> But in that case I don't see why filesystem A would have a live
> ->journal_info?  It's just doing a read.
>=20
> So can we please have more detailed info on the exact scenario here?
>=20
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2347,12 +2347,22 @@ static int do_page_mkwrite(struct vm_fault =
*vmf)
>> {
>> 	int ret;
>> 	struct page *page =3D vmf->page;
>> +	void *old_journal_info =3D current->journal_info;
>> 	unsigned int old_flags =3D vmf->flags;
>>=20
>> +	/*
>> +	 * If the fault happens during read_iter() copies data to
>> +	 * userspace, filesystem may have set current->journal_info.
>> +	 * If the userspace memory is mapped to a file on another
>> +	 * filesystem, page_mkwrite() of the later filesystem may
>> +	 * want to access/modify current->journal_info.
>> +	 */
>> +	current->journal_info =3D NULL;
>> 	vmf->flags =3D FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
>>=20
>> 	ret =3D vmf->vma->vm_ops->page_mkwrite(vmf);
>> -	/* Restore original flags so that caller is not surprised */
>> +	/* Restore original journal_info and flags */
>> +	current->journal_info =3D old_journal_info;
>> 	vmf->flags =3D old_flags;
>> 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
>> 		return ret;
>> @@ -3191,9 +3201,20 @@ static int do_anonymous_page(struct vm_fault =
*vmf)
>> static int __do_fault(struct vm_fault *vmf)
>> {
>> 	struct vm_area_struct *vma =3D vmf->vma;
>> +	void *old_journal_info =3D current->journal_info;
>> 	int ret;
>>=20
>> +	/*
>> +	 * If the fault happens during write_iter() copies data from
>> +	 * userspace, filesystem may have set current->journal_info.
>> +	 * If the userspace memory is mapped to a file on another
>> +	 * filesystem, fault handler of the later filesystem may want
>> +	 * to access/modify current->journal_info.
>> +	 */
>> +	current->journal_info =3D NULL;
>> 	ret =3D vma->vm_ops->fault(vmf);
>> +	/* Restore original journal_info */
>> +	current->journal_info =3D old_journal_info;
>> 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | =
VM_FAULT_RETRY |
>> 			    VM_FAULT_DONE_COW)))
>> 		return ret;
>=20
> Can you explain why you chose these two sites?  Rather than, for
> example, way up in handle_mm_fault()?

I think they are the only two places that code can enter another =
filesystem

>=20
> It's hard to believe that a fault handler will alter ->journal_info if
> it is handling a read fault, so perhaps we only need to do this for a
> write fault?  Although such an optimization probably isn't worthwhile.=20=

> The whole thing is only about three instructions.

ceph uses current->journal_info for both read/write operations. I think =
btrfs also read current->journal_info during read-only operation. (I =
mentioned this in my previous reply)

Regards
Yan, Zheng
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
