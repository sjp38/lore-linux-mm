Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id A7EB76B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 22:44:44 -0500 (EST)
Received: by lahi5 with SMTP id i5so816830lah.25
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:44:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120227144602.07f5ec33.akpm@linux-foundation.org>
References: <1329990365-23779-1-git-send-email-jarkko.sakkinen@intel.com>
	<alpine.LRH.2.02.1202241913400.30742@tundra.namei.org>
	<alpine.LSU.2.00.1202241904070.22389@eggly.anvils>
	<20120227144602.07f5ec33.akpm@linux-foundation.org>
Date: Tue, 28 Feb 2012 12:44:22 +0900
Message-ID: <CAGGTEhPQ6OLgqZbbAwE=3Xj8qE2iNhLOk5LdkGU13WxbY=qb2w@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: security xattr setting on inode creation
From: "Ware, Ryan R" <ryan.r.ware@intel.com>
Content-Type: multipart/alternative; boundary=14dae9d718a6e01ae904b9fe0a44
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, James Morris <jmorris@namei.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org

--14dae9d718a6e01ae904b9fe0a44
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Feb 28, 2012 at 7:46 AM, Andrew Morton <akpm@linux-foundation.org>wrote:

> On Fri, 24 Feb 2012 19:19:22 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
>
> > +/*
> > + * Callback for security_inode_init_security() for acquiring xattrs.
> > + */
> > +static int shmem_initxattrs(struct inode *inode,
> > +                         const struct xattr *xattr_array,
> > +                         void *fs_info)
> > +{
> > +     struct shmem_inode_info *info = SHMEM_I(inode);
> > +     const struct xattr *xattr;
> > +     struct shmem_xattr *new_xattr;
> > +     size_t len;
> > +
> > +     for (xattr = xattr_array; xattr->name != NULL; xattr++) {
> > +             new_xattr = shmem_xattr_alloc(xattr->value,
> xattr->value_len);
> > +             if (!new_xattr)
> > +                     return -ENOMEM;
> > +
> > +             len = strlen(xattr->name) + 1;
> > +             new_xattr->name = kmalloc(XATTR_SECURITY_PREFIX_LEN + len,
> > +                                       GFP_KERNEL);
> > +             if (!new_xattr->name) {
> > +                     kfree(new_xattr);
> > +                     return -ENOMEM;
> > +             }
> > +
> > +             memcpy(new_xattr->name, XATTR_SECURITY_PREFIX,
> > +                    XATTR_SECURITY_PREFIX_LEN);
> > +             memcpy(new_xattr->name + XATTR_SECURITY_PREFIX_LEN,
> > +                    xattr->name, len);
> > +
> > +             spin_lock(&info->lock);
> > +             list_add(&new_xattr->list, &info->xattr_list);
> > +             spin_unlock(&info->lock);
> > +     }
> > +
> > +     return 0;
> > +}
>
> So if there's a kmalloc failure partway through the array, we leave a
> partially xattrified inode in place.
>
> Are we sure this is OK?
>

I'm guessing Jarkko can clean that up a bit.  It wouldn't be a good idea to
leave inaccurate data structures laying around during failure cases.

Ryan

--14dae9d718a6e01ae904b9fe0a44
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote">On Tue, Feb 28, 2012 at 7:46 AM, Andrew Morton <=
span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org">akpm@linu=
x-foundation.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D"HOEnZb"><div class=3D"h5">On Fri, 24 Feb 2012 19:19:22 -0800 =
(PST)<br>
Hugh Dickins &lt;<a href=3D"mailto:hughd@google.com">hughd@google.com</a>&g=
t; wrote:<br>
<br>
&gt; +/*<br>
&gt; + * Callback for security_inode_init_security() for acquiring xattrs.<=
br>
&gt; + */<br>
&gt; +static int shmem_initxattrs(struct inode *inode,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct xattr *=
xattr_array,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *fs_info)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct shmem_inode_info *info =3D SHMEM_I(inode);<br>
&gt; + =A0 =A0 const struct xattr *xattr;<br>
&gt; + =A0 =A0 struct shmem_xattr *new_xattr;<br>
&gt; + =A0 =A0 size_t len;<br>
&gt; +<br>
&gt; + =A0 =A0 for (xattr =3D xattr_array; xattr-&gt;name !=3D NULL; xattr+=
+) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 new_xattr =3D shmem_xattr_alloc(xattr-&gt;va=
lue, xattr-&gt;value_len);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!new_xattr)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 len =3D strlen(xattr-&gt;name) + 1;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 new_xattr-&gt;name =3D kmalloc(XATTR_SECURIT=
Y_PREFIX_LEN + len,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 GFP_KERNEL);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!new_xattr-&gt;name) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(new_xattr);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 memcpy(new_xattr-&gt;name, XATTR_SECURITY_PR=
EFIX,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0XATTR_SECURITY_PREFIX_LEN);<b=
r>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 memcpy(new_xattr-&gt;name + XATTR_SECURITY_P=
REFIX_LEN,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xattr-&gt;name, len);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;info-&gt;lock);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 list_add(&amp;new_xattr-&gt;list, &amp;info-=
&gt;xattr_list);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;info-&gt;lock);<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
<br>
</div></div>So if there&#39;s a kmalloc failure partway through the array, =
we leave a<br>
partially xattrified inode in place.<br>
<br>
Are we sure this is OK?<br></blockquote><div><br></div><div>I&#39;m guessin=
g Jarkko can clean that up a bit. =A0It wouldn&#39;t be a good idea to leav=
e inaccurate data structures laying around during failure cases.</div><div>
<br></div><div>Ryan=A0</div></div>

--14dae9d718a6e01ae904b9fe0a44--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
