From: David Howells <dhowells@redhat.com>
In-Reply-To: <1175659331.690672.592289266160.qpush@grosgo> 
References: <1175659331.690672.592289266160.qpush@grosgo> 
Subject: Re: [PATCH 0/14] Pass MAP_FIXED down to get_unmapped_area 
Date: Wed, 04 Apr 2007 11:31:55 +0100
Message-ID: <23370.1175682715@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> This serie of patches moves the logic to handle MAP_FIXED down to the
> various arch/driver get_unmapped_area() implementations, and then changes
> the generic code to always call them. The hugetlbfs hacks then disappear
> from the generic code.

This sounds like get_unmapped_area() is now doing more than it says on the
tin.  As I understand it, it's to be called to locate an unmapped area when
one wasn't specified by MAP_FIXED, and so shouldn't be called if MAP_FIXED is
set.

Admittedly, on NOMMU, it's also used to find the location of quasi-memory
devices such as framebuffers and ramfs files, but that's not a great deviation
from the original intent.

Perhaps a change of name is in order for the function?

> Since I need to do some special 64K pages mappings for SPEs on cell, I need
> to work around the first problem at least. I have further patches thus
> implementing a "slices" layer that handles multiple page sizes through
> slices of the address space for use by hugetlbfs, the SPE code, and possibly
> others, but it requires that serie of patches first/

That makes it sound like there should be an "unget" too for when an error
occurs between ->get_unmapped_area() being called and ->mmap() returning
successfully.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
