Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DC06C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:34:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1E6E208C3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:34:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E6E208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B6036B027E; Tue, 28 May 2019 08:34:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6679E6B027F; Tue, 28 May 2019 08:34:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 556D96B0281; Tue, 28 May 2019 08:34:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 045CB6B027E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:34:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t58so32827646edb.22
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:34:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version;
        bh=ndx0BALlOoYJJe1XXJ//WqMGeZ+sIARNuE3kDQQb8es=;
        b=mU/qrILz8xlF+S79prCCjbmA1c2Ll6cthCTRprF2WBO8kHlPFLAXEfikYDQ01hTZi6
         nX4iZ0DUem9Hz7gvUcU5jyz/V0mdTv1Moeq6mU7KwzJJOwhwLuE6jaogf7hJtRGBNP55
         L4gMT9QBEQ3QfGv5cCi1go3CU5ZOA6ArUDUE8yXKtWGxfqyXxESKCucNCPSNHWf9rqJm
         IetrlOBHZa8HVozBUN1p7OFYs6mlthMmIvO4BxGfCwuCS+WMennuOJVMkY85ihxk4Y57
         gl9AUvagM/CSYxt8+0H7xmLVCDzUHCEHKTYwdRYQiH4zEE7WozuVTr31qf9SdWWrG2bO
         6u3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Gm-Message-State: APjAAAUWaAXFz/cUTe6fZbceY+EXFyibwh493y9XPbxlEMhxtovWOpJa
	pQFfPG23n5urTQjcpRtg7HvC0+CQ+TaqEQFDQV6XnDMCZ8ZSdQb8Vtw57z2gs+X4eZZ1k/oTdoF
	iPKZP4GpAWnP+NmGe1akN7N4mdg0leajbKS5Cd4vDVW99oiVh8tIMMQiZDThKgxX6fw==
X-Received: by 2002:a17:906:5a42:: with SMTP id l2mr9196482ejs.47.1559046891580;
        Tue, 28 May 2019 05:34:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVyKYjsgNtoJ/dN67cBpmyzTHLKfjzLHAghBS7nw8F648K7v4jKzcMSSvMBnKUdLCeKlCq
X-Received: by 2002:a17:906:5a42:: with SMTP id l2mr9196434ejs.47.1559046890756;
        Tue, 28 May 2019 05:34:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559046890; cv=none;
        d=google.com; s=arc-20160816;
        b=X2n/xJszqUd8ioEDlAeo0kmO8JC2EC1dzKsI6YSQJaA64uvuc7F91Nfn6IEsDo0K39
         /Xy5YwanscgNXa/CDnNhdndHbPuJz8u9t67YJ9eqb+iWpfzXpxyX6vUDZhw7yAw/D84Z
         LkG+miVHtTl//NBHqiKFgxcvtAWy9rb5YmRsNJ+QrwnNurxVGn8nL1jTPH+ynB6vcLUd
         wYDqM7JNIzDTlcFdNJynRJUhCH8xz5EOXdx7gM+8fuCYvYb6puQ5/l48hBFdNn/LIj/K
         GTgXZXqC/MKubc5PK6FiuA8LeldHdTC+el45KEbCkbMq/hDgG9xbjTHpbRqxJ/RLU2jJ
         t+/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=ndx0BALlOoYJJe1XXJ//WqMGeZ+sIARNuE3kDQQb8es=;
        b=kXy6Yf7hT+rUYCc4YV6eQV6MtWoykNvjWB30pIMmt6ViXJI2dg+QailQ5hyZRFqMDr
         DE82ylhl2QJPdHqxkzk7pKx4Mf/PPL30prppyYxBD8XZgMvfiR1MknPWcx4YEKC2dHgb
         DDnRIw7gF14lJIEpRWk9wAR56RBxNViracnIIgcgv8U1j3DsIUUIAyK66Rj9Y504ryFi
         YP3Pp+SP7fAVz3LXn+tFZVSMVy/uDEPkCyPihyqJUWemNKOMEtFoW6vScE+ppRPHfL3/
         gvcz7yOJXp5JFa1F0S81Ysvrgfq8XdxPL88sBkxCk8+Op4yljqDqemfZDrvaW/VfgaNI
         9YcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o18si1300753ejn.301.2019.05.28.05.34.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:34:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0881DAE86;
	Tue, 28 May 2019 12:34:50 +0000 (UTC)
Message-ID: <1559046886.13873.2.camel@suse.com>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
From: Oliver Neukum <oneukum@suse.com>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Jaewon Kim <jaewon31.kim@gmail.com>, Christoph Hellwig
 <hch@infradead.org>,  linux-mm@kvack.org, gregkh@linuxfoundation.org,
 Jaewon Kim <jaewon31.kim@samsung.com>, m.szyprowski@samsung.com,
 ytk.lee@samsung.com,  linux-kernel@vger.kernel.org,
 linux-usb@vger.kernel.org
Date: Tue, 28 May 2019 14:34:46 +0200
In-Reply-To: <Pine.LNX.4.44L0.1905231001100.1553-100000@iolanthe.rowland.org>
References: <Pine.LNX.4.44L0.1905231001100.1553-100000@iolanthe.rowland.org>
Content-Type: multipart/mixed; boundary="=-I2kQBv2Gth4pqYzgYdi+"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-I2kQBv2Gth4pqYzgYdi+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Am Donnerstag, den 23.05.2019, 10:01 -0400 schrieb Alan Stern:
> On Wed, 22 May 2019, Oliver Neukum wrote:
> 
> > On Mi, 2019-05-22 at 10:56 -0400, Alan Stern wrote:
> > > On Wed, 22 May 2019, Oliver Neukum wrote:
> > > 
> > > > I agree with the problem, but I fail to see why this issue would be
> > > > specific to USB. Shouldn't this be done in the device core layer?
> > > 
> > > Only for drivers that are on the block-device writeback path.  The 
> > > device core doesn't know which drivers these are.
> > 
> > Neither does USB know. It is very hard to predict or even tell which
> > devices are block device drivers. I think we must assume that
> > any device may be affected.
> 
> All right.  Would you like to submit a patch?

