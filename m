Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 82E226B00AA
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 15:16:38 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oB1KG9UU023912
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 12:16:09 -0800
Received: by iwn41 with SMTP id 41so388505iwn.14
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 12:16:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1330724443.975931291231775834.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References: <919384632.877731291171499343.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <1330724443.975931291231775834.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 12:15:48 -0800
Message-ID: <AANLkTi=tfDQhcNwhDeLz9jM5QHjDR_8WL+v6AWU3SJpZ@mail.gmail.com>
Subject: Re: oom is broken in mmotm 2010-11-09-15-31 tree?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 1, 2010 at 11:29 AM, CAI Qian <caiqian@redhat.com> wrote:
>>
>> Hi, just a head-up. When testing oom for this tree, my workstation is
>> immediately having no response to ssh, Desktop actions and so on apart
>> from ping. I am trying to bisect but looks like git public server is
>> having problem.
>
> This turned out that it was introduced by,
>
> =A0d065bd810b6deb67d4897a14bfe21f8eb526ba99
> =A0mm: retry page fault when blocking on disk transfer
>
> It was reproduced by:
> 1) ssh to the test box.
> 2) try to trigger oom a few times using a malloc program there.

Interesting. That commit is not supposed to make any semantic
difference at all. And even if we do end up in the retry path, the
arch/x86/mm/fault.c code is very explicitly designed so that it
retries only _once_.

Michel, any ideas? I could see problems with the mmap_sem if
VM_FAULT_OOM is set at the same time as VM_FAULT_RETRY, but I can't
see how that could ever happen.

Anybody?

CAI, can you get any output from sysrq-W when this happens?

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
