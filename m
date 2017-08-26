Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4210C6810D7
	for <linux-mm@kvack.org>; Sat, 26 Aug 2017 14:15:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l185so2058341oib.4
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 11:15:04 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id v6si8120474oie.121.2017.08.26.11.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Aug 2017 11:15:03 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id y193so2405531oie.5
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 11:15:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
References: <83f675ad385d67760da4b99cd95ee912ca7c0b44.1503677178.git.tim.c.chen@linux.intel.com>
 <cd8ce7fbca9c126f7f928b8fa48d7a9197955b45.1503677178.git.tim.c.chen@linux.intel.com>
 <CA+55aFyErsNw8bqTOCzcrarDZBdj+Ev=1N3sV-gxtLTH03bBFQ@mail.gmail.com>
 <f10f4c25-49c0-7ef5-55c2-769c8fd9bf90@linux.intel.com> <CA+55aFzNikMsuPAaExxT1Z8MfOeU6EhSn6UPDkkz-MRqamcemg@mail.gmail.com>
 <CA+55aFx67j0u=GNRKoCWpsLRDcHdrjfVvWRS067wLUSfzstgoQ@mail.gmail.com>
 <CA+55aFzy981a8Ab+89APi6Qnb9U9xap=0A6XNc+wZsAWngWPzA@mail.gmail.com> <CA+55aFwyCSh1RbJ3d5AXURa4_r5OA_=ZZKQrFX0=Z1J3ZgVJ5g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 26 Aug 2017 11:15:01 -0700
Message-ID: <CA+55aFy18WCqZGwkxH6dTZR9LD9M5nXWqEN8DBeZ4LvNo4Y0BQ@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] sched/wait: Introduce lock breaker in wake_up_page_bit
Content-Type: multipart/mixed; boundary="001a114340dc4fff1e0557ac0a7c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>, "Eric W . Biederman" <ebiederm@xmission.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a114340dc4fff1e0557ac0a7c
Content-Type: text/plain; charset="UTF-8"

On Fri, Aug 25, 2017 at 7:54 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Simplify, simplify, simplify.

I've now tried three different approaches (I stopped sending broken
patches after deciding the first one was unfixable), and they all
suck.