Do you like this one?

	Regards
		Oliver

--=-I2kQBv2Gth4pqYzgYdi+
Content-Disposition: attachment;
	filename="0001-base-force-NOIO-allocations-during-unplug.patch"
Content-Transfer-Encoding: base64
Content-Type: text/x-patch; name="0001-base-force-NOIO-allocations-during-unplug.patch";
	charset="UTF-8"

RnJvbSAwZGM5YzdkZmU5OTRmYzljMjhhNjNiYTI4M2U0NDQyYzIzN2Y2OTg5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBPbGl2ZXIgTmV1a3VtIDxvbmV1a3VtQHN1c2UuY29tPgpEYXRl
OiBUdWUsIDI4IE1heSAyMDE5IDExOjQzOjAyICswMjAwClN1YmplY3Q6IFtQQVRDSF0gYmFzZTog
Zm9yY2UgTk9JTyBhbGxvY2F0aW9ucyBkdXJpbmcgdW5wbHVnCgpUaGVyZSBpcyBvbmUgb3Zlcmxv
b2tlZCBzaXR1YXRpb24gdW5kZXIgd2hpY2ggYSBkcml2ZXIKbXVzdCBub3QgZG8gSU8gdG8gYWxs
b2NhdGUgbWVtb3J5LiBZb3UgY2Fubm90IGRvIHRoYXQKd2hpbGUgZGlzY29ubmVjdGluZyBhIGRl
dmljZS4gQSBkZXZpY2UgYmVpbmcgZGlzY29ubmVjdGVkCmlzIG5vIGxvbmdlciBmdW5jdGlvbmFs
IGluIG1vc3QgY2FzZXMsIHlldCBJTyBtYXkgZmFpbApvbmx5IHdoZW4gdGhlIGhhbmRsZXIgcnVu
cy4KClNpZ25lZC1vZmYtYnk6IE9saXZlciBOZXVrdW0gPG9uZXVrdW1Ac3VzZS5jb20+Ci0tLQog
ZHJpdmVycy9iYXNlL2NvcmUuYyB8IDQgKysrKwogMSBmaWxlIGNoYW5nZWQsIDQgaW5zZXJ0aW9u
cygrKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvYmFzZS9jb3JlLmMgYi9kcml2ZXJzL2Jhc2UvY29y
ZS5jCmluZGV4IGZkNzUxMWUwNGU2Mi4uYTdmNWY0NWJkNzYxIDEwMDY0NAotLS0gYS9kcml2ZXJz
L2Jhc2UvY29yZS5jCisrKyBiL2RyaXZlcnMvYmFzZS9jb3JlLmMKQEAgLTIyMjksNiArMjIyOSw3
IEBAIHZvaWQgZGV2aWNlX2RlbChzdHJ1Y3QgZGV2aWNlICpkZXYpCiAJc3RydWN0IGRldmljZSAq
cGFyZW50ID0gZGV2LT5wYXJlbnQ7CiAJc3RydWN0IGtvYmplY3QgKmdsdWVfZGlyID0gTlVMTDsK
IAlzdHJ1Y3QgY2xhc3NfaW50ZXJmYWNlICpjbGFzc19pbnRmOworCXVuc2lnbmVkIGludCBub2lv
X2ZsYWc7CiAKIAkvKgogCSAqIEhvbGQgdGhlIGRldmljZSBsb2NrIGFuZCBzZXQgdGhlICJkZWFk
IiBmbGFnIHRvIGd1YXJhbnRlZSB0aGF0CkBAIC0yMjU2LDYgKzIyNTcsNyBAQCB2b2lkIGRldmlj
ZV9kZWwoc3RydWN0IGRldmljZSAqZGV2KQogCQlkZXZpY2VfcmVtb3ZlX3N5c19kZXZfZW50cnko
ZGV2KTsKIAkJZGV2aWNlX3JlbW92ZV9maWxlKGRldiwgJmRldl9hdHRyX2Rldik7CiAJfQorCW5v
aW9fZmxhZyA9IG1lbWFsbG9jX25vaW9fc2F2ZSgpOwogCWlmIChkZXYtPmNsYXNzKSB7CiAJCWRl
dmljZV9yZW1vdmVfY2xhc3Nfc3ltbGlua3MoZGV2KTsKIApAQCAtMjI3Nyw2ICsyMjc5LDggQEAg
dm9pZCBkZXZpY2VfZGVsKHN0cnVjdCBkZXZpY2UgKmRldikKIAlkZXZpY2VfcGxhdGZvcm1fbm90
aWZ5KGRldiwgS09CSl9SRU1PVkUpOwogCWRldmljZV9yZW1vdmVfcHJvcGVydGllcyhkZXYpOwog
CWRldmljZV9saW5rc19wdXJnZShkZXYpOworCW1lbWFsbG9jX25vaW9fcmVzdG9yZShub2lvX2Zs
YWcpOworCiAKIAlpZiAoZGV2LT5idXMpCiAJCWJsb2NraW5nX25vdGlmaWVyX2NhbGxfY2hhaW4o
JmRldi0+YnVzLT5wLT5idXNfbm90aWZpZXIsCi0tIAoyLjE2LjQKCg==


--=-I2kQBv2Gth4pqYzgYdi+--

