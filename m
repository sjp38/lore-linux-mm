Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 189979000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 05:31:26 -0400 (EDT)
Subject: Re: [PATCH] kmemleak: Never return a pointer you didn't 'get'
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <1303385972-2518-1-git-send-email-ext-phil.2.carmody@nokia.com>
References: <1303385972-2518-1-git-send-email-ext-phil.2.carmody@nokia.com>
Date: Wed, 27 Apr 2011 10:31:20 +0100
Message-ID: <1303896680.15101.1.camel@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2011-04-21 at 12:39 +0100, Phil Carmody wrote:
> Old - If you don't get the last pointer that you looked at, then it will
> still be put, as there's no way of knowing you didn't get it.
>=20
> New - If you didn't get it, then it refers to something deleted, and
> your work is done, so return NULL.
>=20
> Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>

Good catch. But I think the code may look slightly simpler as below:

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index c1d5867..aacee45 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1414,9 +1414,12 @@ static void *kmemleak_seq_next(struct seq_file *seq,=
 void *v, loff_t *pos)
 =09++(*pos);
=20
 =09list_for_each_continue_rcu(n, &object_list) {
-=09=09next_obj =3D list_entry(n, struct kmemleak_object, object_list);
-=09=09if (get_object(next_obj))
+=09=09struct kmemleak_object *obj =3D
+=09=09=09list_entry(n, struct kmemleak_object, object_list);
+=09=09if (get_object(obj)) {
+=09=09=09next_obj =3D obj;
 =09=09=09break;
+=09=09}
 =09}
=20
 =09put_object(prev_obj);


Thanks.

--=20
Catalin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
