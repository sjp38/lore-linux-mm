Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EE3976B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 19:55:09 -0400 (EDT)
Received: by ey-out-1920.google.com with SMTP id 26so186210eyw.44
        for <linux-mm@kvack.org>; Wed, 06 May 2009 16:56:00 -0700 (PDT)
Date: Thu, 7 May 2009 08:55:47 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses
 registrations.
Message-Id: <20090507085547.24efb60f.minchan.kim@barrios-desktop>
In-Reply-To: <20090506145641.GA16078@random.random>
References: <1241475935-21162-2-git-send-email-ieidus@redhat.com>
	<1241475935-21162-3-git-send-email-ieidus@redhat.com>
	<4A00DD4F.8010101@redhat.com>
	<4A015C69.7010600@redhat.com>
	<4A0181EA.3070600@redhat.com>
	<20090506131735.GW16078@random.random>
	<Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
	<20090506140904.GY16078@random.random>
	<20090506152100.41266e4c@lxorguk.ukuu.org.uk>
	<Pine.LNX.4.64.0905061532240.25289@blonde.anvils>
	<20090506145641.GA16078@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Hi, Andrea.

On Wed, 6 May 2009 16:56:42 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, May 06, 2009 at 03:46:31PM +0100, Hugh Dickins wrote:
> > As I understand it, KSM won't affect the vm_overcommit behaviour at all.
> 
> In short vm_overcommit is a virtual thing, KSM only makes virtual
> takes less physical than before. One issue in KSM that was mentioned
> was the cgroup accounting if you merge two pages in different groups
> but that is kind of a corner case and it'll be handled "somehow" :)
> 
> > The only difference would be in how much memory (mostly lowmem)
> > KSM's own data structures will take up - as usual, the kernel
> > data structures aren't being accounted, but do take up memory.
> 
> Oh yeah, on 32bit systems that would be a problem... That lowmem is
> taken for eacy virtual address scanned. One more reason to still allow
> ksm to all users only selectively through chown/chmod with ioctl or
> sysfs permissions with syscall/madvise. Luckily most systems where ksm
> is used are 64bit. We don't plan to kmap_atomic around the
> rmap_item/tree_item. No ram is allocated in the holes though, so if

Hmm. Don't you consider 32-bit system ?

In http://www.mail-archive.com/kvm@vger.kernel.org/msg13043.html, 
Jared siad, it's also good in embedded system. (but I don't know well his testing environement).
Many embedded system is so I/O bouneded that we can use much CPU time in there. 
I hope this feature will help saving memory in embedded system. 

One more thing about interface. 

Ksm map regions are dynamic characteritic ?
I mean sometime A application calls ioctl(0x800000, 0x10000) and sometime it calls ioctl(0xb7000000, 0x20000);
Of course, It depends on application's behavior. 

For using this feature now, we have to add ioctl and recompile applications.
It means we have to know application internal well and to need source code. 
It would prevent various experiements and easy use.

I want to use this feature without appliation internal knowledge easily. 
Maybe it can be useless without appliation behavior knowledge.
But it will help various application experiments without much knowledge of application and recompile. 

ex) echo 'pid 0x8050000 0x100000' > sysfs or procfs or cgroup. 

Personally, I support cgroup interface but don't have a good idea now. 
It can help fork-like application and we can group same address of KSM range among tasks. 

> there's not a real anonymous page allocated the rmap_item will not be
> allocated either (without requiring pending update ;).
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
