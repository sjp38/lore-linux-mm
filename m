Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4F4666B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 11:23:50 -0500 (EST)
Received: by bwz19 with SMTP id 19so4166890bwz.6
        for <linux-mm@kvack.org>; Wed, 24 Feb 2010 08:23:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201002232213.56455.rjw@sisk.pl>
References: <9b2b86521001020703v23152d0cy3ba2c08df88c0a79@mail.gmail.com>
	 <201002222017.55588.rjw@sisk.pl>
	 <9b2b86521002230624g20661564mc35093ee0423ff77@mail.gmail.com>
	 <201002232213.56455.rjw@sisk.pl>
Date: Wed, 24 Feb 2010 16:23:46 +0000
Message-ID: <9b2b86521002240823t126d5ad8nbd292da0f4090e6c@mail.gmail.com>
Subject: Re: s2disk hang update
From: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Content-Type: multipart/mixed; boundary=0015174be29e40ac7c04805b177c
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Mel Gorman <mel@csn.ul.ie>, hugh.dickins@tiscali.co.uk, Pavel Machek <pavel@ucw.cz>, pm list <linux-pm@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--0015174be29e40ac7c04805b177c
Content-Type: text/plain; charset=ISO-8859-1

On 2/23/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Tuesday 23 February 2010, Alan Jenkins wrote:
>> On 2/22/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>> > On Monday 22 February 2010, Alan Jenkins wrote:
>> >> Rafael J. Wysocki wrote:
>> >> > On Friday 19 February 2010, Alan Jenkins wrote:
>> >> >
>> >> >> On 2/18/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>> >> >>
>> >> >>> On Thursday 18 February 2010, Alan Jenkins wrote:
>> >> >>>
>> >> >>>> On 2/17/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>> >> >>>>
>> >> >>>>> On Wednesday 17 February 2010, Alan Jenkins wrote:
>> >> >>>>>
>> >> >>>>>> On 2/16/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>> >> >>>>>>
>> >> >>>>>>> On Tuesday 16 February 2010, Alan Jenkins wrote:
>> >> >>>>>>>
>> >> >>>>>>>> On 2/16/10, Alan Jenkins <sourcejedi.lkml@googlemail.com>
>> >> >>>>>>>> wrote:
>> >> >>>>>>>>
>> >> >>>>>>>>> On 2/15/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>> >> >>>>>>>>>
>> >> >>>>>>>>>> On Tuesday 09 February 2010, Alan Jenkins wrote:
>> >> >>>>>>>>>>
>> >> >>>>>>>>>>> Perhaps I spoke too soon.  I see the same hang if I run too
>> >> >>>>>>>>>>> many
>> >> >>>>>>>>>>> applications.  The first hibernation fails with "not enough
>> >> >>>>>>>>>>> swap"
>> >> >>>>>>>>>>> as
>> >> >>>>>>>>>>> expected, but the second or third attempt hangs (with the
>> >> >>>>>>>>>>> same
>> >> >>>>>>>>>>> backtrace
>> >> >>>>>>>>>>> as before).
>> >> >>>>>>>>>>>
>> >> >>>>>>>>>>> The patch definitely helps though.  Without the patch, I
>> >> >>>>>>>>>>> see a
>> >> >>>>>>>>>>> hang
>> >> >>>>>>>>>>> the
>> >> >>>>>>>>>>> first time I try to hibernate with too many applications
>> >> >>>>>>>>>>> running.
>> >> >>>>>>>>>>>
>> >> >>>>>>>>>> Well, I have an idea.
>> >> >>>>>>>>>>
>> >> >>>>>>>>>> Can you try to apply the appended patch in addition and see
>> >> >>>>>>>>>> if
>> >> >>>>>>>>>> that
>> >> >>>>>>>>>> helps?
>> >> >>>>>>>>>>
>> >> >>>>>>>>>> Rafael
>> >> >>>>>>>>>>
>> >> >>>>>>>>> It doesn't seem to help.
>> >> >>>>>>>>>
>> >> >>>>>>>> To be clear: It doesn't stop the hang when I hibernate with
>> >> >>>>>>>> too
>> >> >>>>>>>> many
>> >> >>>>>>>> applications.
>> >> >>>>>>>>
>> >> >>>>>>>> It does stop the same hang in a different case though.
>> >> >>>>>>>>
>> >> >>>>>>>> 1. boot with init=/bin/bash
>> >> >>>>>>>> 2. run s2disk
>> >> >>>>>>>> 3. cancel the s2disk
>> >> >>>>>>>> 4. repeat steps 2&3
>> >> >>>>>>>>
>> >> >>>>>>>> With the patch, I can run 10s of iterations, with no hang.
>> >> >>>>>>>> Without the patch, it soon hangs, (in disable_nonboot_cpus(),
>> >> >>>>>>>> as
>> >> >>>>>>>> always).
>> >> >>>>>>>>
>> >> >>>>>>>> That's what happens on 2.6.33-rc7.  On 2.6.30, there is no
>> >> >>>>>>>> problem.
>> >> >>>>>>>> On 2.6.31 and 2.6.32 I don't get a hang, but dmesg shows an
>> >> >>>>>>>> allocation
>> >> >>>>>>>> failure after a couple of iterations ("kthreadd: page
>> >> >>>>>>>> allocation
>> >> >>>>>>>> failure. order:1, mode:0xd0").  It looks like it might be the
>> >> >>>>>>>> same
>> >> >>>>>>>> stop_machine thread allocation failure that causes the hang.
>> >> >>>>>>>>
>> >> >>>>>>> Have you tested it alone or on top of the previous one?  If
>> >> >>>>>>> you've
>> >> >>>>>>> tested it
>> >> >>>>>>> alone, please apply the appended one in addition to it and
>> >> >>>>>>> retest.
>> >> >>>>>>>
>> >> >>>>>>> Rafael
>> >> >>>>>>>
>> >> >>>>>> I did test with both patches applied together -
>> >> >>>>>>
>> >> >>>>>> 1. [Update] MM / PM: Force GFP_NOIO during suspend/hibernation
>> >> >>>>>> and
>> >> >>>>>> resume
>> >> >>>>>> 2. "reducing the number of pages that we're going to keep
>> >> >>>>>> preallocated
>> >> >>>>>> by
>> >> >>>>>> 20%"
>> >> >>>>>>
>> >> >>>>> In that case you can try to reduce the number of preallocated
>> >> >>>>> pages
>> >> >>>>> even
>> >> >>>>> more,
>> >> >>>>> ie. change "/ 5" to "/ 2" (for example) in the second patch.
>> >> >>>>>
>> >> >>>> It still hangs if I try to hibernate a couple of times with too
>> >> >>>> many
>> >> >>>> applications.
>> >> >>>>
>> >> >>> Hmm.  I guess I asked that before, but is this a 32-bit or 64-bit
>> >> >>> system and
>> >> >>> how much RAM is there in the box?
>> >> >>>
>> >> >>> Rafael
>> >> >>>
>> >> >> EeePC 701.  32 bit.  512Mb RAM.  350Mb swap file, on a "first-gen"
>> >> >> SSD.
>> >> >>
>> >> >
>> >> > Hmm.  I'd try to make  free_unnecessary_pages() free all of the
>> >> > preallocated
>> >> > pages and see what happens.
>> >> >
>> >>
>> >> It still hangs in hibernation_snapshot() / disable_nonboot_cpus().
>> >> After apparently freeing over 400Mb / 100,000 pages of preallocated
>> >> ram.
>> >>
>> >>
>> >>
>> >> There is a change which I missed before.  When I applied your first
>> >> patch ("Force GFP_NOIO during suspend" etc.), it did change the hung
>> >> task backtraces a bit.  I don't know if it tells us anything.
>> >>
>> >> Without the patch, there were two backtraces.  The first backtrace
>> >> suggested a problem allocating pages for a kernel thread (at
>> >> copy_process() / try_to_free_pages()).  The second showed that this
>> >> problem was blocking s2disk (at hibernation_snapshot() /
>> >> disable_nonboot_cpus() / stop_machine_create()).
>> >>
>> >> With the GFP_NOIO patch, I see only the s2disk backtrace.
>> >
>> > Can you please post this backtrace?
>>
>> Sure.  It's rather like the one I posted before, except
>>
>> a) it only shows the one hung task (s2disk)
>> b) this time I had lockdep enabled
>> c) this time most of the lines don't have question marks.
>
> Well, it still looks like we're waiting for create_workqueue_thread() to
> return, which probably is trying to allocate memory for the thread
> structure.
>
> My guess is that the preallocated memory pages freed by
> free_unnecessary_pages() go into a place from where they cannot be taken for
> subsequent NOIO allocations.  I have no idea why that happens though.
>
> To test that theory you can try to change GFP_IOFS to GFP_KERNEL in the
> calls to clear_gfp_allowed_mask() in kernel/power/hibernate.c (and in
> kernel/power/suspend.c for completness).

