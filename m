Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAIGCCqE003492
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 19 Nov 2008 01:12:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E13AE45DE53
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 01:12:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF30545DD79
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 01:12:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E3331DB803F
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 01:12:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AB9B1DB803A
	for <linux-mm@kvack.org>; Wed, 19 Nov 2008 01:12:11 +0900 (JST)
Message-ID: <6023.10.75.179.61.1227024730.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081119001756.0a31b11e.d-nishimura@mtf.biglobe.ne.jp>
References: <20081118180721.cb2fe744.nishimura@mxp.nes.nec.co.jp><20081118182637.97ae0e48.kamezawa.hiroyu@jp.fujitsu.com><20081118192135.300803ec.nishimura@mxp.nes.nec.co.jp><20081118210838.c99887fd.nishimura@mxp.nes.nec.co.jp><Pine.LNX.4.64.0811181234430.9680@blonde.site>
    <20081119001756.0a31b11e.d-nishimura@mtf.biglobe.ne.jp>
Date: Wed, 19 Nov 2008 01:12:10 +0900 (JST)
Subject: [PATCH mmotm] memcg: avoid using buggy kmap at swap_cgroup 
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20081119011210_87141"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, LiZefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

------=_20081119011210_87141
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit

Daisuke Nishimura said:
> On Tue, 18 Nov 2008 12:48:52 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
>> That's a lot of files which you may not wish to update to get working
>> right now: I think page_cgroup.c can _probably_ reuse KM_PTE1 as a
>> temporary measure, but please verify that's safe first.
>>
> Thank you for your comment.
>
> Hmm, shmem_map_and_free_swp might unmap dir anyway and caller
> (shmem_trancate_range) handles the case, but I do agree it's
> not good manner to unmap other people's kmaps.
>
Hmm...Sorry for my original implementation.
Okay, how about this direction ?
 1. at first, remove kmap_atomic from page_cgroup.c and use GFP_KERNEL
    to allocate buffer.
 2. later, add kmap_atomic + HighMem buffer support in explicit style.
    maybe KM_BOUNCE_READ...can be used.....

patch for BUGFIX is attached.
(Sorry, I have to use Web-Mail and can't make it inlined)

Sorry,
-Kame
------=_20081119011210_87141
Content-Type: application/octet-stream; name="swapcg-kmap-fix.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="swapcg-kmap-fix.patch"

c3dhcF9jZ3JvdXAncyBrbWFwIGxvZ2ljIGNvbmZsaWN0cyBzaG1lbSdzIGttYXAgbG9naWMuCmF2
b2lkIHRvIHVzZSBISUdITUVNIGZvciBub3cgYW5kIHJldmlzaXQgdGhpcyBsYXRlci4KClNpZ25l
ZC1vZmYtYnk6IEtBTUVaQVdBIEhpcm95dWtpIDxrYW1lemF3YS5oaXJveXVAanAuZnVqaXRzdS5j
b20+CgogbW0vcGFnZV9jZ3JvdXAuYyB8ICAgIDggKysrLS0tLS0KIDEgZmlsZSBjaGFuZ2VkLCAz
IGluc2VydGlvbnMoKyksIDUgZGVsZXRpb25zKC0pCgpJbmRleDogdGVtcC9tbS9wYWdlX2Nncm91
cC5jCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT0KLS0tIHRlbXAub3JpZy9tbS9wYWdlX2Nncm91cC5jCisrKyB0ZW1wL21t
L3BhZ2VfY2dyb3VwLmMKQEAgLTMwNiw3ICszMDYsNyBAQCBzdGF0aWMgaW50IHN3YXBfY2dyb3Vw
X3ByZXBhcmUoaW50IHR5cGUpCiAJY3RybCA9ICZzd2FwX2Nncm91cF9jdHJsW3R5cGVdOwogCiAJ
Zm9yIChpZHggPSAwOyBpZHggPCBjdHJsLT5sZW5ndGg7IGlkeCsrKSB7Ci0JCXBhZ2UgPSBhbGxv
Y19wYWdlKEdGUF9LRVJORUwgfCBfX0dGUF9ISUdITUVNIHwgX19HRlBfWkVSTyk7CisJCXBhZ2Ug
PSBhbGxvY19wYWdlKEdGUF9LRVJORUwgfCBfX0dGUF9aRVJPKTsKIAkJaWYgKCFwYWdlKQogCQkJ
Z290byBub3RfZW5vdWdoX3BhZ2U7CiAJCWN0cmwtPm1hcFtpZHhdID0gcGFnZTsKQEAgLTM0Nywx
MSArMzQ3LDEwIEBAIHN0cnVjdCBtZW1fY2dyb3VwICpzd2FwX2Nncm91cF9yZWNvcmQoc3cKIAog
CW1hcHBhZ2UgPSBjdHJsLT5tYXBbaWR4XTsKIAlzcGluX2xvY2tfaXJxc2F2ZSgmY3RybC0+bG9j
aywgZmxhZ3MpOwotCXNjID0ga21hcF9hdG9taWMobWFwcGFnZSwgS01fVVNFUjApOworCXNjID0g
cGFnZV9hZGRyZXNzKG1hcHBhZ2UpOwogCXNjICs9IHBvczsKIAlvbGQgPSBzYy0+dmFsOwogCXNj
LT52YWwgPSBtZW07Ci0Ja3VubWFwX2F0b21pYygodm9pZCAqKXNjLCBLTV9VU0VSMCk7CiAJc3Bp
bl91bmxvY2tfaXJxcmVzdG9yZSgmY3RybC0+bG9jaywgZmxhZ3MpOwogCXJldHVybiBvbGQ7CiB9
CkBAIC0zODIsMTAgKzM4MSw5IEBAIHN0cnVjdCBtZW1fY2dyb3VwICpsb29rdXBfc3dhcF9jZ3Jv
dXAoc3cKIAltYXBwYWdlID0gY3RybC0+bWFwW2lkeF07CiAKIAlzcGluX2xvY2tfaXJxc2F2ZSgm
Y3RybC0+bG9jaywgZmxhZ3MpOwotCXNjID0ga21hcF9hdG9taWMobWFwcGFnZSwgS01fVVNFUjAp
OworCXNjID0gcGFnZV9hZGRyZXNzKG1hcHBhZ2UpOwogCXNjICs9IHBvczsKIAlyZXQgPSBzYy0+
dmFsOwotCWt1bm1hcF9hdG9taWMoKHZvaWQgKilzYywgS01fVVNFUjApOwogCXNwaW5fdW5sb2Nr
X2lycXJlc3RvcmUoJmN0cmwtPmxvY2ssIGZsYWdzKTsKIAlyZXR1cm4gcmV0OwogfQo=
------=_20081119011210_87141--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
