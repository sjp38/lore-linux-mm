Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA08065
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 16:05:08 -0500
Date: Thu, 26 Feb 1998 22:00:17 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [2x PATCH] page map aging & improved kswap logic
Message-ID: <Pine.LNX.3.91.980226213958.6944A-300000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811840-278753295-888526817=:6944"
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463811840-278753295-888526817=:6944
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi Linus,

Here are the two patches I sent you earlier today,
this time against 2.1.89-pre2.

The kswapd logic is almost completely redone. Basically,
kswapd tries (free_pages_high - nr_free_pages) times to
free a page, but when memory becomes tighter, the number
of tries become even higher.

Since the code is compiling as I write, I don't know if
the agression factor is right, but we can adjust that
later...

A nice sideeffect of this is, that when memory is being
allocated slowly, kswapd will behave itself much better
then when memory is allocated faster. In the latter case,
kswapd will also become _far_ more agressive. It's kinda
self-tuning, but just not yet :-)

As for the other patch, it simply copies kswapd's page-aging
behaviour for page cache (and swap cache) pages. Buffer
pages, and possibly other ones, are still thrown out as soon
as they're not used any more.

OK... wait and see if it compiles <wait...wait...wait...wait>:
Yup, it compiles without a hitch (only mprotect.c gives a
warning about an ambiguous else ... gcc-2.8.0).
And since there's no new code in action, I leave the rebooting
to you guys.

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+

---1463811840-278753295-888526817=:6944
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="vmscan-2.1.89-2.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.3.91.980226220017.6944B@mirkwood.dummy.home>
Content-Description: 

