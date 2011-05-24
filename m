Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8F56B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:20:04 -0400 (EDT)
Received: by pzk4 with SMTP id 4so3637237pzk.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 18:20:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikQd34QZnQVSn_9f_Mxc8wtJMHY0w@mail.gmail.com>
References: <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
 <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com> <4DD5DC06.6010204@jp.fujitsu.com>
 <BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com> <BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
 <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com> <20110520101120.GC11729@random.random>
 <BANLkTikAFMvpgHR2dopd+Nvjfyw_XT5=LA@mail.gmail.com> <20110520153346.GA1843@barrios-desktop>
 <BANLkTi=X+=Wh1MLs7Fc-v-OMtxAHbcPmxA@mail.gmail.com> <20110520161934.GA2386@barrios-desktop>
 <BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com> <BANLkTimThVw7-PN6ypBBarqXJa1xxYA_Ow@mail.gmail.com>
 <BANLkTint+Qs+cO+wKUJGytnVY3X1bp+8rQ@mail.gmail.com> <BANLkTinx+oPJFQye7T+RMMGzg9E7m28A=Q@mail.gmail.com>
 <BANLkTik29nkn-DN9ui6XV4sy5Wo2jmeS9w@mail.gmail.com> <BANLkTikQd34QZnQVSn_9f_Mxc8wtJMHY0w@mail.gmail.com>
From: Andrew Lutomirski <luto@mit.edu>
Date: Mon, 23 May 2011 21:19:42 -0400
Message-ID: <BANLkTi=wVOPSv1BA_mZq9=r14Vu3kUh3_w@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: multipart/mixed; boundary=bcaec520f411219c4304a3fb6331
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

