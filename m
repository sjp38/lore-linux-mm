Date: Tue, 13 Jul 2004 16:35:25 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
Message-ID: <Pine.SGI.4.58.0407131612070.111843@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407132113350.8577-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2004, Hugh Dickins wrote:

> Though wli's per-cpu idea was sensible enough, converting to that
> didn't appeal to me very much.  We only have a limited amount of
> per-cpu space, I think, but an indefinite number of tmpfs mounts.
> Might be reasonable to allow per-cpu for 4 or them (the internal
> one which is troubling you, /dev/shm, /tmp and one other).  Tiresome.

Per-CPU has the problem that the CPU on which you did a free_blocks++
might not be the same one where you do a free_blocks--.  Bleh.

Maybe using a hash indexed on some tid bits (pun unintended, but funny
nevertheless) might work?  But of course this suffers from the same
class of problem as mentioned in the previous paragraph.

> Yes, go ahead, though it's getting more and more embarrassing that I
> started out reusing VM_ACCOUNT within shmem.c, it should now have its
> own set of flags: let me tidy that up once you're done.

Hmm. Guess that means I need to crack the whip on myself a bit... :)

> But please don't call the new one SHMEM_NOACCT: ACCT or ACCOUNT refers
> to the security_vm_enough_memory/vm_unacct_memory stuff throughout,
> and _that_ accounting does still apply to these /dev/zero files.
>
> Hmm, I was about to suggest SHMEM_NOSBINFO,
> but how about really no sbinfo, just NULL sbinfo?

If you'd like me to try that, I sure can.  The only problem is that
I'm having a devil of a time figuring out where the struct super_block
comes from for /dev/null -- or heck, if it's even distinct from any
others.  And the relationship between /dev/null and /dev/shm is still
quite fuzzy as well.  Oh the joy of being new to a chunk of code...

Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
