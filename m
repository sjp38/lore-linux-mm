Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id EB6576B00B3
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 16:15:47 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7288786pbb.14
        for <linux-mm@kvack.org>; Sat, 30 Jun 2012 13:15:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1341047274-5616-1-git-send-email-jiang.liu@huawei.com>
References: <1341047274-5616-1-git-send-email-jiang.liu@huawei.com>
Date: Sat, 30 Jun 2012 13:15:46 -0700
Message-ID: <CAE9FiQWzfLkeQs8O22MUEmuGUx=jPi5s=wZt2fcpFMcwrzt3uA@mail.gmail.com>
Subject: Re: [PATCH] mm: setup pageblock_order before it's used by sparse
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/mixed; boundary=f46d042f9e84eb415f04c3b63a76
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tony Luck <tony.luck@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

--f46d042f9e84eb415f04c3b63a76
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 30, 2012 at 2:07 AM, Jiang Liu <jiang.liu@huawei.com> wrote:
> From: Xishi Qiu <qiuxishi@huawei.com>
>
> On architectures with CONFIG_HUGETLB_PAGE_SIZE_VARIABLE set, such as Itan=
ium,
> pageblock_order is a variable with default value of 0. It's set to the ri=
ght
> value by set_pageblock_order() in function free_area_init_core().
>
> But pageblock_order may be used by sparse_init() before free_area_init_co=
re()
> is called along path:
> sparse_init()
> =A0 =A0->sparse_early_usemaps_alloc_node()
> =A0 =A0 =A0 =A0->usemap_size()
> =A0 =A0 =A0 =A0 =A0 =A0->SECTION_BLOCKFLAGS_BITS
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0->((1UL << (PFN_SECTION_SHIFT - pageblock_=
order)) *
> NR_PAGEBLOCK_BITS)
>
> The uninitialized pageblock_size will cause memory wasting because usemap=
_size()
> returns a much bigger value then it's really needed.
>
> For example, on an Itanium platform,
> sparse_init() pageblock_order=3D0 usemap_size=3D24576
> free_area_init_core() before pageblock_order=3D0, usemap_size=3D24576
> free_area_init_core() after pageblock_order=3D12, usemap_size=3D8
>
> That means 24K memory has been wasted for each section, so fix it by call=
ing
> set_pageblock_order() from sparse_init().
>

can you check attached patch?

That will kill more lines code instead.

Thanks

Yinghai

--f46d042f9e84eb415f04c3b63a76
Content-Type: application/octet-stream;
	name="kill_set_pageblock_order.patch"
Content-Disposition: attachment; filename="kill_set_pageblock_order.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h434r2q20

