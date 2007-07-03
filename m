Date: Tue, 3 Jul 2007 19:57:24 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: [PATCH] Re: Sparc32: random invalid instruction occourances on
 sparc32 (sun4c)
In-Reply-To: <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
Message-ID: <Pine.LNX.4.61.0707031910280.29930@mtfhpc.demon.co.uk>
References: <468A7D14.1050505@googlemail.com> <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1750305931-882467821-1183489044=:29930"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Woodhouse <dwmw2@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>, Christoph Lameter <clameter@engr.sgi.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

--1750305931-882467821-1183489044=:29930
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hi all,

I have tested a solution to the random invalid instruction occourances on=
=20
sparc32 (sun4c). I have attached the patch as my mail client messes up=20
patch files.

The problem apears to be an alignment error of the redzone2 word, caused=20
by the userword not being forced onto a 64bit boundary. My solution is to=
=20
increase the size of the user word (BYTES_PER_WORD) to 64bits in order to=
=20
force the correct alignment of the user word (and hence the redzone2=20
word). My solution also works on platforms where sizeof(unsigned long=20
long) is 128bits and requires 128bit alignment.

Regards
 =09Mark Fortescue.

On Tue, 3 Jul 2007, Mark Fortescue wrote:

> Hi all,
>
> I think I have found the cause of the problem.
>
> Commit b46b8f19c9cd435ecac4d9d12b39d78c137ecd66 partially fixed alignment=
=20
> issues but does not ensure that all 64bit alignment requirements of sparc=
32=20
> are met. Tests have shown that the redzone2 word can become misallignd.
>
> I am currently working on a posible fix.
>
> Regards
> =09Mark Fortescue.
>
> On Tue, 3 Jul 2007, Michal Piotrowski wrote:
>
>> Hi all,
>>=20
>> Here is a list of some known regressions in 2.6.22-rc7.
>>=20
>> Feel free to add new regressions/remove fixed etc.
>> http://kernelnewbies.org/known_regressions
>>=20
>> List of Aces
>>=20
>> Name                    Regressions fixed since 21-Jun-2007
>> Hugh Dickins                           2
>> Andi Kleen                             1
>> Andrew Morton                          1
>> Benjamin Herrenschmidt                 1
>> Bj=F6rn Steinbrink                       1
>> Bjorn Helgaas                          1
>> Jean Delvare                           1
>> Olaf Hering                            1
>> Siddha, Suresh B                       1
>> Trent Piepho                           1
>> Ville Syrj=E4l=E4                          1
>>=20
>>=20
>>=20
>> FS
>>=20
>> Subject    : 2.6.22-rc4-git5 reiserfs: null ptr deref.
>> References : http://lkml.org/lkml/2007/6/13/322
>> Submitter  : Randy Dunlap <randy.dunlap@oracle.com>
>> Handled-By : Vladimir V. Saveliev <vs@namesys.com>
>> Status     : problem is being debugged
>>=20
>>=20
>>=20
>> IDE
>>=20
>> Subject    : 2.6.22-rcX: hda: lost interrupt
>> References : http://lkml.org/lkml/2007/6/29/121
>> Submitter  : David Chinner <dgc@sgi.com>
>> Status     : unknown
>>=20
>>=20
>>=20
>> Sparc64
>>=20
>> Subject    : random invalid instruction occourances on sparc32 (sun4c)
>> References : http://lkml.org/lkml/2007/6/17/111
>> Submitter  : Mark Fortescue <mark@mtfhpc.demon.co.uk>
>> Status     : problem is being debugged
>>=20
>> Subject    : 2.6.22-rc broke X on Ultra5
>> References : http://lkml.org/lkml/2007/5/22/78
>> Submitter  : Mikael Pettersson <mikpe@it.uu.se>
>> Handled-By : David Miller <davem@davemloft.net>
>> Status     : problem is being debugged
>>=20
>>=20
>>=20
>> Regards,
>> Michal
>>=20
>> --
>> LOG
>> http://www.stardust.webpages.pl/log/
>> -
>> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
--1750305931-882467821-1183489044=:29930
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="slab_fix.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0707031957230.29930@mtfhpc.demon.co.uk>
Content-Description: 
Content-Disposition: attachment; filename="slab_fix.patch"

