Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id F09D66B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 17:09:10 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id i1-v6so6027291pld.11
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 14:09:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r14-v6sor12280950pgn.83.2018.06.07.14.09.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 14:09:09 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 09/10] mm: Prevent madvise from changing shadow stack
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20180607143807.3611-10-yu-cheng.yu@intel.com>
Date: Thu, 7 Jun 2018 14:09:05 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <D1A84B62-E971-4ECD-A873-2072F2692382@gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
 <20180607143807.3611-10-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-arch@vger.kernel.org, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:

> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
> mm/madvise.c | 9 +++++++++
> 1 file changed, 9 insertions(+)
>=20
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 4d3c922ea1a1..2a6988badd6b 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -839,6 +839,14 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, =
size_t, len_in, int, behavior)
> 	if (vma && start > vma->vm_start)
> 		prev =3D vma;
>=20
> +	/*
> +	 * Don't do anything on shadow stack.
> +	 */
> +	if (vma->vm_flags & VM_SHSTK) {
> +		error =3D -EINVAL;
> +		goto out_no_plug;
> +	}
> +
> 	blk_start_plug(&plug);
> 	for (;;) {
> 		/* Still start < end. */

What happens if the madvise() revolves multiple VMAs, the first one is =
not
VM_SHSTK, but the another one is? Shouldn=E2=80=99t the test be done =
inside the
loop, potentially in madvise_vma() ?
