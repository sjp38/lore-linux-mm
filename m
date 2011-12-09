Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 83EA26B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 09:44:59 -0500 (EST)
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29866-04 for <linux-mm@kvack.org>; Fri,  9 Dec 2011 14:44:56 +0000 (GMT)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Subject: RE: [PATCH v8 1/9] Basic kernel memory functionality for the Memory Controller
Date: Fri, 9 Dec 2011 14:44:45 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF0D@saturn3.aculab.com>
In-Reply-To: <4EE21D23.4000309@parallels.com>
From: "David Laight" <David.Laight@ACULAB.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, Paul Menage <paul@paulmenage.org>

=20
> How about this?
>=20
>          val =3D !!val;
>=20
>          /*
>           * This follows the same hierarchy restrictions than
>           * mem_cgroup_hierarchy_write()
>           */
>          if (!parent || !parent->use_hierarchy) {
>                  if (list_empty(&cgroup->children))
>                          memcg->kmem_independent_accounting =3D val;
>                  else
>                          return -EBUSY;
>          }
>          else
>                  return -EINVAL;
>=20
>          return 0;

Inverting the tests gives easier to read code:

	if (parent && parent->user_hierarchy)
		return -EINVAL;
	if (!list_empty(&cgroup->children))
		return -EBUSY;
	memcg->kmem_independent_accounting =3D val !=3D 0;
	return 0;

NFI about the logic...
On the face of it the tests don't seem related to each other
or to the assignment!

	David

=09


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
