Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 293576B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 06:48:33 -0500 (EST)
Received: by ewy19 with SMTP id 19so2140214ewy.4
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 03:48:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1257151763-11507-1-git-send-email-jirislaby@gmail.com>
References: <4AEE5EA2.6010905@kernel.org>
	 <1257151763-11507-1-git-send-email-jirislaby@gmail.com>
Date: Mon, 2 Nov 2009 19:48:30 +0800
Message-ID: <a8e1da0911020348m177420d2gd1aa25bdf8d53b03@mail.gmail.com>
Subject: Re: [PATCH 1/1] MM: slqb, fix per_cpu access
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 2, 2009 at 4:49 PM, Jiri Slaby <jirislaby@gmail.com> wrote:
> We cannot use the same local variable name as the declared per_cpu
> variable since commit "percpu: remove per_cpu__ prefix."
>
> Otherwise we would see crashes like:
> general protection fault: 0000 [#1] SMP
> last sysfs file:
> CPU 1
> Modules linked in:
> Pid: 1, comm: swapper Tainted: G =C2=A0 =C2=A0 =C2=A0 =C2=A0W =C2=A02.6.3=
2-rc5-mm1_64 #860
> RIP: 0010:[<ffffffff8142ff94>] =C2=A0[<ffffffff8142ff94>] start_cpu_timer=
+0x2b/0x87
> ...
>
> Use slqb_ prefix for the global variable so that we don't collide
> even with the rest of the kernel (s390 and alpha need this).
>
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Nick Piggin <npiggin@suse.de>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Christoph Lameter <cl@linux-foundation.org>

Tested-by: Dave Young <hidave.darkstar@gmail.com>

> ---
> =C2=A0mm/slqb.c | =C2=A0 10 ++++++----
> =C2=A01 files changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/mm/slqb.c b/mm/slqb.c
> index e745d9a..e4bb53f 100644
> --- a/mm/slqb.c
> +++ b/mm/slqb.c
> @@ -2766,11 +2766,12 @@ out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0schedule_delayed_work(work, round_jiffies_rela=
tive(3*HZ));
> =C2=A0}
>
> -static DEFINE_PER_CPU(struct delayed_work, cache_trim_work);
> +static DEFINE_PER_CPU(struct delayed_work, slqb_cache_trim_work);
>
> =C2=A0static void __cpuinit start_cpu_timer(int cpu)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 struct delayed_work *cache_trim_work =3D &per_cpu(=
cache_trim_work, cpu);
> + =C2=A0 =C2=A0 =C2=A0 struct delayed_work *cache_trim_work =3D &per_cpu(=
slqb_cache_trim_work,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 cpu);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * When this gets called from do_initcalls via=
 cpucache_init(),
> @@ -3136,8 +3137,9 @@ static int __cpuinit slab_cpuup_callback(struct not=
ifier_block *nfb,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case CPU_DOWN_PREPARE:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case CPU_DOWN_PREPARE_FROZEN:
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cancel_rearming_delaye=
d_work(&per_cpu(cache_trim_work, cpu));
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 per_cpu(cache_trim_wor=
k, cpu).work.func =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cancel_rearming_delaye=
d_work(&per_cpu(slqb_cache_trim_work,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cpu));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 per_cpu(slqb_cache_tri=
m_work, cpu).work.func =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case CPU_UP_CANCELED:
> --
> 1.6.4.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>



--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
