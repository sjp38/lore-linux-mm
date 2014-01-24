Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7182E6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 02:46:33 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id u14so977827bkz.27
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 23:46:32 -0800 (PST)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id dp1si1896790bkc.133.2014.01.23.23.46.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 23:46:32 -0800 (PST)
Received: by mail-ig0-f169.google.com with SMTP id uq10so4215179igb.0
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 23:46:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52E214C7.9050309@ti.com>
References: <52E19C7D.7050603@intel.com>
	<CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com>
	<52E20A56.1000507@ti.com>
	<52E20E98.7010703@ti.com>
	<CAE9FiQWRkP1Hir6UFuPRGu6bXNd_SHonuaC-MG1UD-tSeE0teQ@mail.gmail.com>
	<52E214C7.9050309@ti.com>
Date: Thu, 23 Jan 2014 23:46:29 -0800
Message-ID: <CAE9FiQXEYb5bkLTS9oMUWB_tQ=2-0EUeRDb0DHPS_YH83CC7nA@mail.gmail.com>
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/mixed; boundary=089e011849e662a27104f0b28e05
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

--089e011849e662a27104f0b28e05
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Jan 23, 2014 at 11:22 PM, Santosh Shilimkar
<santosh.shilimkar@ti.com> wrote:
> On Friday 24 January 2014 02:04 AM, Yinghai Lu wrote:
>> On Thu, Jan 23, 2014 at 10:56 PM, Santosh Shilimkar
>> <santosh.shilimkar@ti.com> wrote:
>>> On Friday 24 January 2014 01:38 AM, Santosh Shilimkar wrote:
>>
>>> The patch which is now commit 457ff1d {lib/swiotlb.c: use
>>> memblock apis for early memory allocations} was the breaking the
>>> boot on Andrew's machine. Now if I look back the patch, based on your
>>> above description, I believe below hunk waS/is the culprit.
>>>
>>> @@ -172,8 +172,9 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
>>>         /*
>>>          * Get the overflow emergency buffer
>>>          */
>>> -       v_overflow_buffer = alloc_bootmem_low_pages_nopanic(
>>> -                                               PAGE_ALIGN(io_tlb_overflow));
>>> +       v_overflow_buffer = memblock_virt_alloc_nopanic(
>>> +                                               PAGE_ALIGN(io_tlb_overflow),
>>> +                                               PAGE_SIZE);
>>>         if (!v_overflow_buffer)
>>>                 return -ENOMEM;
>>>
>>>
>>> Looks like 'v_overflow_buffer' must be allocated from low memory in this
>>> case. Is that correct ?
>>
>> yes.
>>
>> but should the change like following
>>
>> commit 457ff1de2d247d9b8917c4664c2325321a35e313
>> Author: Santosh Shilimkar <santosh.shilimkar@ti.com>
>> Date:   Tue Jan 21 15:50:30 2014 -0800
>>
>>     lib/swiotlb.c: use memblock apis for early memory allocations
>>
>>
>> @@ -215,13 +220,13 @@ swiotlb_init(int verbose)
>>         bytes = io_tlb_nslabs << IO_TLB_SHIFT;
>>
>>         /* Get IO TLB memory from the low pages */
>> -       vstart = alloc_bootmem_low_pages_nopanic(PAGE_ALIGN(bytes));
>> +       vstart = memblock_virt_alloc_nopanic(PAGE_ALIGN(bytes), PAGE_SIZE);
>>         if (vstart && !swiotlb_init_with_tbl(vstart, io_tlb_nslabs, verbose))
>>                 return;
>>
> OK. So we need '__alloc_bootmem_low()' equivalent memblock API. We will try
> to come up with a patch for the same. Thanks for inputs.

Yes,

Andrew, can you try attached two patches in your setup?

Assume your system does not have intel iommu support?

Thanks

Yinghai

