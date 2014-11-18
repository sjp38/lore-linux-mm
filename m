Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 177F06B006C
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 18:02:06 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id r10so12319pdi.13
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:02:05 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id sg2si3126819pbb.148.2014.11.18.15.02.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 15:02:04 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so3343125pdb.18
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:02:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALYGNiMxnxmy-LyJ4OT9OoFeKwTPPkZMF-bJ-eJDBFXgZQ6AEA@mail.gmail.com>
References: <502D42E5.7090403@redhat.com>
	<20120818000312.GA4262@evergreen.ssec.wisc.edu>
	<502F100A.1080401@redhat.com>
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
Date: Wed, 19 Nov 2014 03:02:02 +0400
Message-ID: <CALYGNiM_CsjjiK_36JGirZT8rTP+ROYcH0CSyZjghtSNDU8ptw@mail.gmail.com>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: multipart/mixed; boundary=047d7b15a9ad5e0d0605082a15d4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

--047d7b15a9ad5e0d0605082a15d4
Content-Type: text/plain; charset=UTF-8

On Wed, Nov 19, 2014 at 1:15 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Tue, Nov 18, 2014 at 11:19 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Mon, 17 Nov 2014 21:41:57 -0500 Rik van Riel <riel@redhat.com> wrote:
>>
>>> > Because of the serial forking there does indeed end up being an
>>> > infinite number of vmas.  The initial vma can never be deleted
>>> > (even though the initial parent process has long since terminated)
>>> > because the initial vma is referenced by the children.
>>>
>>> There is a finite number of VMAs, but an infite number of
>>> anon_vmas.
>>>
>>> Subtle, yet deadly...
>>
>> Well, we clearly have the data structures screwed up.  I've forgotten
>> enough about this code for me to be unable to work out what the fixed
>> up data structures would look like :( But surely there is some proper
>> solution here.  Help?
>
> Not sure if it's right but probably we could reuse on fork an old anon_vma
> from the chain if it's already lost all vmas which points to it.
> For endlessly forking exploit this should work mostly like proposed patch
> which stops branching after some depth but without magic constant.

Something like this. I leave proper comment for tomorrow.

>
>>
>>> > I can't say, but it only affects users who fork more than five
>>> > levels deep without doing an exec.  On the other hand, there are at
>>> > least three users (Tim Hartrick, Michal Hocko, and myself) who have
>>> > real world applications where the consequence of no patch is a
>>> > crashed system.
>>> >
>>> > I would suggest reading the thread starting with my initial bug
>>> > report for what others have had to say about this.
>>>
>>> I suspect what Andrew is hinting at is that the
>>> changelog for the patch should contain a detailed
>>> description of exactly what the bug is, how it is
>>> triggered, what the symptoms are, and how the
>>> patch avoids it.
>>>
>>> That way people can understand what the code does
>>> simply by looking at the changelog - no need to go
>>> find old linux-kernel mailing list threads.
>>
>> Yes please, there's a ton of stuff here which we should attempt to
>> capture.
>>
>> https://lkml.org/lkml/2012/8/15/765 is useful.
>>
>> I'm assuming that with the "foo < 5" hack, an application which forked
>> 5 times then did a lot of work would still trigger the "catastrophic
>> issue at page reclaim time" issue which Rik identified at
>> https://lkml.org/lkml/2012/8/20/265?
>>
>> There are real-world workloads which are triggering this slab growth
>> problem, yes?  (Detail them in the changelog, please).
>>
>> This bug snuck under my radar last time - we're permitting unprivileged
>> userspace to exhaust memory and that's bad.  I'm OK with the foo<5
>> thing for -stable kernels, as it is simple.  But I'm reluctant to merge
>> (or at least to retain) it in mainline because then everyone will run
>> away and think about other stuff and this bug will never get fixed
>> properly.
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--047d7b15a9ad5e0d0605082a15d4
Content-Type: application/octet-stream;
	name=mm-reuse-old-anon_vma-if-it-s-lost-all-vmas
Content-Disposition: attachment;
	filename=mm-reuse-old-anon_vma-if-it-s-lost-all-vmas
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i2nv7pxo0

bW06IHJldXNlIG9sZCBhbm9uX3ZtYSBpZiBpdCdzIGxvc3QgYWxsIHZtYXMKCkZyb206IEtvbnN0
YW50aW4gS2hsZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KClNpZ25lZC1vZmYtYnk6IEtvbnN0
YW50aW4gS2hsZWJuaWtvdiA8a29jdDlpQGdtYWlsLmNvbT4KLS0tCiBpbmNsdWRlL2xpbnV4L3Jt
YXAuaCB8ICAgIDIgKysKIG1tL3JtYXAuYyAgICAgICAgICAgIHwgICAxNCArKysrKysrKysrKysr
KwogMiBmaWxlcyBjaGFuZ2VkLCAxNiBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvaW5jbHVk
ZS9saW51eC9ybWFwLmggYi9pbmNsdWRlL2xpbnV4L3JtYXAuaAppbmRleCBjMGMyYmNlLi5kNDBj
YTA4IDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L3JtYXAuaAorKysgYi9pbmNsdWRlL2xpbnV4
L3JtYXAuaApAQCAtMzYsNiArMzYsOCBAQCBzdHJ1Y3QgYW5vbl92bWEgewogCSAqLwogCWF0b21p
Y190IHJlZmNvdW50OwogCisJaW50IG5yX3ZtYXM7CS8qIE51bWJlciBvZiBkaXJlY3QgcmVmZXJl
bmNlcyBmcm9tIHZtYXMgKi8KKwogCS8qCiAJICogTk9URTogdGhlIExTQiBvZiB0aGUgcmJfcm9v
dC5yYl9ub2RlIGlzIHNldCBieQogCSAqIG1tX3Rha2VfYWxsX2xvY2tzKCkgX2FmdGVyXyB0YWtp
bmcgdGhlIGFib3ZlIGxvY2suIFNvIHRoZQpkaWZmIC0tZ2l0IGEvbW0vcm1hcC5jIGIvbW0vcm1h
cC5jCmluZGV4IDE5ODg2ZmIuLmNlZDQ3NTQgMTAwNjQ0Ci0tLSBhL21tL3JtYXAuYworKysgYi9t
bS9ybWFwLmMKQEAgLTcyLDYgKzcyLDcgQEAgc3RhdGljIGlubGluZSBzdHJ1Y3QgYW5vbl92bWEg
KmFub25fdm1hX2FsbG9jKHZvaWQpCiAJYW5vbl92bWEgPSBrbWVtX2NhY2hlX2FsbG9jKGFub25f
dm1hX2NhY2hlcCwgR0ZQX0tFUk5FTCk7CiAJaWYgKGFub25fdm1hKSB7CiAJCWF0b21pY19zZXQo
JmFub25fdm1hLT5yZWZjb3VudCwgMSk7CisJCWFub25fdm1hLT5ucl92bWFzID0gMTsKIAkJLyoK
IAkJICogSW5pdGlhbGlzZSB0aGUgYW5vbl92bWEgcm9vdCB0byBwb2ludCB0byBpdHNlbGYuIElm
IGNhbGxlZAogCQkgKiBmcm9tIGZvcmssIHRoZSByb290IHdpbGwgYmUgcmVzZXQgdG8gdGhlIHBh
cmVudHMgYW5vbl92bWEuCkBAIC0yNTYsNyArMjU3LDExIEBAIGludCBhbm9uX3ZtYV9jbG9uZShz
dHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKmRzdCwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICpzcmMpCiAJ
CWFub25fdm1hID0gcGF2Yy0+YW5vbl92bWE7CiAJCXJvb3QgPSBsb2NrX2Fub25fdm1hX3Jvb3Qo
cm9vdCwgYW5vbl92bWEpOwogCQlhbm9uX3ZtYV9jaGFpbl9saW5rKGRzdCwgYXZjLCBhbm9uX3Zt
YSk7CisJCWlmICghZHN0LT5hbm9uX3ZtYSAmJiAhYW5vbl92bWEtPm5yX3ZtYXMpCisJCQlkc3Qt
PmFub25fdm1hID0gYW5vbl92bWE7CiAJfQorCWlmIChkc3QtPmFub25fdm1hKQorCQlkc3QtPmFu
b25fdm1hLT5ucl92bWFzKys7CiAJdW5sb2NrX2Fub25fdm1hX3Jvb3Qocm9vdCk7CiAJcmV0dXJu
IDA7CiAKQEAgLTI3OSw2ICsyODQsOSBAQCBpbnQgYW5vbl92bWFfZm9yayhzdHJ1Y3Qgdm1fYXJl
YV9zdHJ1Y3QgKnZtYSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICpwdm1hKQogCWlmICghcHZtYS0+
YW5vbl92bWEpCiAJCXJldHVybiAwOwogCisJLyogRHJvcCBwYXJlbnQgYW5vbl92bWEsIHdlIHdh
bnQgZmluZCBvciBhbGxvY2F0ZSBvdXIgb3duLiAqLworCXZtYS0+YW5vbl92bWEgPSBOVUxMOwor
CiAJLyoKIAkgKiBGaXJzdCwgYXR0YWNoIHRoZSBuZXcgVk1BIHRvIHRoZSBwYXJlbnQgVk1BJ3Mg
YW5vbl92bWFzLAogCSAqIHNvIHJtYXAgY2FuIGZpbmQgbm9uLUNPV2VkIHBhZ2VzIGluIGNoaWxk
IHByb2Nlc3Nlcy4KQEAgLTI4Niw2ICsyOTQsMTAgQEAgaW50IGFub25fdm1hX2Zvcmsoc3RydWN0
IHZtX2FyZWFfc3RydWN0ICp2bWEsIHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqcHZtYSkKIAlpZiAo
YW5vbl92bWFfY2xvbmUodm1hLCBwdm1hKSkKIAkJcmV0dXJuIC1FTk9NRU07CiAKKwkvKiBPbGQg
YW5vbl92bWEgaGFzIGJlZW4gcmV1c2VkLiAqLworCWlmICh2bWEtPmFub25fdm1hKQorCQlyZXR1
cm4gMDsKKwogCS8qIFRoZW4gYWRkIG91ciBvd24gYW5vbl92bWEuICovCiAJYW5vbl92bWEgPSBh
bm9uX3ZtYV9hbGxvYygpOwogCWlmICghYW5vbl92bWEpCkBAIC0zNDUsNiArMzU3LDggQEAgdm9p
ZCB1bmxpbmtfYW5vbl92bWFzKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hKQogCQlsaXN0X2Rl
bCgmYXZjLT5zYW1lX3ZtYSk7CiAJCWFub25fdm1hX2NoYWluX2ZyZWUoYXZjKTsKIAl9CisJaWYg
KHZtYS0+YW5vbl92bWEpCisJCXZtYS0+YW5vbl92bWEtPm5yX3ZtYXMtLTsKIAl1bmxvY2tfYW5v
bl92bWFfcm9vdChyb290KTsKIAogCS8qCg==
--047d7b15a9ad5e0d0605082a15d4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
