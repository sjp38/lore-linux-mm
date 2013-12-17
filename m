Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB326B003A
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:41:39 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so6938234pdj.26
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:41:38 -0800 (PST)
Received: from fujitsu24.fnanic.fujitsu.com (fujitsu24.fnanic.fujitsu.com. [192.240.6.14])
        by mx.google.com with ESMTPS id vv1si12102147pbb.269.2013.12.17.08.41.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 08:41:37 -0800 (PST)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Tue, 17 Dec 2013 08:32:49 -0800
Subject: RE: mm: kernel BUG at mm/mlock.c:82!
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E2AFAC0ADF6@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <52AFA331.9070108@oracle.com> <52AFE38D.2030008@oracle.com>
 <52AFF35E.7000908@oracle.com>
 <52b00ae4.a377b60a.1c68.ffffe284SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <52b00ae4.a377b60a.1c68.ffffe284SMTPIN_ADDED_BROKEN@mx.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Bob Liu <bob.liu@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, "npiggin@suse.de" <npiggin@suse.de>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>



> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Wanpeng Li
> Sent: Tuesday, December 17, 2013 3:27 AM
> To: Sasha Levin
> Cc: Bob Liu; Andrew Morton; linux-mm@kvack.org; Michel Lespinasse;
> npiggin@suse.de; Motohiro Kosaki JP; riel@redhat.com
> Subject: Re: mm: kernel BUG at mm/mlock.c:82!
>=20
> Hi Sasha,
> On Tue, Dec 17, 2013 at 01:46:54AM -0500, Sasha Levin wrote:
> >On 12/17/2013 12:39 AM, Bob Liu wrote:
> >>cc'd more people.
> >>
> >>On 12/17/2013 09:04 AM, Sasha Levin wrote:
> >>>Hi all,
> >>>
> >>>While fuzzing with trinity inside a KVM tools guest running latest
> >>>-next kernel, I've stumbled on the following spew.
> >>>
> >>>Codewise, it's pretty straightforward. In try_to_unmap_cluster():
> >>>
> >>>                 page =3D vm_normal_page(vma, address, *pte);
> >>>                 BUG_ON(!page || PageAnon(page));
> >>>
> >>>                 if (locked_vma) {
> >>>                         mlock_vma_page(page);   /* no-op if already
> >>>mlocked */
> >>>                         if (page =3D=3D check_page)
> >>>                                 ret =3D SWAP_MLOCK;
> >>>                         continue;       /* don't unmap */
> >>>                 }
> >>>
> >>>And the BUG triggers once we see that 'page' isn't locked.
> >>>
> >>
> >>Yes, I didn't see any place locked the corresponding page in
> >>try_to_unmap_cluster().
> >>
> >>I'm afraid adding lock_page() over there may cause potential deadlock.
> >>How about just remove the BUG_ON() in mlock_vma_page()?
> >
> >Welp, it's been there for 5 years now - there should be a good reason to
> justify removing it.
> >
>=20
> Page should be locked before invoke try_to_unmap(), this check can't be
> removed since this bug is just triggered by confirm !check page hold page
> lock in virtual scan during nolinear VMAs pages aging. Avoid to confirm !=
check
> page hold page lock is acceptable.

That's a try_to_unmap()'s assumption and it already have  BUG_ON(!PageLocke=
d(page)).
We can remove wrong BUG_ON from mlock_vma_page() simply. Mlock_vma_page() d=
oesn't depend on page-locked.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
