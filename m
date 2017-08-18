Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C27AF6B049D
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 15:14:14 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c80so13672655oig.7
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 12:14:14 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id g141si5474617oic.37.2017.08.18.12.14.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 12:14:13 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id z19so291961oia.4
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 12:14:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170818185455.qol3st2nynfa47yc@techsingularity.net>
References: <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com> <20170818185455.qol3st2nynfa47yc@techsingularity.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Aug 2017 12:14:12 -0700
Message-ID: <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: multipart/mixed; boundary="001a113e579e360c4f05570bef31"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a113e579e360c4f05570bef31
Content-Type: text/plain; charset="UTF-8"

On Fri, Aug 18, 2017 at 11:54 AM, Mel Gorman
<mgorman@techsingularity.net> wrote:
>
> One option to mitigate (but not eliminate) the problem is to record when
> the page lock is contended and pass in TNF_PAGE_CONTENDED (new flag) to
> task_numa_fault().

Well, finding it contended is fairly easy - just look at the page wait
queue, and if it's not empty, assume it's due to contention.

I also wonder if we could be even *more* hacky, and in the whole
__migration_entry_wait() path, change the logic from:

 - wait on page lock before retrying the fault

to

 - yield()

which is hacky, but there's a rationale for it:

 (a) avoid the crazy long wait queues ;)

 (b) we know that migration is *supposed* to be CPU-bound (not IO
bound), so yielding the CPU and retrying may just be the right thing
to do.

It's possible that we could just do a hybrid approach, and introduce a
"wait_on_page_lock_or_yield()", that does a sleeping wait if the
wait-queue is short, and a yield otherwise, but it might be worth just
testing the truly stupid patch.

Because that code sequence doesn't actually depend on
"wait_on_page_lock()" for _correctness_ anyway, afaik. Anybody who
does "migration_entry_wait()" _has_ to retry anyway, since the page
table contents may have changed by waiting.

So I'm not proud of the attached patch, and I don't think it's really
acceptable as-is, but maybe it's worth testing? And maybe it's
arguably no worse than what we have now?

Comments?

(Yeah, if we take this approach, we might even just say "screw the
spinlock - just do ACCESS_ONCE() and do a yield() if it looks like a
migration entry")

                     Linus

--001a113e579e360c4f05570bef31
Content-Type: text/plain; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j6i96yz30

IG1tL21pZ3JhdGUuYyB8IDE1ICstLS0tLS0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDEgaW5z
ZXJ0aW9uKCspLCAxNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9tbS9taWdyYXRlLmMgYi9t
bS9taWdyYXRlLmMKaW5kZXggZDY4YTQxZGE2YWJiLi5hMjg5MDgzMDU4NDEgMTAwNjQ0Ci0tLSBh
L21tL21pZ3JhdGUuYworKysgYi9tbS9taWdyYXRlLmMKQEAgLTI4NCw3ICsyODQsNiBAQCB2b2lk
IF9fbWlncmF0aW9uX2VudHJ5X3dhaXQoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHB0ZV90ICpwdGVw
LAogewogCXB0ZV90IHB0ZTsKIAlzd3BfZW50cnlfdCBlbnRyeTsKLQlzdHJ1Y3QgcGFnZSAqcGFn
ZTsKIAogCXNwaW5fbG9jayhwdGwpOwogCXB0ZSA9ICpwdGVwOwpAQCAtMjk1LDIwICsyOTQsOCBA
QCB2b2lkIF9fbWlncmF0aW9uX2VudHJ5X3dhaXQoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHB0ZV90
ICpwdGVwLAogCWlmICghaXNfbWlncmF0aW9uX2VudHJ5KGVudHJ5KSkKIAkJZ290byBvdXQ7CiAK
LQlwYWdlID0gbWlncmF0aW9uX2VudHJ5X3RvX3BhZ2UoZW50cnkpOwotCi0JLyoKLQkgKiBPbmNl
IHJhZGl4LXRyZWUgcmVwbGFjZW1lbnQgb2YgcGFnZSBtaWdyYXRpb24gc3RhcnRlZCwgcGFnZV9j
b3VudAotCSAqICptdXN0KiBiZSB6ZXJvLiBBbmQsIHdlIGRvbid0IHdhbnQgdG8gY2FsbCB3YWl0
X29uX3BhZ2VfbG9ja2VkKCkKLQkgKiBhZ2FpbnN0IGEgcGFnZSB3aXRob3V0IGdldF9wYWdlKCku
Ci0JICogU28sIHdlIHVzZSBnZXRfcGFnZV91bmxlc3NfemVybygpLCBoZXJlLiBFdmVuIGZhaWxl
ZCwgcGFnZSBmYXVsdAotCSAqIHdpbGwgb2NjdXIgYWdhaW4uCi0JICovCi0JaWYgKCFnZXRfcGFn
ZV91bmxlc3NfemVybyhwYWdlKSkKLQkJZ290byBvdXQ7CiAJcHRlX3VubWFwX3VubG9jayhwdGVw
LCBwdGwpOwotCXdhaXRfb25fcGFnZV9sb2NrZWQocGFnZSk7Ci0JcHV0X3BhZ2UocGFnZSk7CisJ
eWllbGQoKTsKIAlyZXR1cm47CiBvdXQ6CiAJcHRlX3VubWFwX3VubG9jayhwdGVwLCBwdGwpOwo=
--001a113e579e360c4f05570bef31--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