U3ViamVjdDogW1BBVENIXSBtbTogc2V0IHBhZ2VibG9ja19vcmRlciBpbiBjb21waWxpbmcgdGlt
ZQoKVGhhdCBpcyBpbml0aWFsIHNldHRpbmcsIGFuZCBjb3VsZCBiZSBvdmVycmlkZSBieSBjb21t
YW5kIGxpbmUuCgpTaWduZWQtb2ZmLWJ5OiBZaW5naGFpIEx1IDx5aW5naGFpQGtlcm5lbC5vcmc+
CgotLS0KIG1tL3BhZ2VfYWxsb2MuYyB8ICAgNDUgKysrKysrLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tCiAxIGZpbGUgY2hhbmdlZCwgNiBpbnNlcnRpb25zKCspLCAzOSBk
ZWxldGlvbnMoLSkKCkluZGV4OiBsaW51eC0yLjYvbW0vcGFnZV9hbGxvYy5jCj09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0K
LS0tIGxpbnV4LTIuNi5vcmlnL21tL3BhZ2VfYWxsb2MuYworKysgbGludXgtMi42L21tL3BhZ2Vf
YWxsb2MuYwpAQCAtMTQ3LDcgKzE0NywxMiBAQCBib29sIHBtX3N1c3BlbmRlZF9zdG9yYWdlKHZv
aWQpCiAjZW5kaWYgLyogQ09ORklHX1BNX1NMRUVQICovCiAKICNpZmRlZiBDT05GSUdfSFVHRVRM
Ql9QQUdFX1NJWkVfVkFSSUFCTEUKLWludCBwYWdlYmxvY2tfb3JkZXIgX19yZWFkX21vc3RseTsK
Ky8qCisgKiBBc3N1bWUgdGhlIGxhcmdlc3QgY29udGlndW91cyBvcmRlciBvZiBpbnRlcmVzdCBp
cyBhIGh1Z2UgcGFnZS4KKyAqIFRoaXMgdmFsdWUgbWF5IGJlIHZhcmlhYmxlIGRlcGVuZGluZyBv
biBib290IHBhcmFtZXRlcnMgb24gSUE2NCBhbmQKKyAqIHBvd2VycGMuCisgKi8KK2ludCBwYWdl
YmxvY2tfb3JkZXIgPSAoKEhQQUdFX1NISVQgPiBQQUdFX1NISUZUKSA/IEhVR0VUTEJfUEFHRV9P
UkRFUiA6IChNQVhfT1JERVIgLSAxKSkgX19yZWFkX21vc3RseTsKICNlbmRpZgogCiBzdGF0aWMg
dm9pZCBfX2ZyZWVfcGFnZXNfb2soc3RydWN0IHBhZ2UgKnBhZ2UsIHVuc2lnbmVkIGludCBvcmRl
cik7CkBAIC00Mjk4LDQzICs0MzAzLDYgQEAgc3RhdGljIGlubGluZSB2b2lkIHNldHVwX3VzZW1h
cChzdHJ1Y3QgcAogCQkJCXN0cnVjdCB6b25lICp6b25lLCB1bnNpZ25lZCBsb25nIHpvbmVzaXpl
KSB7fQogI2VuZGlmIC8qIENPTkZJR19TUEFSU0VNRU0gKi8KIAotI2lmZGVmIENPTkZJR19IVUdF
VExCX1BBR0VfU0laRV9WQVJJQUJMRQotCi0vKiBJbml0aWFsaXNlIHRoZSBudW1iZXIgb2YgcGFn
ZXMgcmVwcmVzZW50ZWQgYnkgTlJfUEFHRUJMT0NLX0JJVFMgKi8KLXN0YXRpYyBpbmxpbmUgdm9p
ZCBfX2luaXQgc2V0X3BhZ2VibG9ja19vcmRlcih2b2lkKQotewotCXVuc2lnbmVkIGludCBvcmRl
cjsKLQotCS8qIENoZWNrIHRoYXQgcGFnZWJsb2NrX25yX3BhZ2VzIGhhcyBub3QgYWxyZWFkeSBi
ZWVuIHNldHVwICovCi0JaWYgKHBhZ2VibG9ja19vcmRlcikKLQkJcmV0dXJuOwotCi0JaWYgKEhQ
QUdFX1NISUZUID4gUEFHRV9TSElGVCkKLQkJb3JkZXIgPSBIVUdFVExCX1BBR0VfT1JERVI7Ci0J
ZWxzZQotCQlvcmRlciA9IE1BWF9PUkRFUiAtIDE7Ci0KLQkvKgotCSAqIEFzc3VtZSB0aGUgbGFy
Z2VzdCBjb250aWd1b3VzIG9yZGVyIG9mIGludGVyZXN0IGlzIGEgaHVnZSBwYWdlLgotCSAqIFRo
aXMgdmFsdWUgbWF5IGJlIHZhcmlhYmxlIGRlcGVuZGluZyBvbiBib290IHBhcmFtZXRlcnMgb24g
SUE2NCBhbmQKLQkgKiBwb3dlcnBjLgotCSAqLwotCXBhZ2VibG9ja19vcmRlciA9IG9yZGVyOwot
fQotI2Vsc2UgLyogQ09ORklHX0hVR0VUTEJfUEFHRV9TSVpFX1ZBUklBQkxFICovCi0KLS8qCi0g
KiBXaGVuIENPTkZJR19IVUdFVExCX1BBR0VfU0laRV9WQVJJQUJMRSBpcyBub3Qgc2V0LCBzZXRf
cGFnZWJsb2NrX29yZGVyKCkKLSAqIGlzIHVudXNlZCBhcyBwYWdlYmxvY2tfb3JkZXIgaXMgc2V0
IGF0IGNvbXBpbGUtdGltZS4gU2VlCi0gKiBpbmNsdWRlL2xpbnV4L3BhZ2VibG9jay1mbGFncy5o
IGZvciB0aGUgdmFsdWVzIG9mIHBhZ2VibG9ja19vcmRlciBiYXNlZCBvbgotICogdGhlIGtlcm5l
bCBjb25maWcKLSAqLwotc3RhdGljIGlubGluZSB2b2lkIHNldF9wYWdlYmxvY2tfb3JkZXIodm9p
ZCkKLXsKLX0KLQotI2VuZGlmIC8qIENPTkZJR19IVUdFVExCX1BBR0VfU0laRV9WQVJJQUJMRSAq
LwotCiAvKgogICogU2V0IHVwIHRoZSB6b25lIGRhdGEgc3RydWN0dXJlczoKICAqICAgLSBtYXJr
IGFsbCBwYWdlcyByZXNlcnZlZApAQCAtNDQxMyw3ICs0MzgxLDYgQEAgc3RhdGljIHZvaWQgX19w
YWdpbmdpbml0IGZyZWVfYXJlYV9pbml0XwogCQlpZiAoIXNpemUpCiAJCQljb250aW51ZTsKIAot
CQlzZXRfcGFnZWJsb2NrX29yZGVyKCk7CiAJCXNldHVwX3VzZW1hcChwZ2RhdCwgem9uZSwgc2l6
ZSk7CiAJCXJldCA9IGluaXRfY3VycmVudGx5X2VtcHR5X3pvbmUoem9uZSwgem9uZV9zdGFydF9w
Zm4sCiAJCQkJCQlzaXplLCBNRU1NQVBfRUFSTFkpOwo=
--f46d042f9e84eb415f04c3b63a76--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
