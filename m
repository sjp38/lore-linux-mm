Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 64879800CA
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 02:09:41 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so4605780wid.15
        for <linux-mm@kvack.org>; Sun, 23 Nov 2014 23:09:40 -0800 (PST)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id q3si10873180wix.22.2014.11.23.23.09.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 23 Nov 2014 23:09:40 -0800 (PST)
Received: by mail-wg0-f42.google.com with SMTP id z12so11534770wgg.29
        for <linux-mm@kvack.org>; Sun, 23 Nov 2014 23:09:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALYGNiP_zqAucmN=Gn75Mm2wK1iE6fPNxTsaTRgnUbFbFE7C-g@mail.gmail.com>
References: <502D42E5.7090403@redhat.com>
	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
	<20120822032057.GA30871@google.com>
	<50345232.4090002@redhat.com>
	<20130603195003.GA31275@evergreen.ssec.wisc.edu>
	<20141114163053.GA6547@cosmos.ssec.wisc.edu>
	<20141117160212.b86d031e1870601240b0131d@linux-foundation.org>
	<20141118014135.GA17252@cosmos.ssec.wisc.edu>
	<546AB1F5.6030306@redhat.com>
	<20141118121936.07b02545a0684b2cc839a10c@linux-foundation.org>
	<CALYGNiMxnxmy-LyJ4OT9OoFeKwTPPkZMF-bJ-eJDBFXgZQ6AEA@mail.gmail.com>
	<CALYGNiM_CsjjiK_36JGirZT8rTP+ROYcH0CSyZjghtSNDU8ptw@mail.gmail.com>
	<546BDB29.9050403@suse.cz>
	<CALYGNiOHXvyqr3+Jq5FsZ_xscsXwrQ_9YCtL2819i6iRkgms2w@mail.gmail.com>
	<546CC0CD.40906@suse.cz>
	<CALYGNiO9_bAVVZ2GdFq=PO2yV3LPs2utsbcb2pFby7MypptLCw@mail.gmail.com>
	<CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com>
	<CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com>
	<546DFFA1.4030700@redhat.com>
	<CALYGNiP_zqAucmN=Gn75Mm2wK1iE6fPNxTsaTRgnUbFbFE7C-g@mail.gmail.com>
Date: Mon, 24 Nov 2014 11:09:40 +0400
Message-ID: <CALYGNiO9NSpCFcRezArgfqzLQcTx2DnFYWYgpyK2HFyCnuGLOA@mail.gmail.com>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: multipart/mixed; boundary=089e013d1da2667a570508957af9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

--089e013d1da2667a570508957af9
Content-Type: text/plain; charset=UTF-8

On Thu, Nov 20, 2014 at 6:03 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Thu, Nov 20, 2014 at 5:50 PM, Rik van Riel <riel@redhat.com> wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> On 11/20/2014 09:42 AM, Konstantin Khlebnikov wrote:
>>
>>> I'm thinking about limitation for reusing anon_vmas which might
>>> increase performance without breaking asymptotic estimation of
>>> count anon_vma in the worst case. For example this heuristic: allow
>>> to reuse only anon_vma with single direct descendant. It seems
>>> there will be arount up to two times more anon_vmas but
>>> false-aliasing must be much lower.

Done. RFC patch in attachment.

This patch adds heuristic which decides to reuse existing anon_vma instead
of forking new one. It counts vmas and direct descendants for each anon_vma.
Anon_vma with degree lower than two will be reused at next fork.
As a result each anon_vma has either alive vma or at least two descendants,
endless chains are no longer possible and count of anon_vmas is no more than
two times more than count of vmas.


>>
>> It may even be possible to not create a child anon_vma for the
>> first child a parent forks, but only create a new anon_vma once
>> the parent clones a second child (alive at the same time as the
>> first child).
>>
>> That still takes care of things like apache or sendmail, but
>> would not create infinite anon_vmas for a task that keeps forking
>> itself to infinite depth without calling exec...
>
> But this scheme is still exploitable. Malicious software easily could create
> sequence of forks and exits which leads to infinite chain of anon_vmas.
>
>>
>> - --
>> All rights reversed
>> -----BEGIN PGP SIGNATURE-----
>> Version: GnuPG v1
>>
>> iQEcBAEBAgAGBQJUbf+hAAoJEM553pKExN6DxhQH/1QL+9GdhaSx7EQnRcbDRcHi
>> GuEfMU0g9Kv4ad+oPSQnH/L7vJMJAYeh5ZJGH+rOykWHp3sGReqDZOnzpXRAe11z
>> 1cSC1BJsndzrv9wX8niFpuKpYbF0IP+ckv3qaEzWtm5yCRyhHVZfr6b794Y4K9jF
>> z2EPPu1vAAldbkx1VlYTwofBA5lESL5UmrFvH4ouI7BeWYSEe6BgVCbvK+K5fANT
>> ketdA5R08xyUAcXDa+28qpBYkdWnxNhwqseDoXCW8SOFNwWbLDI6GRfrsCNku13i
>> Gi41h3uEuIAGDf+AU/GMjiymgwutCOGq+cfZlszELaRvHmDpNGYdPv1llghNg7Q=
>> =Vk+H
>> -----END PGP SIGNATURE-----