RnJvbTogTWFyayBGb3J0ZXNjdWUgPG1hcmtAbXRmaHBjLmRlbW9uLmNvLnVr
Pg0KDQpWZXJpb3VzIGFsaWdubWVudCBmaXhlcyBpbiB0aGUgU0xBQiBhbG9j
YXRvciB0aGF0IGluY3JlYXNlZCB0aGUgc2l6ZQ0Kb2YgdGhlIFJlZFpvbmUg
d29yZHMgZmFpbGVkIHRvIGVuc3VyZSB0aGF0IFJlZFpvbmUgd29yZCAyIGlz
IGFsaWduZWQNCm9uIGEgNjRiaXQgYm91bmRhcnkuIFRoaXMgaGFzIHJlc3Vs
dGVkIGluIHJhbmRvbSBpbnZhbGlkIGluc3RydWN0aW9uDQpvY2NvdXJhbmNl
cyBvbiBTcGFyYzMyIChzdW40YykuDQpCeSBpbmNyZWFzaW5nIHRoZSBzaXpl
IG9mIHRoZSBVc2VyIFdvcmQgKEJZVEVTX1BFUl9XT1JEKSB0byA2NGJpdHMN
CnNlYW1zIHRvIGVuc3VyZSB0aGF0IGNvcnJlY3QgYWxpZ25tZW50IGlzIG1h
aW50YWluZWQgYnV0IGFzc3VtZXMgdGhhdDoNCiAgIHNpemVvZiAodm9pZCAq
KSA8PSBzaXplb2YgKHVuc2lnbmVkIGRsb25nIGxvbmcpIA0KDQpTaWduZWQt
b2ZmLWJ5OiBNYXJrIEZvcnRlc2N1ZSA8bWFya0BtdGZocGMuZGVtb24uY28u
dWs+DQotLS0NCkFsdGVybmF0aXZlIHNvbHV0aW9ucyB3b3VsZCBpbnZvbHZl
IGNvcnJlY3RpbmcgdGhlIHNpemUgY2FjdWxhdGlvbnMgb24NCmxpbmVzIDIx
NzUgdG8gMjI3NSBhbmQgbWF5IGFsc28gaW52b2x2ZSBhZGRpdGlvbmFsIGNo
YW5nZXMgdG8gdGhlDQpjYWxjdWxhdGlvbnMgdG8gZ2V0IGEgcG9pbnRlciB0
byB0aGUgUmVkWm9uZSBXb3JkIDIuDQotLS0gbGludXgtMi42L21tL3NsYWIu
YwkyMDA3LTA3LTAzIDE3OjM1OjA3LjAwMDAwMDAwMCArMDEwMA0KKysrIGxp
bnV4LXRlc3QvbW0vc2xhYi5jCTIwMDctMDctMDMgMTk6MDU6MTkuMDAwMDAw
MDAwICswMTAwDQpAQCAtMTM2LDcgKzEzNiw4IEBADQogI2VuZGlmDQogDQog
LyogU2hvdWxkbid0IHRoaXMgYmUgaW4gYSBoZWFkZXIgZmlsZSBzb21ld2hl
cmU/ICovDQotI2RlZmluZQlCWVRFU19QRVJfV09SRAkJc2l6ZW9mKHZvaWQg
KikNCisvKiBGaXggYWxpZ25tZW50IG9mIHJlZHpvbmUyLiBBc3N1bWVzIHNp
emVvZiAodm9pZCopIDw9IHNpemVvZiAodW5zaWduZWQgbG9uZyBsb25nKSAq
Lw0KKyNkZWZpbmUJQllURVNfUEVSX1dPUkQJCXNpemVvZih1bnNpZ25lZCBs
b25nIGxvbmcpDQogDQogI2lmbmRlZiBjYWNoZV9saW5lX3NpemUNCiAjZGVm
aW5lIGNhY2hlX2xpbmVfc2l6ZSgpCUwxX0NBQ0hFX0JZVEVTDQpAQCAtNTM4
LDcgKzUzOSw3IEBAIHN0YXRpYyB1bnNpZ25lZCBsb25nIGxvbmcgKmRiZ19y
ZWR6b25lMSgNCiB7DQogCUJVR19PTighKGNhY2hlcC0+ZmxhZ3MgJiBTTEFC
X1JFRF9aT05FKSk7DQogCXJldHVybiAodW5zaWduZWQgbG9uZyBsb25nKikg
KG9ianAgKyBvYmpfb2Zmc2V0KGNhY2hlcCkgLQ0KLQkJCQkgICAgICBzaXpl
b2YodW5zaWduZWQgbG9uZyBsb25nKSk7DQorCQkJCSAgICAgIEJZVEVTX1BF
Ul9XT1JEKTsNCiB9DQogDQogc3RhdGljIHVuc2lnbmVkIGxvbmcgbG9uZyAq
ZGJnX3JlZHpvbmUyKHN0cnVjdCBrbWVtX2NhY2hlICpjYWNoZXAsIHZvaWQg
Km9ianApDQpAQCAtNTQ2LDEwICs1NDcsOSBAQCBzdGF0aWMgdW5zaWduZWQg
bG9uZyBsb25nICpkYmdfcmVkem9uZTIoDQogCUJVR19PTighKGNhY2hlcC0+
ZmxhZ3MgJiBTTEFCX1JFRF9aT05FKSk7DQogCWlmIChjYWNoZXAtPmZsYWdz
ICYgU0xBQl9TVE9SRV9VU0VSKQ0KIAkJcmV0dXJuICh1bnNpZ25lZCBsb25n
IGxvbmcgKikob2JqcCArIGNhY2hlcC0+YnVmZmVyX3NpemUgLQ0KLQkJCQkJ
ICAgICAgc2l6ZW9mKHVuc2lnbmVkIGxvbmcgbG9uZykgLQ0KLQkJCQkJICAg
ICAgQllURVNfUEVSX1dPUkQpOw0KKwkJCQkJICAgICAgMiAqIEJZVEVTX1BF
Ul9XT1JEKTsNCiAJcmV0dXJuICh1bnNpZ25lZCBsb25nIGxvbmcgKikgKG9i
anAgKyBjYWNoZXAtPmJ1ZmZlcl9zaXplIC0NCi0JCQkJICAgICAgIHNpemVv
Zih1bnNpZ25lZCBsb25nIGxvbmcpKTsNCisJCQkJICAgICAgIEJZVEVTX1BF
Ul9XT1JEKTsNCiB9DQogDQogc3RhdGljIHZvaWQgKipkYmdfdXNlcndvcmQo
c3RydWN0IGttZW1fY2FjaGUgKmNhY2hlcCwgdm9pZCAqb2JqcCkNCkBAIC0y
MjU2LDggKzIyNTYsOCBAQCBrbWVtX2NhY2hlX2NyZWF0ZSAoY29uc3QgY2hh
ciAqbmFtZSwgc2l6DQogCSAqLw0KIAlpZiAoZmxhZ3MgJiBTTEFCX1JFRF9a
T05FKSB7DQogCQkvKiBhZGQgc3BhY2UgZm9yIHJlZCB6b25lIHdvcmRzICov
DQotCQljYWNoZXAtPm9ial9vZmZzZXQgKz0gc2l6ZW9mKHVuc2lnbmVkIGxv
bmcgbG9uZyk7DQotCQlzaXplICs9IDIgKiBzaXplb2YodW5zaWduZWQgbG9u
ZyBsb25nKTsNCisJCWNhY2hlcC0+b2JqX29mZnNldCArPSBCWVRFU19QRVJf
V09SRDsNCisJCXNpemUgKz0gMiAqIEJZVEVTX1BFUl9XT1JEOw0KIAl9DQog
CWlmIChmbGFncyAmIFNMQUJfU1RPUkVfVVNFUikgew0KIAkJLyogdXNlciBz
dG9yZSByZXF1aXJlcyBvbmUgd29yZCBzdG9yYWdlIGJlaGluZCB0aGUgZW5k
IG9mDQo=

--1750305931-882467821-1183489044=:29930--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
