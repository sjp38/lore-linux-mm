Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0626B0253
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 08:58:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v109so8972430wrc.5
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 05:58:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h30si1015613edb.322.2017.09.25.05.58.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 05:58:27 -0700 (PDT)
Date: Mon, 25 Sep 2017 14:58:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory hotplug regression in 4.13
Message-ID: <20170925125825.zpgasjhjufupbias@dhcp22.suse.cz>
References: <20170919164114.f4ef6oi3yhhjwkqy@ubuntu-xps13>
 <20170920092931.m2ouxfoy62wr65ld@dhcp22.suse.cz>
 <20170921054034.judv6ovyg5yks4na@ubuntu-hedt>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170921054034.judv6ovyg5yks4na@ubuntu-hedt>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Forshee <seth.forshee@canonical.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 21-09-17 00:40:34, Seth Forshee wrote:
> On Wed, Sep 20, 2017 at 11:29:31AM +0200, Michal Hocko wrote:
> > Hi,
> > I am currently at a conference so I will most probably get to this next
> > week but I will try to ASAP.
> > 
> > On Tue 19-09-17 11:41:14, Seth Forshee wrote:
> > > Hi Michal,
> > > 
> > > I'm seeing oopses in various locations when hotplugging memory in an x86
> > > vm while running a 32-bit kernel. The config I'm using is attached. To
> > > reproduce I'm using kvm with the memory options "-m
> > > size=512M,slots=3,maxmem=2G". Then in the qemu monitor I run:
> > > 
> > >   object_add memory-backend-ram,id=mem1,size=512M
> > >   device_add pc-dimm,id=dimm1,memdev=mem1
> > > 
> > > Not long after that I'll see an oops, not always in the same location
> > > but most often in wp_page_copy, like this one:
> > 
> > This is rather surprising. How do you online the memory?
> 
> The kernel has CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE=y.

OK, so the memory gets online automagically at the time when it is
hotadded. Could you send the full dmesg?

> > > [   24.673623] BUG: unable to handle kernel paging request at dffff000
> > > [   24.675569] IP: wp_page_copy+0xa8/0x660
> > 
> > could you resolve the IP into the source line?
> 
> It seems I don't have that kernel anymore, but I've got a 4.14-rc1 build
> and the problem still occurs there. It's pointing to the call to
> __builtin_memcpy in memcpy (include/linux/string.h line 340), which we
> get to via wp_page_copy -> cow_user_page -> copy_user_highpage.

Hmm, this is interesting. That would mean that we have successfully
mapped the destination page but its memory is still not accessible.

Right now I do not see how the patch you have bisected to could make any
difference because it only postponed the onlining to be independent but
your config simply onlines automatically so there shouldn't be any
semantic change. Maybe there is some sort of off-by-one or something.

I will try to investigate some more. Do you think it would be possible
to configure kdump on your system and provide me with the vmcore in some
way?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
