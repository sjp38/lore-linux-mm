Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6D29000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 15:18:37 -0400 (EDT)
Received: by vws20 with SMTP id 20so11348692vws.38
        for <linux-mm@kvack.org>; Mon, 19 Sep 2011 12:18:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwnxOvkS12i97kJcWFrH7n591vxq7vBXKzuROiirnYJ0g@mail.gmail.com>
References: <20110918170512.GA2351@albatros>
	<CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
	<20110919144657.GA5928@albatros>
	<CAOJsxLG8gW=BLOptpULsaAEwTravADKbNbXp5e9Wd7xVEfR9AQ@mail.gmail.com>
	<20110919155718.GB16272@albatros>
	<CAOJsxLGZm+npcR0YgXSE2wLC2iXCtzYyCdTDCt1LN=Z28Rm_UA@mail.gmail.com>
	<20110919161837.GA2232@albatros>
	<CAOJsxLE2od0f+6cbL2hA_31CbrqS7AUofx5DT2L9fO_7gxH+PQ@mail.gmail.com>
	<20110919173539.GA3751@albatros>
	<CAOJsxLGc0bwCkDtk2PVe7c155a9wVoDAY0CmYDTLg8_bL4qxqg@mail.gmail.com>
	<20110919175856.GA4282@albatros>
	<CAOJsxLFdNVnW6Faap0UaqZQDQxbA_dEiR2HGdzZtGMJFsVR1WQ@mail.gmail.com>
	<CA+55aFwnxOvkS12i97kJcWFrH7n591vxq7vBXKzuROiirnYJ0g@mail.gmail.com>
Date: Mon, 19 Sep 2011 22:18:34 +0300
Message-ID: <CAOJsxLE5TMXwAHPks-mvk0EPAHC18fDXf345uZ3umkzNkk7-cQ@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>

Hi Linus,

On Mon, Sep 19, 2011 at 9:55 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Also, quite frankly, your argument that /proc/slabinfo is so important
> for kernel debugging is bogus. Every time I've complained about the
> fact that the thing is useless AND ACTIVELY MISLEADING because it
> mixes up all the slabs (so big numbers for "vm_area_struct" might
> actually be about some other slab entirely, and *has* been, to the
> point of people wasting time), the answer has been "whatever".
>
> You can't have it both ways just to argue for the status quo.

Well, sure. I was actually planning to rip out SLUB merging completely
because it makes /proc/slabinfo so useless but never got around doing
that. Mixing up allocations makes heap exploits harder but there's no
agreement on how much more difficult (i.e. if it matters at all for brute
force attacks).

So dunno what's the right thing to do here. Every time I discuss the
issues with 'security folks' I'm left with more questions than answers...
Everybody seems to be more interested in closing down kernel ABIs
rather than making kernel memory allocations more robust against
attacks.

But anyway, if you feel about this strongly feel free to pick up
Vasiliy's patch. I think my suggestion of introducing a
CONFIG_RESTRICT_PROCFS makes most sense because:

  - When we've mucked around with /proc/slabinfo in the past, we have
    broken setups. (That might be less relevant now.)

  - /proc/slabinfo is not the only source where you can get information
    on kernel memory allocations (we have one in sysfs and perf kmem).

On Mon, Sep 19, 2011 at 9:55 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Considering how useless /proc/slabinfo actually is today - exactly
> because of the misleading mixing - I suspect the right thing to do is
> to make it root-only.
>
> Having some aggregate number in /proc/meminfo would probably be fine.
>
> And yes, we probably should avoid giving page-level granularity in
> /proc/meminfo too. Do it in megabytes instead. None of the information
> there is really relevant at a page level, everybody just wants rough
> aggregates.

We have this in /proc/meminfo:

Slab:              20012 kB

Or did you mean something even more specific?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