LS0tIHZtc2Nhbi5wcmU4OS0yCVRodSBGZWIgMjYgMjE6MTA6MzMgMTk5OA0K
KysrIHZtc2Nhbi5jCVRodSBGZWIgMjYgMjE6NTc6NTMgMTk5OA0KQEAgLTUz
OSw3ICs1MzksNyBAQA0KIAlpbml0X3N3YXBfdGltZXIoKTsNCiAJYWRkX3dh
aXRfcXVldWUoJmtzd2FwZF93YWl0LCAmd2FpdCk7DQogCXdoaWxlICgxKSB7
DQotCQlpbnQgYXN5bmM7DQorCQlpbnQgdHJpZXM7DQogDQogCQlrc3dhcGRf
YXdha2UgPSAwOw0KIAkJZmx1c2hfc2lnbmFscyhjdXJyZW50KTsNCkBAIC01
NDksMzIgKzU0OSw0NSBAQA0KIAkJa3N3YXBkX2F3YWtlID0gMTsNCiAJCXN3
YXBzdGF0cy53YWtldXBzKys7DQogCQkvKiBEbyB0aGUgYmFja2dyb3VuZCBw
YWdlb3V0OiANCi0JCSAqIFdlIG5vdyBvbmx5IHN3YXAgb3V0IGFzIG1hbnkg
cGFnZXMgYXMgbmVlZGVkLg0KLQkJICogV2hlbiB3ZSBhcmUgdHJ1bHkgbG93
IG9uIG1lbW9yeSwgd2Ugc3dhcCBvdXQNCi0JCSAqIHN5bmNocm9ub3VzbHkg
KFdBSVQgPT0gMSkuICAtLSBSaWsuDQotCQkgKiBJZiB3ZSd2ZSBoYWQgdG9v
IG1hbnkgY29uc2VjdXRpdmUgZmFpbHVyZXMsDQotCQkgKiBnbyBiYWNrIHRv
IHNsZWVwIHRvIGxldCBvdGhlciB0YXNrcyBydW4uDQorCQkgKiBXaGVuIHdl
J3ZlIGdvdCBsb2FkcyBvZiBtZW1vcnksIHdlIHRyeQ0KKwkJICogKGZyZWVf
cGFnZXNfaGlnaCAtIG5yX2ZyZWVfcGFnZXMpIHRpbWVzIHRvDQorCQkgKiBm
cmVlIG1lbW9yeS4gQXMgbWVtb3J5IGdldHMgdGlnaHRlciwga3N3YXBkDQor
CQkgKiBnZXRzIG1vcmUgYW5kIG1vcmUgYWdyZXNzaXZlLiAtLSBSaWsuDQog
CQkgKi8NCi0JCWFzeW5jID0gMTsNCi0JCWZvciAoOzspIHsNCisJCXRyaWVz
ID0gZnJlZV9wYWdlc19oaWdoIC0gbnJfZnJlZV9wYWdlczsNCisJCWlmICh0
cmllcyA8IG1pbl9mcmVlX3BhZ2VzKSB7DQorCQkJdHJpZXMgPSBtaW5fZnJl
ZV9wYWdlczsNCisJCX0NCisJCWVsc2UgaWYgKG5yX2ZyZWVfcGFnZXMgPCAo
ZnJlZV9wYWdlc19oaWdoICsgZnJlZV9wYWdlc19sb3cpIC8gMikgew0KKwkJ
CXRyaWVzIDw8PSAxOw0KKwkJCWlmIChucl9mcmVlX3BhZ2VzIDwgZnJlZV9w
YWdlc19sb3cpIHsNCisJCQkJdHJpZXMgPDw9IDE7DQorCQkJCWlmIChucl9m
cmVlX3BhZ2VzIDw9IG1pbl9mcmVlX3BhZ2VzKSB7DQorCQkJCQl0cmllcyA8
PD0gMTsNCisJCQkJfQ0KKwkJCX0NCisJCX0NCisJCXdoaWxlICh0cmllcy0t
KSB7DQogCQkJaW50IGdmcF9tYXNrOw0KIA0KIAkJCWlmIChmcmVlX21lbW9y
eV9hdmFpbGFibGUoKSkNCiAJCQkJYnJlYWs7DQogCQkJZ2ZwX21hc2sgPSBf
X0dGUF9JTzsNCi0JCQlpZiAoIWFzeW5jKQ0KLQkJCQlnZnBfbWFzayB8PSBf
X0dGUF9XQUlUOw0KLQkJCWFzeW5jID0gdHJ5X3RvX2ZyZWVfcGFnZShnZnBf
bWFzayk7DQotCQkJaWYgKCEoZ2ZwX21hc2sgJiBfX0dGUF9XQUlUKSB8fCBh
c3luYykNCi0JCQkJY29udGludWU7DQotDQorCQkJdHJ5X3RvX2ZyZWVfcGFn
ZShnZnBfbWFzayk7DQogCQkJLyoNCi0JCQkgKiBOb3QgZ29vZC4gV2UgZmFp
bGVkIHRvIGZyZWUgYSBwYWdlIGV2ZW4gdGhvdWdoDQotCQkJICogd2Ugd2Vy
ZSBzeW5jaHJvbm91cy4gQ29tcGxhaW4gYW5kIGdpdmUgdXAuLg0KKwkJCSAq
IFN5bmNpbmcgbGFyZ2UgY2h1bmtzIGlzIGZhc3RlciB0aGFuIHN3YXBwaW5n
DQorCQkJICogc3luY2hyb25vdXNseSAobGVzcyBoZWFkIG1vdmVtZW50KS4g
LS0gUmlrLg0KIAkJCSAqLw0KLQkJCXByaW50aygia3N3YXBkOiBmYWlsZWQg
dG8gZnJlZSBwYWdlXG4iKTsNCi0JCQlicmVhazsNCisJCQlpZiAoYXRvbWlj
X3JlYWQoJm5yX2FzeW5jX3BhZ2VzKSA+PSBTV0FQX0NMVVNURVJfTUFYKQ0K
KwkJCQlydW5fdGFza19xdWV1ZSgmdHFfZGlzayk7DQorDQogCQl9DQorCS8q
DQorCSAqIFJlcG9ydCBmYWlsdXJlIGlmIHdlIGNvdWxkbid0IGV2ZW4gcmVh
Y2ggbWluX2ZyZWVfcGFnZXMuDQorCSAqLw0KKwlpZiAobnJfZnJlZV9wYWdl
cyA8IG1pbl9mcmVlX3BhZ2VzKQ0KKwkJcHJpbnRrKCJrc3dhcGQ6IGZhaWxl
ZCwgZ290ICVkIG9mICVkXG4iLA0KKwkJCW5yX2ZyZWVfcGFnZXMsIG1pbl9m
cmVlX3BhZ2VzKTsNCiAJfQ0KIAkvKiBBcyBpZiB3ZSBjb3VsZCBldmVyIGdl
dCBoZXJlIC0gbWF5YmUgd2Ugd2FudCB0byBtYWtlIHRoaXMga2lsbGFibGUg
Ki8NCiAJcmVtb3ZlX3dhaXRfcXVldWUoJmtzd2FwZF93YWl0LCAmd2FpdCk7
DQo=
---1463811840-278753295-888526817=:6944
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="mmap-age-2.1.89-2"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.3.91.980226220017.6944C@mirkwood.dummy.home>
Content-Description: 