--089e011849e662a27104f0b28e05
Content-Type: text/x-patch; charset=US-ASCII; name="fix_numa_x.patch"
Content-Disposition: attachment; filename="fix_numa_x.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hqt5bvnn0

U3ViamVjdDogW1BBVENIXSB4ODY6IEZpeCBudW1hIHdpdGggcmV2ZXJ0aW5nIHdyb25nIG1lbWJs
b2NrIHNldHRpbmcuCgpEYXZlIHJlcG9ydGVkIE51bWEgb24geDg2IGlzIGJyb2tlbiBvbiBzeXN0
ZW0gd2l0aCAxVCBtZW1vcnkuCgpJdCB0dXJucyBvdXQKfCBjb21taXQgNWI2ZTUyOTUyMWQzNWUx
YmNhYTBmZTQzNDU2ZDFiYmIzMzVjYWU1ZAp8IEF1dGhvcjogU2FudG9zaCBTaGlsaW1rYXIgPHNh
bnRvc2guc2hpbGlta2FyQHRpLmNvbT4KfCBEYXRlOiAgIFR1ZSBKYW4gMjEgMTU6NTA6MDMgMjAx
NCAtMDgwMAp8CnwgICAgeDg2OiBtZW1ibG9jazogc2V0IGN1cnJlbnQgbGltaXQgdG8gbWF4IGxv
dyBtZW1vcnkgYWRkcmVzcwoKc2V0IGxpbWl0IHRvIGxvdyB3cm9uZ2x5LgoKbWF4X2xvd19wZm5f
bWFwcGVkIGlzIGRpZmZlcmVudCBmcm9tIG1heF9wZm5fbWFwcGVkLgptYXhfbG93X3Bmbl9tYXBw
ZWQgaXMgYWx3YXlzIHVuZGVyIDRHLgoKVGhhdCB3aWxsIG1lbWJsb2NrX2FsbG9jX25pZCBhbGwg
Z28gdW5kZXIgNEcuCgpSZXZlcnQgdGhhdCBvZmZlbmRpbmcgcGF0Y2guCgpSZXBvcnRlZC1ieTog
RGF2ZSBIYW5zZW4gPGRhdmUuaGFuc2VuQGludGVsLmNvbT4KU2lnbmVkLW9mZi1ieTogWWluZ2hh
aSBMdSA8eWluZ2hhaUBrZXJuZWwub3JnPgoKCi0tLQogYXJjaC94ODYvaW5jbHVkZS9hc20vcGFn
ZV90eXBlcy5oIHwgICAgNCArKy0tCiBhcmNoL3g4Ni9rZXJuZWwvc2V0dXAuYyAgICAgICAgICAg
fCAgICAyICstCiAyIGZpbGVzIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMo
LSkKCkluZGV4OiBsaW51eC0yLjYvYXJjaC94ODYvaW5jbHVkZS9hc20vcGFnZV90eXBlcy5oCj09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2FyY2gveDg2L2luY2x1ZGUvYXNtL3BhZ2VfdHlw
ZXMuaAorKysgbGludXgtMi42L2FyY2gveDg2L2luY2x1ZGUvYXNtL3BhZ2VfdHlwZXMuaApAQCAt
NTEsOSArNTEsOSBAQCBleHRlcm4gaW50IGRldm1lbV9pc19hbGxvd2VkKHVuc2lnbmVkIGxvCiBl
eHRlcm4gdW5zaWduZWQgbG9uZyBtYXhfbG93X3Bmbl9tYXBwZWQ7CiBleHRlcm4gdW5zaWduZWQg
bG9uZyBtYXhfcGZuX21hcHBlZDsKIAotc3RhdGljIGlubGluZSBwaHlzX2FkZHJfdCBnZXRfbWF4
X2xvd19tYXBwZWQodm9pZCkKK3N0YXRpYyBpbmxpbmUgcGh5c19hZGRyX3QgZ2V0X21heF9tYXBw
ZWQodm9pZCkKIHsKLQlyZXR1cm4gKHBoeXNfYWRkcl90KW1heF9sb3dfcGZuX21hcHBlZCA8PCBQ
QUdFX1NISUZUOworCXJldHVybiAocGh5c19hZGRyX3QpbWF4X3Bmbl9tYXBwZWQgPDwgUEFHRV9T
SElGVDsKIH0KIAogYm9vbCBwZm5fcmFuZ2VfaXNfbWFwcGVkKHVuc2lnbmVkIGxvbmcgc3RhcnRf
cGZuLCB1bnNpZ25lZCBsb25nIGVuZF9wZm4pOwpJbmRleDogbGludXgtMi42L2FyY2gveDg2L2tl
cm5lbC9zZXR1cC5jCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2FyY2gveDg2L2tlcm5l
bC9zZXR1cC5jCisrKyBsaW51eC0yLjYvYXJjaC94ODYva2VybmVsL3NldHVwLmMKQEAgLTExNzMs
NyArMTE3Myw3IEBAIHZvaWQgX19pbml0IHNldHVwX2FyY2goY2hhciAqKmNtZGxpbmVfcCkKIAog
CXNldHVwX3JlYWxfbW9kZSgpOwogCi0JbWVtYmxvY2tfc2V0X2N1cnJlbnRfbGltaXQoZ2V0X21h
eF9sb3dfbWFwcGVkKCkpOworCW1lbWJsb2NrX3NldF9jdXJyZW50X2xpbWl0KGdldF9tYXhfbWFw
cGVkKCkpOwogCWRtYV9jb250aWd1b3VzX3Jlc2VydmUoMCk7CiAKIAkvKgo=
--089e011849e662a27104f0b28e05
Content-Type: text/x-patch; charset=US-ASCII; name="revert_memblock_swiotlb_change.patch"
Content-Disposition: attachment;
	filename="revert_memblock_swiotlb_change.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hqt5ck3l1

