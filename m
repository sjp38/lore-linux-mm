Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C9AAB6B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 20:03:20 -0400 (EDT)
Received: by iwn40 with SMTP id 40so2896606iwn.1
        for <linux-mm@kvack.org>; Sun, 18 Apr 2010 17:03:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BCB780C.1030001@kernel.org>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <4BC6CB30.7030308@kernel.org>
	 <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>
	 <4BC6E581.1000604@kernel.org>
	 <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>
	 <4BC6FBC8.9090204@kernel.org>
	 <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>
	 <alpine.DEB.2.00.1004161105120.7710@router.home>
	 <1271606079.2100.159.camel@barrios-desktop>
	 <4BCB780C.1030001@kernel.org>
Date: Mon, 19 Apr 2010 09:03:17 +0900
Message-ID: <j2h28c262361004181703gd3f4bc19r6d00451e01b779a7@mail.gmail.com>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: multipart/mixed; boundary=0016e64c0616293a2d04848bb0cc
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--0016e64c0616293a2d04848bb0cc
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi, Tejun.

On Mon, Apr 19, 2010 at 6:22 AM, Tejun Heo <tj@kernel.org> wrote:
> On 04/19/2010 12:54 AM, Minchan Kim wrote:
>>> alloc_pages is the same as alloc_pages_any_node so why have it?
>>
>> I don't want to force using '_node' postfix on UMA users.
>> Maybe they don't care getting page from any node and event don't need to
>> know about _NODE_.
>
> Yeah, then, remove alloc_pages_any_node(). =C2=A0I can't really see the
> point of any_/exact_node. =C2=A0alloc_pages() and alloc_pages_node() are
> fine and in line with other functions. =C2=A0Why change it?
>
>>> Why remove it? If you want to get rid of -1 handling then check all the
>>
>> alloc_pages_node have multiple meaning as you said. So some of users
>> misuses that API. I want to clear intention of user.
>
> The name is fine. =C2=A0Just clean up the users and make the intended usa=
ge
> clear in documentation and implementation (ie. trigger a big fat
> warning) and make all the callers use named constants instead of -1
> for special meanings.
>
> Thanks.

Let's tidy my table.

I made quick patch to show the concept with one example of pci-dma.
(Sorry but I attach patch since web gmail's mangling.)

On UMA, we can change alloc_pages with
alloc_pages_exact_node(numa_node_id(),....)
(Actually, the patch is already merged mmotm)

on NUMA, alloc_pages is some different meaning, so I don't want to change i=
t.
on NUMA, alloc_pages_node means _ANY_NODE_.
So let's remove nid argument and change naming with alloc_pages_any_node.

Then, whole users of alloc_pages_node can be changed between
alloc_pages_exact_node and alloc_pages_any_node.

It was my intention. What's your concern?

Thanks for your interest, Tejun. :)

diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
index a4ac764..dc511cb 100644
--- a/arch/x86/kernel/pci-dma.c
+++ b/arch/x86/kernel/pci-dma.c
@@ -152,12 +152,21 @@ void *dma_generic_alloc_coherent(struct device
*dev, size_t size,
        unsigned long dma_mask;
        struct page *page;
        dma_addr_t addr;
+       int nid;

        dma_mask =3D dma_alloc_coherent_mask(dev, flag);

        flag |=3D __GFP_ZERO;
 again:
-       page =3D alloc_pages_node(dev_to_node(dev), flag, get_order(size));
+       nid =3D dev_to_node(dev);
+       /*
+        * If pci-dma maintainer makes sure nid never has NUMA_NO_NODE
+        * we can remove this ugly checking.
+        */
+       if (nid =3D=3D NUMA_NO_NODE)
+               page =3D alloc_pages_any_node(flag, get_order(size));
+       else
+               page =3D alloc_pages_exact_node(nid, flag, get_order(size))=
;
        if (!page)
                return NULL;

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 4c6d413..47fba21 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -278,13 +278,10 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
        return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
 }

-static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
+static inline struct page *alloc_pagse_any_node(gfp_t gfp_mask,
                                                unsigned int order)
 {
-       /* Unknown node is current node */
-       if (nid < 0)
-               nid =3D numa_node_id();
-
+       int nid =3D numa_node_id();
        return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask))=
;
 }

@@ -308,7 +305,7 @@ extern struct page *alloc_page_vma(gfp_t gfp_mask,
                        struct vm_area_struct *vma, unsigned long addr);
 #else
 #define alloc_pages(gfp_mask, order) \
-               alloc_pages_node(numa_node_id(), gfp_mask, order)
+               alloc_pages_exact_node(numa_node_id(), gfp_mask, order)
 #define alloc_page_vma(gfp_mask, vma, addr) alloc_pages(gfp_mask, 0)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
~

--=20
Kind regards,
Minchan Kim

--0016e64c0616293a2d04848bb0cc
Content-Type: text/x-diff; charset=US-ASCII; name="change_alloc_functions_naming.patch"
Content-Disposition: attachment;
	filename="change_alloc_functions_naming.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g86iqf260

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
