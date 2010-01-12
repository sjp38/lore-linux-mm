Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 10C4F6B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 18:01:49 -0500 (EST)
Received: by pwj10 with SMTP id 10so3005412pwj.6
        for <linux-mm@kvack.org>; Tue, 12 Jan 2010 15:01:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100112133556.GB7647@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
	 <20100108124851.GB6153@localhost>
	 <DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com>
	 <20100111124303.GA21408@localhost>
	 <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100112023307.GA16661@localhost>
	 <20100112113903.89163c46.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100112133556.GB7647@localhost>
Date: Tue, 12 Jan 2010 15:01:47 -0800
Message-ID: <86802c441001121501v57b61815lc4b4c6d86dc5818d@mail.gmail.com>
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel(v1)
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/mixed; boundary=00504502b223753a4a047cffa337
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

--00504502b223753a4a047cffa337
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 12, 2010 at 5:35 AM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Tue, Jan 12, 2010 at 10:39:03AM +0800, KAMEZAWA Hiroyuki wrote:
>> On Tue, 12 Jan 2010 10:33:08 +0800
>> Wu Fengguang <fengguang.wu@intel.com> wrote:
>>
>> > Sure, here it is :)
>> > ---
>> > x86: use the generic page_is_ram()
>> >
>> > The generic resource based page_is_ram() works better with memory
>> > hotplug/hotremove. So switch the x86 e820map based code to it.
>> >
>> > CC: Andi Kleen <andi@firstfloor.org>
>> > CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>>
>> Ack.
>
> Thank you.
>
>>
>> > +#ifdef CONFIG_X86
>> > + =A0 /*
>> > + =A0 =A0* A special case is the first 4Kb of memory;
>> > + =A0 =A0* This is a BIOS owned area, not kernel ram, but generally
>> > + =A0 =A0* not listed as such in the E820 table.
>> > + =A0 =A0*/
>> > + =A0 if (pfn =3D=3D 0)
>> > + =A0 =A0 =A0 =A0 =A0 return 0;
>> > +
>> > + =A0 /*
>> > + =A0 =A0* Second special case: Some BIOSen report the PC BIOS
>> > + =A0 =A0* area (640->1Mb) as ram even though it is not.
>> > + =A0 =A0*/
>> > + =A0 if (pfn >=3D (BIOS_BEGIN >> PAGE_SHIFT) &&
>> > + =A0 =A0 =A0 pfn < =A0(BIOS_END =A0 >> PAGE_SHIFT))
>> > + =A0 =A0 =A0 =A0 =A0 return 0;
>> > +#endif
>>
>> I'm glad if this part is sorted out in clean way ;)
>
> Two possible solutions are:
>
> - to exclude the above two ranges directly in e820 map;
> - to not add the above two ranges into iomem_resource.
>
> Yinghai, do you have any suggestions?
> We want to get rid of the two explicit tests from page_is_ram().

please check attached patch.

YH

--00504502b223753a4a047cffa337
Content-Type: text/x-diff; charset=US-ASCII; name="remove_bios_begin_end.patch"
Content-Disposition: attachment; filename="remove_bios_begin_end.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g4dac1ov0

