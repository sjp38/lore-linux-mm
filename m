Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id B95F76B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 14:32:06 -0500 (EST)
Received: by iadj38 with SMTP id j38so7013348iad.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 11:32:06 -0800 (PST)
Date: Mon, 23 Jan 2012 11:31:55 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Help] : RSS/PSS showing 0 during smaps for Xorg
In-Reply-To: <1327313719.76517.YahooMailNeo@web162002.mail.bf1.yahoo.com>
Message-ID: <alpine.LSU.2.00.1201231125200.1677@eggly.anvils>
References: <1327310360.96918.YahooMailNeo@web162003.mail.bf1.yahoo.com> <1327313719.76517.YahooMailNeo@web162002.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 23 Jan 2012, PINTU KUMAR wrote:
> Dear All,
>=20
> I am facing one problem for one of my kernel module for our linux mobile =
with kernel2.6.36.
>=20
> When I do cat /proc/<Xorg pid>/smaps | grep -A 11 /dev/ump , to track inf=
ormation for my=A0ump module,
> we always get Rss/Pss as 0 kB as shown below:
> cat /proc/1731/smaps | grep -A 11 /dev/ump
> 414db000-415ff000 rw-s 00015000 00:12 6803=A0=A0=A0=A0=A0=A0 /dev/ump
> Size:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 1168 kB
> Rss:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB
> Pss:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0 kB
> track_rss_value =3D 0, iswalkcalled =3D 1, smap_pte_range_called =3D 1,=
=A0swap_pte =3D 0,=A0not_pte_present =3D 0,=A0not_normal_page =3D 1
> isspecial =3D 0, not_special =3D 1, isMixedMap =3D 0, pfnpages_null =3D 0=
, pfnoff_flag =3D 0, not_cow_mapping =3D 1,=A0normal_page_end =3D 0
> =A0
> After tracing down the problem, I found out that during "show_smaps" in f=
s/proc/task_mmu.c and during call to smaps_pte_range the vm_normal_page() i=
s always returning NULL for our /dev/ump driver.
> (smaps_pte_range() is the place where Rss/Pss information is populated)
> Thus mss->resident (Rss value) is never getting incremented.=A0=20
> =A0
> To trace the problem I added few flags during show_smaps & vm_normal_page=
() as shown above. The value of 1 indicates that the condition is executed.
> Thus "normal_page_end" indicates that the "vm_normal_page" has never ende=
d successfully and always returns from=20
> "!is_cow_mapping()".
> =A0
> So, I wanted to know the main cause for vm_normal_page() always returning=
 NULL page for our ump driver.=20
> What is that I am missing in my driver ?
> =A0
> Can anyone please let me know what could be the problem in our driver.

This not evidence of any problem in your driver.

vm_normal_page() returns NULL because the pages mapped by your driver
are not normal faultable and reclaimable pages, but an area of physical
memory mapped in by remap_pfn_range(), which sets the VM_PFNMAP flag.

The mm subsystem does not count such pages towards rss (or pss),
hence your 0s.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
