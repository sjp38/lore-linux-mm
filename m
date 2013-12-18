Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1826B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:51:44 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id lj1so117733pab.15
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:51:44 -0800 (PST)
Received: from fujitsu25.fnanic.fujitsu.com (fujitsu25.fnanic.fujitsu.com. [192.240.6.15])
        by mx.google.com with ESMTPS id tt8si764446pbc.318.2013.12.18.11.51.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:51:42 -0800 (PST)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Wed, 18 Dec 2013 11:27:17 -0800
Subject: RE: mm: kernel BUG at mm/mlock.c:82!
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E2AFAD01371@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <52AFA331.9070108@oracle.com> <52AFE38D.2030008@oracle.com>
 <52AFF35E.7000908@oracle.com>
 <52b00ae4.a377b60a.1c68.ffffe284SMTPIN_ADDED_BROKEN@mx.google.com>
 <6B2BA408B38BA1478B473C31C3D2074E2AFAC0ADF6@SV-EXCHANGE1.Corp.FC.LOCAL>
 <20131218020239.GA16603@hacker.(null)>
In-Reply-To: <20131218020239.GA16603@hacker.(null)>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Bob Liu <bob.liu@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, "npiggin@suse.de" <npiggin@suse.de>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>



> -----Original Message-----
> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
> Sent: Tuesday, December 17, 2013 9:03 PM
> To: Motohiro Kosaki
> Cc: Bob Liu; Andrew Morton; linux-mm@kvack.org; Michel Lespinasse;
> npiggin@suse.de; Motohiro Kosaki JP; riel@redhat.com; Sasha Levin
> Subject: Re: mm: kernel BUG at mm/mlock.c:82!
>=20
> Hi Motohiro,
> On Tue, Dec 17, 2013 at 08:32:49AM -0800, Motohiro Kosaki wrote:
> >
> >
> >> -----Original Message-----
> >> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org]
> On
> >> Behalf Of Wanpeng Li
> >> Sent: Tuesday, December 17, 2013 3:27 AM
> >> To: Sasha Levin
> >> Cc: Bob Liu; Andrew Morton; linux-mm@kvack.org; Michel Lespinasse;
> >> npiggin@suse.de; Motohiro Kosaki JP; riel@redhat.com
> >> Subject: Re: mm: kernel BUG at mm/mlock.c:82!
> >>
> >> Hi Sasha,
> >> On Tue, Dec 17, 2013 at 01:46:54AM -0500, Sasha Levin wrote:
> >> >On 12/17/2013 12:39 AM, Bob Liu wrote:
> >> >>cc'd more people.
> >> >>
> >> >>On 12/17/2013 09:04 AM, Sasha Levin wrote:
> >> >>>Hi all,
> >> >>>
> >> >>>While fuzzing with trinity inside a KVM tools guest running latest
> >> >>>-next kernel, I've stumbled on the following spew.
> >> >>>
> >> >>>Codewise, it's pretty straightforward. In try_to_unmap_cluster():
> >> >>>
> >> >>>                 page =3D vm_normal_page(vma, address, *pte);
> >> >>>                 BUG_ON(!page || PageAnon(page));
> >> >>>
> >> >>>                 if (locked_vma) {
> >> >>>                         mlock_vma_page(page);   /* no-op if alread=
y
> >> >>>mlocked */
> >> >>>                         if (page =3D=3D check_page)
> >> >>>                                 ret =3D SWAP_MLOCK;
> >> >>>                         continue;       /* don't unmap */
> >> >>>                 }
> >> >>>
> >> >>>And the BUG triggers once we see that 'page' isn't locked.
> >> >>>
> >> >>
> >> >>Yes, I didn't see any place locked the corresponding page in
> >> >>try_to_unmap_cluster().
> >> >>
> >> >>I'm afraid adding lock_page() over there may cause potential deadloc=
k.
> >> >>How about just remove the BUG_ON() in mlock_vma_page()?
> >> >
> >> >Welp, it's been there for 5 years now - there should be a good
> >> >reason to
> >> justify removing it.
> >> >
> >>
> >> Page should be locked before invoke try_to_unmap(), this check can't
> >> be removed since this bug is just triggered by confirm !check page
> >> hold page lock in virtual scan during nolinear VMAs pages aging.
> >> Avoid to confirm !check page hold page lock is acceptable.
> >
> >That's a try_to_unmap()'s assumption and it already have
> BUG_ON(!PageLocked(page)).
> >We can remove wrong BUG_ON from mlock_vma_page() simply.
> Mlock_vma_page() doesn't depend on page-locked.
> >
>=20
> There is a race between mlock_vma_page() and munlock_vma_page(). Both
> of them should hold page lock and have a BUG_ON assumption.

Please explain which race you are worried.  The main race of mlock and munl=
ock are closed by PG_mlocked, not PG_locked.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
