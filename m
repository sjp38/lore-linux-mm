Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id BE4456B004D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 01:21:14 -0500 (EST)
Received: by vcge1 with SMTP id e1so1543465vcg.14
        for <linux-mm@kvack.org>; Thu, 15 Dec 2011 22:21:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1323676029-5890-2-git-send-email-glommer@parallels.com>
References: <1323676029-5890-1-git-send-email-glommer@parallels.com> <1323676029-5890-2-git-send-email-glommer@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 15 Dec 2011 22:20:52 -0800
Message-ID: <CAHH2K0YUK9CVk4Ds3cPA=6SNjX0y79nSo+Vy8r1H5PiVXA1RWQ@mail.gmail.com>
Subject: Re: [PATCH v9 1/9] Basic kernel memory functionality for the Memory Controller
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>

On Sun, Dec 11, 2011 at 11:47 PM, Glauber Costa <glommer@parallels.com> wro=
te:
> +Memory limits as specified by the standard Memory Controller may or may =
not
> +take kernel memory into consideration. This is achieved through the file
> +memory.independent_kmem_limit. A Value different than 0 will allow for k=
ernel

s/Value/value/

It is probably worth documenting the default value for
memory.independent_kmem_limit?  I figure it would be zero at root and
and inherited from parents.  But I think the implementation differs.

> @@ -277,6 +281,11 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0unsigned long =A0 move_charge_at_immigrate;
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* Should kernel memory limits be stabilished independent=
ly
> + =A0 =A0 =A0 =A0* from user memory ?
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 kmem_independent_accounting;

I have no serious objection, but a full int seems like overkill for a
boolean value.

> +static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys=
 *ss)
> +{
> + =A0 =A0 =A0 int ret =3D 0;
> +
> + =A0 =A0 =A0 ret =3D cgroup_add_files(cont, ss, kmem_cgroup_files,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ARRAY_SIZE(k=
mem_cgroup_files));
> + =A0 =A0 =A0 return ret;

If you want to this function could be condensed down to:
  return cgroup_add_files(...);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
