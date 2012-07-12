Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id CCD826B0068
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 10:13:04 -0400 (EDT)
Message-ID: <1342102376.28010.7.camel@twins>
Subject: Re: [PATCH 00/13] rbtree updates
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 12 Jul 2012 16:12:56 +0200
In-Reply-To: <20120712011208.GA1152@google.com>
References: <1341876923-12469-1-git-send-email-walken@google.com>
	 <1342012996.3462.154.camel@twins> <20120712011208.GA1152@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Wed, 2012-07-11 at 18:12 -0700, Michel Lespinasse wrote:
>=20
> In __rb_erase_color(), some of the cases are more complicated than you dr=
ew however, because some node colors aren't known.

Right, the wikipedia article draws them blank, I couldn't come up with a
3rd case, although maybe we can annotate them like (P) to mean blank..


> This is what I ended up with:
>=20
>   *  5), then the longest possible path due to 4 is 2B.
>   *
>   *  We shall indicate color with case, where black nodes are uppercase a=
nd red
> - *  nodes will be lowercase.
> + *  nodes will be lowercase. Unknown color nodes shall be drawn as red w=
ith
> + *  some accompanying text comment.
>   */
>=20
> +                                       /*
> +                                        * Case 2 - sibling color flip
> +                                        * (p could be either color here)
> +                                        *
> +                                        *     p             p
> +                                        *    / \           / \
> +                                        *   N   S    -->  N   s
> +                                        *      / \           / \
> +                                        *     Sl  Sr        Sl  Sr
> +                                        *
> +                                        * This leaves us violating 5), s=
o
> +                                        * recurse at p. If p is red, the
> +                                        * recursion will just flip it to=
 black
> +                                        * and exit. If coming from Case =
1,
> +                                        * p is known to be red.
> +                                        */
>=20
> +                               /*
> +                                * Case 3 - right rotate at sibling
> +                                * (p could be either color here)
> +                                *
> +                                *    p             p
> +                                *   / \           / \
> +                                *  N   S    -->  N   Sl
> +                                *     / \             \
> +                                *    sl  Sr            s
> +                                *                       \
> +                                *                        Sr
> +                                */
>=20
> +                       /*
> +                        * Case 4 - left rotate at parent + color flips
> +                        * (p and sl could be either color here.
> +                        *  After rotation, p becomes black, s acquires
> +                        *  p's color, and sl keeps its color)
> +                        *
> +                        *       p               s
> +                        *      / \             / \
> +                        *     N   S     -->   P   Sr
> +                        *        / \         / \
> +                        *       sl  sr      N   sl
> +                        */=20


Yes, very nice.. someday when I'm bored I might expand the comments with
the reason why we're doing the given operation.

Also, I was sorely tempted to rename your tmp1,tmp2 variables to sl and
sr.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