LS0tIGxpbnV4L21tL2ZpbGVtYXAucHJlODktMglUaHUgRmViIDI2IDIxOjEw
OjQ0IDE5OTgNCisrKyBsaW51eC9tbS9maWxlbWFwLmMJVGh1IEZlYiAyNiAy
MToxOTo1MiAxOTk4DQpAQCAtMjUsNiArMjUsNyBAQA0KICNpbmNsdWRlIDxs
aW51eC9zbXAuaD4NCiAjaW5jbHVkZSA8bGludXgvc21wX2xvY2suaD4NCiAj
aW5jbHVkZSA8bGludXgvYmxrZGV2Lmg+DQorI2luY2x1ZGUgPGxpbnV4L3N3
YXBjdGwuaD4NCiANCiAjaW5jbHVkZSA8YXNtL3N5c3RlbS5oPg0KICNpbmNs
dWRlIDxhc20vcGd0YWJsZS5oPg0KQEAgLTE1OCwxMiArMTU5LDE1IEBADQog
DQogCQlzd2l0Y2ggKGF0b21pY19yZWFkKCZwYWdlLT5jb3VudCkpIHsNCiAJ
CQljYXNlIDE6DQotCQkJCS8qIElmIGl0IGhhcyBiZWVuIHJlZmVyZW5jZWQg
cmVjZW50bHksIGRvbid0IGZyZWUgaXQgKi8NCi0JCQkJaWYgKHRlc3RfYW5k
X2NsZWFyX2JpdChQR19yZWZlcmVuY2VkLCAmcGFnZS0+ZmxhZ3MpKQ0KLQkJ
CQkJYnJlYWs7DQotDQogCQkJCS8qIGlzIGl0IGEgc3dhcC1jYWNoZSBvciBw
YWdlLWNhY2hlIHBhZ2U/ICovDQogCQkJCWlmIChwYWdlLT5pbm9kZSkgew0K
KwkJCQkJaWYgKHRlc3RfYW5kX2NsZWFyX2JpdChQR19yZWZlcmVuY2VkLCAm
cGFnZS0+ZmxhZ3MpKSB7DQorCQkJCQkJdG91Y2hfcGFnZShwYWdlKTsNCisJ
CQkJCQlicmVhazsNCisJCQkJCX0NCisJCQkJCWFnZV9wYWdlKHBhZ2UpOw0K
KwkJCQkJaWYgKHBhZ2UtPmFnZSkNCisJCQkJCQlicmVhazsNCiAJCQkJCWlm
IChQYWdlU3dhcENhY2hlKHBhZ2UpKSB7DQogCQkJCQkJZGVsZXRlX2Zyb21f
c3dhcF9jYWNoZShwYWdlKTsNCiAJCQkJCQlyZXR1cm4gMTsNCkBAIC0xNzMs
NiArMTc3LDEwIEBADQogCQkJCQlfX2ZyZWVfcGFnZShwYWdlKTsNCiAJCQkJ
CXJldHVybiAxOw0KIAkJCQl9DQorCQkJCS8qIEl0J3Mgbm90IGEgY2FjaGUg
cGFnZSwgc28gd2UgZG9uJ3QgZG8gYWdpbmcuDQorCQkJCSAqIElmIGl0IGhh
cyBiZWVuIHJlZmVyZW5jZWQgcmVjZW50bHksIGRvbid0IGZyZWUgaXQgKi8N
CisJCQkJaWYgKHRlc3RfYW5kX2NsZWFyX2JpdChQR19yZWZlcmVuY2VkLCAm
cGFnZS0+ZmxhZ3MpKQ0KKwkJCQkJYnJlYWs7DQogDQogCQkJCS8qIGlzIGl0
IGEgYnVmZmVyIGNhY2hlIHBhZ2U/ICovDQogCQkJCWlmICgoZ2ZwX21hc2sg
JiBfX0dGUF9JTykgJiYgYmggJiYgdHJ5X3RvX2ZyZWVfYnVmZmVyKGJoLCAm
YmgsIDYpKQ0K
---1463811840-278753295-888526817=:6944--
