Date: Wed, 4 Feb 2004 17:29:04 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [Bugme-new] [Bug 2019] New: Bug from the mm subsystem involving
 X  (fwd)
In-Reply-To: <20040204165620.3d608798.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0402041719300.2086@home.osdl.org>
References: <51080000.1075936626@flay> <Pine.LNX.4.58.0402041539470.2086@home.osdl.org>
 <60330000.1075939958@flay> <64260000.1075941399@flay>
 <Pine.LNX.4.58.0402041639420.2086@home.osdl.org> <20040204165620.3d608798.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: mbligh@aracnet.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kmannth@us.ibm.com
List-ID: <linux-mm.kvack.org>


On Wed, 4 Feb 2004, Andrew Morton wrote:
> 
> pfn_valid() could become quite expensive indeed, and it lies on super-duper
> hotpaths.

Yes. However, sometimes it is the only choice. 

So it does need to be fixed, and if it ends up being a noticeable
perofmance problem, then we can look at the hot-paths one by one and see
if we can avoid using it. We probably can, most of the time.

> An alternative which is less conceptually clean but should work in this
> case is to mark all vma's which were created by /dev/mem mappings as VM_IO,
> and test that in remap_page_range().

Hmm.. Grepping for "pfn_valid()", I'm starting to suspect that yes, with a
VM_IO approach and a fixed virt_addr_valid(), there really aren't any
other uses.

(virt_addr_valid() is useful for debugging and for validation of untrusted
pointers, but pfn_valid() just isn't very good for it. Never really was:  
it started out as an ugly hack, and it never got cleaned up. It should be
easily fixable with something _proper_).

			Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
