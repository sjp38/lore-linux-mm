Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E702D6B0038
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 01:40:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r74so4748915wme.5
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 22:40:39 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id o26si361360edf.511.2017.09.20.22.40.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Sep 2017 22:40:38 -0700 (PDT)
Received: from mail-io0-f199.google.com ([209.85.223.199])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <seth.forshee@canonical.com>)
	id 1duuE1-00064y-Bm
	for linux-mm@kvack.org; Thu, 21 Sep 2017 05:40:37 +0000
Received: by mail-io0-f199.google.com with SMTP id 93so8482505iol.2
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 22:40:37 -0700 (PDT)
Date: Thu, 21 Sep 2017 00:40:34 -0500
From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: Memory hotplug regression in 4.13
Message-ID: <20170921054034.judv6ovyg5yks4na@ubuntu-hedt>
References: <20170919164114.f4ef6oi3yhhjwkqy@ubuntu-xps13>
 <20170920092931.m2ouxfoy62wr65ld@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920092931.m2ouxfoy62wr65ld@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 20, 2017 at 11:29:31AM +0200, Michal Hocko wrote:
> Hi,
> I am currently at a conference so I will most probably get to this next
> week but I will try to ASAP.
> 
> On Tue 19-09-17 11:41:14, Seth Forshee wrote:
> > Hi Michal,
> > 
> > I'm seeing oopses in various locations when hotplugging memory in an x86
> > vm while running a 32-bit kernel. The config I'm using is attached. To
> > reproduce I'm using kvm with the memory options "-m
> > size=512M,slots=3,maxmem=2G". Then in the qemu monitor I run:
> > 
> >   object_add memory-backend-ram,id=mem1,size=512M
> >   device_add pc-dimm,id=dimm1,memdev=mem1
> > 
> > Not long after that I'll see an oops, not always in the same location
> > but most often in wp_page_copy, like this one:
> 
> This is rather surprising. How do you online the memory?

The kernel has CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE=y.

> > [   24.673623] BUG: unable to handle kernel paging request at dffff000
> > [   24.675569] IP: wp_page_copy+0xa8/0x660
> 
> could you resolve the IP into the source line?

It seems I don't have that kernel anymore, but I've got a 4.14-rc1 build
and the problem still occurs there. It's pointing to the call to
__builtin_memcpy in memcpy (include/linux/string.h line 340), which we
get to via wp_page_copy -> cow_user_page -> copy_user_highpage.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
