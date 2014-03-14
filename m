Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id B58C26B0073
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 09:42:28 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id w8so2511041qac.12
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 06:42:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c5si3396164qgc.67.2014.03.14.06.42.27
        for <linux-mm@kvack.org>;
        Fri, 14 Mar 2014 06:42:27 -0700 (PDT)
Date: Fri, 14 Mar 2014 09:42:23 -0400
From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH] A long explanation for a short patch
Message-ID: <20140314134222.GG16145@hansolo.jdub.homelinux.org>
References: <1394764246-19936-1-git-send-email-jhubbard@nvidia.com>
 <5322875D.1040702@oracle.com>
 <532289F6.5010404@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532289F6.5010404@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, "john.hubbard@gmail.com" <john.hubbard@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Mar 13, 2014 at 09:47:50PM -0700, John Hubbard wrote:
> On 03/13/2014 09:36 PM, Sasha Levin wrote:
> > On 03/13/2014 10:30 PM, john.hubbard@gmail.com wrote:
> >> From: John Hubbard <jhubbard@nvidia.com>
> >>
> >> Hi Sasha and linux-mm,
> >>
> >> Prior to commit 309381feaee564281c3d9e90fbca8963bb7428ad, it was
> >> possible to build MIT-licensed (non-GPL) drivers on Fedora. Fedora is
> >> semi-unique, in that it sets CONFIG_VM_DEBUG.
> >>
> >> Because Fedora sets CONFIG_VM_DEBUG, they end up pulling in
> >> dump_page(), via VM_BUG_ON_PAGE, via get_page().  As one of the
> >> authors of NVIDIA's new, open source, "UVM-Lite" kernel module, I
> >> originally choose to use the kernel's get_page() routine from within
> >> nvidia_uvm_page_cache.c, because get_page() has always seemed to be
> >> very clearly intended for use by non-GPL, driver code.
> >>
> >> So I'm hoping that making get_page() widely accessible again will not
> >> be too controversial. We did check with Fedora first, and they
> >> responded (https://bugzilla.redhat.com/show_bug.cgi?id=1074710#c3)
> >> that we should try to get upstream changed, before asking Fedora
> >> to change.  Their reasoning seems beneficial to Linux: leaving
> >> CONFIG_DEBUG_VM set allows Fedora to help catch mm bugs.
> > 
> > Thanks for pointing it out. I've definitely overlooked it as a
> > consequence of the patch. My reasoning behind making it _GPL() was
> > simply that it's a new export, so it's GPL unless there's a really
> > good excuse to make it non-GPL.

Breaking an open-source licensed driver isn't a good excuse? :)

> > However, dump_page() as well as the regular VM_BUG_ON() are debug
> > functions that access functionality which isn't essential for
> > non-GPL modules.

Doesn't your change make it somewhat essential to the drivers calling
the functions that _are_ essential?  The dump_page function itself
wasn't previously exported at all, and I'm guessing you had to export
it because of the inline functions dragging it in and drivers using
those functions.  It seems the biggest issue stems from the previously
working inline functions now being marked as GPL-only in this case when
they clearly weren't before.

> > This isn't the first and only case where enabling debug options will
> > turn code that was previously usable under a non-GPL license into
> > GPL specific. For example:
> > 
> >   - CONFIG_LOCKDEP* will turn locks GPL-only.
> >   - CONFIG_DYNAMIC_DEBUG will turn module loading GPL-only.
> >   - CONFIG_SUNRPC_DEBUG will turn the net RPC code GPL-only.
> >
> > To keep it short, my opinion is that since it doesn't break any existing
> > code it should be kept as _GPL(), same way it was done for various other
> > subsystems.

I'm not entirely sure that's an apples to apples comparison, or that
some of those statements are even accurate.  I really don't want to get
into that debate though.

> > Also, I think that enabling CONFIG_DEBUG_VM for end-users is a very risky
> > thing to do. I agree you'll find more bugs, but you'll also hit one of the many
> > false-positives hidden there as well. I've reported a few of those but
> > in some cases it's hard to determine whether it's an actual false-positive
> > or a bug somewhere else. Since the assumption is that end-users won't
> > have CONFIG_DEBUG_VM, they don't get all the attention they deserve and
> > end up slipping into releases: http://www.spinics.net/lists/linux-mm/msg70368.html .

The last time this came up not that long ago, various MM people were
surprised we had it enabled but overall supportive.  I think Hugh and
Dave were involved in those discussions.  I'm certainly willing to
revisit having it enabled if the state of the code has changed since
then.

However, if the things wrapped in DEBUG_VM aren't getting the attention
they deserve, are causing false-positives, and generally aren't
maintained, then perhaps having a config option to enable them isn't a
great idea.  Users will toggle any and all config options that are out
there and making assumptions that they aren't going to be enabled by
users is pretty silly.  Perhaps just make them depend on modifying a
#debug define at the top of each file in question?  That way "end users"
won't easily be able to turn on broken debug code.

josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
