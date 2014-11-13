Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id B201B6B00D4
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 18:50:04 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id hy10so293561vcb.14
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 15:50:04 -0800 (PST)
Received: from mail-vc0-x232.google.com (mail-vc0-x232.google.com. [2607:f8b0:400c:c03::232])
        by mx.google.com with ESMTPS id 9si17147676vcq.96.2014.11.13.15.50.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 15:50:03 -0800 (PST)
Received: by mail-vc0-f178.google.com with SMTP id hq12so4865723vcb.23
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 15:50:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
	<1415644096-3513-4-git-send-email-j.glisse@gmail.com>
	<CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
	<20141110205814.GA4186@gmail.com>
	<CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
	<20141110225036.GB4186@gmail.com>
	<CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
Date: Thu, 13 Nov 2014 15:50:02 -0800
Message-ID: <CA+55aFxYnBxGZr3ed0i46SpSdOj+3VSVBZiqRbdJuwFMuTmxDw@mail.gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/mixed; boundary=001a1133e720c6c7210507c62bef
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

--001a1133e720c6c7210507c62bef
Content-Type: text/plain; charset=UTF-8

On Mon, Nov 10, 2014 at 3:53 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So I am fine with that, it's the details that confuse me. The thing
> doesn't seem to be generic enough to be used for arbitrary page
> tables, with (for example) the shifts fixed by the VM page size and
> the size of the pte entry type. Also, the levels seem to be very
> infexible, with the page table entries being the simple case, but then
> you have that "pdep" thing that seems to be just _one_ level of page
> directory.

Ok, so let me just put my money where my mouth is, and show some
example code of a tree walker that I think is actually more generic.
Sorry for the delay, I got distracted by other things, and I wanted to
write something to show what I think might be a better approach.

NOTE NOTE NOTE! I'm not saying you have to do it this way. But before
I even show the patch, let me show you the "tree descriptor" from my
stupid test-program that uses it, and hopefully that will show what
I'm really aiming for:

    struct tree_walker_definition x86_64_def = {
        .total_bits = 48,
        .start = 0,
        .end = 0x7fffffffffff,
        .levels = {
            { .level_bits = 9, .lookup = pgd_lookup },
            { .level_bits = 9, .lookup = pud_lookup },
            { .level_bits = 9, .lookup = pmd_lookup },
            { .level_bits = 9, .walker = pte_walker }
        }
    };

so basically, the *concept* is that you can describe a real page table
by actually *describing* it. What the above does is tell you:

 - the amount of bits the tables can cover (48 is four levels of 9
bits each, leaving 12 bits - 4096 bytes - for the actual pages)

 - limit the range that can be walked (this isn't really all that
important, but it does, for example, mean that the walker will
fundamentally refuse to give access to the kernel mapping)

 - show how the different levels work, and what their sizes are and
how you look them up or walk them, starting from the top-most.

Anyway, I think a descriptor like the above looks *understandable*. It
kind of stands on its own, even without showing the actual code.

Now, the code to actually *walk* the above tree looks like this:

       struct tree_walker walk = {
               .first = 4096,
               .last = 4096*512*3,
               .walk = show_walk,
               .hole = show_hole,
               .pre_walk = show_pre_walk,
               .post_walk = show_post_walk,
       };

       walk_tree((struct tree_entry *)pgd, &x86_64_def, &walk);

ie you use the "walk_tree()" function to walk a particular tree (in
this case it's a fake page table directory in "pgd", see the details
in the stupid test-application), giving it the tree definition and the
"walk" parameters that show what should happen for particular details
(quite often hole/pre-walk/post-walk may be NULL, my test app just
shows them being called).

