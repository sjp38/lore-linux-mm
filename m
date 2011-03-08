Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DF4888D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 08:52:03 -0500 (EST)
Received: by vws13 with SMTP id 13so6364585vws.14
        for <linux-mm@kvack.org>; Tue, 08 Mar 2011 05:52:01 -0800 (PST)
Date: Tue, 8 Mar 2011 08:51:57 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH] hugetlb: /proc/meminfo shows data for all sizes of
 hugepages
Message-ID: <20110308135157.GA4403@mgebm.net>
References: <1299503155-6210-1-git-send-email-pholasek@redhat.com>
 <1299527214.8493.13263.camel@nimitz>
 <20110307145149.97e6676e.akpm@linux-foundation.org>
 <20110307231448.GA2946@spritzera.linux.bs1.fc.nec.co.jp>
 <20110307152516.fee931bb.akpm@linux-foundation.org>
 <4D761138.4030705@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Content-Disposition: inline
In-Reply-To: <4D761138.4030705@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, anton@redhat.com, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 08 Mar 2011, Petr Holasek wrote:

> On 03/08/2011 12:25 AM, Andrew Morton wrote:
> >On Tue, 8 Mar 2011 08:14:49 +0900
> >Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>  wrote:
> >
> >>On Mon, Mar 07, 2011 at 02:51:49PM -0800, Andrew Morton wrote:
> >>>On Mon, 07 Mar 2011 11:46:54 -0800
> >>>Dave Hansen<dave@linux.vnet.ibm.com>  wrote:
> >>>
> >>>>On Mon, 2011-03-07 at 14:05 +0100, Petr Holasek wrote:
> >>>>>+       for_each_hstate(h)
> >>>>>+               seq_printf(m,
> >>>>>+                               "HugePages_Total:   %5lu\n"
> >>>>>+                               "HugePages_Free:    %5lu\n"
> >>>>>+                               "HugePages_Rsvd:    %5lu\n"
> >>>>>+                               "HugePages_Surp:    %5lu\n"
> >>>>>+                               "Hugepagesize:   %8lu kB\n",
> >>>>>+                               h->nr_huge_pages,
> >>>>>+                               h->free_huge_pages,
> >>>>>+                               h->resv_huge_pages,
> >>>>>+                               h->surplus_huge_pages,
> >>>>>+                               1UL<<  (huge_page_order(h) + PAGE_SH=
IFT - 10));
> >>>>>  }
> >>>>
> >>>>It sounds like now we'll get a meminfo that looks like:
> >>>>
> >>>>...
> >>>>AnonHugePages:    491520 kB
> >>>>HugePages_Total:       5
> >>>>HugePages_Free:        2
> >>>>HugePages_Rsvd:        3
> >>>>HugePages_Surp:        1
> >>>>Hugepagesize:       2048 kB
> >>>>HugePages_Total:       2
> >>>>HugePages_Free:        1
> >>>>HugePages_Rsvd:        1
> >>>>HugePages_Surp:        1
> >>>>Hugepagesize:    1048576 kB
> >>>>DirectMap4k:       12160 kB
> >>>>DirectMap2M:     2082816 kB
> >>>>DirectMap1G:     2097152 kB
> >>>>
> >>>>At best, that's a bit confusing.  There aren't any other entries in
> >>>>meminfo that occur more than once.  Plus, this information is availab=
le
> >>>>in the sysfs interface.  Why isn't that sufficient?
> >>>>
> >>>>Could we do something where we keep the default hpage_size looking li=
ke
> >>>>it does now, but append the size explicitly for the new entries?
> >>>>
> >>>>HugePages_Total(1G):       2
> >>>>HugePages_Free(1G):        1
> >>>>HugePages_Rsvd(1G):        1
> >>>>HugePages_Surp(1G):        1
> >>>>
> >>>
> >>>Let's not change the existing interface, please.
> >>>
> >>>Adding new fields: OK.
> >>>Changing the way in whcih existing fields are calculated: OKish.
> >>>Renaming existing fields: not OK.
> >>
> >>How about lining up multiple values in each field like this?
> >>
> >>   HugePages_Total:       5 2
> >>   HugePages_Free:        2 1
> >>   HugePages_Rsvd:        3 1
> >>   HugePages_Surp:        1 1
> >>   Hugepagesize:       2048 1048576 kB
> >>   ...
> >>
> >>This doesn't change the field names and the impact for user space
> >>is still small?
> >
> >It might break some existing parsers, dunno.
> >
> >It was a mistake to assume that all hugepages will have the same size
> >for all time, and we just have to live with that mistake.
> >
> >I'd suggest that we leave meminfo alone, just ensuring that its output
> >makes some sense.  Instead create a new interface which presents all
> >the required info in a sensible fashion and migrate usersapce reporting
> >tools over to that interface.  Just let the meminfo field die a slow
> >death.
>=20
> The main idea behind this patch is to unify hugetlb interfaces in
> /proc/meminfo
> and sysfs. When somebody wants to find out all important
> informations about hugepage
> pools (as hugeadm from libhugetlbfs does), he has to determine
> default hugepage size
> from /proc/meminfo and then go into
> /sys/kernel/mm/hugepages/hugepages-<size>kB/
> for informations about next nodes.
>=20
> I agree with idea of throwing away of meminfo hugepage fields in the futu=
re,
> but before doing this, sysfs part of interface should indicate
> default hugepage
> size. And meminfo could possibly show data for all hugepage sizes on
> system. So when
> these parts will be independent, it is no problem to let meminfo
> fields die.

I think the two best options here are:

1. Use hugeadm (packaged with libhugetlbfs) to indicate the kernel default =
huge
page size to any userspace tool that needs to know.

2. Add an marker for the kernel default huge page size in sysfs.

I don't have a strong opinion about which is "right".

>=20
> >
> >It's tempting to remove the meminfo hugepage fields altogether - most
> >parsers _should_ be able to cope with a CONFIG_HUGETLB=3Dn kernel.  But
> >that's breakage as well - some applications may be using meminfo to
> >detect whether the kernel supports huge pages!
>=20

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNdjR9AAoJEH65iIruGRnNSCwH/1to/Bq+fl2aTKOunpfsEpZP
zhW2VOaTaNgBZaUuvr2sJFzpseQeNVtVi6v/NhPzmALoucL0AD9uvGKuY6Lo9+zy
5YWpkaq6Y4D1FeL3eNvqUZZ7fuD+Bg+9BEn1F76wpo110oLvESCMrPdibDkhSPAs
kMOX8/kh+D+K++Zo3/KvIwnSHVlGgiK3owmiDubFB+DQEElXVjLhEw51tlf5O7Om
F2/52hpDs0v6JxW3t6ie+8nhztQaGghjUULurht7a5TL78VfvKkL4ANNqkcWga8u
ChMIthYIRzmx6JNCUv+dGFcgJ3zKPtv/0yNCAq8TdOKBq4noulK4nczSWn5HIQw=
=A76V
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
