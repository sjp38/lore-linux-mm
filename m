Received: by ti-out-0910.google.com with SMTP id j3so1176257tid.8
        for <linux-mm@kvack.org>; Mon, 23 Jun 2008 22:49:49 -0700 (PDT)
Message-ID: <a8e1da0806232249s36eb90c7la517a40ccfe839ea@mail.gmail.com>
Date: Tue, 24 Jun 2008 13:49:48 +0800
From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: [PATCH] kernel parameter vmalloc size fix
In-Reply-To: <20080616080131.GC25632@elte.hu>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_14576_10000309.1214286588935"
References: <20080616042528.GA3003@darkstar.te-china.tietoenator.com>
	 <20080616080131.GC25632@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

------=_Part_14576_10000309.1214286588935
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Mon, Jun 16, 2008 at 4:01 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Dave Young <hidave.darkstar@gmail.com> wrote:
>
>> booting kernel with vmalloc=[any size<=16m] will oops.
>>
>> It's due to the vm area hole.
>>
>> In include/asm-x86/pgtable_32.h:
>> #define VMALLOC_OFFSET        (8 * 1024 * 1024)
>> #define VMALLOC_START (((unsigned long)high_memory + 2 * VMALLOC_OFFSET - 1) \
>>                        & ~(VMALLOC_OFFSET - 1))
>>
>> BUG_ON in arch/x86/mm/init_32.c will be triggered:
>> BUG_ON((unsigned long)high_memory             > VMALLOC_START);
>>
>> Fixed by return -EINVAL for invalid parameter
>
> hm. Why dont we instead add the size of the hole to the
> __VMALLOC_RESERVE value instead? There's nothing inherently bad about
> using vmalloc=16m. The VM area hole is really a kernel-internal
> abstraction that should not be visible in the usage of the parameter.

I do some test about this last weekend, there's some questions,  could
you help to fix it?

1. MAXMEM :
 (-__PAGE_OFFSET - __VMALLOC_RESERVE).
The space after VMALLOC_END is included as well, seting it to
(VMALLOC_END - PAGE_OFFSET - __VMALLOC_RESERVE), is it right?

2. VMALLOC_OFFSET is not considered in __VMALLOC_RESERVE
Should fixed by adding VMALLOC_OFFSET to it.

3. VMALLOC_START :
 (((unsigned long)high_memory + 2 * VMALLOC_OFFSET - 1) & ~(VMALLOC_OFFSET - 1))
So it's not always 8M, bigger than 8M possible.
Set it to ((unsigned long)high_memory + VMALLOC_OFFSET), is it right?

Attached the proposed patch. please give some advice.

Regards
dave

------=_Part_14576_10000309.1214286588935
Content-Type: application/octet-stream; name=diff.vmalloc
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fhu2uxra0
Content-Disposition: attachment; filename=diff.vmalloc

