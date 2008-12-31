Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 119F26B0087
	for <linux-mm@kvack.org>; Wed, 31 Dec 2008 04:00:01 -0500 (EST)
Received: by ik-out-1112.google.com with SMTP id c29so1239710ika.6
        for <linux-mm@kvack.org>; Wed, 31 Dec 2008 00:59:58 -0800 (PST)
Message-ID: <cb94e63d0812310059s263a0a75x12905a20526dafaf@mail.gmail.com>
Date: Wed, 31 Dec 2008 10:59:58 +0200
From: "wassim dagash" <wassim.dagash@gmail.com>
Subject: Re: [PATCH] mm: stop kswapd's infinite loop at high order allocation
In-Reply-To: <2f11576a0812302054rd26d8bcw6a113b3abefe8965@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_120615_20213153.1230713998406"
References: <20081230195006.1286.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081230185919.GA17725@csn.ul.ie>
	 <2f11576a0812302054rd26d8bcw6a113b3abefe8965@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

------=_Part_120615_20213153.1230713998406
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi ,
Thank you all for reviewing.
Why don't we implement a solution where the order is defined per zone?
I implemented such a solution for my kernel (2.6.18) and tested it, it
worked fine for me. Attached a patch with a solution for 2.6.28
(compile tested only).

On Wed, Dec 31, 2008 at 6:54 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi
>
> thank you for reviewing.
>
>>> ==
>>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>> Subject: [PATCH] mm: kswapd stop infinite loop at high order allocation
>>>
>>> Wassim Dagash reported following kswapd infinite loop problem.
>>>
>>>   kswapd runs in some infinite loop trying to swap until order 10 of zone
>>>   highmem is OK, While zone higmem (as I understand) has nothing to do
>>>   with contiguous memory (cause there is no 1-1 mapping) which means
>>>   kswapd will continue to try to balance order 10 of zone highmem
>>>   forever (or until someone release a very large chunk of highmem).
>>>
>>> He proposed remove contenious checking on highmem at all.
>>> However hugepage on highmem need contenious highmem page.
>>>
>>
>> I'm lacking the original problem report, but contiguous order-10 pages are
>> indeed required for hugepages in highmem and reclaiming for them should not
>> be totally disabled at any point. While no 1-1 mapping exists for the kernel,
>> contiguity is still required.
>
> correct.
> but that's ok.
>
> my patch only change corner case bahavior and only disable high-order
> when priority==0. typical hugepage reclaim don't need and don't reach
> priority==0.
>
> and sorry. I agree with my "2nd loop"  word of the patch comment is a
> bit misleading.
>
>
>> kswapd gets a sc.order when it is known there is a process trying to get
>> high-order pages so it can reclaim at that order in an attempt to prevent
>> future direct reclaim at a high-order. Your patch does not appear to depend on
>> GFP_KERNEL at all so I found the comment misleading. Furthermore, asking it to
>> loop again at order-0 means it may scan and reclaim more memory unnecessarily
>> seeing as all_zones_ok was calculated based on a high-order value, not order-0.
>
> Yup. my patch doesn't depend on GFP_KERNEL.
>
> but, Why order-0 means it may scan more memory unnecessary?
> all_zones_ok() is calculated by zone_watermark_ok() and zone_watermark_ok()
> depend on order argument. and my patch set order variable to 0 too.
>
>
>> While constantly looping trying to balance for high-orders is indeed bad,
>> I'm unconvinced this is the correct change. As we have already gone through
>> a priorities and scanned everything at the high-order, would it not make
>> more sense to do just give up with something like the following?
>>
>>       /*
>>        * If zones are still not balanced, loop again and continue attempting
>>        * to rebalance the system. For high-order allocations, fragmentation
>>        * can prevent the zones being rebalanced no matter how hard kswapd
>>        * works, particularly on systems with little or no swap. For costly
>>        * orders, just give up and assume interested processes will either
>>        * direct reclaim or wake up kswapd as necessary.
>>        */
>>        if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
>>                cond_resched();
>>
>>                try_to_freeze();
>>
>>                goto loop_again;
>>        }
>>
>> I used PAGE_ALLOC_COSTLY_ORDER instead of sc.order == 0 because we are
>> expected to support allocations up to that order in a fairly reliable fashion.
>
> my comment is bellow.
>
>
>> =============
>> From: Mel Gorman <mel@csn.ul.ie>
>> Subject: [PATCH] mm: stop kswapd's infinite loop at high order allocation
>>
>>  kswapd runs in some infinite loop trying to swap until order 10 of zone
>>  highmem is OK.... kswapd will continue to try to balance order 10 of zone
>>  highmem forever (or until someone release a very large chunk of highmem).
>>
>> For costly high-order allocations, the system may never be balanced due to
>> fragmentation but kswapd should not infinitely loop as a result. The
>> following patch lets kswapd stop reclaiming in the event it cannot
>> balance zones and the order is high-order.
>>
>> Reported-by: wassim dagash <wassim.dagash@gmail.com>
>> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 62e7f62..03ed9a0 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1867,7 +1867,16 @@ out:
>>
>>                zone->prev_priority = temp_priority[i];
>>        }
>> -       if (!all_zones_ok) {
>> +
>> +       /*
>> +        * If zones are still not balanced, loop again and continue attempting
>> +        * to rebalance the system. For high-order allocations, fragmentation
>> +        * can prevent the zones being rebalanced no matter how hard kswapd
>> +        * works, particularly on systems with little or no swap. For costly
>> +        * orders, just give up and assume interested processes will either
>> +        * direct reclaim or wake up kswapd as necessary.
>> +        */
>> +       if (!all_zones_ok && sc.order <= PAGE_ALLOC_COSTLY_ORDER) {
>>                cond_resched();
>>
>>                try_to_freeze();
>
> this patch seems no good.
> kswapd come this point every SWAP_CLUSTER_MAX reclaimed because to avoid
> unnecessary priority variable decreasing.
> then "nr_reclaimed >= SWAP_CLUSTER_MAX" indicate kswapd need reclaim more.
>
> kswapd purpose is "reclaim until pages_high", not reclaim
> SWAP_CLUSTER_MAX pages.
>
> if your patch applied and kswapd start to reclaim for hugepage, kswapd
> exit balance_pgdat() function after to reclaim only 32 pages
> (SWAP_CLUSTER_MAX).
>
> In the other hand, "nr_reclaimed < SWAP_CLUSTER_MAX" mean kswapd can't
> reclaim enough
> page although priority == 0.
> in this case, retry is worthless.
>
> sorting out again.
> "goto loop_again" reaching happend by two case.
>
> 1. kswapd reclaimed SWAP_CLUSTER_MAX pages.
>    at that time, kswapd reset priority variable to prevent
> unnecessary priority decreasing.
>    I don't hope this behavior change.
> 2. kswapd scanned until priority==0.
>    this case is debatable. my patch reset any order to 0. but
> following code is also considerable to me. (sorry for tab corrupted,
> current my mail environment is very poor)
>
>
> code-A:
>       if (!all_zones_ok) {
>              if ((nr_reclaimed >= SWAP_CLUSTER_MAX) ||
>                 (sc.order <= PAGE_ALLOC_COSTLY_ORDER)) {
>                          cond_resched();
>                           try_to_freeze();
>                           goto loop_again;
>                }
>       }
>
> or
>
> code-B:
>       if (!all_zones_ok) {
>              cond_resched();
>               try_to_freeze();
>
>              if (nr_reclaimed >= SWAP_CLUSTER_MAX)
>                           goto loop_again;
>
>              if (sc.order <= PAGE_ALLOC_COSTLY_ORDER)) {
>                           order = sc.order = 0;
>                           goto loop_again;
>              }
>       }
>
>
> However, I still like my original proposal because ..
>  - code-A forget to order-1 (for stack) allocation also can cause
> infinite loop.
>  - code-B doesn't simpler than my original proposal.
>
> What do you think it?
>



-- 
too much is never enough!!!!!

------=_Part_120615_20213153.1230713998406
Content-Type: application/octet-stream; name=kswapd.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fpdr62cc0
Content-Disposition: attachment; filename=kswapd.patch

UmVwb3J0ZWQtYnk6IHdhc3NpbSBkYWdhc2ggPHdhc3NpbS5kYWdhc2hAZ21haWwuY29tPgpTaWdu
ZWQtb2ZmLWJ5OiB3YXNzaW0gZGFnYXNoIDx3YXNzaW0uZGFnYXNoQGdtYWlsLmNvbT4KCmRpZmYg
LU51YXIgbGludXgtMi42LjI4Lm9yaWcvaW5jbHVkZS9saW51eC9tbXpvbmUuaCBsaW51eC0yLjYu
MjgvaW5jbHVkZS9saW51eC9tbXpvbmUuaAotLS0gbGludXgtMi42LjI4Lm9yaWcvaW5jbHVkZS9s
aW51eC9tbXpvbmUuaAkyMDA4LTEyLTI1IDEyOjIwOjEwLjAwMDAwMDAwMCArMDIwMAorKysgbGlu
dXgtMi42LjI4L2luY2x1ZGUvbGludXgvbW16b25lLmgJMjAwOC0xMi0zMSAxMDoxNjowMy4wMDAw
MDAwMDAgKzAyMDAKQEAgLTQwOSw2ICs0MDksNyBAQAogCSAqIHJhcmVseSB1c2VkIGZpZWxkczoK
IAkgKi8KIAljb25zdCBjaGFyCQkqbmFtZTsKKwl1bnNpZ25lZCBpbnQgCQlrc3dhcGRfbWF4X29y
ZGVyOwogfSBfX19fY2FjaGVsaW5lX2ludGVybm9kZWFsaWduZWRfaW5fc21wOwogCiB0eXBlZGVm
IGVudW0gewpAQCAtNjI1LDcgKzYyNiw2IEBACiAJaW50IG5vZGVfaWQ7CiAJd2FpdF9xdWV1ZV9o
ZWFkX3Qga3N3YXBkX3dhaXQ7CiAJc3RydWN0IHRhc2tfc3RydWN0ICprc3dhcGQ7Ci0JaW50IGtz
d2FwZF9tYXhfb3JkZXI7CiB9IHBnX2RhdGFfdDsKIAogI2RlZmluZSBub2RlX3ByZXNlbnRfcGFn
ZXMobmlkKQkoTk9ERV9EQVRBKG5pZCktPm5vZGVfcHJlc2VudF9wYWdlcykKQEAgLTY0Miw4ICs2
NDIsOCBAQAogdm9pZCBnZXRfem9uZV9jb3VudHModW5zaWduZWQgbG9uZyAqYWN0aXZlLCB1bnNp
Z25lZCBsb25nICppbmFjdGl2ZSwKIAkJCXVuc2lnbmVkIGxvbmcgKmZyZWUpOwogdm9pZCBidWls
ZF9hbGxfem9uZWxpc3RzKHZvaWQpOwotdm9pZCB3YWtldXBfa3N3YXBkKHN0cnVjdCB6b25lICp6
b25lLCBpbnQgb3JkZXIpOwotaW50IHpvbmVfd2F0ZXJtYXJrX29rKHN0cnVjdCB6b25lICp6LCBp
bnQgb3JkZXIsIHVuc2lnbmVkIGxvbmcgbWFyaywKK3ZvaWQgd2FrZXVwX2tzd2FwZChzdHJ1Y3Qg
em9uZSAqem9uZSk7CitpbnQgem9uZV93YXRlcm1hcmtfb2soc3RydWN0IHpvbmUgKnosIHVuc2ln
bmVkIGxvbmcgbWFyaywKIAkJaW50IGNsYXNzem9uZV9pZHgsIGludCBhbGxvY19mbGFncyk7CiBl
bnVtIG1lbW1hcF9jb250ZXh0IHsKIAlNRU1NQVBfRUFSTFksCmRpZmYgLU51YXIgbGludXgtMi42
LjI4Lm9yaWcvTWFrZWZpbGUgbGludXgtMi42LjI4L01ha2VmaWxlCi0tLSBsaW51eC0yLjYuMjgu
b3JpZy9NYWtlZmlsZQkyMDA4LTEyLTI1IDEyOjE5OjEwLjAwMDAwMDAwMCArMDIwMAorKysgbGlu
dXgtMi42LjI4L01ha2VmaWxlCTIwMDgtMTItMzEgMTA6NTE6MTguMDAwMDAwMDAwICswMjAwCkBA
IC0yLDcgKzIsNyBAQAogUEFUQ0hMRVZFTCA9IDYKIFNVQkxFVkVMID0gMjgKIEVYVFJBVkVSU0lP
TiA9Ci1OQU1FID0gRXJvdGljIFBpY2tsZWQgSGVycmluZworTkFNRSA9IGtzd2FwZF9zb2wgCiAK
ICMgKkRPQ1VNRU5UQVRJT04qCiAjIFRvIHNlZSBhIGxpc3Qgb2YgdHlwaWNhbCB0YXJnZXRzIGV4
ZWN1dGUgIm1ha2UgaGVscCIKZGlmZiAtTnVhciBsaW51eC0yLjYuMjgub3JpZy9tbS9wYWdlX2Fs
bG9jLmMgbGludXgtMi42LjI4L21tL3BhZ2VfYWxsb2MuYwotLS0gbGludXgtMi42LjI4Lm9yaWcv
bW0vcGFnZV9hbGxvYy5jCTIwMDgtMTItMjUgMTI6MjA6MTQuMDAwMDAwMDAwICswMjAwCisrKyBs
aW51eC0yLjYuMjgvbW0vcGFnZV9hbGxvYy5jCTIwMDgtMTItMzEgMTA6MjY6MzIuMDAwMDAwMDAw
ICswMjAwCkBAIC0xMjI0LDEwICsxMjI0LDExIEBACiAgKiBSZXR1cm4gMSBpZiBmcmVlIHBhZ2Vz
IGFyZSBhYm92ZSAnbWFyaycuIFRoaXMgdGFrZXMgaW50byBhY2NvdW50IHRoZSBvcmRlcgogICog
b2YgdGhlIGFsbG9jYXRpb24uCiAgKi8KLWludCB6b25lX3dhdGVybWFya19vayhzdHJ1Y3Qgem9u
ZSAqeiwgaW50IG9yZGVyLCB1bnNpZ25lZCBsb25nIG1hcmssCitpbnQgem9uZV93YXRlcm1hcmtf
b2soc3RydWN0IHpvbmUgKnosIHVuc2lnbmVkIGxvbmcgbWFyaywKIAkJICAgICAgaW50IGNsYXNz
em9uZV9pZHgsIGludCBhbGxvY19mbGFncykKIHsKIAkvKiBmcmVlX3BhZ2VzIG15IGdvIG5lZ2F0
aXZlIC0gdGhhdCdzIE9LICovCisJdW5zaWduZWQgaW50IG9yZGVyID0gei0+a3N3YXBkX21heF9v
cmRlcjsKIAlsb25nIG1pbiA9IG1hcms7CiAJbG9uZyBmcmVlX3BhZ2VzID0gem9uZV9wYWdlX3N0
YXRlKHosIE5SX0ZSRUVfUEFHRVMpIC0gKDEgPDwgb3JkZXIpICsgMTsKIAlpbnQgbzsKQEAgLTE0
MTcsNyArMTQxOCw3IEBACiAJCQkJbWFyayA9IHpvbmUtPnBhZ2VzX2xvdzsKIAkJCWVsc2UKIAkJ
CQltYXJrID0gem9uZS0+cGFnZXNfaGlnaDsKLQkJCWlmICghem9uZV93YXRlcm1hcmtfb2soem9u
ZSwgb3JkZXIsIG1hcmssCisJCQlpZiAoIXpvbmVfd2F0ZXJtYXJrX29rKHpvbmUsIG1hcmssCiAJ
CQkJICAgIGNsYXNzem9uZV9pZHgsIGFsbG9jX2ZsYWdzKSkgewogCQkJCWlmICghem9uZV9yZWNs
YWltX21vZGUgfHwKIAkJCQkgICAgIXpvbmVfcmVjbGFpbSh6b25lLCBnZnBfbWFzaywgb3JkZXIp
KQpAQCAtMTQ4NSw5ICsxNDg2LDE2IEBACiAKIAlwYWdlID0gZ2V0X3BhZ2VfZnJvbV9mcmVlbGlz
dChnZnBfbWFza3xfX0dGUF9IQVJEV0FMTCwgbm9kZW1hc2ssIG9yZGVyLAogCQkJem9uZWxpc3Qs
IGhpZ2hfem9uZWlkeCwgQUxMT0NfV01BUktfTE9XfEFMTE9DX0NQVVNFVCk7CisKIAlpZiAocGFn
ZSkKIAkJZ290byBnb3RfcGc7CiAKKyAgICAgICAgLyoKKyAgICAgICAgRmlyc3QgaXRlbSBpbiBs
aXN0IG9mIHpvbmVzIHN1aXRhYmxlIGZvciBnZnBfbWFzayBpcyB0aGUgem9uZSB0aGUgcmVxdWVz
dCBpbnRlbmRlZCB0bywKKyAgICAgICAgdGhlIG90aGVyIGl0ZW1zIGFyZSBmYWxsYmFjaworICAg
ICAgICAqLworICAgICAgICB6LT56b25lLT5rc3dhcGRfbWF4X29yZGVyID0gb3JkZXI7CisKIAkv
KgogCSAqIEdGUF9USElTTk9ERSAobWVhbmluZyBfX0dGUF9USElTTk9ERSwgX19HRlBfTk9SRVRS
WSBhbmQKIAkgKiBfX0dGUF9OT1dBUk4gc2V0KSBzaG91bGQgbm90IGNhdXNlIHJlY2xhaW0gc2lu
Y2UgdGhlIHN1YnN5c3RlbQpAQCAtMTUwMCw3ICsxNTA4LDcgQEAKIAkJZ290byBub3BhZ2U7CiAK
IAlmb3JfZWFjaF96b25lX3pvbmVsaXN0KHpvbmUsIHosIHpvbmVsaXN0LCBoaWdoX3pvbmVpZHgp
Ci0JCXdha2V1cF9rc3dhcGQoem9uZSwgb3JkZXIpOworCQl3YWtldXBfa3N3YXBkKHpvbmUpOwog
CiAJLyoKIAkgKiBPSywgd2UncmUgYmVsb3cgdGhlIGtzd2FwZCB3YXRlcm1hcmsgYW5kIGhhdmUg
a2lja2VkIGJhY2tncm91bmQKQEAgLTM0NDgsNyArMzQ1Niw2IEBACiAJcGdkYXRfcmVzaXplX2lu
aXQocGdkYXQpOwogCXBnZGF0LT5ucl96b25lcyA9IDA7CiAJaW5pdF93YWl0cXVldWVfaGVhZCgm
cGdkYXQtPmtzd2FwZF93YWl0KTsKLQlwZ2RhdC0+a3N3YXBkX21heF9vcmRlciA9IDA7CiAJcGdk
YXRfcGFnZV9jZ3JvdXBfaW5pdChwZ2RhdCk7CiAJCiAJZm9yIChqID0gMDsgaiA8IE1BWF9OUl9a
T05FUzsgaisrKSB7CkBAIC0zNDg4LDYgKzM0OTUsOCBAQAogCQkJbnJfa2VybmVsX3BhZ2VzICs9
IHJlYWxzaXplOwogCQlucl9hbGxfcGFnZXMgKz0gcmVhbHNpemU7CiAKKwkJLyogSW5pdGlhbGl6
aW5nIGtzd2FwZF9tYXhfb3JkZXIgdG8gemVybyAqLworCQl6b25lLT5rc3dhcGRfbWF4X29yZGVy
ID0gMDsKIAkJem9uZS0+c3Bhbm5lZF9wYWdlcyA9IHNpemU7CiAJCXpvbmUtPnByZXNlbnRfcGFn
ZXMgPSByZWFsc2l6ZTsKICNpZmRlZiBDT05GSUdfTlVNQQpkaWZmIC1OdWFyIGxpbnV4LTIuNi4y
OC5vcmlnL21tL3Ztc2Nhbi5jIGxpbnV4LTIuNi4yOC9tbS92bXNjYW4uYwotLS0gbGludXgtMi42
LjI4Lm9yaWcvbW0vdm1zY2FuLmMJMjAwOC0xMi0yNSAxMjoyMDoxNC4wMDAwMDAwMDAgKzAyMDAK
KysrIGxpbnV4LTIuNi4yOC9tbS92bXNjYW4uYwkyMDA4LTEyLTMxIDEwOjI5OjI3LjAwMDAwMDAw
MCArMDIwMApAQCAtMTc3MCw3ICsxNzcwLDcgQEAKIAkJCQlzaHJpbmtfYWN0aXZlX2xpc3QoU1dB
UF9DTFVTVEVSX01BWCwgem9uZSwKIAkJCQkJCQkmc2MsIHByaW9yaXR5LCAwKTsKIAotCQkJaWYg
KCF6b25lX3dhdGVybWFya19vayh6b25lLCBvcmRlciwgem9uZS0+cGFnZXNfaGlnaCwKKwkJCWlm
ICghem9uZV93YXRlcm1hcmtfb2soem9uZSwgem9uZS0+cGFnZXNfaGlnaCwKIAkJCQkJICAgICAg
IDAsIDApKSB7CiAJCQkJZW5kX3pvbmUgPSBpOwogCQkJCWJyZWFrOwpAQCAtMTgwNSw3ICsxODA1
LDcgQEAKIAkJCQkJcHJpb3JpdHkgIT0gREVGX1BSSU9SSVRZKQogCQkJCWNvbnRpbnVlOwogCi0J
CQlpZiAoIXpvbmVfd2F0ZXJtYXJrX29rKHpvbmUsIG9yZGVyLCB6b25lLT5wYWdlc19oaWdoLAor
CQkJaWYgKCF6b25lX3dhdGVybWFya19vayh6b25lLCB6b25lLT5wYWdlc19oaWdoLAogCQkJCQkg
ICAgICAgZW5kX3pvbmUsIDApKQogCQkJCWFsbF96b25lc19vayA9IDA7CiAJCQl0ZW1wX3ByaW9y
aXR5W2ldID0gcHJpb3JpdHk7CkBAIC0xODE1LDcgKzE4MTUsNyBAQAogCQkJICogV2UgcHV0IGVx
dWFsIHByZXNzdXJlIG9uIGV2ZXJ5IHpvbmUsIHVubGVzcyBvbmUKIAkJCSAqIHpvbmUgaGFzIHdh
eSB0b28gbWFueSBwYWdlcyBmcmVlIGFscmVhZHkuCiAJCQkgKi8KLQkJCWlmICghem9uZV93YXRl
cm1hcmtfb2soem9uZSwgb3JkZXIsIDgqem9uZS0+cGFnZXNfaGlnaCwKKwkJCWlmICghem9uZV93
YXRlcm1hcmtfb2soem9uZSwgOCp6b25lLT5wYWdlc19oaWdoLAogCQkJCQkJZW5kX3pvbmUsIDAp
KQogCQkJCW5yX3JlY2xhaW1lZCArPSBzaHJpbmtfem9uZShwcmlvcml0eSwgem9uZSwgJnNjKTsK
IAkJCXJlY2xhaW1fc3RhdGUtPnJlY2xhaW1lZF9zbGFiID0gMDsKQEAgLTE5MjQsMjIgKzE5MjQs
MzAgQEAKIAlvcmRlciA9IDA7CiAJZm9yICggOyA7ICkgewogCQl1bnNpZ25lZCBsb25nIG5ld19v
cmRlcjsKLQorCQlpbnQgaSxtYXhfb3JkZXI7CiAJCXByZXBhcmVfdG9fd2FpdCgmcGdkYXQtPmtz
d2FwZF93YWl0LCAmd2FpdCwgVEFTS19JTlRFUlJVUFRJQkxFKTsKLQkJbmV3X29yZGVyID0gcGdk
YXQtPmtzd2FwZF9tYXhfb3JkZXI7Ci0JCXBnZGF0LT5rc3dhcGRfbWF4X29yZGVyID0gMDsKLQkJ
aWYgKG9yZGVyIDwgbmV3X29yZGVyKSB7Ci0JCQkvKgotCQkJICogRG9uJ3Qgc2xlZXAgaWYgc29t
ZW9uZSB3YW50cyBhIGxhcmdlciAnb3JkZXInCi0JCQkgKiBhbGxvY2F0aW9uCi0JCQkgKi8KLQkJ
CW9yZGVyID0gbmV3X29yZGVyOwotCQl9IGVsc2UgewotCQkJaWYgKCFmcmVlemluZyhjdXJyZW50
KSkKLQkJCQlzY2hlZHVsZSgpOwogCi0JCQlvcmRlciA9IHBnZGF0LT5rc3dhcGRfbWF4X29yZGVy
OworCQltYXhfb3JkZXIgPSAwOworCQlmb3IgKGkgPSBwZ2RhdC0+bnJfem9uZXMgLSAxOyBpID49
IDA7IGktLSkgCisJCXsKKwkJCXN0cnVjdCB6b25lICp6b25lID0gcGdkYXQtPm5vZGVfem9uZXMg
KyBpOworCQkJbmV3X29yZGVyID0gem9uZS0+a3N3YXBkX21heF9vcmRlcjsKKwkJCXpvbmUtPmtz
d2FwZF9tYXhfb3JkZXIgPSAwOworCQkJaWYgKG1heF9vcmRlciA8IG5ld19vcmRlcil7CisJCQkJ
bWF4X29yZGVyID0gbmV3X29yZGVyOworCQkJfQorICAgICAgICAgICAgICAgIH0KKworCQlpZihv
cmRlciA8IG1heF9vcmRlcikKKwkJeworCQkJb3JkZXIgPSBtYXhfb3JkZXI7CiAJCX0KKwkJZWxz
ZQorCQl7CQorCQkJaWYgKCFmcmVlemluZyhjdXJyZW50KSkKKyAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgIHNjaGVkdWxlKCk7CisJCX0KKwogCQlmaW5pc2hfd2FpdCgmcGdkYXQtPmtzd2Fw
ZF93YWl0LCAmd2FpdCk7CiAKIAkJaWYgKCF0cnlfdG9fZnJlZXplKCkpIHsKQEAgLTE5NTUsNyAr
MTk2Myw3IEBACiAvKgogICogQSB6b25lIGlzIGxvdyBvbiBmcmVlIG1lbW9yeSwgc28gd2FrZSBp
dHMga3N3YXBkIHRhc2sgdG8gc2VydmljZSBpdC4KICAqLwotdm9pZCB3YWtldXBfa3N3YXBkKHN0
cnVjdCB6b25lICp6b25lLCBpbnQgb3JkZXIpCit2b2lkIHdha2V1cF9rc3dhcGQoc3RydWN0IHpv
bmUgKnpvbmUpCiB7CiAJcGdfZGF0YV90ICpwZ2RhdDsKIApAQCAtMTk2MywxMCArMTk3MSw4IEBA
CiAJCXJldHVybjsKIAogCXBnZGF0ID0gem9uZS0+em9uZV9wZ2RhdDsKLQlpZiAoem9uZV93YXRl
cm1hcmtfb2soem9uZSwgb3JkZXIsIHpvbmUtPnBhZ2VzX2xvdywgMCwgMCkpCisJaWYgKHpvbmVf
d2F0ZXJtYXJrX29rKHpvbmUsIHpvbmUtPnBhZ2VzX2xvdywgMCwgMCkpCiAJCXJldHVybjsKLQlp
ZiAocGdkYXQtPmtzd2FwZF9tYXhfb3JkZXIgPCBvcmRlcikKLQkJcGdkYXQtPmtzd2FwZF9tYXhf
b3JkZXIgPSBvcmRlcjsKIAlpZiAoIWNwdXNldF96b25lX2FsbG93ZWRfaGFyZHdhbGwoem9uZSwg
R0ZQX0tFUk5FTCkpCiAJCXJldHVybjsKIAlpZiAoIXdhaXRxdWV1ZV9hY3RpdmUoJnBnZGF0LT5r
c3dhcGRfd2FpdCkpCg==
------=_Part_120615_20213153.1230713998406--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
