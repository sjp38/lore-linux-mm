Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0A8280704
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 14:19:19 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a79so8575895oii.7
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 11:19:19 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id l144si12070574oig.201.2017.08.22.11.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 11:19:13 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id j144so66266741oib.1
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 11:19:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net> <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 22 Aug 2017 11:19:12 -0700
Message-ID: <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: multipart/mixed; boundary="001a113d0a8ae0f4c305575ba1bf"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liang, Kan" <kan.liang@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a113d0a8ae0f4c305575ba1bf
Content-Type: text/plain; charset="UTF-8"

On Tue, Aug 22, 2017 at 10:23 AM, Liang, Kan <kan.liang@intel.com> wrote:
>
> Although the patch doesn't trigger watchdog, the spin lock wait time
> is not small (0.45s).
> It may get worse again on larger systems.

Yeah, I don't think Mel's patch is great - because I think we could do
so much better.

What I like about Mel's patch is that it recognizes that
"wait_on_page_locked()" there is special, and replaces it with
something else. I think that "something else" is worse than my
"yield()" call, though.

In particular, it wastes CPU time even in the good case, and the
process that will unlock the page may actually be waiting for us to
reschedule. It may be CPU bound, but it might well have just been
preempted out.

So if we do busy loops, I really think we should also make sure that
the thing we're waiting for is not preempted.

HOWEVER, I'm actually starting to think that there is perhaps
something else going on.

Let me walk you through my thinking:

This is the migration logic:

 (a) migration locks the page

 (b) migration is supposedly CPU-limited

 (c) migration then unlocks the page.

Ignore all the details, that's the 10.000 ft view. Right?

Now, if the above is right, then I have a question for people:

  HOW IN THE HELL DO WE HAVE TIME FOR THOUSANDS OF THREADS TO HIT THAT ONE PAGE?

That just sounds really sketchy to me. Even if all those thousands of
threads are runnable, we need to schedule into them just to get them
to wait on that one page.

So that sounds really quite odd when migration is supposed to hold the
page lock for a relatively short time and get out. Don't you agree?

Which is why I started thinking of what the hell could go on for that
long wait-queue to happen.

One thing that strikes me is that the way wait_on_page_bit() works is
that it will NOT wait until the next bit clearing, it will wait until
it actively *sees* the page bit being clear.

Now, work with me on that. What's the difference?

What we could have is some bad NUMA balancing pattern that actually
has a page that everybody touches.

And hey, we pretty much know that everybody touches that page, since
people get stuck on that wait-queue, right?

And since everybody touches it, as a result everybody eventually
thinks that page should be migrated to their NUMA node.

But for all we know, the migration keeps on failing, because one of
the points of that "lock page - try to move - unlock page" is that
*TRY* in "try to move". There's a number of things that makes it not
actually migrate. Like not being movable, or failing to isolate the
page, or whatever.

So we could have some situation where we end up locking and unlocking
the page over and over again (which admittedly is already a sign of
something wrong in the NUMA balancing, but that's a separate issue).

And if we get into that situation, where everybody wants that one hot
page, what happens to the waiters?

One of the thousands of waiters is unlucky (remember, this argument
started with the whole "you shouldn't get that many waiters on one
single page that isn't even locked for that long"), and goes:

 (a) Oh, the page is locked, I will wait for the lock bit to clear

 (b) go to sleep

 (c) the migration fails, the lock bit is cleared, the waiter is woken
up but doesn't get the CPU immediately, and one of the other
*thousands* of threads decides to also try to migrate (see above),

 (d) the guy waiting for the lock bit to clear will see the page
"still" locked (really just "locked again") and continue to wait.

In the meantime, one of the other threads happens to be unlucky, also
hits the race, and now we have one more thread waiting for that page
lock. It keeps getting unlocked, but it also keeps on getting locked,
and so the queue can keep growing.

See where I'm going here? I think it's really odd how *thousands* of
threads can hit that locked window that is supposed to be pretty
small. But I think it's much more likely if we have some kind of
repeated event going on.

So I'm starting to think that part of the problem may be how stupid
that "wait_for_page_bit_common()" code is. It really shouldn't wait
until it sees that the bit is clear. It could have been cleared and
then re-taken.

And honestly, we actually have extra code for that "let's go round
again". That seems pointless. If the bit has been cleared, we've been
woken up, and nothing else would have done so anyway, so if we're not
interested in locking, we're simply *done* after we've done the
"io_scheduler()".

So I propose testing the attached trivial patch. It may not do
anything at all. But the existing code is actually doing extra work
just to be fragile, in case the scenario above can happen.

Comments?

                Linus

--001a113d0a8ae0f4c305575ba1bf
Content-Type: text/plain; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j6nwrnm90

IG1tL2ZpbGVtYXAuYyB8IDEyICsrKysrLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDUgaW5zZXJ0
aW9ucygrKSwgNyBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9tbS9maWxlbWFwLmMgYi9tbS9m
aWxlbWFwLmMKaW5kZXggYTQ5NzAyNDQ1Y2UwLi43NWMyOWExZjkwZmIgMTAwNjQ0Ci0tLSBhL21t
L2ZpbGVtYXAuYworKysgYi9tbS9maWxlbWFwLmMKQEAgLTk5MSwxMyArOTkxLDExIEBAIHN0YXRp
YyBpbmxpbmUgaW50IHdhaXRfb25fcGFnZV9iaXRfY29tbW9uKHdhaXRfcXVldWVfaGVhZF90ICpx
LAogCQkJfQogCQl9CiAKLQkJaWYgKGxvY2spIHsKLQkJCWlmICghdGVzdF9hbmRfc2V0X2JpdF9s
b2NrKGJpdF9uciwgJnBhZ2UtPmZsYWdzKSkKLQkJCQlicmVhazsKLQkJfSBlbHNlIHsKLQkJCWlm
ICghdGVzdF9iaXQoYml0X25yLCAmcGFnZS0+ZmxhZ3MpKQotCQkJCWJyZWFrOwotCQl9CisJCWlm
ICghbG9jaykKKwkJCWJyZWFrOworCisJCWlmICghdGVzdF9hbmRfc2V0X2JpdF9sb2NrKGJpdF9u
ciwgJnBhZ2UtPmZsYWdzKSkKKwkJCWJyZWFrOwogCX0KIAogCWZpbmlzaF93YWl0KHEsIHdhaXQp
Owo=
--001a113d0a8ae0f4c305575ba1bf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