ZGlmZiAtdXByIGxpbnV4L2FyY2gveDg2L2tlcm5lbC9zZXR1cF8zMi5jIGxpbnV4Lm5ldy9hcmNo
L3g4Ni9rZXJuZWwvc2V0dXBfMzIuYwotLS0gbGludXgvYXJjaC94ODYva2VybmVsL3NldHVwXzMy
LmMJMjAwOC0wNi0yNCAxMDoxNjoxMC4wMDAwMDAwMDAgKzA4MDAKKysrIGxpbnV4Lm5ldy9hcmNo
L3g4Ni9rZXJuZWwvc2V0dXBfMzIuYwkyMDA4LTA2LTI0IDEwOjIwOjI4LjAwMDAwMDAwMCArMDgw
MApAQCAtMzEzLDcgKzMxMyw4IEBAIHN0YXRpYyBpbnQgX19pbml0IHBhcnNlX3ZtYWxsb2MoY2hh
ciAqYXIKIAlpZiAoIWFyZykKIAkJcmV0dXJuIC1FSU5WQUw7CiAKLQlfX1ZNQUxMT0NfUkVTRVJW
RSA9IG1lbXBhcnNlKGFyZywgJmFyZyk7CisJLyogQWRkIFZNQUxMT0NfT0ZGU0VUIHRvIHRoZSBw
YXJzZWQgdmFsdWUgZHVlIHRvIHZtIGFyZWEgZ3VhcmQgaG9sZSovCisJX19WTUFMTE9DX1JFU0VS
VkUgPSBtZW1wYXJzZShhcmcsICZhcmcpICsgVk1BTExPQ19PRkZTRVQ7CiAJcmV0dXJuIDA7CiB9
CiBlYXJseV9wYXJhbSgidm1hbGxvYyIsIHBhcnNlX3ZtYWxsb2MpOwpkaWZmIC11cHIgbGludXgv
aW5jbHVkZS9hc20teDg2L3BhZ2VfMzIuaCBsaW51eC5uZXcvaW5jbHVkZS9hc20teDg2L3BhZ2Vf
MzIuaAotLS0gbGludXgvaW5jbHVkZS9hc20teDg2L3BhZ2VfMzIuaAkyMDA4LTA2LTI0IDEwOjE2
OjM0LjAwMDAwMDAwMCArMDgwMAorKysgbGludXgubmV3L2luY2x1ZGUvYXNtLXg4Ni9wYWdlXzMy
LmgJMjAwOC0wNi0yNCAxMDoxNzo0OS4wMDAwMDAwMDAgKzA4MDAKQEAgLTgyLDcgKzgyLDYgQEAg
ZXh0ZXJuIHVuc2lnbmVkIGludCBfX1ZNQUxMT0NfUkVTRVJWRTsKIGV4dGVybiBpbnQgc3lzY3Rs
X2xlZ2FjeV92YV9sYXlvdXQ7CiAKICNkZWZpbmUgVk1BTExPQ19SRVNFUlZFCQkoKHVuc2lnbmVk
IGxvbmcpX19WTUFMTE9DX1JFU0VSVkUpCi0jZGVmaW5lIE1BWE1FTQkJCSgtX19QQUdFX09GRlNF
VCAtIF9fVk1BTExPQ19SRVNFUlZFKQogCiAjaWZkZWYgQ09ORklHX1g4Nl9VU0VfM0ROT1cKICNp
bmNsdWRlIDxhc20vbW14Lmg+CmRpZmYgLXVwciBsaW51eC9pbmNsdWRlL2FzbS14ODYvcGd0YWJs
ZV8zMi5oIGxpbnV4Lm5ldy9pbmNsdWRlL2FzbS14ODYvcGd0YWJsZV8zMi5oCi0tLSBsaW51eC9p
bmNsdWRlL2FzbS14ODYvcGd0YWJsZV8zMi5oCTIwMDgtMDYtMjQgMTA6MTY6NDIuMDAwMDAwMDAw
ICswODAwCisrKyBsaW51eC5uZXcvaW5jbHVkZS9hc20teDg2L3BndGFibGVfMzIuaAkyMDA4LTA2
LTI0IDExOjQ2OjM5LjAwMDAwMDAwMCArMDgwMApAQCAtNTYsOCArNTYsNyBAQCB2b2lkIHBhZ2lu
Z19pbml0KHZvaWQpOwogICogYXJlYSBmb3IgdGhlIHNhbWUgcmVhc29uLiA7KQogICovCiAjZGVm
aW5lIFZNQUxMT0NfT0ZGU0VUCSg4ICogMTAyNCAqIDEwMjQpCi0jZGVmaW5lIFZNQUxMT0NfU1RB
UlQJKCgodW5zaWduZWQgbG9uZyloaWdoX21lbW9yeSArIDIgKiBWTUFMTE9DX09GRlNFVCAtIDEp
IFwKLQkJCSAmIH4oVk1BTExPQ19PRkZTRVQgLSAxKSkKKyNkZWZpbmUgVk1BTExPQ19TVEFSVAko
KHVuc2lnbmVkIGxvbmcpaGlnaF9tZW1vcnkgKyBWTUFMTE9DX09GRlNFVCkKICNpZmRlZiBDT05G
SUdfWDg2X1BBRQogI2RlZmluZSBMQVNUX1BLTUFQIDUxMgogI2Vsc2UKQEAgLTczLDYgKzcyLDgg
QEAgdm9pZCBwYWdpbmdfaW5pdCh2b2lkKTsKICMgZGVmaW5lIFZNQUxMT0NfRU5ECShGSVhBRERS
X1NUQVJUIC0gMiAqIFBBR0VfU0laRSkKICNlbmRpZgogCisjZGVmaW5lIE1BWE1FTQkoVk1BTExP
Q19FTkQgLSBQQUdFX09GRlNFVCAtIF9fVk1BTExPQ19SRVNFUlZFKQorCiAvKgogICogRGVmaW5l
IHRoaXMgaWYgdGhpbmdzIHdvcmsgZGlmZmVyZW50bHkgb24gYW4gaTM4NiBhbmQgYW4gaTQ4NjoK
ICAqIGl0IHdpbGwgKG9uIGFuIGk0ODYpIHdhcm4gYWJvdXQga2VybmVsIG1lbW9yeSBhY2Nlc3Nl
cyB0aGF0IGFyZQo=
------=_Part_14576_10000309.1214286588935--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
