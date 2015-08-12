Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9286F6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:35:25 -0400 (EDT)
Received: by igfj19 with SMTP id j19so9744265igf.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:35:25 -0700 (PDT)
Received: from BLU004-OMC1S20.hotmail.com (blu004-omc1s20.hotmail.com. [65.55.116.31])
        by mx.google.com with ESMTPS id i23si3514870iod.203.2015.08.12.02.35.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Aug 2015 02:35:25 -0700 (PDT)
Message-ID: <BLU436-SMTP14794A5DF5341F01069AA8A807E0@phx.gbl>
Subject: Re: [PATCH v2 5/5] mm/hwpoison: replace most of put_page in memory
 error handling by put_hwpoison_page
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP12740A47B6EBB7DF2F12A9280700@phx.gbl>
 <20150812085525.GD32192@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP111993C22274095EC6F2FAE807E0@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Wed, 12 Aug 2015 17:35:18 +0800
MIME-Version: 1.0
In-Reply-To: <BLU436-SMTP111993C22274095EC6F2FAE807E0@phx.gbl>
Content-Type: multipart/mixed;
	boundary="------------070009020307080301070305"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--------------070009020307080301070305
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit

On 8/12/15 5:13 PM, Wanpeng Li wrote:
> On 8/12/15 4:55 PM, Naoya Horiguchi wrote:
>> On Mon, Aug 10, 2015 at 07:28:23PM +0800, Wanpeng Li wrote:
>>> Replace most of put_page in memory error handling by put_hwpoison_page,
>>> except the ones at the front of soft_offline_page since the page maybe
>>> THP page and the get refcount in madvise_hwpoison is against the single
>>> 4KB page instead of the logic in get_hwpoison_page.
>>>
>>> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
>> # Sorry for my late response.
>>
>> If I read correctly, get_user_pages_fast() (called by madvise_hwpoison)
>> for a THP tail page takes a refcount from each of head and tail page.
>> gup_huge_pmd() does this in the fast path, and get_page_foll() does this
>> in the slow path (maybe via the following code path)
>>
>>   get_user_pages_unlocked
>>     __get_user_pages_unlocked
>>       __get_user_pages_locked
>>         __get_user_pages
>>           follow_page_mask
>>             follow_trans_huge_pmd (with FOLL_GET set)
>>               get_page_foll
>>
>> So this should be equivalent to what get_hwpoison_page() does for thp pages
>> with regard to refcounting.
>>
>> And I'm expecting that a refcount taken by get_hwpoison_page() is released
>> by put_hwpoison_page() even if the page's status is changed during error
>> handling (the typical (or only?) case is successful thp split.)
> Indeed. :-)
>
>> So I think you can apply put_hwpoison_page() for 3 more callsites in
>> mm/memory-failure.c.
>>  - MF_MSG_POISONED_HUGE case
> I have already done this in my patch.
>
>>  - "soft offline: %#lx page already poisoned" case (you mentioned above)
>>  - "soft offline: %#lx: failed to split THP" case (you mentioned above)
> You are right, I will send a patch rebased on this one since they are
> merged.

The fix patch is in attachment. :)

Regards,
Wanpeng Li


--------------070009020307080301070305
Content-Type: text/plain; charset="UTF-8"; x-mac-type=0; x-mac-creator=0;
	name="0001-mm-hwpoison-mm-hwpoison-replace-most-of-put_page-in-.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename*0="0001-mm-hwpoison-mm-hwpoison-replace-most-of-put_page-in-.pa";
	filename*1="tch"

