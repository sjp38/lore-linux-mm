Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7DC376B01F1
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 13:45:24 -0400 (EDT)
Date: Mon, 19 Apr 2010 12:45:04 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
In-Reply-To: <j2h28c262361004181703gd3f4bc19r6d00451e01b779a7@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004191238450.9855@router.home>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>  <4BC6CB30.7030308@kernel.org>  <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>  <4BC6E581.1000604@kernel.org>  <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>
  <4BC6FBC8.9090204@kernel.org>  <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>  <alpine.DEB.2.00.1004161105120.7710@router.home>  <1271606079.2100.159.camel@barrios-desktop>  <4BCB780C.1030001@kernel.org>
 <j2h28c262361004181703gd3f4bc19r6d00451e01b779a7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY=0016e64c0616293a2d04848bb0cc
Content-ID: <alpine.DEB.2.00.1004191238451.9855@router.home>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0016e64c0616293a2d04848bb0cc
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1004191238452.9855@router.home>

On Mon, 19 Apr 2010, Minchan Kim wrote:

> Let's tidy my table.
>
> I made quick patch to show the concept with one example of pci-dma.
> (Sorry but I attach patch since web gmail's mangling.)
>
> On UMA, we can change alloc_pages with
> alloc_pages_exact_node(numa_node_id(),....)
> (Actually, the patch is already merged mmotm)

UMA does not have the concept of nodes. Whatever node you specify is
irrelevant. Please remove the patch from mmotm.

> on NUMA, alloc_pages is some different meaning, so I don't want to change it.

No it has the same meaning. It means allocate a page.

> on NUMA, alloc_pages_node means _ANY_NODE_.

It means allocate on the indicated node if possible. Memory could come
from any node due to fallback (in order of node preference).

> So let's remove nid argument and change naming with alloc_pages_any_node.

??? What in the world are you doing?

> Then, whole users of alloc_pages_node can be changed between
> alloc_pages_exact_node and alloc_pages_any_node.
>
> It was my intention. What's your concern?

I dont see the point.

>  again:
> -       page = alloc_pages_node(dev_to_node(dev), flag, get_order(size));
> +       nid = dev_to_node(dev);
> +       /*
> +        * If pci-dma maintainer makes sure nid never has NUMA_NO_NODE
> +        * we can remove this ugly checking.
> +        */
> +       if (nid == NUMA_NO_NODE)
> +               page = alloc_pages_any_node(flag, get_order(size));

s/alloc_pages_any_node/alloc_pages/

> +       else
> +               page = alloc_pages_exact_node(nid, flag, get_order(size));

s/alloc_pages_exact_node/alloc_pages_node/

> -static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
> +static inline struct page *alloc_pagse_any_node(gfp_t gfp_mask,
>                                                 unsigned int order)
>  {
> -       /* Unknown node is current node */
> -       if (nid < 0)
> -               nid = numa_node_id();
> -
> +       int nid = numa_node_id();
>         return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>  }
>

This is very confusing. Because it is

	alloc_pages_numa_node_id()


alloca_pages_any_node suggests that the kernel randomly picks a node?

--0016e64c0616293a2d04848bb0cc
Content-Type: TEXT/X-DIFF; CHARSET=US-ASCII; NAME=change_alloc_functions_naming.patch
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.2.00.1004191238453.9855@router.home>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=change_alloc_functions_naming.patch

ZGlmZiAtLWdpdCBhL2FyY2gveDg2L2tlcm5lbC9wY2ktZG1hLmMgYi9hcmNoL3g4Ni9rZXJuZWwv
cGNpLWRtYS5jCmluZGV4IGE0YWM3NjQuLmRjNTExY2IgMTAwNjQ0Ci0tLSBhL2FyY2gveDg2L2tl
cm5lbC9wY2ktZG1hLmMKKysrIGIvYXJjaC94ODYva2VybmVsL3BjaS1kbWEuYwpAQCAtMTUyLDEy
ICsxNTIsMjEgQEAgdm9pZCAqZG1hX2dlbmVyaWNfYWxsb2NfY29oZXJlbnQoc3RydWN0IGRldmlj
ZSAqZGV2LCBzaXplX3Qgc2l6ZSwKIAl1bnNpZ25lZCBsb25nIGRtYV9tYXNrOwogCXN0cnVjdCBw
YWdlICpwYWdlOwogCWRtYV9hZGRyX3QgYWRkcjsKKwlpbnQgbmlkOwogCiAJZG1hX21hc2sgPSBk
bWFfYWxsb2NfY29oZXJlbnRfbWFzayhkZXYsIGZsYWcpOwogCiAJZmxhZyB8PSBfX0dGUF9aRVJP
OwogYWdhaW46Ci0JcGFnZSA9IGFsbG9jX3BhZ2VzX25vZGUoZGV2X3RvX25vZGUoZGV2KSwgZmxh
ZywgZ2V0X29yZGVyKHNpemUpKTsKKwluaWQgPSBkZXZfdG9fbm9kZShkZXYpOworCS8qCisJICog
SWYgcGNpLWRtYSBtYWludGFpbmVyIG1ha2VzIHN1cmUgbmlkIG5ldmVyIGhhcyBOVU1BX05PX05P
REUKKwkgKiB3ZSBjYW4gcmVtb3ZlIHRoaXMgdWdseSBjaGVja2luZy4KKwkgKi8KKwlpZiAobmlk
ID09IE5VTUFfTk9fTk9ERSkKKwkJcGFnZSA9IGFsbG9jX3BhZ2VzX2FueV9ub2RlKGZsYWcsIGdl
dF9vcmRlcihzaXplKSk7CisJZWxzZQorCQlwYWdlID0gYWxsb2NfcGFnZXNfZXhhY3Rfbm9kZShu
aWQsIGZsYWcsIGdldF9vcmRlcihzaXplKSk7CiAJaWYgKCFwYWdlKQogCQlyZXR1cm4gTlVMTDsK
IApkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9nZnAuaCBiL2luY2x1ZGUvbGludXgvZ2ZwLmgK
aW5kZXggNGM2ZDQxMy4uNDdmYmEyMSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9nZnAuaAor
KysgYi9pbmNsdWRlL2xpbnV4L2dmcC5oCkBAIC0yNzgsMTMgKzI3OCwxMCBAQCBfX2FsbG9jX3Bh
Z2VzKGdmcF90IGdmcF9tYXNrLCB1bnNpZ25lZCBpbnQgb3JkZXIsCiAJcmV0dXJuIF9fYWxsb2Nf
cGFnZXNfbm9kZW1hc2soZ2ZwX21hc2ssIG9yZGVyLCB6b25lbGlzdCwgTlVMTCk7CiB9CiAKLXN0
YXRpYyBpbmxpbmUgc3RydWN0IHBhZ2UgKmFsbG9jX3BhZ2VzX25vZGUoaW50IG5pZCwgZ2ZwX3Qg
Z2ZwX21hc2ssCitzdGF0aWMgaW5saW5lIHN0cnVjdCBwYWdlICphbGxvY19wYWdzZV9hbnlfbm9k
ZShnZnBfdCBnZnBfbWFzaywKIAkJCQkJCXVuc2lnbmVkIGludCBvcmRlcikKIHsKLQkvKiBVbmtu
b3duIG5vZGUgaXMgY3VycmVudCBub2RlICovCi0JaWYgKG5pZCA8IDApCi0JCW5pZCA9IG51bWFf
bm9kZV9pZCgpOwotCisJaW50IG5pZCA9IG51bWFfbm9kZV9pZCgpOwogCXJldHVybiBfX2FsbG9j
X3BhZ2VzKGdmcF9tYXNrLCBvcmRlciwgbm9kZV96b25lbGlzdChuaWQsIGdmcF9tYXNrKSk7CiB9
CiAKQEAgLTMwOCw3ICszMDUsNyBAQCBleHRlcm4gc3RydWN0IHBhZ2UgKmFsbG9jX3BhZ2Vfdm1h
KGdmcF90IGdmcF9tYXNrLAogCQkJc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHVuc2lnbmVk
IGxvbmcgYWRkcik7CiAjZWxzZQogI2RlZmluZSBhbGxvY19wYWdlcyhnZnBfbWFzaywgb3JkZXIp
IFwKLQkJYWxsb2NfcGFnZXNfbm9kZShudW1hX25vZGVfaWQoKSwgZ2ZwX21hc2ssIG9yZGVyKQor
CQlhbGxvY19wYWdlc19leGFjdF9ub2RlKG51bWFfbm9kZV9pZCgpLCBnZnBfbWFzaywgb3JkZXIp
CiAjZGVmaW5lIGFsbG9jX3BhZ2Vfdm1hKGdmcF9tYXNrLCB2bWEsIGFkZHIpIGFsbG9jX3BhZ2Vz
KGdmcF9tYXNrLCAwKQogI2VuZGlmCiAjZGVmaW5lIGFsbG9jX3BhZ2UoZ2ZwX21hc2spIGFsbG9j
X3BhZ2VzKGdmcF9tYXNrLCAwKQo=
--0016e64c0616293a2d04848bb0cc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