W1BBVENIXSB4ODY6IHJlbW92ZSBiaW9zIGRhdGEgcmFuZ2UgZnJvbSBlODIwCgp0byBwcmVwYXJl
IG1vdmUgcGFnZV9pc19yYW0gYXMgZ2VuZXJpYyBvbmUKClNpZ25lZC1vZmYtYnk6IFlpbmdoYWkg
THUgPHlpbmdoYWlAa2VybmVsLm9yZy4KCi0tLQogYXJjaC94ODYva2VybmVsL2U4MjAuYyAgIHwg
ICAgOCArKysrKysrKwogYXJjaC94ODYva2VybmVsL2hlYWQzMi5jIHwgICAgMiAtLQogYXJjaC94
ODYva2VybmVsL2hlYWQ2NC5jIHwgICAgMiAtLQogYXJjaC94ODYva2VybmVsL3NldHVwLmMgIHwg
ICAxOSArKysrKysrKysrKysrKysrKystCiBhcmNoL3g4Ni9tbS9pb3JlbWFwLmMgICAgfCAgIDE2
IC0tLS0tLS0tLS0tLS0tLS0KIDUgZmlsZXMgY2hhbmdlZCwgMjYgaW5zZXJ0aW9ucygrKSwgMjEg
ZGVsZXRpb25zKC0pCgpJbmRleDogbGludXgtMi42L2FyY2gveDg2L2tlcm5lbC9zZXR1cC5jCj09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2FyY2gveDg2L2tlcm5lbC9zZXR1cC5jCisrKyBs
aW51eC0yLjYvYXJjaC94ODYva2VybmVsL3NldHVwLmMKQEAgLTY1Nyw2ICs2NTcsMjMgQEAgc3Rh
dGljIHN0cnVjdCBkbWlfc3lzdGVtX2lkIF9faW5pdGRhdGEgYgogCXt9CiB9OwogCitzdGF0aWMg
dm9pZCBfX2luaXQgdHJpbV9iaW9zX3JhbmdlKHZvaWQpCit7CisJLyoKKwkgKiBBIHNwZWNpYWwg
Y2FzZSBpcyB0aGUgZmlyc3QgNEtiIG9mIG1lbW9yeTsKKwkgKiBUaGlzIGlzIGEgQklPUyBvd25l
ZCBhcmVhLCBub3Qga2VybmVsIHJhbSwgYnV0IGdlbmVyYWxseQorCSAqIG5vdCBsaXN0ZWQgYXMg
c3VjaCBpbiB0aGUgRTgyMCB0YWJsZS4KKwkgKi8KKwllODIwX3VwZGF0ZV9yYW5nZSgwLCBQQUdF
X1NJWkUsIEU4MjBfUkFNLCBFODIwX1JFU0VSVkVEKTsKKwkvKgorCSAqIHNwZWNpYWwgY2FzZTog
U29tZSBCSU9TZW4gcmVwb3J0IHRoZSBQQyBCSU9TCisJICogYXJlYSAoNjQwLT4xTWIpIGFzIHJh
bSBldmVuIHRob3VnaCBpdCBpcyBub3QuCisJICogdGFrZSB0aGVtIG91dC4KKwkgKi8KKwllODIw
X3JlbW92ZV9yYW5nZShCSU9TX0JFR0lOLCBCSU9TX0VORCAtIEJJT1NfQkVHSU4sIEU4MjBfUkFN
LCAxKTsKKwlzYW5pdGl6ZV9lODIwX21hcChlODIwLm1hcCwgQVJSQVlfU0laRShlODIwLm1hcCks
ICZlODIwLm5yX21hcCk7Cit9CisKIC8qCiAgKiBEZXRlcm1pbmUgaWYgd2Ugd2VyZSBsb2FkZWQg
YnkgYW4gRUZJIGxvYWRlci4gIElmIHNvLCB0aGVuIHdlIGhhdmUgYWxzbyBiZWVuCiAgKiBwYXNz
ZWQgdGhlIGVmaSBtZW1tYXAsIHN5c3RhYiwgZXRjLiwgc28gd2Ugc2hvdWxkIHVzZSB0aGVzZSBk
YXRhIHN0cnVjdHVyZXMKQEAgLTgyMCw3ICs4MzcsNyBAQCB2b2lkIF9faW5pdCBzZXR1cF9hcmNo
KGNoYXIgKipjbWRsaW5lX3ApCiAJaW5zZXJ0X3Jlc291cmNlKCZpb21lbV9yZXNvdXJjZSwgJmRh
dGFfcmVzb3VyY2UpOwogCWluc2VydF9yZXNvdXJjZSgmaW9tZW1fcmVzb3VyY2UsICZic3NfcmVz
b3VyY2UpOwogCi0KKwl0cmltX2Jpb3NfcmFuZ2UoKTsKICNpZmRlZiBDT05GSUdfWDg2XzMyCiAJ
aWYgKHBwcm9fd2l0aF9yYW1fYnVnKCkpIHsKIAkJZTgyMF91cGRhdGVfcmFuZ2UoMHg3MDAwMDAw
MFVMTCwgMHg0MDAwMFVMTCwgRTgyMF9SQU0sCkluZGV4OiBsaW51eC0yLjYvYXJjaC94ODYva2Vy
bmVsL2U4MjAuYwo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0yLjYub3JpZy9hcmNoL3g4Ni9rZXJuZWwv
ZTgyMC5jCisrKyBsaW51eC0yLjYvYXJjaC94ODYva2VybmVsL2U4MjAuYwpAQCAtNTA5LDExICs1
MDksMTkgQEAgdTY0IF9faW5pdCBlODIwX3JlbW92ZV9yYW5nZSh1NjQgc3RhcnQsCiAJCQkgICAg
IGludCBjaGVja3R5cGUpCiB7CiAJaW50IGk7CisJdTY0IGVuZDsKIAl1NjQgcmVhbF9yZW1vdmVk
X3NpemUgPSAwOwogCiAJaWYgKHNpemUgPiAoVUxMT05HX01BWCAtIHN0YXJ0KSkKIAkJc2l6ZSA9
IFVMTE9OR19NQVggLSBzdGFydDsKIAorCWVuZCA9IHN0YXJ0ICsgc2l6ZTsKKwlwcmludGsoS0VS
Tl9ERUJVRyAiZTgyMCByZW1vdmUgcmFuZ2U6ICUwMTZMeCAtICUwMTZMeCAiLAorCQkgICAgICAg
KHVuc2lnbmVkIGxvbmcgbG9uZykgc3RhcnQsCisJCSAgICAgICAodW5zaWduZWQgbG9uZyBsb25n
KSBlbmQpOworCWU4MjBfcHJpbnRfdHlwZShvbGRfdHlwZSk7CisJcHJpbnRrKEtFUk5fQ09OVCAi
XG4iKTsKKwogCWZvciAoaSA9IDA7IGkgPCBlODIwLm5yX21hcDsgaSsrKSB7CiAJCXN0cnVjdCBl
ODIwZW50cnkgKmVpID0gJmU4MjAubWFwW2ldOwogCQl1NjQgZmluYWxfc3RhcnQsIGZpbmFsX2Vu
ZDsKSW5kZXg6IGxpbnV4LTIuNi9hcmNoL3g4Ni9tbS9pb3JlbWFwLmMKPT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQotLS0g
bGludXgtMi42Lm9yaWcvYXJjaC94ODYvbW0vaW9yZW1hcC5jCisrKyBsaW51eC0yLjYvYXJjaC94
ODYvbW0vaW9yZW1hcC5jCkBAIC0yOSwyMiArMjksNiBAQCBpbnQgcGFnZV9pc19yYW0odW5zaWdu
ZWQgbG9uZyBwYWdlbnIpCiAJcmVzb3VyY2Vfc2l6ZV90IGFkZHIsIGVuZDsKIAlpbnQgaTsKIAot
CS8qCi0JICogQSBzcGVjaWFsIGNhc2UgaXMgdGhlIGZpcnN0IDRLYiBvZiBtZW1vcnk7Ci0JICog
VGhpcyBpcyBhIEJJT1Mgb3duZWQgYXJlYSwgbm90IGtlcm5lbCByYW0sIGJ1dCBnZW5lcmFsbHkK
LQkgKiBub3QgbGlzdGVkIGFzIHN1Y2ggaW4gdGhlIEU4MjAgdGFibGUuCi0JICovCi0JaWYgKHBh
Z2VuciA9PSAwKQotCQlyZXR1cm4gMDsKLQotCS8qCi0JICogU2Vjb25kIHNwZWNpYWwgY2FzZTog
U29tZSBCSU9TZW4gcmVwb3J0IHRoZSBQQyBCSU9TCi0JICogYXJlYSAoNjQwLT4xTWIpIGFzIHJh
bSBldmVuIHRob3VnaCBpdCBpcyBub3QuCi0JICovCi0JaWYgKHBhZ2VuciA+PSAoQklPU19CRUdJ
TiA+PiBQQUdFX1NISUZUKSAmJgotCQkgICAgcGFnZW5yIDwgKEJJT1NfRU5EID4+IFBBR0VfU0hJ
RlQpKQotCQlyZXR1cm4gMDsKLQogCWZvciAoaSA9IDA7IGkgPCBlODIwLm5yX21hcDsgaSsrKSB7
CiAJCS8qCiAJCSAqIE5vdCB1c2FibGUgbWVtb3J5OgpJbmRleDogbGludXgtMi42L2FyY2gveDg2
L2tlcm5lbC9oZWFkMzIuYwo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0yLjYub3JpZy9hcmNoL3g4Ni9r
ZXJuZWwvaGVhZDMyLmMKKysrIGxpbnV4LTIuNi9hcmNoL3g4Ni9rZXJuZWwvaGVhZDMyLmMKQEAg
LTI5LDggKzI5LDYgQEAgc3RhdGljIHZvaWQgX19pbml0IGkzODZfZGVmYXVsdF9lYXJseV9zZQog
CiB2b2lkIF9faW5pdCBpMzg2X3N0YXJ0X2tlcm5lbCh2b2lkKQogewotCXJlc2VydmVfZWFybHlf
b3ZlcmxhcF9vaygwLCBQQUdFX1NJWkUsICJCSU9TIGRhdGEgcGFnZSIpOwotCiAjaWZkZWYgQ09O
RklHX1g4Nl9UUkFNUE9MSU5FCiAJLyoKIAkgKiBCdXQgZmlyc3QgcGluY2ggYSBmZXcgZm9yIHRo
ZSBzdGFjay90cmFtcG9saW5lIHN0dWZmCkluZGV4OiBsaW51eC0yLjYvYXJjaC94ODYva2VybmVs
L2hlYWQ2NC5jCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT0KLS0tIGxpbnV4LTIuNi5vcmlnL2FyY2gveDg2L2tlcm5lbC9o
ZWFkNjQuYworKysgbGludXgtMi42L2FyY2gveDg2L2tlcm5lbC9oZWFkNjQuYwpAQCAtOTgsOCAr
OTgsNiBAQCB2b2lkIF9faW5pdCB4ODZfNjRfc3RhcnRfcmVzZXJ2YXRpb25zKGNoCiB7CiAJY29w
eV9ib290ZGF0YShfX3ZhKHJlYWxfbW9kZV9kYXRhKSk7CiAKLQlyZXNlcnZlX2Vhcmx5X292ZXJs
YXBfb2soMCwgUEFHRV9TSVpFLCAiQklPUyBkYXRhIHBhZ2UiKTsKLQogCXJlc2VydmVfZWFybHko
X19wYV9zeW1ib2woJl90ZXh0KSwgX19wYV9zeW1ib2woJl9fYnNzX3N0b3ApLCAiVEVYVCBEQVRB
IEJTUyIpOwogCiAjaWZkZWYgQ09ORklHX0JMS19ERVZfSU5JVFJECg==
--00504502b223753a4a047cffa337--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
