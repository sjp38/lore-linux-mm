Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C4654E.954BEF84"
Subject: RE: Which is the proper way to bring in the backing store behindaninode as an struct page?
Date: Thu, 8 Jul 2004 17:45:41 -0700
Message-ID: <F989B1573A3A644BAB3920FBECA4D25A6EBF28@orsmsx407>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C4654E.954BEF84
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

> From: Ram Pai [mailto:linuxram@us.ibm.com]
>
> I dont' see why any of the readpage() methods need the filp =
information.
> A quick scan shows that  zisofs_readpage() deferences filp.
> zisofs_readpage() uses the filp to get to the inode, which it can =
always
> get through  page->mapping->host

Hm, so that is something that could be patched.

> >  - the error paths, for example, for "error_unlock", #77, leaving
> >    the page in the LRU cache [is this ok? will somebody else
> >    use it or will it drop automatically?]
>=20
> page_cache_release() takes care of that. So this should be ok.

Ok.

I went on an digged in some more similar code, like =
swapfile.c:sys_swapon(),
where it calls read_cache_page(). I realized I could accomplish the same =

[almost] with the following:

01 struct page * page_cache_readpage (struct inode *inode, unsigned long =
pgoff)
02 {
03         struct page *page;
04         struct address_space *mapping =3D inode->i_mapping;
05        =20
06         page =3D read_cache_page (mapping, pgoff,=20
07                                 (filler_t *) =
mapping->a_ops->readpage,
08                                 NULL);
09         if (IS_ERR (page))
10                 goto out;
11         wait_on_page_locked (page);
12         if (!PageUptodate (page)) {
13                 page_cache_release (page);
14                 page =3D ERR_PTR (-EIO);
15         }
16 out:
17         return page;
18 }

For the time being I should add some BUG_ON()s on inode->i_mapping
being NULL, but this should do better than the monster I coded.

THanks!

I=F1aky P=E9rez-Gonz=E1lez -- Not speaking for Intel -- all opinions are =
my own (and my fault)


------_=_NextPart_001_01C4654E.954BEF84
Content-Type: text/plain;
	name="t.txt"
Content-Transfer-Encoding: base64
Content-Description: t.txt
Content-Disposition: attachment;
	filename="t.txt"

MDEgc3RydWN0IHBhZ2UgKiBwYWdlX2NhY2hlX3JlYWRwYWdlIChzdHJ1Y3QgaW5vZGUgKmlub2Rl
LCB1bnNpZ25lZCBsb25nIHBnb2ZmKQowMiB7CjAzICAgICAgICAgc3RydWN0IHBhZ2UgKnBhZ2U7
CjA0ICAgICAgICAgc3RydWN0IGFkZHJlc3Nfc3BhY2UgKm1hcHBpbmcgPSBpbm9kZS0+aV9tYXBw
aW5nOwowNSAgICAgICAgIAowNiAgICAgICAgIHBhZ2UgPSByZWFkX2NhY2hlX3BhZ2UgKG1hcHBp
bmcsIHBnb2ZmLCAKMDcgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAoZmlsbGVyX3Qg
KikgbWFwcGluZy0+YV9vcHMtPnJlYWRwYWdlLAowOCAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIE5VTEwpOwowOSAgICAgICAgIGlmIChJU19FUlIgKHBhZ2UpKQoxMCAgICAgICAgICAg
ICAgICAgZ290byBvdXQ7CjExICAgICAgICAgd2FpdF9vbl9wYWdlX2xvY2tlZCAocGFnZSk7CjEy
ICAgICAgICAgaWYgKCFQYWdlVXB0b2RhdGUgKHBhZ2UpKSB7CjEzICAgICAgICAgICAgICAgICBw
YWdlX2NhY2hlX3JlbGVhc2UgKHBhZ2UpOwoxNCAgICAgICAgICAgICAgICAgcGFnZSA9IEVSUl9Q
VFIgKC1FSU8pOwoxNSAgICAgICAgIH0KMTYgb3V0OgoxNyAgICAgICAgIHJldHVybiBwYWdlOwox
OCB9Cg==

------_=_NextPart_001_01C4654E.954BEF84--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
