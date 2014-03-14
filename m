Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 062B16B003B
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 12:53:37 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so8108188qgf.0
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 09:53:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x6si3733671qas.74.2014.03.14.09.53.37
        for <linux-mm@kvack.org>;
        Fri, 14 Mar 2014 09:53:37 -0700 (PDT)
Date: Fri, 14 Mar 2014 12:53:32 -0400
From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH] A long explanation for a short patch
Message-ID: <20140314165332.GH16145@hansolo.jdub.homelinux.org>
References: <1394764246-19936-1-git-send-email-jhubbard@nvidia.com>
 <5322875D.1040702@oracle.com>
 <532289F6.5010404@nvidia.com>
 <20140314134222.GG16145@hansolo.jdub.homelinux.org>
 <53231BB3.20205@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53231BB3.20205@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: John Hubbard <jhubbard@nvidia.com>, "john.hubbard@gmail.com" <john.hubbard@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 14, 2014 at 11:09:39AM -0400, Sasha Levin wrote:
> On 03/14/2014 09:42 AM, Josh Boyer wrote:
> >On Thu, Mar 13, 2014 at 09:47:50PM -0700, John Hubbard wrote:
> >>>To keep it short, my opinion is that since it doesn't break any existing
> >>>code it should be kept as _GPL(), same way it was done for various other
> >>>subsystems.
> >
> >I'm not entirely sure that's an apples to apples comparison, or that
> >some of those statements are even accurate.  I really don't want to get
> >into that debate though.
> 
> Fair enough. I'm not trying to say that it's exactly the same issue, but
> only that such issues occurred in the past and were dealt differently by
> Fedora. From the text of the Fedora bug report on the subject:
> 
> """
> A similar conflict exists between the nvidia.ko module and kernels with
> CONFIG_DEBUG_LOCK_ALLOC enabled: Fedora alpha kernels have this option
> enabled by default, and Fedora beta and release kernels have it disabled.
> """

Right.  We can do that with DEBUG_VM as well if needs be.  I suppose the
thing that gave me pause here is that the highlighted example was an
issue with a proprietary module whereas this one is permissively
licensed (more permissively than GPL even).  Unfortunately, there is no
EXPORT_SYMBOL_OPENSOURCE or equivalent today, which means things break
somewhat unnecessarily.

This entire issue could be avoided if the UVM-lite module had:

MODULE_LICENSE("Dual MIT/GPL")

instead of just "MIT".  John, is that something that is possible?

> >>>Also, I think that enabling CONFIG_DEBUG_VM for end-users is a very risky
> >>>thing to do. I agree you'll find more bugs, but you'll also hit one of the many
> >>>false-positives hidden there as well. I've reported a few of those but
> >>>in some cases it's hard to determine whether it's an actual false-positive
> >>>or a bug somewhere else. Since the assumption is that end-users won't
> >>>have CONFIG_DEBUG_VM, they don't get all the attention they deserve and
> >>>end up slipping into releases: http://www.spinics.net/lists/linux-mm/msg70368.html .
> >
> >The last time this came up not that long ago, various MM people were
> >surprised we had it enabled but overall supportive.  I think Hugh and
> >Dave were involved in those discussions.  I'm certainly willing to
> >revisit having it enabled if the state of the code has changed since
> >then.
> >
> >However, if the things wrapped in DEBUG_VM aren't getting the attention
> >they deserve, are causing false-positives, and generally aren't
> >maintained, then perhaps having a config option to enable them isn't a
> >great idea.  Users will toggle any and all config options that are out
> >there and making assumptions that they aren't going to be enabled by
> >users is pretty silly.  Perhaps just make them depend on modifying a
> >#debug define at the top of each file in question?  That way "end users"
> >won't easily be able to turn on broken debug code.
> 
> I didn't want to imply that DEBUG_VM issues are getting pushed aside and
> ignored because "no one will see it". DEBUG_VM issues are being treated
> like any other mm/ issue, but they do get placed lower on a lower priority
> than issues that happen without DEBUG_VM due to lack of "manpower".
> 
> There's also no assumption that they won't get enabled, the only assumption
> is that if you enable it then you know what you're doing.

Hm.  It's enabled by default in defconfigs for tegra (ARM), blackfin,
s390, sh, and tile machines.  I suppose the "end user" of those
architectures knows what they're doing.  It still might be worthwhile to
add some cautionary wording to the Kconfig help text.  Today that says:

"Enable this to turn on extended checks in the virtual-memory system
 that may impact performance."

Extended checks sound good.  Sounds like it would make things safer.
Why wouldn't I want them?

Perhaps this would be more accurate:

"Enable this to turn on debugging infrastructure used by kernel
virtual-memory developers.  This may impact performance.  If you are not
debugging the Linux kernel virtual-memory subsystem, say N."

josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
