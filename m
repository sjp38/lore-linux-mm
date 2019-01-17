Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A62C8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 13:07:08 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id v188so1361280ita.0
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:07:08 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750040.outbound.protection.outlook.com. [40.107.75.40])
        by mx.google.com with ESMTPS id l8si1256410iop.30.2019.01.17.10.07.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Jan 2019 10:07:07 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH 17/17] module: Prevent module removal racing with
 text_poke()
Date: Thu, 17 Jan 2019 18:07:03 +0000
Message-ID: <B48C6E93-AD57-4FF8-BBE8-887A5E965793@vmware.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-18-rick.p.edgecombe@intel.com>
 <20190117165422.d33d1af83db8716e24960a3c@kernel.org>
In-Reply-To: <20190117165422.d33d1af83db8716e24960a3c@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <697B667B5CAE78419D006F479D0BF3CB@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Damian Tometzki <linux_dti@icloud.com>, linux-integrity <linux-integrity@vger.kernel.org>, LSM List <linux-security-module@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "deneen.t.dock@intel.com" <deneen.t.dock@intel.com>

PiBPbiBKYW4gMTYsIDIwMTksIGF0IDExOjU0IFBNLCBNYXNhbWkgSGlyYW1hdHN1IDxtaGlyYW1h
dEBrZXJuZWwub3JnPiB3cm90ZToNCj4gDQo+IE9uIFdlZCwgMTYgSmFuIDIwMTkgMTY6MzI6NTkg
LTA4MDANCj4gUmljayBFZGdlY29tYmUgPHJpY2sucC5lZGdlY29tYmVAaW50ZWwuY29tPiB3cm90
ZToNCj4gDQo+PiBGcm9tOiBOYWRhdiBBbWl0IDxuYW1pdEB2bXdhcmUuY29tPg0KPj4gDQo+PiBJ
dCBzZWVtcyBkYW5nZXJvdXMgdG8gYWxsb3cgY29kZSBtb2RpZmljYXRpb25zIHRvIHRha2UgcGxh
Y2UNCj4+IGNvbmN1cnJlbnRseSB3aXRoIG1vZHVsZSB1bmxvYWRpbmcuIFNvIHRha2UgdGhlIHRl
eHRfbXV0ZXggd2hpbGUgdGhlDQo+PiBtZW1vcnkgb2YgdGhlIG1vZHVsZSBpcyBmcmVlZC4NCj4g
DQo+IEF0IHRoYXQgcG9pbnQsIHNpbmNlIHRoZSBtb2R1bGUgaXRzZWxmIGlzIHJlbW92ZWQgZnJv
bSBtb2R1bGUgbGlzdCwNCj4gaXQgc2VlbXMgbm8gYWN0dWFsIGhhcm0uIE9yIHdvdWxkIHlvdSBo
YXZlIGFueSBjb25jZXJuPw0KDQpTbyBpdCBhcHBlYXJzIHRoYXQgeW91IGFyZSByaWdodCBhbmQg
YWxsIHRoZSB1c2VycyBvZiB0ZXh0X3Bva2UoKSBhbmQNCnRleHRfcG9rZV9icCgpIGRvIGluc3Rh
bGwgbW9kdWxlIG5vdGlmaWVycywgYW5kIHJlbW92ZSB0aGUgbW9kdWxlIGZyb20gdGhlaXINCmlu
dGVybmFsIGRhdGEgc3RydWN0dXJlIHdoZW4gdGhleSBhcmUgZG9uZSAoKikuIEFzIGxvbmcgYXMg
dGhleSBwcmV2ZW50DQp0ZXh0X3Bva2UqKCkgdG8gYmUgY2FsbGVkIGNvbmN1cnJlbnRseSAoZS5n
LiwgdXNpbmcganVtcF9sYWJlbF9sb2NrKCkpLA0KZXZlcnl0aGluZyBpcyBmaW5lLg0KDQpIYXZp
bmcgc2FpZCB0aGF0LCB0aGUgcXVlc3Rpb24gaXMgd2hldGhlciB5b3Ug4oCcdHJ1c3TigJ0gdGV4
dF9wb2tlKigpIHVzZXJzIHRvDQpkbyBzby4gdGV4dF9wb2tlKCkgZGVzY3JpcHRpb24gZG9lcyBu
b3QgZGF5IGV4cGxpY2l0bHkgdGhhdCB5b3UgbmVlZCB0bw0KcHJldmVudCBtb2R1bGVzIGZyb20g
YmVpbmcgcmVtb3ZlZC4NCg0KV2hhdCBkbyB5b3Ugc2F5Pw0KDQoNCigqKSBJIGFtIG5vdCBzdXJl
IGFib3V0IGtnZGIsIGJ1dCBpdCBwcm9iYWJseSBkb2VzIG5vdCBtYXR0ZXIgbXVjaA==