Effectively forcing GFP_NOWAIT, so the allocation should fail instead
of hanging?

It seems to stop the hang, but I don't see any other difference - the
hibernation process isn't stopped earlier, and I don't get any new
kernel messages about allocation failures.  I wonder if it's because
GFP_NOWAIT triggers ALLOC_HARDER.

I have other evidence which argues for your theory:

[ successful s2disk, with forced NOIO (but not NOWAIT), and test code
as attached ]

 Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
 1280 GFP_NOWAIT allocations of order 0 are possible
 640 GFP_NOWAIT allocations of order 1 are possible
 320 GFP_NOWAIT allocations of order 2 are possible

[ note - 1280 pages is the maximum test allocation used here.  The
test code is only accurate when talking about smaller numbers of free
pages ]

 1280 GFP_KERNEL allocations of order 0 are possible
 640 GFP_KERNEL allocations of order 1 are possible
 320 GFP_KERNEL allocations of order 2 are possible

 PM: Preallocating image memory...
 212 GFP_NOWAIT allocations of order 0 are possible
 102 GFP_NOWAIT allocations of order 1 are possible
 50 GFP_NOWAIT allocations of order 2 are possible

 Freeing all 90083 preallocated pages
 (and 0 highmem pages, out of 0)
 190 GFP_NOWAIT allocations of order 0 are possible
 102 GFP_NOWAIT allocations of order 1 are possible
 50 GFP_NOWAIT allocations of order 2 are possible
 1280 GFP_KERNEL allocations of order 0 are possible
 640 GFP_KERNEL allocations of order 1 are possible
 320 GFP_KERNEL allocations of order 2 are possible
 done (allocated 90083 pages)

