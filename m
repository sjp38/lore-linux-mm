Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 596FB6B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 17:40:40 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so95218575lfb.3
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 14:40:40 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id d124si5459221lfe.378.2016.09.17.14.40.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Sep 2016 14:40:38 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id l131so82709446lfl.2
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 14:40:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160917122021.GC26044@uranus.lan>
References: <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com>
 <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com> <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
 <cone.1474065027.299244.29242.1004@monster.email-scan.com>
 <CA+55aFwPNBQePQCQ7qRmvn-nVaEn2YVsXnBFc5y1UVWExifBHw@mail.gmail.com>
 <CA+55aFy-mMfj3qj6=WMawEUGEkwnFEqB_=S6Pxx3P_c58uHW2w@mail.gmail.com>
 <1474085296.32273.95.camel@perches.com> <CALYGNiNuF1Ggy=DyYG32HXbnJp3Q0cX9ekQ5w2jR1M9rkKaX9A@mail.gmail.com>
 <20160917090941.GB26044@uranus.lan> <CALYGNiNzdsnzCZXg_-2u1Tv8+RdRFJVXa6iXY+s64=+LHr2TSA@mail.gmail.com>
 <20160917122021.GC26044@uranus.lan>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sun, 18 Sep 2016 00:40:37 +0300
Message-ID: <CALYGNiN-ELbwSV0X2_FeKvGSOfRuHMsBnBDj86NHZxQKnZgVsQ@mail.gmail.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
Content-Type: multipart/mixed; boundary=001a11419434038014053cbaee1d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Joe Perches <joe@perches.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Varshavchik <mrsam@courier-mta.com>, Ingo Molnar <mingo@kernel.org>, Laura Abbott <labbott@redhat.com>, Brent <fix@bitrealm.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a11419434038014053cbaee1d
Content-Type: text/plain; charset=UTF-8

On Sat, Sep 17, 2016 at 3:20 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Sat, Sep 17, 2016 at 03:09:09PM +0300, Konstantin Khlebnikov wrote:
>> >
>> > Seems I don't understand the bottom unlikely...
>>
>> This is gcc extrension:  https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html
>> Here macro works as a function which returns bool
>
> no, no, I know for what unlikely extension stand for.
> it was just hard to obtain from without the context.
> this extension implies someone calls for
> if (printk_periodic()) right?

Yep.


Here is perfect macro for that jiffies check: time_in_range_open.

/*
 * Calculate whether a is in the range of [b, c).
 */
#define time_in_range_open(a,b,c) \
(time_after_eq(a,b) && \
time_before(a,c))

So... better version looks like