Now,. in addition to that, each tree description obviously needs the
functions to show how to look up the different levels ("lookup" for
moving from one level to another, and "walker" for actually walking
the last level page table knowing how "present" bits etc work.

Now, your code had a "uint64_t mask" for the present bits, which
probably works reasonably well in practice, but I really prefer to
just have that "walker" callback instead. That way the page tables can
look like *anything*, and you can walk them, without having magic
rules that there has to be a particular bit pattern that says it's
"present".

Also, my walker actually does super-pages - ie one of the mid-level
page tables could map one big area. I didn't much test it, but the
code is actually fairly straightforward, the way it's all been set up.
So it might be buggy, but it's *close*.

Now, one place we differ is on locking. I actually think that the
person who asks to walk the tree should just do the locking
themselves. You can't really walk the tree without knowing what kind
of tree it is, and so I think the caller should just do the locking.
Obviously, the tree walker itself may have some locking in the
"pre_walk/post_walk" thing and in its lookup routines, so the
description of the tree can contain some locking of its own, but I did
*not* want to make the infrastructure itself force any particular
locking strategy.

So this does something quite different from what your patch actually
did, and does that different thing very differently. It may not really
match what you are aiming for, but I'd *really* like the first
implementation of HMM that gets merged to not over-design the locking
(which I think yours did), and I want it to make *sense* (which I
don't think your patch did).

Also, please note that this *is* just an example. It has an example
user (that is just a stupid user-level toy app to show how it all is
put together), but it's not necessarily all that featureful, and it's
definitely not very tested.

But the code is actually fairly simple. But judge for yourself.

                         Linus

--001a1133e720c6c7210507c62bef
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i2grra210

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvd2Fsa190YWJsZXMuaCBiL2luY2x1ZGUvbGludXgv
d2Fsa190YWJsZXMuaApuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwMDAwMDAuLjM5
OGJlNjBlODU0YQotLS0gL2Rldi9udWxsCisrKyBiL2luY2x1ZGUvbGludXgvd2Fsa190YWJsZXMu
aApAQCAtMCwwICsxLDg4IEBACisvKgorICogQ29weXJpZ2h0IDIwMTQgTGludXMgVG9ydmFsZHMK
KyAqCisgKiBUaGlzIGNvZGUgaXMgZGlzdHJ1YnV0ZWQgdW5kZXIgdGhlIEdQTHYyCisgKi8KKyNp
Zm5kZWYgX19MSU5VWF9XQUxLX1RBQkxFX0gKKyNkZWZpbmUgX19MSU5VWF9XQUxLX1RBQkxFX0gK
Kworc3RydWN0IHRyZWVfZW50cnk7CitzdHJ1Y3QgdHJlZV93YWxrZXJfZGVmaW5pdGlvbjsKKwor
LyoKKyAqIFRoZSAndHJlZV9sZXZlbCcgZGF0YSBvbmx5IGRlc2NyaWJlcyBvbmUgcGFydGljdWxh
ciBsZXZlbAorICogb2YgdGhlIHRyZWUuIFRoZSB1cHBlciBsZXZlbHMgYXJlIHRvdGFsbHkgaW52
aXNpYmxlIHRvIHRoZQorICogdXNlciBvZiB0aGUgdHJlZSB3YWxrZXIsIHNpbmNlIHRoZSB0cmVl
IHdhbGtlciB3aWxsIHdhbGsKKyAqIHRob3NlIHVzaW5nIHRoZSB0cmVlIGRlZmluaXRpb25zLgor
ICoKKyAqIE5PVEUhICJzdHJ1Y3QgdHJlZV9lbnRyeSIgaXMgYW4gb3BhcXVlIHR5cGUsIGFuZCBp
cyBqdXN0IGEKKyAqIHVzZWQgYXMgYSBwb2ludGVyIHRvIHRoZSBwYXJ0aWN1bGFyIGxldmVsLiBZ
b3UgY2FuIGZpZ3VyZQorICogb3V0IHdoaWNoIGxldmVsIHlvdSBhcmUgYXQgYnkgbG9va2luZyBh
dCB0aGUgInRyZWVfbGV2ZWwiLAorICogYnV0IGV2ZW4gYmV0dGVyIGlzIHRvIGp1c3QgdXNlIGRp
ZmZlcmVudCAibG9va3VwKCkiCisgKiBmdW5jdGlvbnMgZm9yIGRpZmZlcmVudCBsZXZlbHMsIGF0
IHdoaWNoIHBvaW50IHRoZQorICogZnVuY3Rpb24gaXMgaW5oZXJlbnQgdG8gdGhlIGxldmVsLgor
ICoKKyAqIE5PVEUgMiEgU29tZSB0cmVlcyBhcmUgZml4ZWQtZGVwdGgsIG90aGVycyBhcmUgbm90
LiBFYWNoIGxldmVsCisgKiBoYXMgYSBsb29rdXAgZnVuY3Rpb24sIGFuZCBjYW4gc3BlY2lmeSB3
aGV0aGVyIHRoZXkgYXJlIGEKKyAqIHRlcm1pbmFsIGxldmVsLiBJdCBzaG91bGQgYWxzbyBmaWxs
IGluIHRoZSAic3RhcnQiIGZpZWxkIG9mCisgKiB0aGUgdHJlZV9sZXZlbCBpbmZvcm1hdGlvbiB0
byBwb2ludCB0byB0aGUgbmV4dCBsZXZlbCAob3IKKyAqIHRvIHRoZSBkYXRhKS4gQSBOVUxMIHN0
YXJ0IGlzIGNvbnNpZGVyZWQgdG8gYmUgYSBob2xlLgorICoKKyAqIFlvdSB3b24ndCBzZWUgdGhp
cyBob2xlIGluIHRoZSAid2FsaygpIiBjYWxsYmFjaywgYnV0IGhvbGVzIGRvIGdldAorICogdGhl
IHByZS13YWxrIGNhbGxiYWNrIHNvIHRoYXQgeW91IGNhbiB0cmFjayBob2xlcyB0b28uCisgKgor
ICogSWYgYSAibG9va3VwKCkiIGZ1bmN0aW9uIHJldHVybnMgdGhhdCBpdCdzIGEgdGVybWluYWwg
ZW50cnkgYW5kCisgKiBoYXMgYSBub24tTlVMTCAic3RhcnQiLCB3ZSdsbCBjYWxsIHRoZSAid2Fs
aygpIiBmdW5jdGlvbiB3aXRoIHRoYXQKKyAqIHRyZWUtZW50cnkgX29uY2VfLCBhc3N1bWluZyBp
dCdzIGEgInN1cGVycGFnZSIgdGhhdCBsb29rcyBsaWtlCisgKiBhIG5vcm1hbCBmaW5hbCB0cmVl
LWVudHJ5IGJ1dCBpcyBqdXN0IG11Y2ggbGFyZ2VyLiBUaGUgd2FsayBmdW5jdGlvbgorICogY2Fu
IHRlbGwgZnJvbSB0aGUgc2l6ZSB3ZSBnaXZlIGl0LgorICoKKyAqIE5PVEUgMyEgVGhlIGxhc3Qg
bGV2ZWwgbm9ybWFsbHkgZG9lc24ndCBoYXZlIGEgKCpsb29rdXApKCkKKyAqIGZ1bmN0aW9uIGF0
IGFsbCwganVzdCBhICJ3YWxrIiBmdW5jdGlvbi4gRm9yIHRoYXQgY2FzZSwgd2UnbGwKKyAqIGNh
bGwgdGhlIHRyZWUgZGVmaW5pdGlvbiAid2Fsa2VyKCkiIGZ1bmN0aW9uIGluc3RlYWQgb2YKKyAq
IHRyeWluZyB0byBsb29rIGFueXRoaW5nIHVwLCBhbmQgaXQgaXMgc3VwcG9zZWQgdG8gY2FsbCB0
aGUKKyAqICJ3YWxrKCknIGNhbGxiYWNrIGZvciBlYWNoIGVudHJ5LgorICovCitzdHJ1Y3QgdHJl
ZV9sZXZlbCB7CisJdW5zaWduZWQgaW50IGVudHJ5X2xldmVsOworCXVuc2lnbmVkIGludCBucl9l
bnRyaWVzOworCXVuc2lnbmVkIGludCBlbnRyeV9jb3ZlcmFnZTsKKwl1bnNpZ25lZCBsb25nIHN0
YXJ0LCBlbmQ7CisJc3RydWN0IHRyZWVfZW50cnkgKmVudHJ5OworfTsKKworc3RydWN0IHRyZWVf
d2Fsa2VyIHsKKwl1bnNpZ25lZCBsb25nIGZpcnN0LCBsYXN0OworCWNvbnN0IHZvaWQgKmRhdGE7
CisJY29uc3Qgc3RydWN0IHRyZWVfd2Fsa2VyX2RlZmluaXRpb24gKmRlZjsKKwlpbnQgKCp3YWxr
KShjb25zdCBzdHJ1Y3QgdHJlZV93YWxrZXIgKiwgc3RydWN0IHRyZWVfZW50cnkgKiwgdW5zaWdu
ZWQgbG9uZywgdW5zaWduZWQgaW50KTsKKwlpbnQgKCpob2xlKShjb25zdCBzdHJ1Y3QgdHJlZV93
YWxrZXIgKiwgY29uc3Qgc3RydWN0IHRyZWVfbGV2ZWwgKik7CisJaW50ICgqcHJlX3dhbGspKGNv
bnN0IHN0cnVjdCB0cmVlX3dhbGtlciAqLCBjb25zdCBzdHJ1Y3QgdHJlZV9sZXZlbCAqKTsKKwlp
bnQgKCpwb3N0X3dhbGspKGNvbnN0IHN0cnVjdCB0cmVlX3dhbGtlciAqLCBjb25zdCBzdHJ1Y3Qg
dHJlZV9sZXZlbCAqKTsKK307CisKKy8qCisgKiBUaGUgImxvb2t1cCgpIiBmdW5jdGlvbiBuZWVk
cyB0byByZXR1cm4gd2hldGhlciB0aGlzIGlzIGEgdGVybWluYWwKKyAqIGxldmVsIG9yIG5vdC4K
KyAqLworZW51bSB3YWxrX3RyZWVfbG9va3VwIHsKKwlXQUxLX1RSRUVfREVTQ0VORCwKKwlXQUxL
X1RSRUVfSE9MRSwKKwlXQUxLX1RSRUVfU1VQRVJFTlRSWSwKK307CisKK3N0cnVjdCB0cmVlX3dh
bGtlcl9sZXZlbF9kZWZpbml0aW9uIHsKKwl1bnNpZ25lZCBpbnQgbGV2ZWxfYml0czsKKwllbnVt
IHdhbGtfdHJlZV9sb29rdXAgKCpsb29rdXApKHN0cnVjdCB0cmVlX2VudHJ5ICosIHVuc2lnbmVk
IGludCwgc3RydWN0IHRyZWVfbGV2ZWwgKik7CisJaW50ICgqd2Fsa2VyKShjb25zdCBzdHJ1Y3Qg
dHJlZV93YWxrZXIgKiwgY29uc3Qgc3RydWN0IHRyZWVfbGV2ZWwgKik7Cit9OworCitzdHJ1Y3Qg
dHJlZV93YWxrZXJfZGVmaW5pdGlvbiB7CisJdW5zaWduZWQgaW50IHRvdGFsX2JpdHM7CisJdW5z
aWduZWQgbG9uZyBzdGFydCwgZW5kOworCXN0cnVjdCB0cmVlX3dhbGtlcl9sZXZlbF9kZWZpbml0
aW9uIGxldmVsc1tdOworfTsKKworaW50IHdhbGtfdHJlZShzdHJ1Y3QgdHJlZV9lbnRyeSAqcm9v
dCwgY29uc3Qgc3RydWN0IHRyZWVfd2Fsa2VyX2RlZmluaXRpb24gKiwgc3RydWN0IHRyZWVfd2Fs
a2VyICopOworCisjZW5kaWYgLyogX19MSU5VWF9XQUxLX1RBQkxFX0ggKi8KZGlmZiAtLWdpdCBh
L2xpYi93YWxrX3RhYmxlcy5jIGIvbGliL3dhbGtfdGFibGVzLmMKbmV3IGZpbGUgbW9kZSAxMDA2
NDQKaW5kZXggMDAwMDAwMDAwMDAwLi5mNjNhYzgzZjkxZDcKLS0tIC9kZXYvbnVsbAorKysgYi9s
aWIvd2Fsa190YWJsZXMuYwpAQCAtMCwwICsxLDY4IEBACisvKgorICogQ29weXJpZ2h0IDIwMTQg
TGludXMgVG9ydmFsZHMKKyAqCisgKiBUaGlzIGNvZGUgaXMgZGlzdHJ1YnV0ZWQgdW5kZXIgdGhl
IEdQTHYyCisgKi8KKyNpbmNsdWRlIDxsaW51eC93YWxrX3RhYmxlcy5oPgorCitpbnQgd2Fsa190
cmVlKHN0cnVjdCB0cmVlX2VudHJ5ICpyb290LCBjb25zdCBzdHJ1Y3QgdHJlZV93YWxrZXJfZGVm
aW5pdGlvbiAqZGVmLCBzdHJ1Y3QgdHJlZV93YWxrZXIgKndhbGspCit7CisJd2Fsay0+ZGVmID0g
ZGVmOworCWlmICh3YWxrLT5maXJzdCA8IGRlZi0+c3RhcnQpCisJCXdhbGstPmZpcnN0ID0gZGVm
LT5zdGFydDsKKwlpZiAod2Fsay0+bGFzdCA+IGRlZi0+ZW5kKQorCQl3YWxrLT5sYXN0ID0gZGVm
LT5lbmQ7CisJd2hpbGUgKHdhbGstPmZpcnN0IDwgd2Fsay0+bGFzdCkgeworCQljb25zdCBzdHJ1
Y3QgdHJlZV93YWxrZXJfbGV2ZWxfZGVmaW5pdGlvbiAqbGRlZiA9IGRlZi0+bGV2ZWxzOworCQl1
bnNpZ25lZCBpbnQgc2hpZnQgPSBkZWYtPnRvdGFsX2JpdHM7CisJCXN0cnVjdCB0cmVlX2xldmVs
IGxldmVsOworCQlzdHJ1Y3QgdHJlZV9lbnRyeSAqdHJlZSA9IHJvb3Q7CisKKwkJZm9yIChsZXZl
bC5lbnRyeV9sZXZlbCA9IDA7IDsgbGV2ZWwuZW50cnlfbGV2ZWwrKykgeworCQkJdW5zaWduZWQg
bG9uZyBtYXNrID0gKDF1bCA8PCBzaGlmdCktMTsKKworCQkJLyogRmlsbCBpbiB0aGUgbGV2ZWwg
ZGVzY3JpcHRpb24gKi8KKwkJCWxldmVsLm5yX2VudHJpZXMgPSAxdSA8PCBsZGVmLT5sZXZlbF9i
aXRzOworCQkJbGV2ZWwuZW50cnlfY292ZXJhZ2UgPSAxdWwgPDwgKHNoaWZ0IC0gbGRlZi0+bGV2
ZWxfYml0cyk7CisJCQlsZXZlbC5zdGFydCA9IHdhbGstPmZpcnN0OworCQkJbGV2ZWwuZW5kID0g
KGxldmVsLnN0YXJ0IHwgbWFzaykrMTsKKwkJCWlmIChsZXZlbC5lbmQgPiB3YWxrLT5sYXN0KQor
CQkJCWxldmVsLmVuZCA9IHdhbGstPmxhc3Q7CisKKwkJCWlmIChsZGVmLT5sb29rdXApIHsKKwkJ
CQl1bnNpZ25lZCBpbnQgaW5kZXggPSBsZXZlbC5zdGFydCA+PiAoc2hpZnQgLSBsZGVmLT5sZXZl
bF9iaXRzKTsKKwkJCQlpbmRleCAmPSBsZXZlbC5ucl9lbnRyaWVzLTE7CisKKwkJCQlzd2l0Y2gg
KGxkZWYtPmxvb2t1cCh0cmVlLCBpbmRleCwgJmxldmVsKSkgeworCQkJCWNhc2UgV0FMS19UUkVF
X0RFU0NFTkQ6CisJCQkJCXRyZWUgPSBsZXZlbC5lbnRyeTsKKwkJCQkJc2hpZnQgLT0gbGRlZi0+
bGV2ZWxfYml0czsKKwkJCQkJbGRlZisrOworCQkJCQljb250aW51ZTsKKworCQkJCWNhc2UgV0FM
S19UUkVFX0hPTEU6CisJCQkJCWlmICh3YWxrLT5ob2xlKQorCQkJCQkJd2Fsay0+aG9sZSh3YWxr
LCAmbGV2ZWwpOworCQkJCQlicmVhazsKKworCQkJCWNhc2UgV0FMS19UUkVFX1NVUEVSRU5UUlk6
CisJCQkJCWlmICh3YWxrLT53YWxrKQorCQkJCQkJd2Fsay0+d2Fsayh3YWxrLCBsZXZlbC5lbnRy
eSwgbGV2ZWwuc3RhcnQsIGxldmVsLmVuZCAtIGxldmVsLnN0YXJ0KTsKKwkJCQkJYnJlYWs7CisJ
CQkJfQorCQkJfSBlbHNlIHsKKwkJCQlpZiAod2Fsay0+cHJlX3dhbGspCisJCQkJCXdhbGstPnBy
ZV93YWxrKHdhbGssICZsZXZlbCk7CisJCQkJaWYgKHdhbGstPndhbGspCisJCQkJCWxkZWYtPndh
bGtlcih3YWxrLCAmbGV2ZWwpOworCQkJCWlmICh3YWxrLT5wb3N0X3dhbGspCisJCQkJCXdhbGst
PnBvc3Rfd2Fsayh3YWxrLCAmbGV2ZWwpOworCQkJfQorCisJCQkvKiBPaywgZG9uZSB3aXRoIHRo
aXMgbGV2ZWwgKi8KKwkJCXdhbGstPmZpcnN0ID0gbGV2ZWwuZW5kOworCQkJYnJlYWs7CisJCX0K
Kwl9CisJcmV0dXJuIDA7Cit9CmRpZmYgLS1naXQgYS90ZXN0X3RhYmxlcy5jIGIvdGVzdF90YWJs
ZXMuYwpuZXcgZmlsZSBtb2RlIDEwMDY0NAppbmRleCAwMDAwMDAwMDAwMDAuLmI1MGNlMzM4MDdm
ZgotLS0gL2Rldi9udWxsCisrKyBiL3Rlc3RfdGFibGVzLmMKQEAgLTAsMCArMSwxMDEgQEAKKyNp
bmNsdWRlIDxzdGRpby5oPgorI2luY2x1ZGUgImluY2x1ZGUvbGludXgvd2Fsa190YWJsZXMuaCIK
KworLyogRmFrZSB4ODYtNjQtbGlrZSBkZWZpbml0aW9ucyAqLworI2RlZmluZSBQUkVTRU5UCQko
MXVsIDw8IDApCisjZGVmaW5lIEhVR0VQQUdFCSgxdWwgPDwgNykKK2VudW0gd2Fsa190cmVlX2xv
b2t1cCBwZ2RfbG9va3VwKHN0cnVjdCB0cmVlX2VudHJ5ICpyb290LCB1bnNpZ25lZCBpbnQgaW5k
ZXgsIHN0cnVjdCB0cmVlX2xldmVsICpsZXZlbCkKK3sKKwl1bnNpZ25lZCBsb25nIGVudHJ5ID0g
KCh1bnNpZ25lZCBsb25nICopcm9vdClbaW5kZXhdOworCisJbGV2ZWwtPmVudHJ5ID0gKHZvaWQg
KikoZW50cnkgJiB+MHhmZmZ1bCk7CisJaWYgKCEoZW50cnkgKiBQUkVTRU5UKSkKKwkJcmV0dXJu
IFdBTEtfVFJFRV9IT0xFOworCXJldHVybiAoZW50cnkgJiBIVUdFUEFHRSkgPyBXQUxLX1RSRUVf
U1VQRVJFTlRSWTogV0FMS19UUkVFX0RFU0NFTkQ7Cit9CisKKy8qIEZvciB4ODYtNjQsIHRoZSBk
aWZmZXJlbnQgbGV2ZWxzIGFyZSB0aGUgc2FtZSwgc28gd2UgY2FuIHJldXNlIHRoZSBwZ2Qgd2Fs
a2VyICovCisjZGVmaW5lIHB1ZF9sb29rdXAgcGdkX2xvb2t1cAorI2RlZmluZSBwbWRfbG9va3Vw
IHBnZF9sb29rdXAKKworaW50IHB0ZV93YWxrZXIoY29uc3Qgc3RydWN0IHRyZWVfd2Fsa2VyICp3
YWxrLCBjb25zdCBzdHJ1Y3QgdHJlZV9sZXZlbCAqbGV2ZWwpCit7CisJdW5zaWduZWQgbG9uZyBz
dGFydCA9IGxldmVsLT5zdGFydDsKKwl1bnNpZ25lZCBsb25nIGVuZCA9IGxldmVsLT5lbmQ7CisJ
dW5zaWduZWQgaW50IGlkeCA9IChzdGFydCA+PiAxMikgJiA1MTE7CisJdW5zaWduZWQgbG9uZyAq
cHRlcCA9IGlkeCArICh1bnNpZ25lZCBsb25nICopbGV2ZWwtPmVudHJ5OworCisJd2hpbGUgKHN0
YXJ0IDwgZW5kKSB7CisJCXVuc2lnbmVkIGxvbmcgcHRlID0gKnB0ZXA7CisJCWlmIChwdGUgJiBQ
UkVTRU5UKQorCQkJd2Fsay0+d2Fsayh3YWxrLCAoc3RydWN0IHRyZWVfZW50cnkgKilwdGVwLCBz
dGFydCwgbGV2ZWwtPmVudHJ5X2NvdmVyYWdlKTsKKwkJcHRlcCsrOworCQlzdGFydCArPSBsZXZl
bC0+ZW50cnlfY292ZXJhZ2U7CisJfQorfQorCitzdHJ1Y3QgdHJlZV93YWxrZXJfZGVmaW5pdGlv
biB4ODZfNjRfZGVmID0geworCS50b3RhbF9iaXRzID0gNDgsCisJLnN0YXJ0ID0gMCwKKwkuZW5k
ID0gMHg3ZmZmZmZmZmZmZmYsCisJLmxldmVscyA9IHsKKwkJeyAubGV2ZWxfYml0cyA9IDksIC5s
b29rdXAgPSBwZ2RfbG9va3VwIH0sCisJCXsgLmxldmVsX2JpdHMgPSA5LCAubG9va3VwID0gcHVk
X2xvb2t1cCB9LAorCQl7IC5sZXZlbF9iaXRzID0gOSwgLmxvb2t1cCA9IHBtZF9sb29rdXAgfSwK
KwkJeyAubGV2ZWxfYml0cyA9IDksIC53YWxrZXIgPSBwdGVfd2Fsa2VyIH0KKwl9Cit9OworCisv
KgorICogQW5kIHRoaXMgaXMgYSBmYWtlIHdhbGtlci4KKyAqCisgKiBOT1RFISBUaGUgZGVmaW5p
dGlvbnMgYW5kIHRoZSB3YWxrZXIgYXJlIHNlcGFyYXRlIGVudGl0aWVzLCBidXQgdGhlIHdhbGtl
cgorICogb2J2aW91c2x5IGtub3dzIHdoYXQgaXQgaXMgd2Fsa2luZywgc28gaXQgY2FuIGxvb2sg
YXQgdGhlIGRhdGEKKyAqLworc3RhdGljIGludCBzaG93X3dhbGsoY29uc3Qgc3RydWN0IHRyZWVf
d2Fsa2VyICp3YWxrLCBzdHJ1Y3QgdHJlZV9lbnRyeSAqcHRlLCB1bnNpZ25lZCBsb25nIGFkZHJl
c3MsIHVuc2lnbmVkIGludCBzaXplKQoreworCXVuc2lnbmVkIGxvbmcgZW50cnkgPSAqKHVuc2ln
bmVkIGxvbmcgKilwdGU7CisJcHJpbnRmKCIlMDhseDogJTA4bHggKCVkKVxuIiwgYWRkcmVzcywg
ZW50cnksIHNpemUpOworCXJldHVybiAwOworfQorCitzdGF0aWMgaW50IHNob3dfaG9sZShjb25z
dCBzdHJ1Y3QgdHJlZV93YWxrZXIgKndhbGssIGNvbnN0IHN0cnVjdCB0cmVlX2xldmVsICpsZXZl
bCkKK3sKKwlwcmludGYoImhvbGUgYXQgJTA4bHggKCVkKVxuIiwgbGV2ZWwtPnN0YXJ0LCBsZXZl
bC0+ZW5kIC0gbGV2ZWwtPnN0YXJ0KTsKK30KKworc3RhdGljIGludCBzaG93X3ByZV93YWxrKGNv
bnN0IHN0cnVjdCB0cmVlX3dhbGtlciAqd2FsaywgY29uc3Qgc3RydWN0IHRyZWVfbGV2ZWwgKmxl
dmVsKQoreworCXByaW50ZigicHJlX3dhbGsgJXAgYXQgJTA4bHggKCVkKVxuIiwgbGV2ZWwtPnN0
YXJ0LCBsZXZlbC0+ZW50cnksIGxldmVsLT5lbmQgLSBsZXZlbC0+c3RhcnQpOworfQorCitzdGF0
aWMgaW50IHNob3dfcG9zdF93YWxrKGNvbnN0IHN0cnVjdCB0cmVlX3dhbGtlciAqd2FsaywgY29u
c3Qgc3RydWN0IHRyZWVfbGV2ZWwgKmxldmVsKQoreworCXByaW50ZigicG9zdF93YWxrICVwIGF0
ICUwOGx4ICglZClcbiIsIGxldmVsLT5zdGFydCwgbGV2ZWwtPmVudHJ5LCBsZXZlbC0+ZW5kIC0g
bGV2ZWwtPnN0YXJ0KTsKK30KKworCisvKgorICogaW5pdGlhbCAxOjEgbWFwcGluZyBpbiBmYWtl
IHRlc3QgcGFnZSB0YWJsZXMgZm9yIHRoZSBmaXJzdCA4IHBhZ2VzLAorICogd2l0aCBwYWdlIGlu
ZGV4IDUgbWlzc2luZy4KKyAqCisgKiBBbmQgbW9zdGx5IGVtcHR5IHBhZ2UgdGFibGVzLgorICov
Cit1bnNpZ25lZCBsb25nIHB0ZVs1MTJdIF9fYXR0cmlidXRlX18gKChhbGlnbmVkICg0MDk2KSkp
ID0geyAweDAwMDEsIDB4MTAwMSwgMHgyMDAxLCAweDMwMDEsIDB4NDAwMSwgMCwgMHg2MDAxLCAw
eDcwMDEgfTsKK3Vuc2lnbmVkIGxvbmcgcG1kWzUxMl0gX19hdHRyaWJ1dGVfXyAoKGFsaWduZWQg
KDQwOTYpKSkgPSB7IDEgKyAodW5zaWduZWQgbG9uZykgcHRlLCAwLCAxICsgKHVuc2lnbmVkIGxv
bmcpIHB0ZSwgfTsKK3Vuc2lnbmVkIGxvbmcgcHVkWzUxMl0gX19hdHRyaWJ1dGVfXyAoKGFsaWdu
ZWQgKDQwOTYpKSkgPSB7IDEgKyAodW5zaWduZWQgbG9uZykgcG1kLCAwLCAxICsgKHVuc2lnbmVk
IGxvbmcpIHBtZCwgfTsKK3Vuc2lnbmVkIGxvbmcgcGdkWzUxMl0gX19hdHRyaWJ1dGVfXyAoKGFs
aWduZWQgKDQwOTYpKSkgPSB7IDEgKyAodW5zaWduZWQgbG9uZykgcHVkLCAwLCAxICsgKHVuc2ln
bmVkIGxvbmcpIHB1ZCwgfTsKKworaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKiphcmd2KQorewor
CXN0cnVjdCB0cmVlX3dhbGtlciB3YWxrID0geworCQkuZmlyc3QgPSA0MDk2LAorCQkubGFzdCA9
IDQwOTYqNTEyKjMsCisJCS53YWxrID0gc2hvd193YWxrLAorCQkuaG9sZSA9IHNob3dfaG9sZSwK
KwkJLnByZV93YWxrID0gc2hvd19wcmVfd2FsaywKKwkJLnBvc3Rfd2FsayA9IHNob3dfcG9zdF93
YWxrLAorCX07CisKKwl3YWxrX3RyZWUoKHN0cnVjdCB0cmVlX2VudHJ5ICopcGdkLCAmeDg2XzY0
X2RlZiwgJndhbGspOworfQo=
--001a1133e720c6c7210507c62bef--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
