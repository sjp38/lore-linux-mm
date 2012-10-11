Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 6FC926B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 09:45:12 -0400 (EDT)
Subject: Re: kswapd0: wxcessive CPU usage
In-Reply-To: Your message of "Thu, 11 Oct 2012 10:52:28 +0200."
             <507688CC.9000104@suse.cz>
From: Valdis.Kletnieks@vt.edu
References: <507688CC.9000104@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1349963080_1985P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Oct 2012 09:44:40 -0400
Message-ID: <106695.1349963080@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jiri Slaby <jirislaby@gmail.com>

--==_Exmh_1349963080_1985P
Content-Type: text/plain; charset="us-ascii"
Content-Id: <106687.1349963080.1@turing-police.cc.vt.edu>

On Thu, 11 Oct 2012 10:52:28 +0200, Jiri Slaby said:
> Hi,
>
> with 3.6.0-next-20121008, kswapd0 is spinning my CPU at 100% for 1
> minute or so.


>  [<ffffffff8116ee05>] ? put_super+0x25/0x40
>  [<ffffffff8116fdd4>] ? grab_super_passive+0x24/0xa0
>  [<ffffffff8116ff99>] ? prune_super+0x149/0x1b0
>  [<ffffffff81131531>] ? shrink_slab+0xa1/0x2d0
>  [<ffffffff8113452d>] ? kswapd+0x66d/0xb60
>  [<ffffffff81133ec0>] ? try_to_free_pages+0x180/0x180
>  [<ffffffff810a2770>] ? kthread+0xc0/0xd0
>  [<ffffffff810a26b0>] ? kthread_create_on_node+0x130/0x130
>  [<ffffffff816a6c9c>] ? ret_from_fork+0x7c/0x90
>  [<ffffffff810a26b0>] ? kthread_create_on_node+0x130/0x130

I don't know what it is, I haven't finished bisecting it - but I can confirm that
I started seeing the same problem 2 or 3 weeks ago.  Note that said call
trace does *NOT* require a suspend - I don't do suspend on my laptop and
I'm seeing kswapd burn CPU with similar traces.

# cat /proc/31/stack
[<ffffffff81110306>] grab_super_passive+0x44/0x76
[<ffffffff81110372>] prune_super+0x3a/0x13c
[<ffffffff810dc52a>] shrink_slab+0x95/0x301
[<ffffffff810defb7>] kswapd+0x5c8/0x902
[<ffffffff8104eea4>] kthread+0x9d/0xa5
[<ffffffff815ccfac>] ret_from_fork+0x7c/0x90
[<ffffffffffffffff>] 0xffffffffffffffff
# cat /proc/31/stack
[<ffffffff8110f5af>] put_super+0x29/0x2d
[<ffffffff8110f637>] drop_super+0x1b/0x20
[<ffffffff81110462>] prune_super+0x12a/0x13c
[<ffffffff810dc52a>] shrink_slab+0x95/0x301
[<ffffffff810defb7>] kswapd+0x5c8/0x902
[<ffffffff8104eea4>] kthread+0x9d/0xa5
[<ffffffff815ccfac>] ret_from_fork+0x7c/0x90
[<ffffffffffffffff>] 0xffffffffffffffff

So at least we know we're not hallucinating. :)




--==_Exmh_1349963080_1985P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUHbNSAdmEQWDXROgAQIYfBAAgeHEAz7FgfpzNDpcV4yZGL2B+VHPHovO
Y8TjqAVUB4YEVt7NV215wuh2hX+W21ycqdw6yIJZKipP680Qi+MN+8KO9ayie1nQ
yrE/SDPlGzZjZyKctRLrKKV/GLcw8H9TsVNC46L7s1OyguW9GBS+7KMg2LBIRY6A
LDoutg1c2WrFp9EmeGOy2tvSmmSjjC08hUvezQwP7POtX7iDdjcTjvuoX9KwZErL
EoyzU32Kehwh6xjVTipAd1glIsjR/qeR9EsVBY2yNJN+jUEouF6TYIpod0zumujo
RNTkBYY5KlCd0lJJ924wqP9+YyTM9GoGfgCyvOA8uVQdVwrtYv04PF2szLGqDGSE
xk8G189iE/K1RsMFXvWOnXkHfylf5H4eveTYSWLvDZXr4c8rvQASosTi/u6Qwaa+
3hC30YoHe5Jps+fD3eY3vZeevo+KGrULq0p6bfNOOcMBARFkb5lViytI0RHSfEZM
uBSyBD67vHEQ0FKskyqyugTJPjoh3clFzedJTbsadYY7mi3b52t8TSjcYCJfBDhj
hwCDf9rSNLbyvWoJviz3P2MmqgvnDHrX7zX5h6z+iBxnJPZHT3FnwfrrokF3Pk50
HOME2lvw8oz/Je96tALRIWeJ4GzfIeA9F1ZIUGhTIP1fSJqvRuf6QdQrZJ3VM4V+
8vhVI9NXC+g=
=bkF7
-----END PGP SIGNATURE-----

--==_Exmh_1349963080_1985P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
