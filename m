Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id EB4656B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 02:13:24 -0400 (EDT)
Received: by dadv6 with SMTP id v6so462630dad.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 23:13:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1331617001-20906-5-git-send-email-apenwarr@gmail.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
	<1331617001-20906-5-git-send-email-apenwarr@gmail.com>
Date: Mon, 12 Mar 2012 23:13:24 -0700
Message-ID: <CAE9FiQUakjaxE3fTm1w3SuuE-cAXAg2fePmEdwmjomAgp88Psg@mail.gmail.com>
Subject: Re: [PATCH 4/5] printk: use alloc_bootmem() instead of memblock_alloc().
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avery Pennarun <apenwarr@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 12, 2012 at 10:36 PM, Avery Pennarun <apenwarr@gmail.com> wrote=
:
> The code in setup_log_buf() had two memory allocation branches, depending
> on the value of 'early'. =A0If early=3D=3D1, it would use memblock_alloc(=
); if
> early=3D=3D0, it would use alloc_bootmem_nopanic().
>
> bootmem should already configured by the time setup_log_buf(early=3D1) is
> called, so there's no reason to have the separation. =A0Furthermore, on
> arches with nobootmem, memblock_alloc is essentially the same as
> alloc_bootmem anyway. =A0x86 is one such arch, and also the only one
> that uses early=3D1.
>
> Signed-off-by: Avery Pennarun <apenwarr@gmail.com>
> ---
> =A0kernel/printk.c | =A0 13 +------------
> =A01 files changed, 1 insertions(+), 12 deletions(-)
>
> diff --git a/kernel/printk.c b/kernel/printk.c
> index 32690a0..bf96a7d 100644
> --- a/kernel/printk.c
> +++ b/kernel/printk.c
> @@ -31,7 +31,6 @@
> =A0#include <linux/smp.h>
> =A0#include <linux/security.h>
> =A0#include <linux/bootmem.h>
> -#include <linux/memblock.h>
> =A0#include <linux/syscalls.h>
> =A0#include <linux/kexec.h>
> =A0#include <linux/kdb.h>
> @@ -195,17 +194,7 @@ void __init setup_log_buf(int early)
> =A0 =A0 =A0 =A0if (!new_log_buf_len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> - =A0 =A0 =A0 if (early) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long mem;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D memblock_alloc(new_log_buf_len, PAG=
E_SIZE);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_log_buf =3D __va(mem);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_log_buf =3D alloc_bootmem_nopanic(new_l=
og_buf_len);
> - =A0 =A0 =A0 }
> -
> + =A0 =A0 =A0 new_log_buf =3D alloc_bootmem_nopanic(new_log_buf_len);
> =A0 =A0 =A0 =A0if (unlikely(!new_log_buf)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_err("log_buf_len: %ld bytes not availab=
le\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new_log_buf_len);
> --

that seems not right.

for x86, setup_log_buf(1) is quite early called in setup_arch() before
bootmem is there.

bootmem should be killed after memblock is supported for arch that
current support bootmem.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
