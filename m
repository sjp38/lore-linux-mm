Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 262106B025E
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 20:13:38 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g22so107140002ioj.1
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 17:13:38 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id h73si24922544oib.43.2016.09.16.17.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 17:06:16 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id r126so130167763oib.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 17:06:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cone.1474065027.299244.29242.1004@monster.email-scan.com>
References: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com>
 <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com>
 <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com> <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
 <cone.1474065027.299244.29242.1004@monster.email-scan.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 Sep 2016 16:58:52 -0700
Message-ID: <CA+55aFwPNBQePQCQ7qRmvn-nVaEn2YVsXnBFc5y1UVWExifBHw@mail.gmail.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
Content-Type: multipart/mixed; boundary=001a11c1619e8f5368053ca8bea9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Varshavchik <mrsam@courier-mta.com>, Ingo Molnar <mingo@kernel.org>, Joe Perches <joe@perches.com>
Cc: Laura Abbott <labbott@redhat.com>, Brent <fix@bitrealm.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a11c1619e8f5368053ca8bea9
Content-Type: text/plain; charset=UTF-8

On Fri, Sep 16, 2016 at 3:30 PM, Sam Varshavchik <mrsam@courier-mta.com> wrote:
>>
>> Sam, do you end up seeing the kernel warning in your logs if you just
>> go back earlier in the boot?
>
> Yes, I found it.
>
> Sep 10 07:36:29 shorty kernel: mmap: named (1108): VmData 52588544 exceed
> data ulimit 20971520. Update limits or use boot option ignore_rlimit_data.
>
> Now that I know what to search for: this appeared about 300 lines earlier in
> /var/log/messages.

Ok, so that's a pretty strong argument that we shouldn't just warn once.

Maybe the warning happened at bootup, and it is now three months
later, and somebody notices that something doesn't work. It might not
be *critical* (three months without working implies it isn't), but it
sure is silly for the kernel to say "yeah, I already warned you, I'm
not going to tell you why it's not working any more".

So it sounds like if the kernel had just had a that warning be
rate-limited instead of happening only once, there would never have
been any confusion about the RLIMIT_DATA change.

Doing a grep for "pr_warn_once()", I get the feeling that we could
just change the definition of "once" to be "at most once per minute"
and everybody would be happy.

Maybe we could change all the "pr_xyz_once()" to consider "once" to be
a softer "at most once per minute" thing. After all, these things are
*supposed* to be very uncommon to begin with, but when they do happen
we do want the user to be aware of them.

Here's a totally untested patch. What do people say?

                 Linus

--001a11c1619e8f5368053ca8bea9
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_it6fer5g0

IGluY2x1ZGUvbGludXgvcHJpbnRrLmggfCAzOCArKysrKysrKysrKysrKystLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDE1IGluc2VydGlvbnMoKyksIDIzIGRlbGV0aW9u
cygtKQoKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvcHJpbnRrLmggYi9pbmNsdWRlL2xpbnV4
L3ByaW50ay5oCmluZGV4IDY5NmE1NmJlN2QzZS4uYWU5OGMzODhhMzc3IDEwMDY0NAotLS0gYS9p
bmNsdWRlL2xpbnV4L3ByaW50ay5oCisrKyBiL2luY2x1ZGUvbGludXgvcHJpbnRrLmgKQEAgLTMx
NiwzMSArMzE2LDIzIEBAIGV4dGVybiBhc21saW5rYWdlIHZvaWQgZHVtcF9zdGFjayh2b2lkKSBf
X2NvbGQ7CiAKIC8qCiAgKiBQcmludCBhIG9uZS10aW1lIG1lc3NhZ2UgKGFuYWxvZ291cyB0byBX
QVJOX09OQ0UoKSBldCBhbCk6CisgKgorICogIm9uY2UiIGhlcmUgaXMgYSBtaXNub21lci4gSXQn
cyBzaG9ydGhhbmQgZm9yICJhdCBtb3N0IG9uY2UgYSBtaW51dGUiLgogICovCi0KICNpZmRlZiBD
T05GSUdfUFJJTlRLCi0jZGVmaW5lIHByaW50a19vbmNlKGZtdCwgLi4uKQkJCQkJXAotKHsJCQkJ
CQkJCVwKLQlzdGF0aWMgYm9vbCBfX3ByaW50X29uY2UgX19yZWFkX21vc3RseTsJCQlcCi0JYm9v
bCBfX3JldF9wcmludF9vbmNlID0gIV9fcHJpbnRfb25jZTsJCQlcCi0JCQkJCQkJCVwKLQlpZiAo
IV9fcHJpbnRfb25jZSkgewkJCQkJXAotCQlfX3ByaW50X29uY2UgPSB0cnVlOwkJCQlcCi0JCXBy
aW50ayhmbXQsICMjX19WQV9BUkdTX18pOwkJCVwKLQl9CQkJCQkJCVwKLQl1bmxpa2VseShfX3Jl
dF9wcmludF9vbmNlKTsJCQkJXAotfSkKLSNkZWZpbmUgcHJpbnRrX2RlZmVycmVkX29uY2UoZm10
LCAuLi4pCQkJCVwKLSh7CQkJCQkJCQlcCi0Jc3RhdGljIGJvb2wgX19wcmludF9vbmNlIF9fcmVh
ZF9tb3N0bHk7CQkJXAotCWJvb2wgX19yZXRfcHJpbnRfb25jZSA9ICFfX3ByaW50X29uY2U7CQkJ
XAotCQkJCQkJCQlcCi0JaWYgKCFfX3ByaW50X29uY2UpIHsJCQkJCVwKLQkJX19wcmludF9vbmNl
ID0gdHJ1ZTsJCQkJXAotCQlwcmludGtfZGVmZXJyZWQoZm10LCAjI19fVkFfQVJHU19fKTsJCVwK
LQl9CQkJCQkJCVwKLQl1bmxpa2VseShfX3JldF9wcmludF9vbmNlKTsJCQkJXAotfSkKKworI2Rl
ZmluZSBkb19qdXN0X29uY2Uoc3RtdCkJKHsJCQlcCisJc3RhdGljIERFRklORV9SQVRFTElNSVRf
U1RBVEUoX3JzLCBIWio2MCwgMSk7CVwKKwlib29sIF9fZG9faXQgPSBfX3JhdGVsaW1pdCgmX3Jz
KTsJCVwKKwlpZiAodW5saWtlbHkoX19kb19pdCkpCQkJCVwKKwkJc3RtdDsJCQkJCVwKKwl1bmxp
a2VseShfX2RvX2l0KTsgfSkKKworI2RlZmluZSBwcmludGtfb25jZShmbXQsIC4uLikgXAorCWRv
X2p1c3Rfb25jZShwcmludGsoZm10LCAjI19fVkFfQVJHU19fKSkKKyNkZWZpbmUgcHJpbnRrX2Rl
ZmVycmVkX29uY2UoZm10LCAuLi4pIFwKKwlkb19qdXN0X29uY2UocHJpbnRrX2RlZmVycmVkKGZt
dCwgIyNfX1ZBX0FSR1NfXykpCisKICNlbHNlCiAjZGVmaW5lIHByaW50a19vbmNlKGZtdCwgLi4u
KQkJCQkJXAogCW5vX3ByaW50ayhmbXQsICMjX19WQV9BUkdTX18pCg==
--001a11c1619e8f5368053ca8bea9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
