Date: Sat, 26 Feb 2000 08:38:13 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
In-Reply-To: <200002252308.PAA76871@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10002260827210.747-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 25 Feb 2000, Kanoj Sarcar wrote:
> 
> This is a patch against 2.3.47 that tries to implement shared /dev/zero
> mappings. This is just a first cut attempt, I am hoping I will find a
> few people to apply the patch and throw some real life programs at it
> (preferably on low memory machines so that swapping is induced). 

I'd like to see the shm code use the page cache exclusively to track
pages, and this is going to mess with that, I think. We'll need an inode
(or at least a "struct address_space") to act as a "anchor" for the pages,
and it mustn't be the "/dev/zero" inode.

Before that is done I'd be nervous about letting external things call into
the shm subsystem, but maybe this is ok as-is (the only thing you really
export is "map_zero_setup()", and I guess it can just be updated as
required..)

However, whether that will be changed or not, the following looks really
wrong:

>  	if (vma->vm_flags & VM_SHARED)
> 		if (ret = map_zero_setup(vma))
> 			return ret;
>  	if (zeromap_page_range(vma->vm_start, vma->vm_end - vma->vm_start, vma->vm_page_prot))
>  		return -EAGAIN;

I do NOT believe that it can ever be right to do a "zeromap_page_range()"
on a shared memory area.  I'll tell you why:

	mmap(/dev/zero, MAP_SHARED)
	child = fork();
	if (child) {
		..modify mapping..
	} else {
		..wait for modifications to show up..
	}

the "zeromap_page_range()" thing mapped the area with private NULL pages.
The fork() copied the page tables. The modification of the private NULL
page causes the child to get a real shared page, but the mother will never
see that shared page if it only reads from the mapping because the mother
will still see the private one.


So I suspect at the very least it would have to be

	if (vma->vm_flags & VM_SHARED)
		return map_zero_setup(vma);

and let the whole area be populated with shared pages by "nopage".

Comments?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
