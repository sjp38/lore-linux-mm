Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 744FD6B0032
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 22:31:02 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so6334547pad.24
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 19:31:02 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id i8si66387pdm.106.2014.12.11.19.30.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Dec 2014 19:31:01 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 12 Dec 2014 11:30:53 +0800
Subject: [RFC] discard task stack pages instead of pageout into swap
 partition
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B31408@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
	<CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
	<35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
	<20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
	<35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
	<20141208114601.GA28846@node.dhcp.inet.fi>
	<35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
 <CALYGNiMEytHuND37f+hNdMKqCPzN0k_uha6CaeL_fyzrj-obNQ@mail.gmail.com>
In-Reply-To: <CALYGNiMEytHuND37f+hNdMKqCPzN0k_uha6CaeL_fyzrj-obNQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Konstantin Khlebnikov' <koct9i@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>

SGksDQoNCkkgYW0gdGhpbmsgb2YgZGlzY2FyZCBzdGFjayBwYWdlcyBpZiB0aGUgb2xkDQpQYWdl
IGlzIHVuZGVyIHRoZSBzdGFjayBwb2ludGVyKEFzc3VtZSBzdGFjayBncm93IGRvd24pDQpvZiB0
aGUgdGFzaywgVGhpcyBwYWdlIGRvbid0IG5lZWQgcGFnZW91dCwgd2UgY2FuIGZyZWUgaXQgZGly
ZWN0bHksDQpXaGVuIHRoZSB0YXNrIG5lZWQgaXQgYWdhaW4sIHdlIGp1c3QgdXNlIGEgemVybyBw
YWdlIHRvDQpNYXAsIGl0IGlzIHNhZmUgZm9yIHN0YWNrIC4NCg0KQnV0IEkgZG9uJ3Qga25vdyBo
b3cgdG8gaW1wbGVtZW50IGl0LA0KQW5kIGlzIHRoZXJlIHNvbWUgaXNzdWUgaWYgZG8gbGlrZSB0
aGlzID8NCg0KVGhlIGZvbGxvd2luZyBpcyBwc2V1ZG8gY29kZSB0byBleHBsYWluIG15IGlkZWFz
Lg0KQW55IGNvbW1lbnRzIGFyZSBhcHByZWNpYXRlZCAhDQpUaGFua3MNCi0tLQ0KZGlmZiAtLWdp
dCBhL21tL3Ztc2Nhbi5jIGIvbW0vdm1zY2FuLmMNCmluZGV4IGRjYjQ3MDcuLjUyZTgzMTQgMTAw
NjQ0DQotLS0gYS9tbS92bXNjYW4uYw0KKysrIGIvbW0vdm1zY2FuLmMNCkBAIC05NjIsNiArOTYy
LDEyIEBAIHN0YXRpYyB1bnNpZ25lZCBsb25nIHNocmlua19wYWdlX2xpc3Qoc3RydWN0IGxpc3Rf
aGVhZCAqcGFnZV9saXN0LA0KIAkJCTsgLyogdHJ5IHRvIHJlY2xhaW0gdGhlIHBhZ2UgYmVsb3cg
Ki8NCiAJCX0NCiANCisJCWlmIChwYWdlX3ZtX2ZsYWdzKHBhZ2UpICYgKFZNX0dST1dTVVAgfCBW
TV9HUk9XU0RPV04pICYmDQorCQkJCVBhZ2VBbm9uKHBhZ2UpICYmICFQYWdlU3dhcENhY2hlKHBh
Z2UpKSB7DQorCQkJaWYgKHBhZ2VfdGFza19pc19zbGVlcChwYWdlKSAmJiB0YXNrX3NwID4gcGFn
ZS0+aW5kZXgpIHsNCisJCQkJemFwX3BhZ2VfcmFuZ2Uodm1hLCBwYWdlLT5pbmRleCwgUEFHRV9T
SVpFKTsNCisJCQl9DQorCQl9DQogCQkvKg0KIAkJICogQW5vbnltb3VzIHByb2Nlc3MgbWVtb3J5
IGhhcyBiYWNraW5nIHN0b3JlPw0KIAkJICogVHJ5IHRvIGFsbG9jYXRlIGl0IHNvbWUgc3dhcCBz
cGFjZSBoZXJlLg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
