Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx110.postini.com [74.125.246.210])
	by kanga.kvack.org (Postfix) with SMTP id 9C0BA6B00A9
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 18:17:43 -0400 (EDT)
Received: by mail-ia0-f177.google.com with SMTP id w33so2740274iag.8
        for <linux-mm@kvack.org>; Mon, 25 Mar 2013 15:17:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130325215608.GE4796@sgi.com>
References: <20130318155619.GA18828@sgi.com>
	<20130321105516.GC18484@gmail.com>
	<alpine.DEB.2.02.1303211139110.3775@chino.kir.corp.google.com>
	<20130322072532.GC10608@gmail.com>
	<20130323152948.GA3036@sgi.com>
	<CAE9FiQUjVRUs02-ymmtO+5+SgqTWK8Ae6jJwD08uRbgR=eLJgw@mail.gmail.com>
	<514FB24F.8080104@cn.fujitsu.com>
	<20130325215608.GE4796@sgi.com>
Date: Mon, 25 Mar 2013 15:17:42 -0700
Message-ID: <CAE9FiQUDM2vxVEhh5VAY808X___NBjUAozGOdEoFeVEt+dWvsg@mail.gmail.com>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/mixed; boundary=14dae93410eb79405d04d8c72cdb
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com

--14dae93410eb79405d04d8c72cdb
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Mar 25, 2013 at 2:56 PM, Russ Anderson <rja@sgi.com> wrote:
> On Mon, Mar 25, 2013 at 10:11:27AM +0800, Lin Feng wrote:
>> On 03/24/2013 04:37 AM, Yinghai Lu wrote:
>> > +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>> > +int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
>> > +                    unsigned long *start_pfn, unsigned long *end_pfn)
>> > +{
>> > +   struct memblock_type *type = &memblock.memory;
>> > +   int mid = memblock_search(type, (phys_addr_t)pfn << PAGE_SHIFT);
>>
>> I'm really eager to see how much time can we save using binary search compared to
>> linear search in this case :)
>
> I have machine time tonight to measure the difference.
>
> Based on earlier testing, a system with 9TB memory calls
> __early_pfn_to_nid() 2,377,198,300 times while booting, but
> only 6815 times does it not find that the memory range is
> the same as previous and search the table.  Caching the
> previous range avoids searching the table 2,377,191,485 times,
> saving a significant amount of time.
>
> Of the remaining 6815 times when it searches the table, a binary
> search may help, but with relatively few calls it may not
> make much of an overall difference.  Testing will show how much.

Please check attached patch that could be applied on top of your patch
in -mm.

Thanks

Yinghai

--14dae93410eb79405d04d8c72cdb
Content-Type: application/octet-stream; name="memblock_search_pfn_nid.patch"
Content-Disposition: attachment; filename="memblock_search_pfn_nid.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_heq70o6i0

