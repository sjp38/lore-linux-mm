Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 28D2F8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:18:34 -0500 (EST)
Received: from mail-yw0-f41.google.com (mail-yw0-f41.google.com [209.85.213.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1HKIPmV016402
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:18:25 -0800
Received: by ywj3 with SMTP id 3so1363683ywj.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:18:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTikUF+gz8H3SkW4NhD8SOT5b4bxnpcJgsVU+G-bC@mail.gmail.com>
References: <20110216185234.GA11636@tiehlicka.suse.cz> <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz> <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
 <1297960574.2769.20.camel@edumazet-laptop> <AANLkTikUF+gz8H3SkW4NhD8SOT5b4bxnpcJgsVU+G-bC@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Feb 2011 12:18:04 -0800
Message-ID: <AANLkTi=SHY9gF49zyoECNV3favjS8Q6-9eWnQwNKX2EM@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: multipart/mixed; boundary=90e6ba6e866882822f049c801968
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Octavian Purdila <opurdila@ixiacom.com>, David Miller <davem@davemloft.net>

--90e6ba6e866882822f049c801968
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Feb 17, 2011 at 9:07 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> [ Btw, that also shows another problem: "list_move()" doesn't trigger
> the debugging checks when it does the __list_del(). So
> CONFIG_DEBUG_LIST would never have caught the fact that the
> "list_move()" was done on a list-entry that didn't have valid list
> pointers any more. ]

Ok, so does this patch change things? IOW, if you enable
CONFIG_DEBUG_LIST, this patch should hopefully make the error case of
using "list_move()" on a stale and re-used entry trigger an error
printout.

NOTE! Even if the list is some stale entry on the stack, if nothing
has overwritten that stack entry, no amount of list debugging will
notice this. So you still need to hit the problem. But now the kernel
should print stuff out even if the page got re-allocated to something
else than a page table, so _if_ the problem is a list_move() or
similar, we don't need to hit quite the same very special case. If it
corrupts user space pages or some other random memory, it will still
complain (instead of just resulting in a SIGSEGV or whatever)

Of course, there is absolutely no guarantee that it's actually
"list_move()" at all.

And as usual, the patch is TOTALLY UNTESTED.

                                 Linus

--90e6ba6e866882822f049c801968
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gka44ntr1

IGluY2x1ZGUvbGludXgvbGlzdC5oIHwgICAxMiArKysrKysrKystLS0KIGxpYi9saXN0X2RlYnVn
LmMgICAgIHwgICAzOSArKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0KIDIg
ZmlsZXMgY2hhbmdlZCwgMzUgaW5zZXJ0aW9ucygrKSwgMTYgZGVsZXRpb25zKC0pCgpkaWZmIC0t
Z2l0IGEvaW5jbHVkZS9saW51eC9saXN0LmggYi9pbmNsdWRlL2xpbnV4L2xpc3QuaAppbmRleCA5
YTVmOGE3Li4zYTU0MjY2IDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L2xpc3QuaAorKysgYi9p
bmNsdWRlL2xpbnV4L2xpc3QuaApAQCAtOTYsNiArOTYsMTEgQEAgc3RhdGljIGlubGluZSB2b2lk
IF9fbGlzdF9kZWwoc3RydWN0IGxpc3RfaGVhZCAqIHByZXYsIHN0cnVjdCBsaXN0X2hlYWQgKiBu
ZXh0KQogICogaW4gYW4gdW5kZWZpbmVkIHN0YXRlLgogICovCiAjaWZuZGVmIENPTkZJR19ERUJV
R19MSVNUCitzdGF0aWMgaW5saW5lIHZvaWQgX19saXN0X2RlbF9lbnRyeShzdHJ1Y3QgbGlzdF9o
ZWFkICplbnRyeSkKK3sKKwlfX2xpc3RfZGVsKGVudHJ5LT5wcmV2LCBlbnRyeS0+bmV4dCk7Cit9
CisKIHN0YXRpYyBpbmxpbmUgdm9pZCBsaXN0X2RlbChzdHJ1Y3QgbGlzdF9oZWFkICplbnRyeSkK
IHsKIAlfX2xpc3RfZGVsKGVudHJ5LT5wcmV2LCBlbnRyeS0+bmV4dCk7CkBAIC0xMDMsNiArMTA4
LDcgQEAgc3RhdGljIGlubGluZSB2b2lkIGxpc3RfZGVsKHN0cnVjdCBsaXN0X2hlYWQgKmVudHJ5
KQogCWVudHJ5LT5wcmV2ID0gTElTVF9QT0lTT04yOwogfQogI2Vsc2UKK2V4dGVybiB2b2lkIF9f
bGlzdF9kZWxfZW50cnkoc3RydWN0IGxpc3RfaGVhZCAqZW50cnkpOwogZXh0ZXJuIHZvaWQgbGlz
dF9kZWwoc3RydWN0IGxpc3RfaGVhZCAqZW50cnkpOwogI2VuZGlmCiAKQEAgLTEzNSw3ICsxNDEs
NyBAQCBzdGF0aWMgaW5saW5lIHZvaWQgbGlzdF9yZXBsYWNlX2luaXQoc3RydWN0IGxpc3RfaGVh
ZCAqb2xkLAogICovCiBzdGF0aWMgaW5saW5lIHZvaWQgbGlzdF9kZWxfaW5pdChzdHJ1Y3QgbGlz
dF9oZWFkICplbnRyeSkKIHsKLQlfX2xpc3RfZGVsKGVudHJ5LT5wcmV2LCBlbnRyeS0+bmV4dCk7
CisJX19saXN0X2RlbF9lbnRyeShlbnRyeSk7CiAJSU5JVF9MSVNUX0hFQUQoZW50cnkpOwogfQog
CkBAIC0xNDYsNyArMTUyLDcgQEAgc3RhdGljIGlubGluZSB2b2lkIGxpc3RfZGVsX2luaXQoc3Ry
dWN0IGxpc3RfaGVhZCAqZW50cnkpCiAgKi8KIHN0YXRpYyBpbmxpbmUgdm9pZCBsaXN0X21vdmUo
c3RydWN0IGxpc3RfaGVhZCAqbGlzdCwgc3RydWN0IGxpc3RfaGVhZCAqaGVhZCkKIHsKLQlfX2xp
c3RfZGVsKGxpc3QtPnByZXYsIGxpc3QtPm5leHQpOworCV9fbGlzdF9kZWxfZW50cnkobGlzdCk7
CiAJbGlzdF9hZGQobGlzdCwgaGVhZCk7CiB9CiAKQEAgLTE1OCw3ICsxNjQsNyBAQCBzdGF0aWMg
aW5saW5lIHZvaWQgbGlzdF9tb3ZlKHN0cnVjdCBsaXN0X2hlYWQgKmxpc3QsIHN0cnVjdCBsaXN0
X2hlYWQgKmhlYWQpCiBzdGF0aWMgaW5saW5lIHZvaWQgbGlzdF9tb3ZlX3RhaWwoc3RydWN0IGxp
c3RfaGVhZCAqbGlzdCwKIAkJCQkgIHN0cnVjdCBsaXN0X2hlYWQgKmhlYWQpCiB7Ci0JX19saXN0
X2RlbChsaXN0LT5wcmV2LCBsaXN0LT5uZXh0KTsKKwlfX2xpc3RfZGVsX2VudHJ5KGxpc3QpOwog
CWxpc3RfYWRkX3RhaWwobGlzdCwgaGVhZCk7CiB9CiAKZGlmZiAtLWdpdCBhL2xpYi9saXN0X2Rl
YnVnLmMgYi9saWIvbGlzdF9kZWJ1Zy5jCmluZGV4IDM0NGM3MTAuLmI4MDI5YTUgMTAwNjQ0Ci0t
LSBhL2xpYi9saXN0X2RlYnVnLmMKKysrIGIvbGliL2xpc3RfZGVidWcuYwpAQCAtMzUsNiArMzUs
MzEgQEAgdm9pZCBfX2xpc3RfYWRkKHN0cnVjdCBsaXN0X2hlYWQgKm5ldywKIH0KIEVYUE9SVF9T
WU1CT0woX19saXN0X2FkZCk7CiAKK3ZvaWQgX19saXN0X2RlbF9lbnRyeShzdHJ1Y3QgbGlzdF9o
ZWFkICplbnRyeSkKK3sKKwlzdHJ1Y3QgbGlzdF9oZWFkICpwcmV2LCAqbmV4dDsKKworCXByZXYg
PSBlbnRyeS0+cHJldjsKKwluZXh0ID0gZW50cnktPm5leHQ7CisKKwlpZiAoV0FSTihuZXh0ID09
IExJU1RfUE9JU09OMSwKKwkJImxpc3RfZGVsIGNvcnJ1cHRpb24sICVwLT5uZXh0IGlzIExJU1Rf
UE9JU09OMSAoJXApXG4iLAorCQllbnRyeSwgTElTVF9QT0lTT04xKSB8fAorCSAgICBXQVJOKHBy
ZXYgPT0gTElTVF9QT0lTT04yLAorCQkibGlzdF9kZWwgY29ycnVwdGlvbiwgJXAtPnByZXYgaXMg
TElTVF9QT0lTT04yICglcClcbiIsCisJCWVudHJ5LCBMSVNUX1BPSVNPTjIpIHx8CisJICAgIFdB
Uk4ocHJldi0+bmV4dCAhPSBlbnRyeSwKKwkJImxpc3RfZGVsIGNvcnJ1cHRpb24uIHByZXYtPm5l
eHQgc2hvdWxkIGJlICVwLCAiCisJCSJidXQgd2FzICVwXG4iLCBlbnRyeSwgcHJldi0+bmV4dCkg
fHwKKwkgICAgV0FSTihuZXh0LT5wcmV2ICE9IGVudHJ5LAorCQkibGlzdF9kZWwgY29ycnVwdGlv
bi4gbmV4dC0+cHJldiBzaG91bGQgYmUgJXAsICIKKwkJImJ1dCB3YXMgJXBcbiIsIGVudHJ5LCBu
ZXh0LT5wcmV2KSkKKwkJcmV0dXJuOworCisJX19saXN0X2RlbChwcmV2LCBuZXh0KTsKK30KK0VY
UE9SVF9TWU1CT0woX19saXN0X2RlbF9lbnRyeSk7CisKIC8qKgogICogbGlzdF9kZWwgLSBkZWxl
dGVzIGVudHJ5IGZyb20gbGlzdC4KICAqIEBlbnRyeTogdGhlIGVsZW1lbnQgdG8gZGVsZXRlIGZy
b20gdGhlIGxpc3QuCkBAIC00MywxOSArNjgsNyBAQCBFWFBPUlRfU1lNQk9MKF9fbGlzdF9hZGQp
OwogICovCiB2b2lkIGxpc3RfZGVsKHN0cnVjdCBsaXN0X2hlYWQgKmVudHJ5KQogewotCVdBUk4o
ZW50cnktPm5leHQgPT0gTElTVF9QT0lTT04xLAotCQkibGlzdF9kZWwgY29ycnVwdGlvbiwgbmV4
dCBpcyBMSVNUX1BPSVNPTjEgKCVwKVxuIiwKLQkJTElTVF9QT0lTT04xKTsKLQlXQVJOKGVudHJ5
LT5uZXh0ICE9IExJU1RfUE9JU09OMSAmJiBlbnRyeS0+cHJldiA9PSBMSVNUX1BPSVNPTjIsCi0J
CSJsaXN0X2RlbCBjb3JydXB0aW9uLCBwcmV2IGlzIExJU1RfUE9JU09OMiAoJXApXG4iLAotCQlM
SVNUX1BPSVNPTjIpOwotCVdBUk4oZW50cnktPnByZXYtPm5leHQgIT0gZW50cnksCi0JCSJsaXN0
X2RlbCBjb3JydXB0aW9uLiBwcmV2LT5uZXh0IHNob3VsZCBiZSAlcCwgIgotCQkiYnV0IHdhcyAl
cFxuIiwgZW50cnksIGVudHJ5LT5wcmV2LT5uZXh0KTsKLQlXQVJOKGVudHJ5LT5uZXh0LT5wcmV2
ICE9IGVudHJ5LAotCQkibGlzdF9kZWwgY29ycnVwdGlvbi4gbmV4dC0+cHJldiBzaG91bGQgYmUg
JXAsICIKLQkJImJ1dCB3YXMgJXBcbiIsIGVudHJ5LCBlbnRyeS0+bmV4dC0+cHJldik7Ci0JX19s
aXN0X2RlbChlbnRyeS0+cHJldiwgZW50cnktPm5leHQpOworCV9fbGlzdF9kZWxfZW50cnkoZW50
cnkpOwogCWVudHJ5LT5uZXh0ID0gTElTVF9QT0lTT04xOwogCWVudHJ5LT5wcmV2ID0gTElTVF9Q
T0lTT04yOwogfQo=
--90e6ba6e866882822f049c801968--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