--bcaec520f411219c4304a3fb6331
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Sun, May 22, 2011 at 7:12 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Could you test below patch based on vanilla 2.6.38.6?
> The expect result is that system hang never should happen.
> I hope this is last test about hang.
>
> Thanks.
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 292582c..1663d24 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -231,8 +231,11 @@ unsigned long shrink_slab(struct shrink_control *shr=
ink,
> =A0 =A0 =A0 if (scanned =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 scanned =3D SWAP_CLUSTER_MAX;
>
> - =A0 =A0 =A0 if (!down_read_trylock(&shrinker_rwsem))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1; =A0 =A0 =A0 /* Assume we'll be ab=
le to shrink next time */
> + =A0 =A0 =A0 if (!down_read_trylock(&shrinker_rwsem)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Assume we'll be able to shrink next time=
 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 list_for_each_entry(shrinker, &shrinker_list, list) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long long delta;
> @@ -286,6 +289,8 @@ unsigned long shrink_slab(struct shrink_control *shri=
nk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrinker->nr +=3D total_scan;
> =A0 =A0 =A0 }
> =A0 =A0 =A0 up_read(&shrinker_rwsem);
> +out:
> + =A0 =A0 =A0 cond_resched();
> =A0 =A0 =A0 return ret;
> =A0}
>
> @@ -2331,7 +2336,7 @@ static bool sleeping_prematurely(pg_data_t
> *pgdat, int order, long remaining,
> =A0 =A0 =A0 =A0* must be balanced
> =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 if (order)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return pgdat_balanced(pgdat, balanced, clas=
szone_idx);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return !pgdat_balanced(pgdat, balanced, cla=
sszone_idx);
> =A0 =A0 =A0 else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return !all_zones_ok;
> =A0}

So far with this patch I can't reproduce the hang or the bogus OOM.

To be completely clear, I have COMPACTION, MIGRATION, and THP off, I'm
running 2.6.38.6, and I have exactly two patches applied.  One is the
attached patch and the other is a the fpu.ko/aesni_intel.ko merger
which I need to get dracut to boot my box.

For fun, I also upgraded to 8GB of RAM and it still works.

--Andy

>
> --
> Kind regards,
> Minchan Kim
>

--bcaec520f411219c4304a3fb6331
Content-Type: application/octet-stream; name="minchan-patch-v3.patch"
Content-Disposition: attachment; filename="minchan-patch-v3.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_go25pkug0

Y29tbWl0IDFmMzExMWJlMWY5MjIyNjM2YjFkNTZhOGZmNWMzODNlYzRmYjIwNmIKQXV0aG9yOiBB
bmR5IEx1dG9taXJza2kgPGx1dG9AbWl0LmVkdT4KRGF0ZTogICBNb24gTWF5IDIzIDEyOjIwOjE3
IDIwMTEgLTA0MDAKCiAgICBbTWluY2hhbl0gcGF0Y2ggZm9yIHRlc3RpbmcgMjMtMDUtMjAxMQoK
ZGlmZiAtLWdpdCBhL21tL3Ztc2Nhbi5jIGIvbW0vdm1zY2FuLmMKaW5kZXggMDY2NTUyMC4uYzlj
OWM5MyAxMDA2NDQKLS0tIGEvbW0vdm1zY2FuLmMKKysrIGIvbW0vdm1zY2FuLmMKQEAgLTIzMCw4
ICsyMzAsMTEgQEAgdW5zaWduZWQgbG9uZyBzaHJpbmtfc2xhYih1bnNpZ25lZCBsb25nIHNjYW5u
ZWQsIGdmcF90IGdmcF9tYXNrLAogCWlmIChzY2FubmVkID09IDApCiAJCXNjYW5uZWQgPSBTV0FQ
X0NMVVNURVJfTUFYOwogCi0JaWYgKCFkb3duX3JlYWRfdHJ5bG9jaygmc2hyaW5rZXJfcndzZW0p
KQotCQlyZXR1cm4gMTsJLyogQXNzdW1lIHdlJ2xsIGJlIGFibGUgdG8gc2hyaW5rIG5leHQgdGlt
ZSAqLworCWlmICghZG93bl9yZWFkX3RyeWxvY2soJnNocmlua2VyX3J3c2VtKSkgeworCQkvKiBB
c3N1bWUgd2UnbGwgYmUgYWJsZSB0byBzaHJpbmsgbmV4dCB0aW1lICovCisJCXJldCA9IDE7CisJ
CWdvdG8gb3V0OworCX0KIAogCWxpc3RfZm9yX2VhY2hfZW50cnkoc2hyaW5rZXIsICZzaHJpbmtl
cl9saXN0LCBsaXN0KSB7CiAJCXVuc2lnbmVkIGxvbmcgbG9uZyBkZWx0YTsKQEAgLTI4Miw2ICsy
ODUsOSBAQCB1bnNpZ25lZCBsb25nIHNocmlua19zbGFiKHVuc2lnbmVkIGxvbmcgc2Nhbm5lZCwg
Z2ZwX3QgZ2ZwX21hc2ssCiAJCXNocmlua2VyLT5uciArPSB0b3RhbF9zY2FuOwogCX0KIAl1cF9y
ZWFkKCZzaHJpbmtlcl9yd3NlbSk7CisKK291dDoKKwljb25kX3Jlc2NoZWQoKTsKIAlyZXR1cm4g
cmV0OwogfQogCkBAIC0yMjg2LDcgKzIyOTIsNyBAQCBzdGF0aWMgYm9vbCBzbGVlcGluZ19wcmVt
YXR1cmVseShwZ19kYXRhX3QgKnBnZGF0LCBpbnQgb3JkZXIsIGxvbmcgcmVtYWluaW5nLAogCSAq
IG11c3QgYmUgYmFsYW5jZWQKIAkgKi8KIAlpZiAob3JkZXIpCi0JCXJldHVybiBwZ2RhdF9iYWxh
bmNlZChwZ2RhdCwgYmFsYW5jZWQsIGNsYXNzem9uZV9pZHgpOworCQlyZXR1cm4gIXBnZGF0X2Jh
bGFuY2VkKHBnZGF0LCBiYWxhbmNlZCwgY2xhc3N6b25lX2lkeCk7CiAJZWxzZQogCQlyZXR1cm4g
IWFsbF96b25lc19vazsKIH0K
--bcaec520f411219c4304a3fb6331--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
