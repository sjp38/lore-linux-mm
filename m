Date: Tue, 23 Apr 2002 23:40:46 +0100 (BST)
From: Christian Smith <csmith@micromuse.com>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <3CC371CE.1EE4E264@earthlink.net>
Message-ID: <Pine.LNX.4.33.0204232317320.1968-100000@erol>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joseph A Knapka <jknapka@earthlink.net>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 Apr 2002, Joseph A Knapka wrote:

>"Martin J. Bligh" wrote:
>> 
>> > I was just reading Bill's reply regaring rmap, and it
>> > seems to me that rmap is the most obvious and clean
>> > way to handle unmapping pages. So now I wonder why
>> > it wasn't done that way from the beginning?
>> 
>> Because it costs something to maintain the reverse map.
>> If the cost exceeds the benefit, it's not worth it. That's
>
>Sure, but it's not obvious (is it?) that the rmap cost
>exceeds the cost of scanning every process's virtual
>address space looking for pages to unmap.

Just to stoke the flames somewhat, but I think the empirical evidence 
of any of the BSDs versus Linux on identical harware seems to suggest that 
reverse mapping provides a big win.

Also, the reverse mapping provides *SIMPLER* page accounting, which can 
greatly improve the chances of paging out a suitable page in low memory 
conditions, and can be a substantial win if more correct pages are paged 
out. Even if the process of scanning takes longer (which is debatable,) 
scanning is so much quicker than physical disk transfer that it must be 
preferable.

Finally, the cost of scanning the non-rmap pages becomes proportional to
the amount of VM in use, which I presume is O(n). As the number of pages
in a machine (without hotplug memory!) remains constant , the scan time is
mostly constant[1], no matter how much VM is in use. As the greatest need 
for efficient scanning is when there is lots of VM in use (and hence 
memory,) non-rmap does it's worse precisely when it is required to perform 
it's best!

[1] Under extreme memory circumstances, multiple scans may be required, 
but that is true of non-rmap as well.

>
>I'll have to look at the rmap patch and see. And
>I gather that the *BSDs have always had reverse-
>mappings, but thus far I haven't been able to
>fathom the BSD code tree well enough to track down
>on the VM code.

NetBSD and OpenBSD are UVM based. FreeBSD uses a modified Mach based VM 
from 4.4BSD. In both cases, the layer is processor independant.

All three use the Mach pmap interface for machine dependant MMU interface. 
It basically provides an opaque MMU API.

On NetBSD (and probably OpenBSD,) the UVM layer is in /usr/src/sys/uvm. 
The FreeBSD VM is probably in /usr/src/sys/vm, but I've only got a NetBSD 
machine here to check.

The pmap layer is in /usr/src/sys/arch/<processor>/<processor>, interface 
in /usr/src/sys/arch/<processor>/include/pmap.h.

>
>Thanks,
>

The question becomes, how much work would it be to rip out the Linux MM 
piece-meal, and replace it with an implementation of UVM? It would 
probably require modifications not only to memory related functions, but 
also the VFS. It would certainly be a bigger job than the AA MM swap, as 
AA was a plug in replacement for the old VM, whereas UVM may not fit so 
nicely.

Has anyone looked at this? Is it doable? IMO, Linux MM sucks rocks, and is 
light years behind BSD and SysV. Even NT has rmap!

Christian

-- 
    /"\
    \ /    ASCII RIBBON CAMPAIGN - AGAINST HTML MAIL 
     X                           - AGAINST MS ATTACHMENTS
    / \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
