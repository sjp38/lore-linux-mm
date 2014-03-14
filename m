Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3BCB66B0035
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 00:36:53 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so2078207pbc.30
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 21:36:52 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id nc6si4283033pbc.173.2014.03.13.21.36.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 21:36:52 -0700 (PDT)
Message-ID: <5322875D.1040702@oracle.com>
Date: Fri, 14 Mar 2014 00:36:45 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] A long explanation for a short patch
References: <1394764246-19936-1-git-send-email-jhubbard@nvidia.com>
In-Reply-To: <1394764246-19936-1-git-send-email-jhubbard@nvidia.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>

On 03/13/2014 10:30 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
>
> Hi Sasha and linux-mm,
>
> Prior to commit 309381feaee564281c3d9e90fbca8963bb7428ad, it was
> possible to build MIT-licensed (non-GPL) drivers on Fedora. Fedora is
> semi-unique, in that it sets CONFIG_VM_DEBUG.
>
> Because Fedora sets CONFIG_VM_DEBUG, they end up pulling in
> dump_page(), via VM_BUG_ON_PAGE, via get_page().  As one of the
> authors of NVIDIA's new, open source, "UVM-Lite" kernel module, I
> originally choose to use the kernel's get_page() routine from within
> nvidia_uvm_page_cache.c, because get_page() has always seemed to be
> very clearly intended for use by non-GPL, driver code.
>
> So I'm hoping that making get_page() widely accessible again will not
> be too controversial. We did check with Fedora first, and they
> responded (https://bugzilla.redhat.com/show_bug.cgi?id=1074710#c3)
> that we should try to get upstream changed, before asking Fedora
> to change.  Their reasoning seems beneficial to Linux: leaving
> CONFIG_DEBUG_VM set allows Fedora to help catch mm bugs.

Thanks for pointing it out. I've definitely overlooked it as a
consequence of the patch. My reasoning behind making it _GPL() was
simply that it's a new export, so it's GPL unless there's a really
good excuse to make it non-GPL.

However, dump_page() as well as the regular VM_BUG_ON() are debug
functions that access functionality which isn't essential for
non-GPL modules.

This isn't the first and only case where enabling debug options will
turn code that was previously usable under a non-GPL license into
GPL specific. For example:

  - CONFIG_LOCKDEP* will turn locks GPL-only.
  - CONFIG_DYNAMIC_DEBUG will turn module loading GPL-only.
  - CONFIG_SUNRPC_DEBUG will turn the net RPC code GPL-only.

To keep it short, my opinion is that since it doesn't break any existing
code it should be kept as _GPL(), same way it was done for various other
subsystems.

Also, I think that enabling CONFIG_DEBUG_VM for end-users is a very risky
thing to do. I agree you'll find more bugs, but you'll also hit one of the many
false-positives hidden there as well. I've reported a few of those but
in some cases it's hard to determine whether it's an actual false-positive
or a bug somewhere else. Since the assumption is that end-users won't
have CONFIG_DEBUG_VM, they don't get all the attention they deserve and
end up slipping into releases: http://www.spinics.net/lists/linux-mm/msg70368.html .

Actually, I can think of a few cases where having CONFIG_DEBUG_VM enabled would
qualify a rather simple code to a CVE status.


Thanks,
Sasha


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
