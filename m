Date: Mon, 14 Jun 1999 18:45:23 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Some issues + [PATCH] kanoj-mm8-2.2.9 Show statistics on alloc/free requests for each pagefree list
Message-ID: <19990614184523.A2130@fred.muc.de>
References: <19990612122107.A2245@fred.muc.de> <199906141734.KAA27832@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199906141734.KAA27832@google.engr.sgi.com>; from Kanoj Sarcar on Mon, Jun 14, 1999 at 07:34:49PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andi Kleen <ak@muc.de>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Mon, Jun 14, 1999 at 07:34:49PM +0200, Kanoj Sarcar wrote:
> > 
> > There is a important case ATM that needs bigger blocks allocated from 
> > bottom half context: NFS packet defragmenting. For a 8K wsize it needs
> > even 16K blocks (8K payload + the IP/UDP header forces it to the next
> > buddy size). I guess your statistics would look very different on a nfsroot
> > machine. Until lazy defragmenting is supported for UDP it is probably 
> > better not to change it.
> > 
> 
> This is the experiment I tried: using automount, I cd'ed into a nfs
> mounted directiory, and copied kernel sources over to the local (client)
> machine. The statistics before and after the copy on the client:
> 
> Before:
> 
> 10*4kB (20993, 34343) 3*8kB (398, 319) 0*16kB (2, 0) 0*32kB (2, 0) 0*64kB (0, 0) 1*128kB (0, 0) 0*256kB (1, 0) 0*512kB (0, 0) 1*1024kB (0, 0) 25*2048kB (0, 0) = 52416kB)
> 
> 
> After:
> 
> 192*4kB (88737, 89889) 27*8kB (744, 405) 3*16kB (2, 0) 0*32kB (2, 0) 0*64kB (0,
> 0) 0*128kB (0, 0) 0*256kB (1, 0) 1*512kB (0, 0) 0*1024kB (0, 0) 0*2048kB (0, 0)
> = 1544kB)
> 
> I am not sure about the wsize though ... maybe someone with access to
> a nfsroot machine can try a quick experiment and publish the results?

You probably used the default of 4K (=8K blocks). 8K wsize often performs
better against other Linux servers.

BTW, I am a bit surprised that you don't have a nfsroot or at least
nfs-/usr machine - it is really handy for experimental kernel testing:
no fscks, no fs corruptions ..


> Btw, if the nfs defrag code is coming from bottom half, it probably has
> logic to handle allocation failures? Andi, could you please send me a
> pointer to the relevant code? 

The relevant code in net/ipv4/ip_fragment.c; called from the IP input
path running in net_bh (net/core/dev.c:net_bh() -> net/ipv4/ip_input.c)

It simply drops the packet then. Remember that IP is unreliable so this 
works always.

In theory it could set a a short retry timer and try again later (because the 
smaller fragments in the frag queue are still there), but this would need
some complicated backlog refeed logic. 

Fixing defragmenting to directly defragment into the target buffer is 
on my list for 2.3; I assume it is on David's list too so I it'll probably
change.



-Andi
-- 
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
