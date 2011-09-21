Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 056189000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 13:06:16 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so2248925bkb.14
        for <linux-mm@kvack.org>; Wed, 21 Sep 2011 10:06:12 -0700 (PDT)
Date: Wed, 21 Sep 2011 21:05:27 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to
 /proc/slabinfo
Message-ID: <20110921170527.GA15869@albatros>
References: <20110910164001.GA2342@albatros>
 <20110910164134.GA2442@albatros>
 <20110914192744.GC4529@outflux.net>
 <20110918170512.GA2351@albatros>
 <CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
 <20110919144657.GA5928@albatros>
 <14082.1316461507@turing-police.cc.vt.edu>
 <20110919205541.1c44f1a3@bob.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110919205541.1c44f1a3@bob.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@linux.intel.com>
Cc: Valdis.Kletnieks@vt.edu, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <gregkh@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

(I have to increase the CC list by CC'ing Greg and perf guys.  The
motivation for restricting slabinfo is here:

http://www.openwall.com/lists/kernel-hardening/2011/09/10/4)

> Anybody who thinks that debugging tools should be totally disabled on
> "production" systems probably hasn't spent enough time actually
> running production systems.

On Mon, Sep 19, 2011 at 20:55 +0100, Alan Cox wrote:
> Agreed - far better it is simply set root only.

Sorry, I've poorly worded my statement.  Of course I mean root-only
slabinfo, not totally disable it.


So, where are we now?

Linus, Alan, Kees, and Dave are about to simply restrict slabinfo (and
probably similar interfaces) to root.  Pekka is OK too.

Christoph and Valdis are about to create new CONFIG_ option to be able
to restrict the access to slabinfo/etc., but with old relaxed
permissions.


IMO having a compatibility with the old tools using slabinfo/meminfo as
non-root for good things is great, but probably a seamless upgrade
doesn't worth it in this case.  Instead, we can provide a transition
instructions to continue to use non-root monitoring tools:

    groupadd meminfo
    usermod -a -G meminfo $MONITOR_USER

And add these lines to the init scripts between mount /proc and running
monitoring daemon, for Ubuntu's upstart it should fit in mountall.conf:

    chmod g+r /proc/slabinfo /proc/meminfo
    chgrp meminfo /proc/slabinfo /proc/meminfo

Then the daemon may watch for memleaks again.  It requires some actions
from the sysadmin, but no changes to the daemons and it helps to keep
sane kernel defaults.

Are we OK with this solution?


Now about other sources of infoleaks.  Pekka has noticed that the same
information about slabs is accessible from sysfs and 'perf kmem':

http://www.openwall.com/lists/kernel-hardening/2011/09/19/23

For sysfs the solution is relatively simple - the same __ATTR(..., 0600,
...) for SLAB_ATTR() (all __ATTR* in mm/*.c?) with the same chmod in
init scripts.


For the perf the situation differs.  AFAICS (please correct me if I'm
wrong) all performance events are recorded and passed to userspace
without any security checks.  IOW, every event happened in the current
process' context is signalled to the current task if requested.  It
contains k*alloc/kfree, which are the subject of this thread, and
probably much more infoleaks which simply nobody cared about yet.
Probably it's time to develop some rules to identify what events are
safe to signal to user and what are dangerous/private to the
system/other users (probably, potentially)?  I'm not very familiar with
perf events and there might be already such mechanisms, but they're just
not used for memory things, so this is a question to the perf guys.


Other sources of similar infoleaks are fs-specific and IMO we should fix
them after these more "generic" infoleaks (slabinfo, meminfo, sysfs,
perf).


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
