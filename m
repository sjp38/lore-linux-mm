Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F359C8D0039
	for <linux-mm@kvack.org>; Sun, 30 Jan 2011 05:26:34 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p0UAQUct031372
	for <linux-mm@kvack.org>; Sun, 30 Jan 2011 02:26:33 -0800
Received: from qyk33 (qyk33.prod.google.com [10.241.83.161])
	by hpaq14.eem.corp.google.com with ESMTP id p0UAQSi5012142
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 30 Jan 2011 02:26:29 -0800
Received: by qyk33 with SMTP id 33so4757466qyk.2
        for <linux-mm@kvack.org>; Sun, 30 Jan 2011 02:26:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1296371720-4176-1-git-send-email-tm@tao.ma>
References: <1296371720-4176-1-git-send-email-tm@tao.ma>
Date: Sun, 30 Jan 2011 02:26:27 -0800
Message-ID: <AANLkTik1dt1Q9TA+JmdvkuOqmt5LB2iZ1X2B5GbBFx1+@mail.gmail.com>
Subject: Re: [PATCH] mlock: revert the optimization for dirtying pages and
 triggering writeback.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tao Ma <tm@tao.ma>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jan 29, 2011 at 11:15 PM, Tao Ma <tm@tao.ma> wrote:
> =A0 =A0 =A0 =A0buf =3D mmap(NULL, file_len, PROT_WRITE, MAP_SHARED, fd, 0=
);
> =A0 =A0 =A0 =A0if (buf =3D=3D MAP_FAILED) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("mmap");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (mlock(buf, file_len) < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("mlock");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}

Thanks Tao for tracing this to an individual change. I can reproduce
this on my system. The issue is that the file is mapped without the
PROT_READ permission, so mlock can't fault in the pages. Up to 2.6.37
this worked because mlock was using a write.

The test case does show there was a behavior change; however it's not
clear to me that the tested behavior is valid.

I can see two possible resolutions:

1- do nothing, if we can agree that the test case is invalid

2- restore the previous behavior for writable, non-readable, shared
mappings while preserving the optimization for read/write shared
mappings. The test would then look like:
        if ((vma->vm_flags & VM_WRITE) && (vma->vm_flags & (VM_READ |
VM_SHARED)) !=3D VM_SHARED)
                gup_flags |=3D FOLL_WRITE;

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
