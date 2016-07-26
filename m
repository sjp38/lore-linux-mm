Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E10F56B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 16:13:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p64so31136272pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 13:13:25 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id d8si2188652paw.5.2016.07.26.13.13.24
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 13:13:24 -0700 (PDT)
From: "Roberts, William C" <william.c.roberts@intel.com>
Subject: RE: [PATCH] [RFC] Introduce mmap randomization
Date: Tue, 26 Jul 2016 20:13:23 +0000
Message-ID: <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "nnk@google.com" <nnk@google.com>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>

<snip>

RESEND fixing mm-list email....

> > -----Original Message-----
> > From: Jason Cooper [mailto:jason@lakedaemon.net]
> > Sent: Tuesday, July 26, 2016 1:03 PM
> > To: Roberts, William C <william.c.roberts@intel.com>
> > Cc: linux-mm@vger.kernel.org; linux-kernel@vger.kernel.org; kernel-
> > hardening@lists.openwall.com; akpm@linux-foundation.org;
> > keescook@chromium.org; gregkh@linuxfoundation.org; nnk@google.com;
> > jeffv@google.com; salyzyn@android.com; dcashman@android.com
> > Subject: Re: [PATCH] [RFC] Introduce mmap randomization
> >
> > Hi William!
> >
> > On Tue, Jul 26, 2016 at 11:22:26AM -0700, william.c.roberts@intel.com w=
rote:
> > > From: William Roberts <william.c.roberts@intel.com>
> > >
> > > This patch introduces the ability randomize mmap locations where the
> > > address is not requested, for instance when ld is allocating pages
> > > for shared libraries. It chooses to randomize based on the current
> > > personality for ASLR.
> >
> > Now I see how you found the randomize_range() fix. :-P
> >
> > > Currently, allocations are done sequentially within unmapped address
> > > space gaps. This may happen top down or bottom up depending on scheme=
.
> > >
> > > For instance these mmap calls produce contiguous mappings:
> > > int size =3D getpagesize();
> > > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D
> > 0x40026000
> > > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D
> > 0x40027000
> > >
> > > Note no gap between.
> > >
> > > After patches:
> > > int size =3D getpagesize();
> > > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D
> > 0x400b4000
> > > mmap(NULL, size, flags, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =3D
> > 0x40055000
> > >
> > > Note gap between.
> > >
> > > Using the test program mentioned here, that allocates fixed sized
> > > blocks till exhaustion:
> > > https://www.linux-mips.org/archives/linux-mips/2011-05/msg00252.html
> > > , no difference was noticed in the number of allocations. Most
> > > varied from run to run, but were always within a few allocations of
> > > one another between patched and un-patched runs.
> >
> > Did you test this with different allocation sizes?
>=20
> No I didn't it. I wasn't sure the best way to test this, any ideas?
>=20
> >
> > > Performance Measurements:
> > > Using strace with -T option and filtering for mmap on the program ls
> > > shows a slowdown of approximate 3.7%
> >
> > I think it would be helpful to show the effect on the resulting object =
code.
>=20
> Do you mean the maps of the process? I have some captures for whoopsie on=
 my
> Ubuntu system I can share.
>=20
> One thing I didn't make clear in my commit message is why this is good. R=
ight
> now, if you know An address within in a process, you know all offsets don=
e with
> mmap(). For instance, an offset To libX can yield libY by adding/subtract=
ing an
> offset. This is meant to make rops a bit harder, or In general any mappin=
g offset
> mmore difficult to find/guess.
>=20
> >
> > > Signed-off-by: William Roberts <william.c.roberts@intel.com>
> > > ---
> > >  mm/mmap.c | 24 ++++++++++++++++++++++++
> > >  1 file changed, 24 insertions(+)
> > >
> > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > index de2c176..7891272 100644
> > > --- a/mm/mmap.c
> > > +++ b/mm/mmap.c
> > > @@ -43,6 +43,7 @@
> > >  #include <linux/userfaultfd_k.h>
> > >  #include <linux/moduleparam.h>
> > >  #include <linux/pkeys.h>
> > > +#include <linux/random.h>
> > >
> > >  #include <asm/uaccess.h>
> > >  #include <asm/cacheflush.h>
> > > @@ -1582,6 +1583,24 @@ unacct_error:
> > >  	return error;
> > >  }
> > >
> > > +/*
> > > + * Generate a random address within a range. This differs from
> > > +randomize_addr() by randomizing
> > > + * on len sized chunks. This helps prevent fragmentation of the
> > > +virtual
> > memory map.
> > > + */
> > > +static unsigned long randomize_mmap(unsigned long start, unsigned
> > > +long end, unsigned long len) {
> > > +	unsigned long slots;
> > > +
> > > +	if ((current->personality & ADDR_NO_RANDOMIZE) ||
> > !randomize_va_space)
> > > +		return 0;
> >
> > Couldn't we avoid checking this every time?  Say, by assigning a
> > function pointer during init?
>=20
> Yeah that could be done. I just copied the way others checked elsewhere i=
n the
> kernel :-P
>=20
> >
> > > +
> > > +	slots =3D (end - start)/len;
> > > +	if (!slots)
> > > +		return 0;
> > > +
> > > +	return PAGE_ALIGN(start + ((get_random_long() % slots) * len)); }
> > > +
> >
> > Personally, I'd prefer this function noop out based on a configuration =
option.
>=20
> Me too.
>=20
> >
> > >  unsigned long unmapped_area(struct vm_unmapped_area_info *info)  {
> > >  	/*
> > > @@ -1676,6 +1695,8 @@ found:
> > >  	if (gap_start < info->low_limit)
> > >  		gap_start =3D info->low_limit;
> > >
> > > +	gap_start =3D randomize_mmap(gap_start, gap_end, length) ? :
> > > +gap_start;
> > > +
> > >  	/* Adjust gap address to the desired alignment */
> > >  	gap_start +=3D (info->align_offset - gap_start) & info->align_mask;
> > >
> > > @@ -1775,6 +1796,9 @@ found:
> > >  found_highest:
> > >  	/* Compute highest gap address at the desired alignment */
> > >  	gap_end -=3D info->length;
> > > +
> > > +	gap_end =3D randomize_mmap(gap_start, gap_end, length) ? : gap_end;
> > > +
> > >  	gap_end -=3D (gap_end - info->align_offset) & info->align_mask;
> > >
> > >  	VM_BUG_ON(gap_end < info->low_limit);
> >
> > I'll have to dig into the mm code more before I can comment intelligent=
ly on
> this.
> >
> > thx,
> >
> > Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
