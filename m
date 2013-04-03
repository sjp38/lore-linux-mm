Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 2F2DE6B0027
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:03:49 -0400 (EDT)
Date: Wed, 3 Apr 2013 15:03:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: NUMA Autobalancing Kernel 3.8
Message-ID: <20130403140344.GA5811@suse.de>
References: <515A87C3.1000309@profihost.ag>
 <20130402104844.GE32241@suse.de>
 <515AC3EE.1030803@profihost.ag>
 <20130402125408.GG32241@suse.de>
 <515AEC71.9020704@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <515AEC71.9020704@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, srikar@linux.vnet.ibm.com, aarcange@redhat.com, mingo@kernel.org, riel@redhat.com

On Tue, Apr 02, 2013 at 04:34:25PM +0200, Stefan Priebe - Profihost AG wrote:
> > 
> > When you see the 100% CPU usage can you cat /proc/PID/stack a couple of
> > times and post it here? That might give a hint as to where it's going wrong.
> 
> Sadly i'm not able to reproduce a 100% load process tried now for some
> hours. Mostly they segfault.
> 

I see.

I checked the v3.8 and v3.9-rc results for my own NUMA machine but I'm
seeing no evidence of test failures or segfaults. 

> >>> Anything in the kernel log?
> >> Three examples:
> >> pigz[10194]: segfault at 0 ip           (null) sp 00007f6197ffed50 error
> >> 14 in pigz[400000+e000]
> >>
> >> rbd[2811]: segfault at b8 ip 00007f73c2d51b9e sp 00007f73bcae3b40 error
> >> 4 in librados.so.2.0.0[7f73c2afe000+3b9000]
> >>
> >> rbd[1805]: segfault at 0 ip 00007f60c28dceb4 sp 00007f60b7ffd1f8 error 4
> >> in ld-2.11.3.so[7f60c28cc000+1e000]
> >>
> >>> Any particular pattern to the crashes? Any means of reliably
> >>> reproducing it?
> >> No i just need to run some task and after some time they die or hang
> >> forever. I have this on 10 different E5-2640 and also on E56XX. I can
> >> "fix" this by:
> >>   1.) putting all memory to just ONE CPU
> >>   2.) Disable NUMA Balancing
> >>
> >
> > That does point the finger at the automatic balancing.
> > 
> >>> 3.8 vanilla, 3.8-stable or 3.8 with any other patches
> >>> applied?
> >> 3.8.4 without any patches.
> >>
> > Did it happen in 3.8?
> 
> I've now tested 3.9-rc5 this gaves me a slightly different kernel log:
> [  197.236518] pigz[2908]: segfault at 0 ip           (null) sp
> 00007f347bffed00 error 14
> [  197.237632] traps: pigz[2915] general protection ip:7f3482dbce2d
> sp:7f3473ffec10 error:0 in libz.so.1.2.3.4[7f3482db7000+17000]
> [  197.330615]  in pigz[400000+10000]
> 
> With 3.8 it is the same as with 3.8.4 or 3.8.5.
> 

Ok. Are there NUMA machines were you do *not* see this problem? If so,
can you spot what the common configuration, software or hardware, that
affects the broken machines versus the working machines? I'm wondering
if there is a bug in a migration handler.

Do you know if a NUMA nodes are low on memory when the segfaults occur?
I'm also considering the possibility that one of the migration failure
paths are failing to clear a NUMA hinting entry properly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
