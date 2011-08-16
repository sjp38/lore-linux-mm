Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CEE466B016F
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 05:06:39 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so4929221bkb.14
        for <linux-mm@kvack.org>; Tue, 16 Aug 2011 02:06:36 -0700 (PDT)
Date: Tue, 16 Aug 2011 13:05:40 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC] x86, mm: start mmap allocation for libs from low
 addresses
Message-ID: <20110816090540.GA7857@albatros>
References: <20110812102954.GA3496@albatros>
 <ccea406f-62be-4344-8036-a1b092937fe9@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ccea406f-62be-4344-8036-a1b092937fe9@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel-hardening@lists.openwall.com, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 12, 2011 at 18:19 -0500, H. Peter Anvin wrote:
> Vasiliy Kulikov <segoon@openwall.com> wrote:
> 
> >This patch changes mmap base address allocator logic to incline to
> >allocate addresses from the first 16 Mbs of address space.  These
> >addresses start from zero byte (0x00AABBCC).
...

To make it clear:

The VM space is not significantly reduced - an additional gap, which
is used for ASCII-protected region, is calculated the same way as the
common mmap gap is calculated.  The maximum size of the gap is 1MB for
the upstream kernel default ASLR entropy - a trifle IMO.

If the new allocator fails to find appropriate vma in the protected
zone, the old one tries to do the job.  So, no visible changes for
userspace.


As to the benefit:

1) For small PIE programs, which don't use much libraries, all
executable regions are moved to the protected zone.

2) For non-PIE programs if image starts from 0x00AABBCC address and fits
into the zone the same rule of small libs applies.

3) For non-PIE programs with images above 0x01000000 and/or programs
with much libraries some code sections are outsize of the protected region.

The protection works for (1) and (2) programs.  It doesn't work for (3).


(1) is not too seldom.  Programs, which need such protection (network
daemons, programs parsing untrusted input, etc.), are usually small
enough.  In our distro, Openwall GNU/*/Linux, almost all daemon programs
fit into the region.

As the changes are not intrusive, we'd want to see this feature in the
upstream kernel.  If you know why the patch cannot be a part of the
upstream kernel - please tell me, I'll try to address the issues.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
