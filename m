Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 5A7C26B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 00:51:47 -0500 (EST)
Received: by obbwd18 with SMTP id wd18so2187897obb.25
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 21:51:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1202272003380.1574@eggly.anvils>
References: <1329990365-23779-1-git-send-email-jarkko.sakkinen@intel.com>
	<alpine.LRH.2.02.1202241913400.30742@tundra.namei.org>
	<alpine.LSU.2.00.1202241904070.22389@eggly.anvils>
	<20120227144602.07f5ec33.akpm@linux-foundation.org>
	<CAGGTEhPQ6OLgqZbbAwE=3Xj8qE2iNhLOk5LdkGU13WxbY=qb2w@mail.gmail.com>
	<alpine.LSU.2.00.1202272003380.1574@eggly.anvils>
Date: Tue, 28 Feb 2012 07:51:26 +0200
Message-ID: <CADjiTvCViw4tZ9HvH-s8a2_8uW82BwfXz3PLQmEEVAVC0PbDwg@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: security xattr setting on inode creation
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Ware, Ryan R" <ryan.r.ware@intel.com>, Andrew Morton <akpm@linux-foundation.org>, James Morris <jmorris@namei.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org

On Tue, Feb 28, 2012 at 6:10 AM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 28 Feb 2012, Ware, Ryan R wrote:
>> On Tue, Feb 28, 2012 at 7:46 AM, Andrew Morton <akpm@linux-foundation.or=
g>wrote:
>> > On Fri, 24 Feb 2012 19:19:22 -0800 (PST)
>> > Hugh Dickins <hughd@google.com> wrote:
>> >...
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!new_xattr->name) {
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 kfree(new_xattr);
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return -ENOMEM;
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > > +
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(new_xattr->name, =
XATTR_SECURITY_PREFIX,
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0XATTR_SECURITY_PREFIX_LEN);
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(new_xattr->name +=
 XATTR_SECURITY_PREFIX_LEN,
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0xattr->name, len);
>> > > +
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(&info->lock);
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_add(&new_xattr->lis=
t, &info->xattr_list);
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&info->lock)=
;
>> > > + =C2=A0 =C2=A0 }
>> > > +
>> > > + =C2=A0 =C2=A0 return 0;
>> > > +}
>> >
>> > So if there's a kmalloc failure partway through the array, we leave a
>> > partially xattrified inode in place.
>> >
>> > Are we sure this is OK?
>> >
>>
>> I'm guessing Jarkko can clean that up a bit. =C2=A0It wouldn't be a good=
 idea to
>> leave inaccurate data structures laying around during failure cases.
>
> Andrew raises a good concern, but Jarkko got it just right and no
> change is needed: any xattrs already allocated are properly linked
> on info->xattr_list, then when security_inode_init_security() fails
> (with an error other than EOPNOTSUPP) the failing inode is iput(),
> which ends up in shmem_evict_inode(), which kfree()s those xattrs
> (and their names) on info->xattr_list.

Yeah, that's how I understood it too. These the are places where
security_inode_init_security() is called:

- http://lxr.free-electrons.com/source/mm/shmem.c#L1459
- http://lxr.free-electrons.com/source/mm/shmem.c#L1590

>
> Hugh

/Jarkko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
