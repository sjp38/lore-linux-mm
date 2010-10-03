Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EE1596B0047
	for <linux-mm@kvack.org>; Sun,  3 Oct 2010 15:28:06 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o93J8jXi029132
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 15:08:45 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o93JRuv4459154
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 15:27:58 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o93JRtaA020507
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 13:27:55 -0600
Subject: Re: OOM panics with zram
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4CA8CE45.9040207@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	 <1284053081.7586.7910.camel@nimitz>  <4CA8CE45.9040207@vflare.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Sun, 03 Oct 2010 12:27:53 -0700
Message-ID: <1286134073.9970.11.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Greg KH - Meetings <ghartman@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-10-03 at 14:41 -0400, Nitin Gupta wrote:
> Ability to write out zram (compressed) memory to a backing disk seems
> really useful. However considering lkml reviews, I had to drop this
> feature. Anyways, I guess I will try to push this feature again.

I'd argue that zram is pretty useless without some ability to write to a
backing store, unless you *really* know what is going to be stored in it
and you trust the user.  Otherwise, it's just too easy to OOM the
system.

I've been investigating backing the xvmalloc space with a tmpfs file.
Instead of keeping page/offset pairs, you just keep a linear address
inside the tmpfile file.  There's an extra step needed to look up and
lock the page cache page into place each time you go into the xvmalloc
store, but it does seem to basically work.  The patches are really rough
and not quite functional, but I'm happy to share if you want to see them
now.

> Also, please do not use linux-next/mainline version of compcache. Instead
> just use version in the project repository here:
> hg clone https://compcache.googlecode.com/hg/ compcache 
> 
> This is updated much more frequently and has many more bug fixes over
> the mainline. It will also be easier to fix bugs/add features much more
> quickly in this repo rather than sending them to lkml which can take
> long time.

That looks like just a clone of the code needed to build the module.  

Kernel developers are pretty used to _some_ kernel tree being the
authoritative source.  Also, having it in a kernel tree makes it
possible to get testing in places like linux-next, and it makes it
easier for people to make patches or kernel trees on top of your work. 

There's not really a point to the code being in -staging if it isn't
somewhat up-to-date or people can't generate patches to it.  It sounds
to me like we need to take it out of -staging.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
