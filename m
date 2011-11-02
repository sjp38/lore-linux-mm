Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E4FF46B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 21:15:28 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B00273EE0BD
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 10:15:25 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9342845DE55
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 10:15:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F9DF45DD74
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 10:15:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FF8C1DB803C
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 10:15:25 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D2021DB802C
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 10:15:25 +0900 (JST)
Date: Wed, 2 Nov 2011 10:14:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-Id: <20111102101414.457e0a08.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <f62e02cd-fa41-44e8-8090-efe2ef052f64@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	<20111031171321.097a166c.kamezawa.hiroyu@jp.fujitsu.com>
	<ef778e79-72d0-4c58-99e8-3b36d85fa30d@default
 20111101095038.30289914.kamezawa.hiroyu@jp.fujitsu.com>
	<f62e02cd-fa41-44e8-8090-efe2ef052f64@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

On Tue, 1 Nov 2011 08:25:38 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> >   - At discussing an fujitsu user support guy (just now), he asked
> >     'why it's not designed as device driver ?"
> >     I couldn't answered.
> > 
> >     So, I have small concerns with frontswap.ops ABI design.
> >     Do we need ABI and other modules should be pluggable ?
> >     Can frontswap be implemented as something like
> > 
> >     # setup frontswap via device-mapper or some.
> >     # swapon /dev/frontswap
> >     ?
> >     It seems required hooks are just before/after read/write swap device.
> >     other hooks can be implemented in notifier..no ?
> 
> A good question, and it is answered in FAQ #4 included in
> the patchset (Documentation/vm/frontswap.txt).  The short
> answer is that the tmem ABI/API used by frontswap is
> intentionally very very dynamic -- ANY attempt to put
> a page into it can be rejected by the backend.  This is
> not possible with block I/O or swap, at least without
> a massive rewrite.  And this dynamic capability is the
> key to supporting the many users that frontswap supports.
> 
Hmm.

> By the way, what your fujitsu user support guy suggests is
> exactly what zram does.  The author of zram (Nitin Gupta)
> agrees that frontswap has many advantages over zram,
> see https://lkml.org/lkml/2011/10/28/8 and he supports
> merging frontswap.  And Ed Tomlinson, a current user
> of zram says that he would use frontswap instead of
> zram: https://lkml.org/lkml/2011/10/29/53 
> 
> Kame, can I add you to the list of people who support
> merging frontswap, assuming more good performance numbers
> are posted?
> 
Before answer, let me explain my attitude to this project.

As hobby, I like this kind of work which allows me to imagine what kind
of new fancy features it will allow us. Then, I reviewed patches.

As people who sells enterprise system and support, I can't recommend this
to our customers. IIUC, cleancache/frontswap/zcache hides its avaiable
resources from user's view and making the system performance unvisible and
not-predictable. That's one of the reason why I asksed whether or not
you have plans to make frontswap(cleancache) cgroup aware.
(Hmm, but at making a product which offers best-effort-performance to customers,
 this project may make sense. But I am not very interested in best-effort
 service very much.)

I wonder if there are 'static size simple victim cache per cgroup' project
under frontswap/cleancache and it helps all user's workload isolation
even if there is no VM or zcache, tmem.  It sounds wonderful.

So, I'd like to ask whether you have any enhancement plans in future ?
rather than 'current' peformance. The reason I hesitate to say "Okay!",
is that I can't see enterprise usage of this, a feature which cannot
be controlled by admins and make perfomrance prediction difficult in busy system.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
