Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 23DF86B00F5
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:35:12 -0500 (EST)
Received: by qauh8 with SMTP id h8so8779235qau.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 15:35:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329824079-14449-6-git-send-email-glommer@parallels.com>
References: <1329824079-14449-1-git-send-email-glommer@parallels.com>
	<1329824079-14449-6-git-send-email-glommer@parallels.com>
Date: Tue, 21 Feb 2012 15:35:10 -0800
Message-ID: <CABCjUKCcGWsSqUnN-9g77bTLQdZ0HF3ryLz+2PyLK1VucqPjSg@mail.gmail.com>
Subject: Re: [PATCH 5/7] shrink support for memcg kmem controller
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, Paul Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Tue, Feb 21, 2012 at 3:34 AM, Glauber Costa <glommer@parallels.com> wrot=
e:

> @@ -5055,8 +5117,21 @@ int memcg_kmem_newpage(struct mem_cgroup *memcg, s=
truct page *page, unsigned lon
> =A0{
> =A0 =A0 =A0 =A0unsigned long size =3D pages << PAGE_SHIFT;
> =A0 =A0 =A0 =A0struct res_counter *fail;
> + =A0 =A0 =A0 int ret;
> + =A0 =A0 =A0 bool do_softlimit;
> +
> + =A0 =A0 =A0 ret =3D res_counter_charge(memcg_kmem(memcg), size, &fail);
> + =A0 =A0 =A0 if (unlikely(mem_cgroup_event_ratelimit(memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_TARGET_THRESH))) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_softlimit =3D mem_cgroup_event_ratelimit=
(memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_TARGET_SOFTLIMIT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_threshold(memcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(do_softlimit))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_tree(memc=
g, page);
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 return res_counter_charge(memcg_kmem(memcg), size, &fail);
> + =A0 =A0 =A0 return ret;
> =A0}

It seems like this might cause a lot of kernel memory allocations to
fail whenever we are at the limit, even if we have a lot of
reclaimable memory, when we don't have independent accounting.

Would it be better to use __mem_cgroup_try_charge() here, when we
don't have independent accounting, in order to deal with this
situation?

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
