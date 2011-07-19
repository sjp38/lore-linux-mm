Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8020D6B004A
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 02:20:30 -0400 (EDT)
Message-ID: <4E25221F.6060605@redhat.com>
Date: Tue, 19 Jul 2011 14:20:15 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] mm: make CONFIG_NUMA depend on CONFIG_SYSFS
References: <1310987909-3129-1-git-send-email-amwang@redhat.com> <20110718135243.GA5349@suse.de>
In-Reply-To: <20110718135243.GA5349@suse.de>
Content-Type: multipart/mixed;
 boundary="------------080008090106070507020000"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------080008090106070507020000
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

ao? 2011a1'07ae??18ae?JPY 21:52, Mel Gorman a??e??:
> On Mon, Jul 18, 2011 at 07:18:29PM +0800, Amerigo Wang wrote:
>> On ppc, we got this build error with randconfig:
>>
>> drivers/built-in.o:(.toc1+0xf90): undefined reference to `vmstat_text': 1 errors in 1 logs
>>
>> This is due to that it enabled CONFIG_NUMA but not CONFIG_SYSFS.
>>
>> And the user-space tool numactl depends on sysfs files too.
>> So, I think it is very reasonable to make CONFIG_NUMA depend on CONFIG_SYSFS.
>>
>
> That looks a bit awful. There is no obvious connection between SYSFS
> and NUMA. One is exporting information to userspace and the other is
> the memory model. Without sysfs, NUMA support might be less useful
> but the memory policies should still work and set_mempolicy() should
> still be an option.
>
> You didn't post where the buggy reference to vmstat_text but I'm
> assuming it is in drivers/base/node.c . It would be preferable that
> it be fixed to not reference vmstat_text unless either CONFIG_PROC_FS
> or CONFIG_SYSFS is defined similar to what is in mm/vmstat.c .
>

Hmm, since we don't have to enable SYSFS for NUMA, how about
make a new Kconfig for drivers/base/node.c? I.e., CONFIG_NUMA_SYSFS,
like patch below.

Thanks.

--------------080008090106070507020000
Content-Type: text/plain;
 name="numa-depends-on-sysfs.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="numa-depends-on-sysfs.diff"

SW50cm9kdWNlIGEgbmV3IEtjb25maWcgQ09ORklHX05VTUFfU1lTRlMgZm9yIGRyaXZlcnMv
YmFzZS9ub2RlLmMKd2hpY2gganVzdCBwcm92aWRlcyBzeXNmcyBpbnRlcmZhY2UsIHNvIHRo
YXQgd2hlbiB3ZSBzZWxlY3QKQ09ORklHX05VTUEsIHdlIGRvbid0IGhhdmUgdG8gZW5hYmxl
IHRoZSBzeXNmcyBpbnRlcmZhY2UgdG9vLgoKVGhpcyBieSB0aGUgd2F5IGZpeGVzIGEgcmFu
ZGNvbmZpZyBidWlsZCBlcnJvciB3aGVuIE5VTUEgJiYgIVNZU0ZTLgoKU2lnbmVkLW9mZi1i
eTogV0FORyBDb25nIDxhbXdhbmdAcmVkaGF0LmNvbT4KCi0tLQpkaWZmIC0tZ2l0IGEvZHJp
dmVycy9iYXNlL01ha2VmaWxlIGIvZHJpdmVycy9iYXNlL01ha2VmaWxlCmluZGV4IDRjNTcw
MWMuLmYzNGFiZTYgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvYmFzZS9NYWtlZmlsZQorKysgYi9k
cml2ZXJzL2Jhc2UvTWFrZWZpbGUKQEAgLTEwLDcgKzEwLDcgQEAgb2JqLSQoQ09ORklHX0hB
U19ETUEpCSs9IGRtYS1tYXBwaW5nLm8KIG9iai0kKENPTkZJR19IQVZFX0dFTkVSSUNfRE1B
X0NPSEVSRU5UKSArPSBkbWEtY29oZXJlbnQubwogb2JqLSQoQ09ORklHX0lTQSkJKz0gaXNh
Lm8KIG9iai0kKENPTkZJR19GV19MT0FERVIpCSs9IGZpcm13YXJlX2NsYXNzLm8KLW9iai0k
KENPTkZJR19OVU1BKQkrPSBub2RlLm8KK29iai0kKENPTkZJR19OVU1BX1NZU0ZTKQkrPSBu
b2RlLm8KIG9iai0kKENPTkZJR19NRU1PUllfSE9UUExVR19TUEFSU0UpICs9IG1lbW9yeS5v
CiBvYmotJChDT05GSUdfU01QKQkrPSB0b3BvbG9neS5vCiBvYmotJChDT05GSUdfSU9NTVVf
QVBJKSArPSBpb21tdS5vCmRpZmYgLS1naXQgYS9tbS9LY29uZmlnIGIvbW0vS2NvbmZpZwpp
bmRleCA4Y2E0N2E1Li5mODlhYjE5IDEwMDY0NAotLS0gYS9tbS9LY29uZmlnCisrKyBiL21t
L0tjb25maWcKQEAgLTM0MCw2ICszNDAsMTYgQEAgY2hvaWNlCiAJICBiZW5lZml0LgogZW5k
Y2hvaWNlCiAKK2NvbmZpZyBOVU1BX1NZU0ZTCisJYm9vbCAiRW5hYmxlIE5VTUEgc3lzZnMg
aW50ZXJmYWNlIGZvciB1c2VyLXNwYWNlIgorCWRlcGVuZHMgb24gTlVNQQorCWRlcGVuZHMg
b24gU1lTRlMKKwlkZWZhdWx0IHkKKwloZWxwCisJICBUaGlzIGVuYWJsZXMgTlVNQSBzeXNm
cyBpbnRlcmZhY2UsIC9zeXMvZGV2aWNlcy9zeXN0ZW0vbm9kZS8sCisJICBmb3IgdXNlci1z
cGFjZSB0b29scywgbGlrZSBudW1hY3RsLiBJZiB5b3UgaGF2ZSBlbmFibGVkIE5VTUEsCisJ
ICBwcm9iYWJseSB5b3UgYWxzbyBuZWVkIHRoaXMgb25lLgorCiAjCiAjIFVQIGFuZCBub21t
dSBhcmNocyB1c2Uga20gYmFzZWQgcGVyY3B1IGFsbG9jYXRvcgogIwo=
--------------080008090106070507020000--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
