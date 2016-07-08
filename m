Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD1C828E1
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 06:22:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n127so9085242wme.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 03:22:32 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id u6si2236852wjv.222.2016.07.08.03.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 03:22:31 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id B28CD1C2149
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 11:22:30 +0100 (IST)
Date: Fri, 8 Jul 2016 11:22:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Message-ID: <20160708102228.GF11498@techsingularity.net>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net>
 <577E924C.6010406@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <577E924C.6010406@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On Thu, Jul 07, 2016 at 10:33:00AM -0700, Dave Hansen wrote:
> On 07/07/2016 07:45 AM, Mel Gorman wrote:
> > On Thu, Jul 07, 2016 at 05:47:28AM -0700, Dave Hansen wrote:
> >> > 
> >> > From: Dave Hansen <dave.hansen@linux.intel.com>
> >> > 
> >> > This establishes two more system calls for protection key management:
> >> > 
> >> > 	unsigned long pkey_get(int pkey);
> >> > 	int pkey_set(int pkey, unsigned long access_rights);
> >> > 
> >> > The return value from pkey_get() and the 'access_rights' passed
> >> > to pkey_set() are the same format: a bitmask containing
> >> > PKEY_DENY_WRITE and/or PKEY_DENY_ACCESS, or nothing set at all.
> >> > 
> >> > These can replace userspace's direct use of the new rdpkru/wrpkru
> >> > instructions.
> ...
> > This one feels like something that can or should be implemented in
> > glibc.
> 
> I generally agree, except that glibc doesn't have any visibility into
> whether a pkey is currently valid or not.
> 

Well, it could if it tracked the pkey_alloc/pkey_free calls too. I accept
that's not perfect as nothing prevents the syscalls being used directly.

> > Applications that frequently get
> > called will get hammed into the ground with serialisation on mmap_sem
> > not to mention the cost of the syscall entry/exit.
> 
> I think we can do both of them without mmap_sem, as long as we resign
> ourselves to this just being fundamentally racy (which it is already, I
> think).  But, is it worth performance-tuning things that we don't expect
> performance-sensitive apps to be using in the first place?  They'll just
> use the RDPKRU/WRPKRU instructions directly.
> 

I accept the premature optimisation arguement but I think it'll eventually
bite us. Why this red-flagged for me was because so many people have
complained about just system call overhead when using particular types of
hardware -- DAX springs to mind with the MAP_PMEM_AWARE discussions. Using
mmap_sem means that pkey operations stop parallel faults, mmaps and so on. If
the applications that care are trying to minimise page table operations,
TLB flushes and so on, they might not be that happy if parallel faults
are stalled.

I think whether you serialise pkey_get/pkey_set operations or not, it's
going to be inherently racy with different sized windows. A sequence counter
would be sufficient to protect it to prevent partial reads. If userspace
cares about the race, then userspace is going to have to serialise its
threads access to the keys anyway.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