I was hoping for something lockless to avoid the whole issue with
latency over the long list, but anything that has the wait queue entry
allocated on the stack needs to synchronize the wakeup due to the
stack usage, so once you have lists that are thousands of entries,
either you hold the lock for long times (normal wait queues) or take
and release them constantly (the swait approach), or you batch things
up (Tim's wait-queue patches).

Of those three approaches, the batching does seem to be the best of
the lot. Allocating non-stack wait entries while waiting for pages
seems like a bad idea. We're probably waiting for IO in normal
circumstances, possibly because we're low on memory.

So I *am* ok with the batching (your patch #1), but I'm *not* ok with
the nasty horrible book-keeping to avoid new entries when you batch
and release the lock and that allows new entries on the list (your
patch #2).

That said, I have now stared *way* too much at the page wait code
after having unsuccessfully tried to replace that wait-queue with
other "clever" approaches (all of which ended up being crap).

And I'm starting to see a possible solution, or at least improvement.

Let's just assume I take the batching patch. It's not conceptually
ugly, it's fairly simple, and there are lots of independent arguments
for it (ie latency, but also possible performance from better
parallelism).

That patch doesn't make any data structures bigger or more
complicated, it's just that single "is this a bookmark entry" thing.
So that patch just looks fundamentally fine to me, and the only real
argument I ever had against it was that I would really really _really_
have wanted to root-cause the behavior.

So that leaves my fundamental dislike of your other patch.

And it turns out that all my looking at the page wait code wasn't
entirely unproductive. Yes, I went through three crap approaches
before I gave up on rewriting it, but in the meantime I did get way
too intimate with looking at that pile of crud.

And I think I found the reason why you needed that patch #2 in the first place.

Here's what is going on:

 - we're going to assume that the problem is all with a single page,
not due to hash collisions (as per your earlier reports)

 - we also know that the only bit that matters is the PG_locked bit

 - that means that the only way to get that "multiple concurrent
waker" situation that your patch #2 tries to handle better is because
you have multiple people unlocking the page - since that is what
causes the wakeups

 - that in turn means that you obviously had multiple threads *locking* it too.

 - and that means that among those new entries there are lockers
coming in in the middle and adding an exclusive entry.

 - the exclusive entry already stops the wakeup list walking

 - but we add non-exclusive entries TO THE BEGINNING of the page waiters list

And I really think that last thing is fundamentally wrong.

It's wrong for several reasons:

 - because it's unfair: threads that want to lock get put behind
threads that just want to see the unlocked state.

 - because it's stupid: our non-locking waiters will end up waiting
again if the page got locked, so waking up a locker *and* a lot of
non-locking waiters will just cause them to go back to sleep anyway

 - because it causes us to walk longer lists: we stop walking when we
wake up the exclusive waiter, but because we always put the
non-exclusive waiters in there first, we always walk the long list of
non-exclusive waiters even if we could just stop walking because we
woke up an exclusive one.

Now the reason we do this seems to be entirely random: for a *normal*
wait queue, you really want to always wake up all the non-exclusive
waiters, because exclusive waiters are only exclusive wrt each other.

But for a page lock, an exclusive waiter really is getting the lock,
and the other waiters are going to wait for the lock to clear anyway,
so the page wait thing is actually almost exactly the reverse
situation. We *could* put exclusive waiters at the beginning of the
list instead, and actively try to avoid walking the list at all if we
have pending lockers.

I'm not doing that, because I think the fair thing to do is to just do
things in the order they came in. Plus the code is actually simpler if
we just always add to the tail.

Now, the other thing to look at is how the wakeup function works. It
checks the aliasing information (page and bit number), but then it
*also* does:

        if (test_bit(key->bit_nr, &key->page->flags))
                return 0;

basically saying "continue walking if somebody else already got the bit".

That's *INSANE*. It's exactly the wrong thing to do. It's basically
saying "even if we had an exclusive waiter, let's not wake it up, but
do let us continue to walk the list even though the bit we're waiting
for to clear is set already".

What would be sane is to say "stop walking the list now".. So just do
that - by making "negative return from wake function" mean "stop
walking".

So how about just this fairly trivial patch?

In fact, I think this may help even *without* Tim's patch #1. So I
think this would be lovely to test on that problem load on its own,
and seeing if it makes the wait queues behave better.

It might not cut down on the total length of the wait-queue, but it
should hopefully cause it to walk it much less. We now hit the
exclusive waiters earlier and stop waking things up when we have a new
locker thread pending. And when the page ends up being locked again,
we stop walking the list entirely, so no unnecessarily traversal.

This patch is small and at least minimally works (I'm running it right now).

                               Linus

--001a114340dc4fff1e0557ac0a7c
Content-Type: text/plain; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j6tmdkji0

IGtlcm5lbC9zY2hlZC93YWl0LmMgfCAgNyArKysrLS0tCiBtbS9maWxlbWFwLmMgICAgICAgIHwg
MTAgKysrKystLS0tLQogMiBmaWxlcyBjaGFuZ2VkLCA5IGluc2VydGlvbnMoKyksIDggZGVsZXRp
b25zKC0pCgpkaWZmIC0tZ2l0IGEva2VybmVsL3NjaGVkL3dhaXQuYyBiL2tlcm5lbC9zY2hlZC93
YWl0LmMKaW5kZXggMTdmMTFjNmIwYTlmLi5kNmFmZWQ2ZDA3NTIgMTAwNjQ0Ci0tLSBhL2tlcm5l
bC9zY2hlZC93YWl0LmMKKysrIGIva2VybmVsL3NjaGVkL3dhaXQuYwpAQCAtNzAsOSArNzAsMTAg
QEAgc3RhdGljIHZvaWQgX193YWtlX3VwX2NvbW1vbihzdHJ1Y3Qgd2FpdF9xdWV1ZV9oZWFkICp3
cV9oZWFkLCB1bnNpZ25lZCBpbnQgbW9kZSwKIAogCWxpc3RfZm9yX2VhY2hfZW50cnlfc2FmZShj
dXJyLCBuZXh0LCAmd3FfaGVhZC0+aGVhZCwgZW50cnkpIHsKIAkJdW5zaWduZWQgZmxhZ3MgPSBj
dXJyLT5mbGFnczsKLQotCQlpZiAoY3Vyci0+ZnVuYyhjdXJyLCBtb2RlLCB3YWtlX2ZsYWdzLCBr
ZXkpICYmCi0JCQkJKGZsYWdzICYgV1FfRkxBR19FWENMVVNJVkUpICYmICEtLW5yX2V4Y2x1c2l2
ZSkKKwkJaW50IHJldCA9IGN1cnItPmZ1bmMoY3VyciwgbW9kZSwgd2FrZV9mbGFncywga2V5KTsK
KwkJaWYgKHJldCA8IDApCisJCQlicmVhazsKKwkJaWYgKHJldCAmJiAoZmxhZ3MgJiBXUV9GTEFH
X0VYQ0xVU0lWRSkgJiYgIS0tbnJfZXhjbHVzaXZlKQogCQkJYnJlYWs7CiAJfQogfQpkaWZmIC0t
Z2l0IGEvbW0vZmlsZW1hcC5jIGIvbW0vZmlsZW1hcC5jCmluZGV4IGE0OTcwMjQ0NWNlMC4uNjA3
MDViNzYwOTgzIDEwMDY0NAotLS0gYS9tbS9maWxlbWFwLmMKKysrIGIvbW0vZmlsZW1hcC5jCkBA
IC05MDksOCArOTA5LDEwIEBAIHN0YXRpYyBpbnQgd2FrZV9wYWdlX2Z1bmN0aW9uKHdhaXRfcXVl
dWVfZW50cnlfdCAqd2FpdCwgdW5zaWduZWQgbW9kZSwgaW50IHN5bmMsCiAKIAlpZiAod2FpdF9w
YWdlLT5iaXRfbnIgIT0ga2V5LT5iaXRfbnIpCiAJCXJldHVybiAwOworCisJLyogU3RvcCB3YWxr
aW5nIGlmIGl0J3MgbG9ja2VkICovCiAJaWYgKHRlc3RfYml0KGtleS0+Yml0X25yLCAma2V5LT5w
YWdlLT5mbGFncykpCi0JCXJldHVybiAwOworCQlyZXR1cm4gLTE7CiAKIAlyZXR1cm4gYXV0b3Jl
bW92ZV93YWtlX2Z1bmN0aW9uKHdhaXQsIG1vZGUsIHN5bmMsIGtleSk7CiB9CkBAIC05NjQsNiAr
OTY2LDcgQEAgc3RhdGljIGlubGluZSBpbnQgd2FpdF9vbl9wYWdlX2JpdF9jb21tb24od2FpdF9x
dWV1ZV9oZWFkX3QgKnEsCiAJaW50IHJldCA9IDA7CiAKIAlpbml0X3dhaXQod2FpdCk7CisJd2Fp
dC0+ZmxhZ3MgPSBsb2NrID8gV1FfRkxBR19FWENMVVNJVkUgOiAwOwogCXdhaXQtPmZ1bmMgPSB3
YWtlX3BhZ2VfZnVuY3Rpb247CiAJd2FpdF9wYWdlLnBhZ2UgPSBwYWdlOwogCXdhaXRfcGFnZS5i
aXRfbnIgPSBiaXRfbnI7CkBAIC05NzIsMTAgKzk3NSw3IEBAIHN0YXRpYyBpbmxpbmUgaW50IHdh
aXRfb25fcGFnZV9iaXRfY29tbW9uKHdhaXRfcXVldWVfaGVhZF90ICpxLAogCQlzcGluX2xvY2tf
aXJxKCZxLT5sb2NrKTsKIAogCQlpZiAobGlrZWx5KGxpc3RfZW1wdHkoJndhaXQtPmVudHJ5KSkp
IHsKLQkJCWlmIChsb2NrKQotCQkJCV9fYWRkX3dhaXRfcXVldWVfZW50cnlfdGFpbF9leGNsdXNp
dmUocSwgd2FpdCk7Ci0JCQllbHNlCi0JCQkJX19hZGRfd2FpdF9xdWV1ZShxLCB3YWl0KTsKKwkJ
CV9fYWRkX3dhaXRfcXVldWVfZW50cnlfdGFpbChxLCB3YWl0KTsKIAkJCVNldFBhZ2VXYWl0ZXJz
KHBhZ2UpOwogCQl9CiAK
--001a114340dc4fff1e0557ac0a7c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