RnJvbSAzZDgzYzQwY2MzZjZkNDA4ODNhYWJmOWY2MDMzY2Q5ZDc4ZDExN2I1IE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBXYW5wZW5nIExpIDx3YW5wZW5nLmxpQGhvdG1haWwu
Y29tPgpEYXRlOiBXZWQsIDEyIEF1ZyAyMDE1IDE3OjMxOjQyICswODAwClN1YmplY3Q6IFtQ
QVRDSF0gbW0vaHdwb2lzb246IHJlcGxhY2UgbW9zdCBvZiBwdXRfcGFnZSBpbiBtZW1vcnkg
ZXJyb3IgaGFuZGxpbmcgYnkgcHV0X2h3cG9pc29uX3BhZ2UgZml4CgpOb3RlOiBUaGUgcGF0
Y2ggZGVzY3JpcHRpb24gb2Ygb3JpZ2luYWwgcGF0Y2ggIm1tL2h3cG9pc29uOiByZXBsYWNl
IG1vc3Qgb2YgCnB1dF9wYWdlIGluIG1lbW9yeSBlcnJvciBoYW5kbGluZyBieSBwdXRfaHdw
b2lzb25fcGFnZSIgc2hvdWxkIGJlIHJlcGxhY2VkIGJ5CiJSZXBsYWNlIG1vc3Qgb2YgcHV0
X3BhZ2UoKSBpbiBtZW1vcnkgZXJyb3IgaGFuZGxpbmcgYnkgcHV0X2h3cG9pc29uX3BhZ2Uo
KSIuCgpTaWduZWQtb2ZmLWJ5OiBXYW5wZW5nIExpIDx3YW5wZW5nLmxpQGhvdG1haWwuY29t
PgotLS0KIG1tL21lbW9yeS1mYWlsdXJlLmMgfCAgICA0ICsrLS0KIDEgZmlsZXMgY2hhbmdl
ZCwgMiBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL21tL21l
bW9yeS1mYWlsdXJlLmMgYi9tbS9tZW1vcnktZmFpbHVyZS5jCmluZGV4IDBhY2FmZWUuLmQz
NzgxODggMTAwNjQ0Ci0tLSBhL21tL21lbW9yeS1mYWlsdXJlLmMKKysrIGIvbW0vbWVtb3J5
LWZhaWx1cmUuYwpAQCAtMTcyNyw3ICsxNzI3LDcgQEAgaW50IHNvZnRfb2ZmbGluZV9wYWdl
KHN0cnVjdCBwYWdlICpwYWdlLCBpbnQgZmxhZ3MpCiAJaWYgKFBhZ2VIV1BvaXNvbihwYWdl
KSkgewogCQlwcl9pbmZvKCJzb2Z0IG9mZmxpbmU6ICUjbHggcGFnZSBhbHJlYWR5IHBvaXNv
bmVkXG4iLCBwZm4pOwogCQlpZiAoZmxhZ3MgJiBNRl9DT1VOVF9JTkNSRUFTRUQpCi0JCQlw
dXRfcGFnZShwYWdlKTsKKwkJCXB1dF9od3BvaXNvbl9wYWdlKHBhZ2UpOwogCQlyZXR1cm4g
LUVCVVNZOwogCX0KIAlpZiAoIVBhZ2VIdWdlKHBhZ2UpICYmIFBhZ2VUcmFuc0h1Z2UoaHBh
Z2UpKSB7CkBAIC0xNzM1LDcgKzE3MzUsNyBAQCBpbnQgc29mdF9vZmZsaW5lX3BhZ2Uoc3Ry
dWN0IHBhZ2UgKnBhZ2UsIGludCBmbGFncykKIAkJCXByX2luZm8oInNvZnQgb2ZmbGluZTog
JSNseDogZmFpbGVkIHRvIHNwbGl0IFRIUFxuIiwKIAkJCQlwZm4pOwogCQkJaWYgKGZsYWdz
ICYgTUZfQ09VTlRfSU5DUkVBU0VEKQotCQkJCXB1dF9wYWdlKHBhZ2UpOworCQkJCXB1dF9o
d3BvaXNvbl9wYWdlKHBhZ2UpOwogCQkJcmV0dXJuIC1FQlVTWTsKIAkJfQogCX0KLS0gCjEu
Ny4xCgo=
--------------070009020307080301070305--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
