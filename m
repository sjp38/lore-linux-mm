Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0626B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 15:58:47 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id c9so14202410qcz.5
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 12:58:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q89si3483203qgd.39.2015.01.15.12.58.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 12:58:45 -0800 (PST)
Date: Thu, 15 Jan 2015 21:58:43 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [LSF/MM TOPIC ATTEND]
Message-ID: <20150115205843.GS6103@redhat.com>
References: <20150106161435.GF20860@dhcp22.suse.cz>
 <xr93k30zij6o.fsf@gthelen.mtv.corp.google.com>
 <20150107142804.GD16553@dhcp22.suse.cz>
 <20150114212745.GQ6103@redhat.com>
 <20150115140654.GG7000@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150115140654.GG7000@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

Hi Michal,

On Thu, Jan 15, 2015 at 03:06:54PM +0100, Michal Hocko wrote:
> 
> > http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=a0fcf2323b2e4cffd750c1abc1d2c138acdefcc8
> 
> I am not sure about this one because TIF_MEMDIE is there to give an
> access to memory reserves. GFP_NOFAIL shouldn't mean the same because
> then it would be much harder to "guarantee" that the reserves wouldn't
> be depleted completely. So I do not like this much. Besides that I think
> that GFP_NOFAIL allocation blocking OOM victim is a plain bug.
> grow_dev_page is relying on GFP_NOFAIL but I am wondering whether ext4
> can do something to pre-allocate so that it doesn't have to call it.

Well this is just the longstanding GFP_NOFAIL livelock, it always
existed deep down in the buffer header allocation even before
GFP_NOFAIL existed. GFP_NOFAIL just generalized the livelocking
concept.

There's no proper fix for that other than to teach the filesystem to
deal with allocation errors and remove GFP_NOFAIL (in this case
__GFP_NOFAIL was set:

 #0 get_page_from_freelist (gfp_mask=0x20858, nodemask=0x0
  <irq_stack_union>, order=0x0, zonelist=0xffff88007fffc100, hi
  gh_zoneidx=0x2, alloc_flags=0xc0, preferred_zone=0xffff88007fffa840,
  classzone_idx=classzone_idx@entry=0x1,
  migratetype=migratetype@entry=0x2) at mm/page_alloc.c:1953

gfp_mask=0x20858  & 0x800u = 0x800

If we're OOM and GFP_NOFAIL actually fails to allocate memory, this
patch simply tries to mitigate the potential livelock by giving it a
chance to use the memory reserves that are normally used only for high
priority allocations.

If __GFP_NOFAIL hits OOM I think it's fair to say it is very high
priority (more high priority than a GFP_ATOMIC or something that can
fail totally gracefully).

So the above second patch looks quite safe to me conceptually as well:
at least we put those last 50M of ram to good use instead of
livelocking while 50M are still free.

> > http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=798b7f9d549664f8c0007c6416a2568eedd75d6a
> 
> I think this should be fixed in the filesystem rather than paper over
> it.

No doubt, this third patch basically undoes the fix in the first
patch. This third patch makes __GFP_FS again not failing if invoked in
kernel thread context where TIF_MEMDIE cannot ever be set.

However there was no way I could run without this third patch on my
own production systems with a potential ext4 mounting itself readonly
on me during OOM killing (as result of the livelock fix in the first
patch).

Ideally the ext4 developer should reverse this third patch (which must
be keep separated from the first patch exactly for this reason) and
start an OOM killing loop to reproduce and fix this so then we can
reverse the third patch.

In short:

1) first patch makes !__GFP_FS not equivalent to __GFP_NOFAIL anymore
   (when invoked by kernel threads where TIF_MEMDIE cannot be set)

2) second patch deals with a genuine __GFP_NOFAIL livelock using the
   memory reserves (this is orthogonal with 1)

3) third patch undoes 1 and uses the memory reserves for !__GFP_FS too
   like patch 2 used them to mitigate the genuine __GFP_NOFAIL
   deadlock.  Undoing patch 1 is needed because patch 1 causes ext4 to
   remount itself readonly and complain about metadata corruption.

I later tested further the ext4 trouble after applying only 1 and it
seems ext4 thinks it's corrupted, but e2fsck -f shows it's actually
clean. So it's probably an in-memory issue only, but still having ext4
remounting itself readonly during a OOM killing isn't exactly
acceptable or graceful (until it is fixed). Hence the reason for 3.

Of course it took a long time before the trouble with patch 1 seen the
light, in fact first I hit the genuine __GFP_NOFAIL deadlock fixed by
2 before I could ever hit the ext4 error paths.

Let me know what you'd like me to submit, I just don't think
submitting only the first patch as you suggested is safe idea.

I also think allowing __GFP_NOFAIL to access the emergency reserves is
ok if __GFP_NOFAIL is hitting an OOM condition (what else could be
more urgent than succeeding a potentially livelocking __GFP_NOFAIL?).

I think the combination of the 3 patches is safe and in practice it
solves all OOM related livelocks I run into. It also allows ext4
developers to trivially (git reverse #ofpatch3) to fix their bugs and
then we can reverse the third patch upstream so !__GFP_FS allocations
from kernel threads becomes theoretically safe too. As opposed
__GFP_NOFAIL is never theoretically safe but that's much harder to fix
than the already existing ext4 error paths that aren't using
__GFP_NOFAIL but that haven't been properly exercised, simply because
they couldn't be exercised without patch 1 applied (kernel thread
allocations without __GFP_FS set cannot fail currently and making them
fail by applying patch1, exercises those untested error paths for the
first time).

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
