Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1156F6B0095
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 18:02:39 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oB3N2ZPv025019
	for <linux-mm@kvack.org>; Fri, 3 Dec 2010 15:02:36 -0800
Received: from qyk34 (qyk34.prod.google.com [10.241.83.162])
	by kpbe20.cbf.corp.google.com with ESMTP id oB3N28iN013369
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 3 Dec 2010 15:02:33 -0800
Received: by qyk34 with SMTP id 34so1394028qyk.3
        for <linux-mm@kvack.org>; Fri, 03 Dec 2010 15:02:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291335412-16231-1-git-send-email-walken@google.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
Date: Fri, 3 Dec 2010 15:02:33 -0800
Message-ID: <AANLkTi=3VJRa4g4UcDM+Z_vYHAuCwwHM=DyOOPD41MPe@mail.gmail.com>
Subject: Re: [PATCH 0/6] mlock: do not hold mmap_sem for extended periods of time
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi David,

I forgot to add you on the original submission, but I think you'd be
best qualified to look at the two patches implementing
rwsem_is_contended()...

On Thu, Dec 2, 2010 at 4:16 PM, Michel Lespinasse <walken@google.com> wrote=
:
> Currently mlock() holds mmap_sem in exclusive mode while the pages get
> faulted in. In the case of a large mlock, this can potentially take a
> very long time, during which various commands such as 'ps auxw' will
> block. This makes sysadmins unhappy:
>
> real =A0 =A014m36.232s
> user =A0 =A00m0.003s
> sys =A0 =A0 0m0.015s
> (output from 'time ps auxw' while a 20GB file was being mlocked without
> being previously preloaded into page cache)
>
> I propose that mlock() could release mmap_sem after the VM_LOCKED bits
> have been set in all appropriate VMAs. Then a second pass could be done
> to actually mlock the pages, in small batches, releasing mmap_sem when
> we block on disk access or when we detect some contention.
>
> Patches are against v2.6.37-rc4 plus my patches to avoid mlock dirtying
> (presently queued in -mm).
>
> Michel Lespinasse (6):
> =A0mlock: only hold mmap_sem in shared mode when faulting in pages
> =A0mm: add FOLL_MLOCK follow_page flag.
> =A0mm: move VM_LOCKED check to __mlock_vma_pages_range()
> =A0rwsem: implement rwsem_is_contended()
> =A0mlock: do not hold mmap_sem for extended periods of time
> =A0x86 rwsem: more precise rwsem_is_contended() implementation

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
