Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 2E3426B00F8
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:50:34 -0500 (EST)
Received: by qauh8 with SMTP id h8so8792026qau.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 15:50:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329824079-14449-4-git-send-email-glommer@parallels.com>
References: <1329824079-14449-1-git-send-email-glommer@parallels.com>
	<1329824079-14449-4-git-send-email-glommer@parallels.com>
Date: Tue, 21 Feb 2012 15:50:32 -0800
Message-ID: <CABCjUKAmjGS1j6kNgj8it_QZSPKJiCmgpme6BTxAGkoJ=DSR7w@mail.gmail.com>
Subject: Re: [PATCH 3/7] per-cgroup slab caches
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, Paul Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Tue, Feb 21, 2012 at 3:34 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 26fda11..2aa35b0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> +struct kmem_cache *
> +kmem_cache_dup(struct mem_cgroup *memcg, struct kmem_cache *base)
> +{
> + =A0 =A0 =A0 struct kmem_cache *s;
> + =A0 =A0 =A0 unsigned long pages;
> + =A0 =A0 =A0 struct res_counter *fail;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* TODO: We should use an ida-like index here, instead
> + =A0 =A0 =A0 =A0* of the kernel address
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 char *kname =3D kasprintf(GFP_KERNEL, "%s-%p", base->name, =
memcg);

Would it make more sense to use the memcg name instead of the pointer?

> +
> + =A0 =A0 =A0 WARN_ON(mem_cgroup_is_root(memcg));
> +
> + =A0 =A0 =A0 if (!kname)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 s =3D kmem_cache_create_cg(memcg, kname, base->size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0base->al=
ign, base->flags, base->ctor);
> + =A0 =A0 =A0 if (WARN_ON(!s))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> +
> + =A0 =A0 =A0 pages =3D slab_nr_pages(s);
> +
> + =A0 =A0 =A0 if (res_counter_charge(memcg_kmem(memcg), pages << PAGE_SHI=
FT, &fail)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_destroy(s);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D NULL;
> + =A0 =A0 =A0 }

What are we charging here? Does it ever get uncharged?

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