#define printk_periodic(period, fmt, ...)
({
        static unsigned long __prev __read_mostly = INITIAL_JIFFIES - (period);
        unsigned long __now = jiffies;
        bool __print = !time_in_range_open(__now, __prev, __prev + (period));

        if (__print) {
                __prev = __now;
                printk(fmt, ##__VA_ARGS__);
        }
        unlikely(__print);
})

--001a11419434038014053cbaee1d
Content-Type: application/octet-stream;
	name=printk-add-pr_warn_once_per_minute
Content-Disposition: attachment;
	filename=printk-add-pr_warn_once_per_minute
Content-Transfer-Encoding: base64
X-Attachment-Id: f_it7pq6tq0

cHJpbnRrOiBhZGQgcHJfd2Fybl9vbmNlX3Blcl9taW51dGUKCkZyb206IEtvbnN0YW50aW4gS2hs
ZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KClNpZ25lZC1vZmYtYnk6IEtvbnN0YW50aW4gS2hs
ZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KLS0tCiBpbmNsdWRlL2xpbnV4L3ByaW50ay5oIHwg
ICAxNyArKysrKysrKysrKysrKysrKwogbW0vbW1hcC5jICAgICAgICAgICAgICB8ICAgIDIgKy0K
IDIgZmlsZXMgY2hhbmdlZCwgMTggaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAt
LWdpdCBhL2luY2x1ZGUvbGludXgvcHJpbnRrLmggYi9pbmNsdWRlL2xpbnV4L3ByaW50ay5oCmlu
ZGV4IDY5NmE1NmJlN2QzZS4uMzcyOTg0YjY2NDViIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4
L3ByaW50ay5oCisrKyBiL2luY2x1ZGUvbGludXgvcHJpbnRrLmgKQEAgLTM0MSwxMSArMzQxLDI1
IEBAIGV4dGVybiBhc21saW5rYWdlIHZvaWQgZHVtcF9zdGFjayh2b2lkKSBfX2NvbGQ7CiAJfQkJ
CQkJCQlcCiAJdW5saWtlbHkoX19yZXRfcHJpbnRfb25jZSk7CQkJCVwKIH0pCisjZGVmaW5lIHBy
aW50a19wZXJpb2RpYyhwZXJpb2QsIGZtdCwgLi4uKQkJCVwKKyh7CQkJCQkJCQlcCisJc3RhdGlj
IHVuc2lnbmVkIGxvbmcgX19wcmV2IF9fcmVhZF9tb3N0bHkgPSBJTklUSUFMX0pJRkZJRVMgLSAo
cGVyaW9kKTsgXAorCXVuc2lnbmVkIGxvbmcgX19ub3cgPSBqaWZmaWVzOwkJCQlcCisJYm9vbCBf
X3ByaW50ID0gIXRpbWVfaW5fcmFuZ2Vfb3BlbihfX25vdywgX19wcmV2LCBfX3ByZXYgKyAocGVy
aW9kKSk7IFwKKwkJCQkJCQkJXAorCWlmIChfX3ByaW50KSB7CQkJCQkJXAorCQlfX3ByZXYgPSBf
X25vdzsJCQkJCVwKKwkJcHJpbnRrKGZtdCwgIyNfX1ZBX0FSR1NfXyk7CQkJXAorCX0JCQkJCQkJ
XAorCXVubGlrZWx5KF9fcHJpbnQpOwkJCQkJXAorfSkKICNlbHNlCiAjZGVmaW5lIHByaW50a19v
bmNlKGZtdCwgLi4uKQkJCQkJXAogCW5vX3ByaW50ayhmbXQsICMjX19WQV9BUkdTX18pCiAjZGVm
aW5lIHByaW50a19kZWZlcnJlZF9vbmNlKGZtdCwgLi4uKQkJCQlcCiAJbm9fcHJpbnRrKGZtdCwg
IyNfX1ZBX0FSR1NfXykKKyNkZWZpbmUgcHJpbnRrX3BlcmlvZGljKHBlcmlvZCwgZm10LCAuLi4p
CQkJXAorCW5vX3ByaW50ayhmbXQsICMjX19WQV9BUkdTX18pCiAjZW5kaWYKIAogI2RlZmluZSBw
cl9lbWVyZ19vbmNlKGZtdCwgLi4uKQkJCQkJXApAQCAtMzY1LDYgKzM3OSw5IEBAIGV4dGVybiBh
c21saW5rYWdlIHZvaWQgZHVtcF9zdGFjayh2b2lkKSBfX2NvbGQ7CiAjZGVmaW5lIHByX2NvbnRf
b25jZShmbXQsIC4uLikJCQkJCVwKIAlwcmludGtfb25jZShLRVJOX0NPTlQgcHJfZm10KGZtdCks
ICMjX19WQV9BUkdTX18pCiAKKyNkZWZpbmUgcHJfd2Fybl9vbmNlX3Blcl9taW51dGUoZm10LCAu
Li4pCQkJXAorCXByaW50a19wZXJpb2RpYyhIWiAqIDYwLCBLRVJOX1dBUk5JTkcgcHJfZm10KGZt
dCksICMjX19WQV9BUkdTX18pCisKICNpZiBkZWZpbmVkKERFQlVHKQogI2RlZmluZSBwcl9kZXZl
bF9vbmNlKGZtdCwgLi4uKQkJCQkJXAogCXByaW50a19vbmNlKEtFUk5fREVCVUcgcHJfZm10KGZt
dCksICMjX19WQV9BUkdTX18pCmRpZmYgLS1naXQgYS9tbS9tbWFwLmMgYi9tbS9tbWFwLmMKaW5k
ZXggY2E5ZDkxYmNhMGQ2Li4zNGY5ZmIyYWRjYWIgMTAwNjQ0Ci0tLSBhL21tL21tYXAuYworKysg
Yi9tbS9tbWFwLmMKQEAgLTI5MzUsNyArMjkzNSw3IEBAIGJvb2wgbWF5X2V4cGFuZF92bShzdHJ1
Y3QgbW1fc3RydWN0ICptbSwgdm1fZmxhZ3NfdCBmbGFncywgdW5zaWduZWQgbG9uZyBucGFnZXMp
CiAJCSAgICBtbS0+ZGF0YV92bSArIG5wYWdlcyA8PSBybGltaXRfbWF4KFJMSU1JVF9EQVRBKSA+
PiBQQUdFX1NISUZUKQogCQkJcmV0dXJuIHRydWU7CiAJCWlmICghaWdub3JlX3JsaW1pdF9kYXRh
KSB7Ci0JCQlwcl93YXJuX29uY2UoIiVzICglZCk6IFZtRGF0YSAlbHUgZXhjZWVkIGRhdGEgdWxp
bWl0ICVsdS4gVXBkYXRlIGxpbWl0cyBvciB1c2UgYm9vdCBvcHRpb24gaWdub3JlX3JsaW1pdF9k
YXRhLlxuIiwKKwkJCXByX3dhcm5fb25jZV9wZXJfbWludXRlKCIlcyAoJWQpOiBWbURhdGEgJWx1
IGV4Y2VlZCBkYXRhIHVsaW1pdCAlbHUuIFVwZGF0ZSBsaW1pdHMgb3IgdXNlIGJvb3Qgb3B0aW9u
IGlnbm9yZV9ybGltaXRfZGF0YS5cbiIsCiAJCQkJICAgICBjdXJyZW50LT5jb21tLCBjdXJyZW50
LT5waWQsCiAJCQkJICAgICAobW0tPmRhdGFfdm0gKyBucGFnZXMpIDw8IFBBR0VfU0hJRlQsCiAJ
CQkJICAgICBybGltaXQoUkxJTUlUX0RBVEEpKTsK
--001a11419434038014053cbaee1d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
