Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85DEF6B04B2
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 18:52:19 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id k62so135984oia.6
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:52:19 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id k205si80640oia.14.2017.08.22.15.52.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 15:52:18 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id g131so1229319oic.3
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:52:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170822212408.GC28715@tassilo.jf.intel.com>
References: <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net> <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <20170822190828.GO32112@worktop.programming.kicks-ass.net>
 <CA+55aFzPt401xpRzd6Qu-WuDNGneR_m7z25O=0YspNi+cLRb8w@mail.gmail.com>
 <20170822193714.GZ28715@tassilo.jf.intel.com> <alpine.DEB.2.20.1708221605220.18344@nuc-kabylake>
 <20170822212408.GC28715@tassilo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 22 Aug 2017 15:52:17 -0700
Message-ID: <CA+55aFw_-RmdWF6mPHonnqoJcMEmjhvjzcwp5OU7Uwzk3KPNmw@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: multipart/mixed; boundary="001a113d0a8a833a7e05575f72ee"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Christopher Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a113d0a8a833a7e05575f72ee
Content-Type: text/plain; charset="UTF-8"

On Tue, Aug 22, 2017 at 2:24 PM, Andi Kleen <ak@linux.intel.com> wrote:
>
> I believe in this case it's used by threads, so a reference count limit
> wouldn't help.

For the first migration try, yes. But if it's some kind of "try and
try again" pattern, the second time you try and there are people
waiting for the page, the page count (not the map count) would be
elevanted.

So it's possible that depending on exactly what the deeper problem is,
the "this page is very busy, don't migrate" case might be
discoverable, and the page count might be part of it.

However, after PeterZ made that comment that page migration should
have that should_numa_migrate_memory() filter, I am looking at that
mpol_misplaced() code.

And honestly, that MPOL_PREFERRED / MPOL_F_LOCAL case really looks
like complete garbage to me.

It looks like garbage exactly because it says "always migrate to the
current node", but that's crazy - if it's a group of threads all
running together on the same VM, that obviously will just bounce the
page around for absolute zero good ewason.

The *other* memory policies look fairly sane. They basically have a
fairly well-defined preferred node for the policy (although the
"MPOL_INTERLEAVE" looks wrong for a hugepage).  But
MPOL_PREFERRED/MPOL_F_LOCAL really looks completely broken.

Maybe people expected that anybody who uses MPOL_F_LOCAL will also
bind all threads to one single node?

Could we perhaps make that "MPOL_PREFERRED / MPOL_F_LOCAL" case just
do the MPOL_F_MORON policy, which *does* use that "should I migrate to
the local node" filter?

IOW, we've been looking at the waiters (because the problem shows up
due to the excessive wait queues), but maybe the source of the problem
comes from the numa balancing code just insanely bouncing pages
back-and-forth if you use that "always balance to local node" thing.

Untested (as always) patch attached.

              Linus

--001a113d0a8a833a7e05575f72ee
Content-Type: text/plain; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j6o6qs3b0

IG1tL21lbXBvbGljeS5jIHwgNyArKysrLS0tCiAxIGZpbGUgY2hhbmdlZCwgNCBpbnNlcnRpb25z
KCspLCAzIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL21tL21lbXBvbGljeS5jIGIvbW0vbWVt
cG9saWN5LmMKaW5kZXggNjE4YWIxMjUyMjhiLi5mMmQ1YWFiODRjNDkgMTAwNjQ0Ci0tLSBhL21t
L21lbXBvbGljeS5jCisrKyBiL21tL21lbXBvbGljeS5jCkBAIC0yMTkwLDkgKzIxOTAsOSBAQCBp
bnQgbXBvbF9taXNwbGFjZWQoc3RydWN0IHBhZ2UgKnBhZ2UsIHN0cnVjdCB2bV9hcmVhX3N0cnVj
dCAqdm1hLCB1bnNpZ25lZCBsb25nCiAKIAljYXNlIE1QT0xfUFJFRkVSUkVEOgogCQlpZiAocG9s
LT5mbGFncyAmIE1QT0xfRl9MT0NBTCkKLQkJCXBvbG5pZCA9IG51bWFfbm9kZV9pZCgpOwotCQll
bHNlCi0JCQlwb2xuaWQgPSBwb2wtPnYucHJlZmVycmVkX25vZGU7CisJCQlnb3RvIGxvY2FsX25v
ZGU7CisKKwkJcG9sbmlkID0gcG9sLT52LnByZWZlcnJlZF9ub2RlOwogCQlicmVhazsKIAogCWNh
c2UgTVBPTF9CSU5EOgpAQCAtMjIxOCw2ICsyMjE4LDcgQEAgaW50IG1wb2xfbWlzcGxhY2VkKHN0
cnVjdCBwYWdlICpwYWdlLCBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwgdW5zaWduZWQgbG9u
ZwogCiAJLyogTWlncmF0ZSB0aGUgcGFnZSB0b3dhcmRzIHRoZSBub2RlIHdob3NlIENQVSBpcyBy
ZWZlcmVuY2luZyBpdCAqLwogCWlmIChwb2wtPmZsYWdzICYgTVBPTF9GX01PUk9OKSB7Citsb2Nh
bF9ub2RlOgogCQlwb2xuaWQgPSB0aGlzbmlkOwogCiAJCWlmICghc2hvdWxkX251bWFfbWlncmF0
ZV9tZW1vcnkoY3VycmVudCwgcGFnZSwgY3VybmlkLCB0aGlzY3B1KSkK
--001a113d0a8a833a7e05575f72ee--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
