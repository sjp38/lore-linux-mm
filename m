Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id AD8316B0005
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 03:08:06 -0400 (EDT)
Date: Thu, 21 Mar 2013 17:37:50 +1030
From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: OOM triggered with plenty of memory free
Message-ID: <20130321070750.GV30145@marvin.atrad.com.au>
References: <CAJd=RBDHwgtm=to3WUj73d7q6cjJ7oG6capjUxvcpVk0wH-fbQ@mail.gmail.com>
 <CAGDaZ_ryxdMBm44kotjKyCeFEFk3OURjHav3zVOcQNGwP_ZwAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_ryxdMBm44kotjKyCeFEFk3OURjHav3zVOcQNGwP_ZwAQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jonathan Woithe <jwoithe@atrad.com.au>

On Sat, Mar 16, 2013 at 02:33:23AM -0700, Raymond Jennings wrote:
> Anyway, to the parent poster, could you tell us more, such as how much
> ram you had left free?

Following on from my previous post, here is a summary of what I know about
this memory leak following additional testing.
 * It was introduced in 2.6.35.11
 * It was not present in 2.6.35.12
 * Previous git bisects on the main git tree indicate that the leak was
   not in 2.6.36 or any later mainline kernel version

Commit cab9e9848b9a8283b0504a2d7c435a9f5ba026de to the stable tree ("scm:
Capture the full credentials of the scm sender") seems to have introduced
the leak.

Commit 48e6b121605512d87f8da1ccd014313489c19630 to the stable tree ("Fix
cred leak in AF_NETLINK") seems to have fixed the leak in the stable branch. 
The commit message concentrates on the closure of an information leak, but
evidently there was a memory leak behind it as well.

cab9..26de was upstreamed as 257b5358b32f17e0603b6ff57b13610b0e02348f, but
48e6..9630 does not appear to have made it into mainline in its entirety.
However, the call to scm_destroy() in the "out:" block added by 48e6..9630
is in mainline; I presume that this is what closes the memory leak because
the only other parts of the commit set the function return value (unless the
different function returns cause the callers not to leak).

I'm guessing that 48e6..9630 was not applied to mainline in its
entirety due to the underlying problem being fixed in a slightly different
way.

Regards
  jonathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
