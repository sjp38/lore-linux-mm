Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4DAAB8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 06:43:19 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 320633EE0B6
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:43:16 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 114FC2AEA81
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:43:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C43101EF083
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:43:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4FD41DB803E
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:43:15 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FDEE1DB8038
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:43:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mlock: revert the optimization for dirtying pages and triggering writeback.
In-Reply-To: <AANLkTik1dt1Q9TA+JmdvkuOqmt5LB2iZ1X2B5GbBFx1+@mail.gmail.com>
References: <1296371720-4176-1-git-send-email-tm@tao.ma> <AANLkTik1dt1Q9TA+JmdvkuOqmt5LB2iZ1X2B5GbBFx1+@mail.gmail.com>
Message-Id: <20110131203943.4C77.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 31 Jan 2011 20:43:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Tao Ma <tm@tao.ma>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Sat, Jan 29, 2011 at 11:15 PM, Tao Ma <tm@tao.ma> wrote:
> > =A0 =A0 =A0 =A0buf =3D mmap(NULL, file_len, PROT_WRITE, MAP_SHARED, fd,=
 0);
> > =A0 =A0 =A0 =A0if (buf =3D=3D MAP_FAILED) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("mmap");
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> > =A0 =A0 =A0 =A0}
> >
> > =A0 =A0 =A0 =A0if (mlock(buf, file_len) < 0) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("mlock");
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> > =A0 =A0 =A0 =A0}
>=20
> Thanks Tao for tracing this to an individual change. I can reproduce
> this on my system. The issue is that the file is mapped without the
> PROT_READ permission, so mlock can't fault in the pages. Up to 2.6.37
> this worked because mlock was using a write.
>=20
> The test case does show there was a behavior change; however it's not
> clear to me that the tested behavior is valid.
>=20
> I can see two possible resolutions:

Please don't ignore bug port anytime.


> 1- do nothing, if we can agree that the test case is invalid
>=20
> 2- restore the previous behavior for writable, non-readable, shared
> mappings while preserving the optimization for read/write shared
> mappings. The test would then look like:
>         if ((vma->vm_flags & VM_WRITE) && (vma->vm_flags & (VM_READ |
> VM_SHARED)) !=3D VM_SHARED)
>                 gup_flags |=3D FOLL_WRITE;

Maybe two separate conditiions are cleaner more. Like this,

	/*
	 * We want to touch writable mappings with a write fault in order
	 * to break COW, except for shared mappings because these don't COW
	 * and we would not want to dirty them for nothing.
	 */
	if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) =3D=3D VM_WRITE)
 		gup_flags |=3D FOLL_WRITE;

	/*
	* We don't have writable permission. Therefore we can't use read operation
	*  even though it's faster.
	*/
	if ((vma->vm_flags & (VM_READ|VM_WRITE)) =3D=3D VM_WRITE)
 		gup_flags |=3D FOLL_WRITE;


Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