It looks like you're right and the freed pages are not accessible with
GFP_NOWAIT for some reason.

I also tried a number of test runs with too many applications, and saw this:

Freeing all 104006 preallocated pages ...
65 GFP_NOWAIT allocations of order 0 ...
18 GFP_NOWAIT allocations of order 1 ...
9 GFP_NOWAIT allocations of order 2 ...
0 GFP_KERNEL allocations of order 0 are possible
...
Disabling nonboot cpus ...
...
PM: Hibernation image created
Force enabled HPET at resume
PM: early thaw of devices complete after ... msecs

<hang, no backtrace visible even after 120 seconds>

I'm not bothered by the new hang; the test code will inevitably have
some side effects.  I'm not sure why GFP_KERNEL allocations would fail
in this scenario though...  perhaps the difference is that we've
swapped out the entire userspace so GFP_IO doesn't help.

Regards
Alan

--0015174be29e40ac7c04805b177c
Content-Type: text/x-patch; charset=US-ASCII; name="check-free.patch"
Content-Disposition: attachment; filename="check-free.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: file1

ZGlmZiAtLWdpdCBhL2tlcm5lbC9wb3dlci9oaWJlcm5hdGUuYyBiL2tlcm5lbC9wb3dlci9oaWJl
cm5hdGUuYwppbmRleCBkYTUyODhlLi4yZTI0NWQ5IDEwMDY0NAotLS0gYS9rZXJuZWwvcG93ZXIv
aGliZXJuYXRlLmMKKysrIGIva2VybmVsL3Bvd2VyL2hpYmVybmF0ZS5jCkBAIC0yNjIsNiArMjYy
LDcgQEAgc3RhdGljIGludCBjcmVhdGVfaW1hZ2UoaW50IHBsYXRmb3JtX21vZGUpCiAJaWYgKGVy
cm9yIHx8IGhpYmVybmF0aW9uX3Rlc3QoVEVTVF9QTEFURk9STSkpCiAJCWdvdG8gUGxhdGZvcm1f
ZmluaXNoOwogCisJY2hlY2tfZnJlZShHRlBfTk9XQUlUKTsKIAllcnJvciA9IGRpc2FibGVfbm9u
Ym9vdF9jcHVzKCk7CiAJaWYgKGVycm9yIHx8IGhpYmVybmF0aW9uX3Rlc3QoVEVTVF9DUFVTKQog
CSAgICB8fCBoaWJlcm5hdGlvbl90ZXN0bW9kZShISUJFUk5BVElPTl9URVNUKSkKZGlmZiAtLWdp
dCBhL2tlcm5lbC9wb3dlci9wb3dlci5oIGIva2VybmVsL3Bvd2VyL3Bvd2VyLmgKaW5kZXggNDZj
NWEyNi4uZDIxNzhkYyAxMDA2NDQKLS0tIGEva2VybmVsL3Bvd2VyL3Bvd2VyLmgKKysrIGIva2Vy
bmVsL3Bvd2VyL3Bvd2VyLmgKQEAgLTIzNiwzICsyMzYsNTMgQEAgc3RhdGljIGlubGluZSB2b2lk
IHN1c3BlbmRfdGhhd19wcm9jZXNzZXModm9pZCkKIHsKIH0KICNlbmRpZgorCisvKiBBbiBlbXBp
cmljYWwgY2hlY2sgb24gdGhlIG51bWJlciBvZiBmcmVlIHBhZ2VzICovCitzdGF0aWMgaW5saW5l
IGludCBjaGVja19mcmVlX3BhZ2VzKGdmcF90IGdmcF9mbGFncywgY29uc3QgY2hhciAqZ2ZwX25h
bWUsIGludCBvcmRlcikKK3sKKwlpbnQgcmV0OworCWludCBjb3VudCA9IDA7CisJdm9pZCAqZmly
c3QgPSBOVUxMOworCXZvaWQgKipwID0gJmZpcnN0OworCXVuc2lnbmVkIGxvbmcgcGFnZTsKKwor
CS8qIEFsbG9jYXRlIGZyZWUgcGFnZXMgaW50byBhIGxpbmtlZCBsaXN0LCBoZWFkZWQgYnkgImZp
cnN0IiAqLworCXdoaWxlKGNvdW50IDwgKChQQUdFU19GT1JfSU8gKyBTUEFSRV9QQUdFUykgPj4g
b3JkZXIpKSB7CisJCXBhZ2UgPSBfX2dldF9mcmVlX3BhZ2VzKGdmcF9mbGFnc3xfX0dGUF9OT1dB
Uk4sIG9yZGVyKTsKKwkJaWYgKCFwYWdlKQorCQkJYnJlYWs7CisJCSpwID0gKHZvaWQgKilwYWdl
OworCQlwID0gKHZvaWQgKiopcGFnZTsKKwkJY291bnQrKzsKKwl9CisJKnAgPSBOVUxMOworCisJ
cmV0ID0gY291bnQ7CisJcHJpbnRrKEtFUk5fSU5GTworCQkiJWQgJXMgYWxsb2NhdGlvbnMgb2Yg
b3JkZXIgJWQgYXJlIHBvc3NpYmxlXG4iLAorCQljb3VudCwgZ2ZwX25hbWUsIG9yZGVyKTsKKwor
CS8qIEZyZWUgdGhlIHBhZ2VzIGFnYWluICovCisJcCA9IGZpcnN0OworCXdoaWxlKHApIHsKKwkJ
cGFnZSA9ICh1bnNpZ25lZCBsb25nKSBwOworCQlwID0gKnA7CisJCWZyZWVfcGFnZXMocGFnZSwg
b3JkZXIpOworCQljb3VudC0tOworCX0KKwlCVUdfT04oY291bnQgIT0gMCk7CisKKwlyZXR1cm4g
cmV0OworfQorCitzdGF0aWMgaW5saW5lIHZvaWQgX19jaGVja19mcmVlKGdmcF90IGdmcF9mbGFn
cywgY29uc3QgY2hhciAqZ2ZwX25hbWUpCit7CisJaW50IG9yZGVyOworCisJZm9yIChvcmRlciA9
IDA7IG9yZGVyIDwgMzsgb3JkZXIrKykKKwkJaWYgKGNoZWNrX2ZyZWVfcGFnZXMoZ2ZwX2ZsYWdz
LCBnZnBfbmFtZSwgb3JkZXIpIDw9IDApCisJCQlicmVhazsKK30KKworI2RlZmluZSBjaGVja19m
cmVlKGZsYWdzKSBfX2NoZWNrX2ZyZWUoZmxhZ3MsICNmbGFncykKKwpkaWZmIC0tZ2l0IGEva2Vy
bmVsL3Bvd2VyL3NuYXBzaG90LmMgYi9rZXJuZWwvcG93ZXIvc25hcHNob3QuYwppbmRleCAzNmNi
MTY4Li42MDViN2I3IDEwMDY0NAotLS0gYS9rZXJuZWwvcG93ZXIvc25hcHNob3QuYworKysgYi9r
ZXJuZWwvcG93ZXIvc25hcHNob3QuYwpAQCAtMTI2MSw2ICsxMjYxLDggQEAgaW50IGhpYmVybmF0
ZV9wcmVhbGxvY2F0ZV9tZW1vcnkodm9pZCkKIAlzdHJ1Y3QgdGltZXZhbCBzdGFydCwgc3RvcDsK
IAlpbnQgZXJyb3I7CiAKKwljaGVja19mcmVlKEdGUF9OT1dBSVQpOworCWNoZWNrX2ZyZWUoR0ZQ
X0tFUk5FTCk7CiAJcHJpbnRrKEtFUk5fSU5GTyAiUE06IFByZWFsbG9jYXRpbmcgaW1hZ2UgbWVt
b3J5Li4uICIpOwogCWRvX2dldHRpbWVvZmRheSgmc3RhcnQpOwogCkBAIC0xMzUwLDcgKzEzNTIs
MTAgQEAgaW50IGhpYmVybmF0ZV9wcmVhbGxvY2F0ZV9tZW1vcnkodm9pZCkKIAkgKiBwYWdlcyBp
biBtZW1vcnksIGJ1dCB3ZSBoYXZlIGFsbG9jYXRlZCBtb3JlLiAgUmVsZWFzZSB0aGUgZXhjZXNz
aXZlCiAJICogb25lcyBub3cuCiAJICovCisJY2hlY2tfZnJlZShHRlBfTk9XQUlUKTsKIAlmcmVl
X3VubmVjZXNzYXJ5X3BhZ2VzKCk7CisJY2hlY2tfZnJlZShHRlBfTk9XQUlUKTsKKwljaGVja19m
cmVlKEdGUF9LRVJORUwpOwogCiAgb3V0OgogCWRvX2dldHRpbWVvZmRheSgmc3RvcCk7Cg==
--0015174be29e40ac7c04805b177c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