LS0tCiBpbmNsdWRlL2xpbnV4L21lbWJsb2NrLmggfCAgICAyICsrCiBtbS9tZW1ibG9jay5jICAg
ICAgICAgICAgfCAgIDE4ICsrKysrKysrKysrKysrKysrKwogbW0vcGFnZV9hbGxvYy5jICAgICAg
ICAgIHwgICAxOSArKysrKysrKystLS0tLS0tLS0tCiAzIGZpbGVzIGNoYW5nZWQsIDI5IGluc2Vy
dGlvbnMoKyksIDEwIGRlbGV0aW9ucygtKQoKSW5kZXg6IGxpbnV4LTIuNi9pbmNsdWRlL2xpbnV4
L21lbWJsb2NrLmgKPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PQotLS0gbGludXgtMi42Lm9yaWcvaW5jbHVkZS9saW51eC9t
ZW1ibG9jay5oCisrKyBsaW51eC0yLjYvaW5jbHVkZS9saW51eC9tZW1ibG9jay5oCkBAIC02Myw2
ICs2Myw4IEBAIGludCBfX21lbWJsb2NrX3Jlc2VydmUocGh5c19hZGRyX3QgYmFzZSwKIHZvaWQg
bWVtYmxvY2tfdHJpbV9tZW1vcnkocGh5c19hZGRyX3QgYWxpZ24pOwogCiAjaWZkZWYgQ09ORklH
X0hBVkVfTUVNQkxPQ0tfTk9ERV9NQVAKK2ludCBtZW1ibG9ja19zZWFyY2hfcGZuX25pZCh1bnNp
Z25lZCBsb25nIHBmbiwgdW5zaWduZWQgbG9uZyAqc3RhcnRfcGZuLAorCQkJICAgIHVuc2lnbmVk
IGxvbmcgICplbmRfcGZuKTsKIHZvaWQgX19uZXh0X21lbV9wZm5fcmFuZ2UoaW50ICppZHgsIGlu
dCBuaWQsIHVuc2lnbmVkIGxvbmcgKm91dF9zdGFydF9wZm4sCiAJCQkgIHVuc2lnbmVkIGxvbmcg
Km91dF9lbmRfcGZuLCBpbnQgKm91dF9uaWQpOwogCkluZGV4OiBsaW51eC0yLjYvbW0vbWVtYmxv
Y2suYwo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0yLjYub3JpZy9tbS9tZW1ibG9jay5jCisrKyBsaW51
eC0yLjYvbW0vbWVtYmxvY2suYwpAQCAtOTU0LDYgKzk1NCwyNCBAQCBpbnQgX19pbml0X21lbWJs
b2NrIG1lbWJsb2NrX2lzX21lbW9yeShwCiAJcmV0dXJuIG1lbWJsb2NrX3NlYXJjaCgmbWVtYmxv
Y2subWVtb3J5LCBhZGRyKSAhPSAtMTsKIH0KIAorI2lmZGVmIENPTkZJR19IQVZFX01FTUJMT0NL
X05PREVfTUFQCitpbnQgX19pbml0X21lbWJsb2NrIG1lbWJsb2NrX3NlYXJjaF9wZm5fbmlkKHVu
c2lnbmVkIGxvbmcgcGZuLAorCQkJIHVuc2lnbmVkIGxvbmcgKnN0YXJ0X3BmbiwgdW5zaWduZWQg
bG9uZyAqZW5kX3BmbikKK3sKKwlzdHJ1Y3QgbWVtYmxvY2tfdHlwZSAqdHlwZSA9ICZtZW1ibG9j
ay5tZW1vcnk7CisJaW50IG1pZCA9IG1lbWJsb2NrX3NlYXJjaCh0eXBlLCAocGh5c19hZGRyX3Qp
cGZuIDw8IFBBR0VfU0hJRlQpOworCisJaWYgKG1pZCA9PSAtMSkKKwkJcmV0dXJuIC0xOworCisJ
KnN0YXJ0X3BmbiA9IHR5cGUtPnJlZ2lvbnNbbWlkXS5iYXNlID4+IFBBR0VfU0hJRlQ7CisJKmVu
ZF9wZm4gPSAodHlwZS0+cmVnaW9uc1ttaWRdLmJhc2UgKyB0eXBlLT5yZWdpb25zW21pZF0uc2l6
ZSkKKwkJCT4+IFBBR0VfU0hJRlQ7CisKKwlyZXR1cm4gdHlwZS0+cmVnaW9uc1ttaWRdLm5pZDsK
K30KKyNlbmRpZgorCiAvKioKICAqIG1lbWJsb2NrX2lzX3JlZ2lvbl9tZW1vcnkgLSBjaGVjayBp
ZiBhIHJlZ2lvbiBpcyBhIHN1YnNldCBvZiBtZW1vcnkKICAqIEBiYXNlOiBiYXNlIG9mIHJlZ2lv
biB0byBjaGVjawpJbmRleDogbGludXgtMi42L21tL3BhZ2VfYWxsb2MuYwo9PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0t
LSBsaW51eC0yLjYub3JpZy9tbS9wYWdlX2FsbG9jLmMKKysrIGxpbnV4LTIuNi9tbS9wYWdlX2Fs
bG9jLmMKQEAgLTQxNjYsNyArNDE2Niw3IEBAIGludCBfX21lbWluaXQgaW5pdF9jdXJyZW50bHlf
ZW1wdHlfem9uZSgKIGludCBfX21lbWluaXQgX19lYXJseV9wZm5fdG9fbmlkKHVuc2lnbmVkIGxv
bmcgcGZuKQogewogCXVuc2lnbmVkIGxvbmcgc3RhcnRfcGZuLCBlbmRfcGZuOwotCWludCBpLCBu
aWQ7CisJaW50IG5pZDsKIAkvKgogCSAqIE5PVEU6IFRoZSBmb2xsb3dpbmcgU01QLXVuc2FmZSBn
bG9iYWxzIGFyZSBvbmx5IHVzZWQgZWFybHkKIAkgKiBpbiBib290IHdoZW4gdGhlIGtlcm5lbCBp
cyBydW5uaW5nIHNpbmdsZS10aHJlYWRlZC4KQEAgLTQxNzcsMTUgKzQxNzcsMTQgQEAgaW50IF9f
bWVtaW5pdCBfX2Vhcmx5X3Bmbl90b19uaWQodW5zaWduZQogCWlmIChsYXN0X3N0YXJ0X3BmbiA8
PSBwZm4gJiYgcGZuIDwgbGFzdF9lbmRfcGZuKQogCQlyZXR1cm4gbGFzdF9uaWQ7CiAKLQlmb3Jf
ZWFjaF9tZW1fcGZuX3JhbmdlKGksIE1BWF9OVU1OT0RFUywgJnN0YXJ0X3BmbiwgJmVuZF9wZm4s
ICZuaWQpCi0JCWlmIChzdGFydF9wZm4gPD0gcGZuICYmIHBmbiA8IGVuZF9wZm4pIHsKLQkJCWxh
c3Rfc3RhcnRfcGZuID0gc3RhcnRfcGZuOwotCQkJbGFzdF9lbmRfcGZuID0gZW5kX3BmbjsKLQkJ
CWxhc3RfbmlkID0gbmlkOwotCQkJcmV0dXJuIG5pZDsKLQkJfQotCS8qIFRoaXMgaXMgYSBtZW1v
cnkgaG9sZSAqLwotCXJldHVybiAtMTsKKwluaWQgPSBtZW1ibG9ja19zZWFyY2hfcGZuX25pZChw
Zm4sICZzdGFydF9wZm4sICZlbmRfcGZuKTsKKwlpZiAobmlkICE9IC0xKSB7CisJCWxhc3Rfc3Rh
cnRfcGZuID0gc3RhcnRfcGZuOworCQlsYXN0X2VuZF9wZm4gPSBlbmRfcGZuOworCQlsYXN0X25p
ZCA9IG5pZDsKKwl9CisKKwlyZXR1cm4gbmlkOwogfQogI2VuZGlmIC8qIENPTkZJR19IQVZFX0FS
Q0hfRUFSTFlfUEZOX1RPX05JRCAqLwogCg==
--14dae93410eb79405d04d8c72cdb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