LS0tCiBhcmNoL2FybS9rZXJuZWwvc2V0dXAuYyB8ICAgIDIgKy0KIGluY2x1ZGUvbGludXgvYm9v
dG1lbS5oIHwgICAzNyArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrCiBsaWIv
c3dpb3RsYi5jICAgICAgICAgICB8ICAgIDQgKystLQogMyBmaWxlcyBjaGFuZ2VkLCA0MCBpbnNl
cnRpb25zKCspLCAzIGRlbGV0aW9ucygtKQoKSW5kZXg6IGxpbnV4LTIuNi9pbmNsdWRlL2xpbnV4
L2Jvb3RtZW0uaAo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0yLjYub3JpZy9pbmNsdWRlL2xpbnV4L2Jv
b3RtZW0uaAorKysgbGludXgtMi42L2luY2x1ZGUvbGludXgvYm9vdG1lbS5oCkBAIC0xNzUsNiAr
MTc1LDI3IEBAIHN0YXRpYyBpbmxpbmUgdm9pZCAqIF9faW5pdCBtZW1ibG9ja192aXIKIAkJCQkJ
CSAgICBOVU1BX05PX05PREUpOwogfQogCisjaWZuZGVmIEFSQ0hfTE9XX0FERFJFU1NfTElNSVQK
KyNkZWZpbmUgQVJDSF9MT1dfQUREUkVTU19MSU1JVCAgMHhmZmZmZmZmZlVMCisjZW5kaWYKKwor
c3RhdGljIGlubGluZSB2b2lkICogX19pbml0IG1lbWJsb2NrX3ZpcnRfYWxsb2NfbG93KAorICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHBoeXNfYWRkcl90IHNpemUsIHBo
eXNfYWRkcl90IGFsaWduKQoreworICAgICAgICByZXR1cm4gbWVtYmxvY2tfdmlydF9hbGxvY190
cnlfbmlkKHNpemUsIGFsaWduLAorCQkJCQkJICAgQk9PVE1FTV9MT1dfTElNSVQsCisJCQkJCQkg
ICBBUkNIX0xPV19BRERSRVNTX0xJTUlULAorCQkJCQkJICAgTlVNQV9OT19OT0RFKTsKK30KK3N0
YXRpYyBpbmxpbmUgdm9pZCAqIF9faW5pdCBtZW1ibG9ja192aXJ0X2FsbG9jX2xvd19ub3Bhbmlj
KAorICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHBoeXNfYWRkcl90IHNp
emUsIHBoeXNfYWRkcl90IGFsaWduKQoreworICAgICAgICByZXR1cm4gbWVtYmxvY2tfdmlydF9h
bGxvY190cnlfbmlkX25vcGFuaWMoc2l6ZSwgYWxpZ24sCisJCQkJCQkgICBCT09UTUVNX0xPV19M
SU1JVCwKKwkJCQkJCSAgIEFSQ0hfTE9XX0FERFJFU1NfTElNSVQsCisJCQkJCQkgICBOVU1BX05P
X05PREUpOworfQorCiBzdGF0aWMgaW5saW5lIHZvaWQgKiBfX2luaXQgbWVtYmxvY2tfdmlydF9h
bGxvY19mcm9tX25vcGFuaWMoCiAJCXBoeXNfYWRkcl90IHNpemUsIHBoeXNfYWRkcl90IGFsaWdu
LCBwaHlzX2FkZHJfdCBtaW5fYWRkcikKIHsKQEAgLTIzOCw2ICsyNTksMjIgQEAgc3RhdGljIGlu
bGluZSB2b2lkICogX19pbml0IG1lbWJsb2NrX3ZpcgogCXJldHVybiBfX2FsbG9jX2Jvb3RtZW1f
bm9wYW5pYyhzaXplLCBhbGlnbiwgQk9PVE1FTV9MT1dfTElNSVQpOwogfQogCitzdGF0aWMgaW5s
aW5lIHZvaWQgKiBfX2luaXQgbWVtYmxvY2tfdmlydF9hbGxvY19sb3coCisgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgcGh5c19hZGRyX3Qgc2l6ZSwgcGh5c19hZGRyX3Qg
YWxpZ24pCit7CisJaWYgKCFhbGlnbikKKwkJYWxpZ24gPSBTTVBfQ0FDSEVfQllURVM7CisJcmV0
dXJuIF9fYWxsb2NfYm9vdG1lbV9sb3coc2l6ZSwgYWxpZ24sIEJPT1RNRU1fTE9XX0xJTUlUKTsK
K30KKworc3RhdGljIGlubGluZSB2b2lkICogX19pbml0IG1lbWJsb2NrX3ZpcnRfYWxsb2NfbG93
X25vcGFuaWMoCisgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgcGh5c19h
ZGRyX3Qgc2l6ZSwgcGh5c19hZGRyX3QgYWxpZ24pCit7CisJaWYgKCFhbGlnbikKKwkJYWxpZ24g
PSBTTVBfQ0FDSEVfQllURVM7CisJcmV0dXJuIF9fYWxsb2NfYm9vdG1lbV9sb3dfbm9wYW5pYyhz
aXplLCBhbGlnbiwgQk9PVE1FTV9MT1dfTElNSVQpOworfQorCiBzdGF0aWMgaW5saW5lIHZvaWQg
KiBfX2luaXQgbWVtYmxvY2tfdmlydF9hbGxvY19mcm9tX25vcGFuaWMoCiAJCXBoeXNfYWRkcl90
IHNpemUsIHBoeXNfYWRkcl90IGFsaWduLCBwaHlzX2FkZHJfdCBtaW5fYWRkcikKIHsKSW5kZXg6
IGxpbnV4LTIuNi9saWIvc3dpb3RsYi5jCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2xp
Yi9zd2lvdGxiLmMKKysrIGxpbnV4LTIuNi9saWIvc3dpb3RsYi5jCkBAIC0xNzIsNyArMTcyLDcg
QEAgaW50IF9faW5pdCBzd2lvdGxiX2luaXRfd2l0aF90YmwoY2hhciAqdAogCS8qCiAJICogR2V0
IHRoZSBvdmVyZmxvdyBlbWVyZ2VuY3kgYnVmZmVyCiAJICovCi0Jdl9vdmVyZmxvd19idWZmZXIg
PSBtZW1ibG9ja192aXJ0X2FsbG9jX25vcGFuaWMoCisJdl9vdmVyZmxvd19idWZmZXIgPSBtZW1i
bG9ja192aXJ0X2FsbG9jX2xvd19ub3BhbmljKAogCQkJCQkJUEFHRV9BTElHTihpb190bGJfb3Zl
cmZsb3cpLAogCQkJCQkJUEFHRV9TSVpFKTsKIAlpZiAoIXZfb3ZlcmZsb3dfYnVmZmVyKQpAQCAt
MjIwLDcgKzIyMCw3IEBAIHN3aW90bGJfaW5pdChpbnQgdmVyYm9zZSkKIAlieXRlcyA9IGlvX3Rs
Yl9uc2xhYnMgPDwgSU9fVExCX1NISUZUOwogCiAJLyogR2V0IElPIFRMQiBtZW1vcnkgZnJvbSB0
aGUgbG93IHBhZ2VzICovCi0JdnN0YXJ0ID0gbWVtYmxvY2tfdmlydF9hbGxvY19ub3BhbmljKFBB
R0VfQUxJR04oYnl0ZXMpLCBQQUdFX1NJWkUpOworCXZzdGFydCA9IG1lbWJsb2NrX3ZpcnRfYWxs
b2NfbG93X25vcGFuaWMoUEFHRV9BTElHTihieXRlcyksIFBBR0VfU0laRSk7CiAJaWYgKHZzdGFy
dCAmJiAhc3dpb3RsYl9pbml0X3dpdGhfdGJsKHZzdGFydCwgaW9fdGxiX25zbGFicywgdmVyYm9z
ZSkpCiAJCXJldHVybjsKIApJbmRleDogbGludXgtMi42L2FyY2gvYXJtL2tlcm5lbC9zZXR1cC5j
Cj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2FyY2gvYXJtL2tlcm5lbC9zZXR1cC5jCisr
KyBsaW51eC0yLjYvYXJjaC9hcm0va2VybmVsL3NldHVwLmMKQEAgLTcxNyw3ICs3MTcsNyBAQCBz
dGF0aWMgdm9pZCBfX2luaXQgcmVxdWVzdF9zdGFuZGFyZF9yZXNvCiAJa2VybmVsX2RhdGEuZW5k
ICAgICA9IHZpcnRfdG9fcGh5cyhfZW5kIC0gMSk7CiAKIAlmb3JfZWFjaF9tZW1ibG9jayhtZW1v
cnksIHJlZ2lvbikgewotCQlyZXMgPSBtZW1ibG9ja192aXJ0X2FsbG9jKHNpemVvZigqcmVzKSwg
MCk7CisJCXJlcyA9IG1lbWJsb2NrX3ZpcnRfYWxsb2NfbG93KHNpemVvZigqcmVzKSwgMCk7CiAJ
CXJlcy0+bmFtZSAgPSAiU3lzdGVtIFJBTSI7CiAJCXJlcy0+c3RhcnQgPSBfX3Bmbl90b19waHlz
KG1lbWJsb2NrX3JlZ2lvbl9tZW1vcnlfYmFzZV9wZm4ocmVnaW9uKSk7CiAJCXJlcy0+ZW5kID0g
X19wZm5fdG9fcGh5cyhtZW1ibG9ja19yZWdpb25fbWVtb3J5X2VuZF9wZm4ocmVnaW9uKSkgLSAx
Owo=
--089e011849e662a27104f0b28e05--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
