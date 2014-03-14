Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 14D926B0037
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 00:47:52 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so2098547pbb.15
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 21:47:51 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id vu10si4301169pbc.159.2014.03.13.21.47.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 21:47:51 -0700 (PDT)
Message-ID: <532289F6.5010404@nvidia.com>
Date: Thu, 13 Mar 2014 21:47:50 -0700
From: John Hubbard <jhubbard@nvidia.com>
MIME-Version: 1.0
Subject: Re: [PATCH] A long explanation for a short patch
References: <1394764246-19936-1-git-send-email-jhubbard@nvidia.com> <5322875D.1040702@oracle.com>
In-Reply-To: <5322875D.1040702@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "john.hubbard@gmail.com" <john.hubbard@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Josh Boyer <jwboyer@redhat.com>

On 03/13/2014 09:36 PM, Sasha Levin wrote:
> On 03/13/2014 10:30 PM, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> Hi Sasha and linux-mm,
>>
>> Prior to commit 309381feaee564281c3d9e90fbca8963bb7428ad, it was
>> possible to build MIT-licensed (non-GPL) drivers on Fedora. Fedora is
>> semi-unique, in that it sets CONFIG_VM_DEBUG.
>>
>> Because Fedora sets CONFIG_VM_DEBUG, they end up pulling in
>> dump_page(), via VM_BUG_ON_PAGE, via get_page().  As one of the
>> authors of NVIDIA's new, open source, "UVM-Lite" kernel module, I
>> originally choose to use the kernel's get_page() routine from within
>> nvidia_uvm_page_cache.c, because get_page() has always seemed to be
>> very clearly intended for use by non-GPL, driver code.
>>
>> So I'm hoping that making get_page() widely accessible again will not
>> be too controversial. We did check with Fedora first, and they
>> responded (https://bugzilla.redhat.com/show_bug.cgi?id=1074710#c3)
>> that we should try to get upstream changed, before asking Fedora
>> to change.  Their reasoning seems beneficial to Linux: leaving
>> CONFIG_DEBUG_VM set allows Fedora to help catch mm bugs.
> 
> Thanks for pointing it out. I've definitely overlooked it as a
> consequence of the patch. My reasoning behind making it _GPL() was
> simply that it's a new export, so it's GPL unless there's a really
> good excuse to make it non-GPL.
> 
> However, dump_page() as well as the regular VM_BUG_ON() are debug
> functions that access functionality which isn't essential for
> non-GPL modules.
> 
> This isn't the first and only case where enabling debug options will
> turn code that was previously usable under a non-GPL license into
> GPL specific. For example:
> 
>   - CONFIG_LOCKDEP* will turn locks GPL-only.
>   - CONFIG_DYNAMIC_DEBUG will turn module loading GPL-only.
>   - CONFIG_SUNRPC_DEBUG will turn the net RPC code GPL-only.
> 
> To keep it short, my opinion is that since it doesn't break any existing
> code it should be kept as _GPL(), same way it was done for various other
> subsystems.
> 
> Also, I think that enabling CONFIG_DEBUG_VM for end-users is a very risky
> thing to do. I agree you'll find more bugs, but you'll also hit one of the many
> false-positives hidden there as well. I've reported a few of those but
> in some cases it's hard to determine whether it's an actual false-positive
> or a bug somewhere else. Since the assumption is that end-users won't
> have CONFIG_DEBUG_VM, they don't get all the attention they deserve and
> end up slipping into releases: http://www.spinics.net/lists/linux-mm/msg70368.html .

OK, fair enough. I'm adding Fedora's Josh Boyer to CC, in case he wants to
weigh in, but that's about as hard as I'm really willing to push here. :)

thanks so much for the quick and courteous response, btw.

> 
> Actually, I can think of a few cases where having CONFIG_DEBUG_VM enabled would
> qualify a rather simple code to a CVE status.
> 
> 
> Thanks,
> Sasha
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