--089e013d1da2667a570508957af9
Content-Type: application/octet-stream;
	name=mm-prevent-endless-growth-of-anon_vma-hierarchy
Content-Disposition: attachment;
	filename=mm-prevent-endless-growth-of-anon_vma-hierarchy
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i2vhurku0

bW06IHByZXZlbnQgZW5kbGVzcyBncm93dGggb2YgYW5vbl92bWEgaGllcmFyY2h5CgpGcm9tOiBL
b25zdGFudGluIEtobGVibmlrb3YgPGtvY3Q5aUBnbWFpbC5jb20+CgpDb25zdGFudGx5IGZvcmtp
bmcgdGFzayBjYXVzZXMgdW5saW1pdGVkIGdyb3cgb2YgYW5vbl92bWEgY2hhaW4uCkVhY2ggbmV4
dCBjaGlsZCBhbGxvY2F0ZSBuZXcgbGV2ZWwgb2YgYW5vbl92bWFzIGFuZCBsaW5rcyB2bWFzIHRv
IGFsbApwcmV2aW91cyBsZXZlbHMgYmVjYXVzZSBpdCBpbmhlcml0cyBwYWdlcyBmcm9tIHRoZW0u
IE5vbmUgb2YgYW5vbl92bWFzCmNhbm5vdCBiZSBmcmVlZCBiZWNhdXNlIHRoZXJlIG1pZ2h0IGJl
IHBhZ2VzIHdoaWNoIHBvaW50cyB0byB0aGVtLgoKVGhpcyBwYXRjaCBhZGRzIGhldXJpc3RpYyB3
aGljaCBkZWNpZGVzIHRvIHJldXNlIGV4aXN0aW5nIGFub25fdm1hIGluc3RlYWQKb2YgZm9ya2lu
ZyBuZXcgb25lLiBJdCBjb3VudHMgdm1hcyBhbmQgZGlyZWN0IGRlc2NlbmRhbnRzIGZvciBlYWNo
IGFub25fdm1hLgpBbm9uX3ZtYSB3aXRoIGRlZ3JlZSBsb3dlciB0aGFuIHR3byB3aWxsIGJlIHJl
dXNlZCBhdCBuZXh0IGZvcmsuCkFzIGEgcmVzdWx0IGVhY2ggYW5vbl92bWEgaGFzIGVpdGhlciBh
bGl2ZSB2bWEgb3IgYXQgbGVhc3QgdHdvIGRlc2NlbmRhbnRzLAplbmRsZXNzIGNoYWlucyBhcmUg
bm8gbG9uZ2VyIHBvc3NpYmxlIGFuZCBjb3VudCBvZiBhbm9uX3ZtYXMgaXMgbm8gbW9yZSB0aGFu
CnR3byB0aW1lcyBtb3JlIHRoYW4gY291bnQgb2Ygdm1hcy4KClNpZ25lZC1vZmYtYnk6IEtvbnN0
YW50aW4gS2hsZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KTGluazogaHR0cDovL2xrbWwua2Vy
bmVsLm9yZy9yLzIwMTIwODE2MDI0NjEwLkdBNTM1MEBldmVyZ3JlZW4uc3NlYy53aXNjLmVkdQot
LS0KIGluY2x1ZGUvbGludXgvcm1hcC5oIHwgICAxNiArKysrKysrKysrKysrKysrCiBtbS9ybWFw
LmMgICAgICAgICAgICB8ICAgMzAgKysrKysrKysrKysrKysrKysrKysrKysrKysrKystCiAyIGZp
bGVzIGNoYW5nZWQsIDQ1IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1naXQg
YS9pbmNsdWRlL2xpbnV4L3JtYXAuaCBiL2luY2x1ZGUvbGludXgvcm1hcC5oCmluZGV4IGMwYzJi
Y2UuLmIxZDE0MGMgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvcm1hcC5oCisrKyBiL2luY2x1
ZGUvbGludXgvcm1hcC5oCkBAIC00NSw2ICs0NSwyMiBAQCBzdHJ1Y3QgYW5vbl92bWEgewogCSAq
IG1tX3Rha2VfYWxsX2xvY2tzKCkgKG1tX2FsbF9sb2Nrc19tdXRleCkuCiAJICovCiAJc3RydWN0
IHJiX3Jvb3QgcmJfcm9vdDsJLyogSW50ZXJ2YWwgdHJlZSBvZiBwcml2YXRlICJyZWxhdGVkIiB2
bWFzICovCisKKwkvKgorCSAqIENvdW50IG9mIGNoaWxkIGFub25fdm1hcyBhbmQgVk1BcyB3aGlj
aCBwb2ludHMgdG8gdGhpcyBhbm9uX3ZtYS4KKwkgKgorCSAqIFRoaXMgY291bnRlciBpcyB1c2Vk
IGZvciBtYWtpbmcgZGVjaXNpb24gYWJvdXQgcmV1c2luZyBvbGQgYW5vbl92bWEKKwkgKiBpbnN0
ZWFkIG9mIGZvcmtpbmcgbmV3IG9uZS4gSXQgYWxsb3dzIHRvIGRldGVjdCBhbm9uX3ZtYXMgd2hp
Y2ggaGF2ZQorCSAqIGp1c3Qgb25lIGRpcmVjdCBkZXNjZW5kYW50IGFuZCBubyB2bWFzLiBSZXVz
aW5nIHN1Y2ggYW5vbl92bWEgbm90CisJICogbGVhZHMgdG8gc2lnbmlmaWNhbnQgcHJlZm9ybWFu
Y2UgcmVncmVzc2lvbiBidXQgcHJldmVudHMgZGVncmFkYXRpb24KKwkgKiBvZiBhbm9uX3ZtYSBo
aWVyYXJjaHkgdG8gZW5kbGVzcyBsaW5lYXIgY2hhaW4uCisJICoKKwkgKiBSb290IGFub25fdm1h
IGlzIG5ldmVyIHJldXNlZCBiZWNhdXNlIGl0IGlzIGl0cyBvd24gcGFyZW50IGFuZCBpdCBoYXMK
KwkgKiBhdCBsZWF0IG9uZSB2bWEgb3IgY2hpbGQsIHRodXMgYXQgZm9yayBpdCdzIGRlZ3JlZSBp
cyBhdCBsZWFzdCAyLgorCSAqLworCXVuc2lnbmVkIGRlZ3JlZTsKKworCXN0cnVjdCBhbm9uX3Zt
YSAqcGFyZW50OwkvKiBQYXJlbnQgb2YgdGhpcyBhbm9uX3ZtYSAqLwogfTsKIAogLyoKZGlmZiAt
LWdpdCBhL21tL3JtYXAuYyBiL21tL3JtYXAuYwppbmRleCAxOTg4NmZiLi5iYTI5ZTFjIDEwMDY0
NAotLS0gYS9tbS9ybWFwLmMKKysrIGIvbW0vcm1hcC5jCkBAIC03Miw2ICs3Miw4IEBAIHN0YXRp
YyBpbmxpbmUgc3RydWN0IGFub25fdm1hICphbm9uX3ZtYV9hbGxvYyh2b2lkKQogCWFub25fdm1h
ID0ga21lbV9jYWNoZV9hbGxvYyhhbm9uX3ZtYV9jYWNoZXAsIEdGUF9LRVJORUwpOwogCWlmIChh
bm9uX3ZtYSkgewogCQlhdG9taWNfc2V0KCZhbm9uX3ZtYS0+cmVmY291bnQsIDEpOworCQlhbm9u
X3ZtYS0+ZGVncmVlID0gMTsJLyogUmVmZXJlbmNlIGZvciBmaXJzdCB2bWEgKi8KKwkJYW5vbl92
bWEtPnBhcmVudCA9IGFub25fdm1hOwogCQkvKgogCQkgKiBJbml0aWFsaXNlIHRoZSBhbm9uX3Zt
YSByb290IHRvIHBvaW50IHRvIGl0c2VsZi4gSWYgY2FsbGVkCiAJCSAqIGZyb20gZm9yaywgdGhl
IHJvb3Qgd2lsbCBiZSByZXNldCB0byB0aGUgcGFyZW50cyBhbm9uX3ZtYS4KQEAgLTE4MCw2ICsx
ODIsOCBAQCBpbnQgYW5vbl92bWFfcHJlcGFyZShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSkK
IAkJCWlmICh1bmxpa2VseSghYW5vbl92bWEpKQogCQkJCWdvdG8gb3V0X2Vub21lbV9mcmVlX2F2
YzsKIAkJCWFsbG9jYXRlZCA9IGFub25fdm1hOworCQkJLyogQnVtcCBkZWdyZWUsIHJvb3QgYW5v
bl92bWEgaXMgaXRzIG93biBwYXJlbnQuICovCisJCQlhbm9uX3ZtYS0+ZGVncmVlKys7CiAJCX0K
IAogCQlhbm9uX3ZtYV9sb2NrX3dyaXRlKGFub25fdm1hKTsKQEAgLTI1Niw3ICsyNjAsMTcgQEAg
aW50IGFub25fdm1hX2Nsb25lKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqZHN0LCBzdHJ1Y3Qgdm1f
YXJlYV9zdHJ1Y3QgKnNyYykKIAkJYW5vbl92bWEgPSBwYXZjLT5hbm9uX3ZtYTsKIAkJcm9vdCA9
IGxvY2tfYW5vbl92bWFfcm9vdChyb290LCBhbm9uX3ZtYSk7CiAJCWFub25fdm1hX2NoYWluX2xp
bmsoZHN0LCBhdmMsIGFub25fdm1hKTsKKworCQkvKgorCQkgKiBSZXVzZSBleGlzdGluZyBhbm9u
X3ZtYSBpZiBpdHMgZGVncmVlIGxvd2VyIHRoYW4gdHdvLAorCQkgKiB0aGF0IG1lYW5zIGl0IGhh
cyBubyB2bWEgYW5kIGp1c3Qgb25lIGFub25fdm1hIGNoaWxkLgorCQkgKi8KKwkJaWYgKCFkc3Qt
PmFub25fdm1hICYmIGFub25fdm1hICE9IHNyYy0+YW5vbl92bWEgJiYKKwkJCQlhbm9uX3ZtYS0+
ZGVncmVlIDwgMikKKwkJCWRzdC0+YW5vbl92bWEgPSBhbm9uX3ZtYTsKIAl9CisJaWYgKGRzdC0+
YW5vbl92bWEpCisJCWRzdC0+YW5vbl92bWEtPmRlZ3JlZSsrOwogCXVubG9ja19hbm9uX3ZtYV9y
b290KHJvb3QpOwogCXJldHVybiAwOwogCkBAIC0yNzksNiArMjkzLDkgQEAgaW50IGFub25fdm1h
X2Zvcmsoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAq
cHZtYSkKIAlpZiAoIXB2bWEtPmFub25fdm1hKQogCQlyZXR1cm4gMDsKIAorCS8qIERyb3AgaW5o
ZXJpdGVkIGFub25fdm1hLCB3ZSdsbCByZXVzZSBvbGQgb25lIG9yIGFsbG9jYXRlIG5ldy4gKi8K
Kwl2bWEtPmFub25fdm1hID0gTlVMTDsKKwogCS8qCiAJICogRmlyc3QsIGF0dGFjaCB0aGUgbmV3
IFZNQSB0byB0aGUgcGFyZW50IFZNQSdzIGFub25fdm1hcywKIAkgKiBzbyBybWFwIGNhbiBmaW5k
IG5vbi1DT1dlZCBwYWdlcyBpbiBjaGlsZCBwcm9jZXNzZXMuCkBAIC0yODYsNiArMzAzLDEwIEBA
IGludCBhbm9uX3ZtYV9mb3JrKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCBzdHJ1Y3Qgdm1f
YXJlYV9zdHJ1Y3QgKnB2bWEpCiAJaWYgKGFub25fdm1hX2Nsb25lKHZtYSwgcHZtYSkpCiAJCXJl
dHVybiAtRU5PTUVNOwogCisJLyogQW4gb2xkIGFub25fdm1hIGhhcyBiZWVuIHJldXNlZC4gKi8K
KwlpZiAodm1hLT5hbm9uX3ZtYSkKKwkJcmV0dXJuIDA7CisKIAkvKiBUaGVuIGFkZCBvdXIgb3du
IGFub25fdm1hLiAqLwogCWFub25fdm1hID0gYW5vbl92bWFfYWxsb2MoKTsKIAlpZiAoIWFub25f
dm1hKQpAQCAtMjk5LDYgKzMyMCw3IEBAIGludCBhbm9uX3ZtYV9mb3JrKHN0cnVjdCB2bV9hcmVh
X3N0cnVjdCAqdm1hLCBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnB2bWEpCiAJICogbG9jayBhbnkg
b2YgdGhlIGFub25fdm1hcyBpbiB0aGlzIGFub25fdm1hIHRyZWUuCiAJICovCiAJYW5vbl92bWEt
PnJvb3QgPSBwdm1hLT5hbm9uX3ZtYS0+cm9vdDsKKwlhbm9uX3ZtYS0+cGFyZW50ID0gcHZtYS0+
YW5vbl92bWE7CiAJLyoKIAkgKiBXaXRoIHJlZmNvdW50cywgYW4gYW5vbl92bWEgY2FuIHN0YXkg
YXJvdW5kIGxvbmdlciB0aGFuIHRoZQogCSAqIHByb2Nlc3MgaXQgYmVsb25ncyB0by4gVGhlIHJv
b3QgYW5vbl92bWEgbmVlZHMgdG8gYmUgcGlubmVkIHVudGlsCkBAIC0zMDksNiArMzMxLDcgQEAg
aW50IGFub25fdm1hX2Zvcmsoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsIHN0cnVjdCB2bV9h
cmVhX3N0cnVjdCAqcHZtYSkKIAl2bWEtPmFub25fdm1hID0gYW5vbl92bWE7CiAJYW5vbl92bWFf
bG9ja193cml0ZShhbm9uX3ZtYSk7CiAJYW5vbl92bWFfY2hhaW5fbGluayh2bWEsIGF2YywgYW5v
bl92bWEpOworCWFub25fdm1hLT5wYXJlbnQtPmRlZ3JlZSsrOwogCWFub25fdm1hX3VubG9ja193
cml0ZShhbm9uX3ZtYSk7CiAKIAlyZXR1cm4gMDsKQEAgLTMzOSwxMiArMzYyLDE2IEBAIHZvaWQg
dW5saW5rX2Fub25fdm1hcyhzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSkKIAkJICogTGVhdmUg
ZW1wdHkgYW5vbl92bWFzIG9uIHRoZSBsaXN0IC0gd2UnbGwgbmVlZAogCQkgKiB0byBmcmVlIHRo
ZW0gb3V0c2lkZSB0aGUgbG9jay4KIAkJICovCi0JCWlmIChSQl9FTVBUWV9ST09UKCZhbm9uX3Zt
YS0+cmJfcm9vdCkpCisJCWlmIChSQl9FTVBUWV9ST09UKCZhbm9uX3ZtYS0+cmJfcm9vdCkpIHsK
KwkJCWFub25fdm1hLT5wYXJlbnQtPmRlZ3JlZS0tOwogCQkJY29udGludWU7CisJCX0KIAogCQls
aXN0X2RlbCgmYXZjLT5zYW1lX3ZtYSk7CiAJCWFub25fdm1hX2NoYWluX2ZyZWUoYXZjKTsKIAl9
CisJaWYgKHZtYS0+YW5vbl92bWEpCisJCXZtYS0+YW5vbl92bWEtPmRlZ3JlZS0tOwogCXVubG9j
a19hbm9uX3ZtYV9yb290KHJvb3QpOwogCiAJLyoKQEAgLTM1NSw2ICszODIsNyBAQCB2b2lkIHVu
bGlua19hbm9uX3ZtYXMoc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEpCiAJbGlzdF9mb3JfZWFj
aF9lbnRyeV9zYWZlKGF2YywgbmV4dCwgJnZtYS0+YW5vbl92bWFfY2hhaW4sIHNhbWVfdm1hKSB7
CiAJCXN0cnVjdCBhbm9uX3ZtYSAqYW5vbl92bWEgPSBhdmMtPmFub25fdm1hOwogCisJCUJVR19P
Tihhbm9uX3ZtYS0+ZGVncmVlKTsKIAkJcHV0X2Fub25fdm1hKGFub25fdm1hKTsKIAogCQlsaXN0
X2RlbCgmYXZjLT5zYW1lX3ZtYSk7Cg==
--089e013d1da2667a570508957af9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
