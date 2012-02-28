Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id AB3F16B007E
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 22:46:16 -0500 (EST)
Received: by lahi5 with SMTP id i5so818131lah.25
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:46:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120227144602.07f5ec33.akpm@linux-foundation.org>
References: <1329990365-23779-1-git-send-email-jarkko.sakkinen@intel.com>
	<alpine.LRH.2.02.1202241913400.30742@tundra.namei.org>
	<alpine.LSU.2.00.1202241904070.22389@eggly.anvils>
	<20120227144602.07f5ec33.akpm@linux-foundation.org>
Date: Tue, 28 Feb 2012 12:46:13 +0900
Message-ID: <CAGGTEhP=jbA664fbbZaVEN5Bxq9_3iiV84ME8QSTUohv2JLkqw@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: security xattr setting on inode creation
From: "Ware, Ryan R" <ryan.r.ware@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, James Morris <jmorris@namei.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org

On Tue, Feb 28, 2012 at 7:46 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Fri, 24 Feb 2012 19:19:22 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
>
> > +/*
> > + * Callback for security_inode_init_security() for acquiring xattrs.
> > + */
> > +static int shmem_initxattrs(struct inode *inode,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct xattr *x=
attr_array,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *fs_info)
> > +{
> > + =A0 =A0 struct shmem_inode_info *info =3D SHMEM_I(inode);
> > + =A0 =A0 const struct xattr *xattr;
> > + =A0 =A0 struct shmem_xattr *new_xattr;
> > + =A0 =A0 size_t len;
> > +
> > + =A0 =A0 for (xattr =3D xattr_array; xattr->name !=3D NULL; xattr++) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 new_xattr =3D shmem_xattr_alloc(xattr->value,
> > xattr->value_len);
> > + =A0 =A0 =A0 =A0 =A0 =A0 if (!new_xattr)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 len =3D strlen(xattr->name) + 1;
> > + =A0 =A0 =A0 =A0 =A0 =A0 new_xattr->name =3D kmalloc(XATTR_SECURITY_PR=
EFIX_LEN + len,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 GFP_KERNEL);
> > + =A0 =A0 =A0 =A0 =A0 =A0 if (!new_xattr->name) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(new_xattr);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> > + =A0 =A0 =A0 =A0 =A0 =A0 }
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 memcpy(new_xattr->name, XATTR_SECURITY_PREFIX=
,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XATTR_SECURITY_PREFIX_LEN);
> > + =A0 =A0 =A0 =A0 =A0 =A0 memcpy(new_xattr->name + XATTR_SECURITY_PREFI=
X_LEN,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xattr->name, len);
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&info->lock);
> > + =A0 =A0 =A0 =A0 =A0 =A0 list_add(&new_xattr->list, &info->xattr_list)=
;
> > + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&info->lock);
> > + =A0 =A0 }
> > +
> > + =A0 =A0 return 0;
> > +}
>
> So if there's a kmalloc failure partway through the array, we leave a
> partially xattrified inode in place.
>
> Are we sure this is OK?

I'm guessing Jarkko can clean that up a bit.  It wouldn't be a good
idea to leave inaccurate data structures laying around during failure
cases.

Ryan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
