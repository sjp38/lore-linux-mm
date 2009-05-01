Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6F7BB6B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 14:04:20 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so956338wah.22
        for <linux-mm@kvack.org>; Fri, 01 May 2009 11:04:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <49FB01C1.6050204@redhat.com>
References: <20090428044426.GA5035@eskimo.com> <1240987349.4512.18.camel@laptop>
	<20090429114708.66114c03@cuia.bos.redhat.com> <20090430072057.GA4663@eskimo.com>
	<20090430174536.d0f438dd.akpm@linux-foundation.org> <20090430205936.0f8b29fc@riellaptop.surriel.com>
	<20090430181340.6f07421d.akpm@linux-foundation.org> <20090430215034.4748e615@riellaptop.surriel.com>
	<20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com>
From: Ray Lee <ray-lk@madrabbit.org>
Date: Fri, 1 May 2009 11:04:03 -0700
Message-ID: <2c0942db0905011104u4e6df9ap9d95fa30b1284294@mail.gmail.com>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 1, 2009 at 7:05 AM, Rik van Riel <riel@redhat.com> wrote:
>
> Andrew Morton wrote:
>
>>> When we implement working set protection, we might as well
>>> do it for frequently accessed unmapped pages too. =C2=A0There is
>>> no reason to restrict this protection to mapped pages.
>>
>> Well. =C2=A0Except for empirical observation, which tells us that biasin=
g
>> reclaim to prefer to retain mapped memory produces a better result.
>
> That used to be the case because file-backed and
> swap-backed pages shared the same set of LRUs,
> while each following a different page reclaim
> heuristic!
>
> Today:
> 1) file-backed and swap-backed pages are separated,
> 2) the majority of mapped pages are on the swap-backed LRUs
> 3) the accessed bit on active pages no longer means much,
> =C2=A0 for good scalability reasons, and
> 4) because of (3), we cannot really provide special treatment
> =C2=A0 to any individual page any more, however
>
> This means we need to provide our working set protection
> on a per-list basis, by tweaking the scan rate or avoiding
> scanning of the active file list alltogether under certain
> conditions.
>
> As a side effect, this will help protect frequently accessed
> file pages (good for ftp and nfs servers), indirect blocks,
> inode buffers and other frequently used metadata.

Just an honest question: Who does #3 help? All normal linux users, or
large systems for some definition of large? (Helping large systems is
good; historically it eventually helps everyone. But the point I'm
driving at is that the minority of systems which tend to use one
kernel for a while and stick with it -- ie, embedded or large iron --
can and are tuned for specific workloads. The majority of systems that
upgrade the kernel frequently, such as desktop systems needing support
for new hardware, tend to rely more upon the kernel defaults.)

Also, not all the above items are equal from a latency point of view.
The latency impact of an inode needing to be fetched from disk is
budgeted for already in most userspace design. Opening a file can be
slow, news at 11. Try not to open as many files, solution at 11:01.

The latency impact of jumping to a different part of your own
executable, however, is something most userspace programmers likely
never think of. This hurts even more in this modern age of web
browsers, where firefox has to act as a layout engine, video player,
parser and compiler, etc. Not every web page uses every feature, which
means clicking a random URL can suddenly stop the whole shebang while
a previously-unreferenced page is swapped back in. With executables,
past usage doesn't presage future need.

Said a different way, executables are not equivalent to a random
collection of mapped pages. A collection of inodes may or may not have
any causal links between them. A collection of pages for an executable
are linked via function calls, and the compiler and linker already
took a first pass at evicting unnecessary baggage.

Said way #3: We desktop users really want a way to say "Please don't
page my executables out when I'm running a system with 3gig of RAM." I
hate knobs, but I'm willing to beg for one in this case. 'cause
mlock()ing my entire working set into RAM seems pretty silly.

Does any of that make sense, or am I talking out of an inappropriate orific=
e?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
