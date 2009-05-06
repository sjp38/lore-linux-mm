Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 40CDE6B00A2
	for <linux-mm@kvack.org>; Wed,  6 May 2009 10:55:53 -0400 (EDT)
Date: Wed, 6 May 2009 16:56:42 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses
	registrations.
Message-ID: <20090506145641.GA16078@random.random>
References: <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <4A00DD4F.8010101@redhat.com> <4A015C69.7010600@redhat.com> <4A0181EA.3070600@redhat.com> <20090506131735.GW16078@random.random> <Pine.LNX.4.64.0905061424480.19190@blonde.anvils> <20090506140904.GY16078@random.random> <20090506152100.41266e4c@lxorguk.ukuu.org.uk> <Pine.LNX.4.64.0905061532240.25289@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905061532240.25289@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, May 06, 2009 at 03:46:31PM +0100, Hugh Dickins wrote:
> As I understand it, KSM won't affect the vm_overcommit behaviour at all.

In short vm_overcommit is a virtual thing, KSM only makes virtual
takes less physical than before. One issue in KSM that was mentioned
was the cgroup accounting if you merge two pages in different groups
but that is kind of a corner case and it'll be handled "somehow" :)

> The only difference would be in how much memory (mostly lowmem)
> KSM's own data structures will take up - as usual, the kernel
> data structures aren't being accounted, but do take up memory.

Oh yeah, on 32bit systems that would be a problem... That lowmem is
taken for eacy virtual address scanned. One more reason to still allow
ksm to all users only selectively through chown/chmod with ioctl or
sysfs permissions with syscall/madvise. Luckily most systems where ksm
is used are 64bit. We don't plan to kmap_atomic around the
rmap_item/tree_item. No ram is allocated in the holes though, so if
there's not a real anonymous page allocated the rmap_item will not be
allocated either (without requiring pending update ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
