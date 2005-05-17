Message-ID: <428A1F6F.2020109@engr.sgi.com>
Date: Tue, 17 May 2005 11:44:31 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: manual page migration and madvise/mbind
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@engr.sgi.com>, Andi Kleen <ak@muc.de>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Andi and hch,

Resending to make sure you see this.

-------- Original Message --------
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page 
migration-rc2 -- xfs-extended-attributes-rc2.patch
Date: Mon, 16 May 2005 23:22:50 -0500
From: Ray Bryant <raybry@engr.sgi.com>
To: Christoph Hellwig <hch@infradead.org>, Andi Kleen <ak@suse.de>
CC: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, 
    Marcelo Tosatti <marcelo.tosatti@cyclades.com>,        Dave Hansen 
<haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>,        Nathan Scott 
<nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, 
lhms-devel@lists.sourceforge.net,        Jes Sorensen <jes@wildopensource.com>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> 
<20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> 
<20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> 
<20050511125932.GW25612@wotan.suse.de> <42825236.1030503@engr.sgi.com> 
<20050511193207.GE11200@wotan.suse.de> <20050512104543.GA14799@infradead.org>

Christoph Hellwig wrote:
> On Wed, May 11, 2005 at 09:32:07PM +0200, Andi Kleen wrote:
> 
>>A minor change for that is probably ok, as long as the actual logic
>>who uses this is generic. 
>>
>>hch: if you still are against this please reread the original thread
>>with me and Ray and see why we decided that ld.so changes are not
>>a good idea.
> 
> 
> So reading through the thread I think using mempolicies to mark shared
> libraries is better than the mmap flag I proposed.  I still don't think
> xattrs interpreted by the kernel is a good way to store them.  Setting
> up libraries is the job of the dynamic linker, and reading pre-defined
> memory policies from an ELF header fits the approach we do for related
> things.
> 

Andi and hch,

OK, I've been off chasing down what the possibilities are in that area.
I'm also looking at Steve Longerbeam's patches to see if that will help
us out here.

However, I've come across a minor issue that has complicated my thinking
on this:  If one were to use madvise() or mbind() to apply the migration
policy flags (e. g. the three policies we basically need are:  migrate,
migrate_non_shared, and migrated_none, used for normal files, libraries,
and shared binaries, respectively) then when madvise() (let us say)
is called, it isn't good enough to mark the vma that the address and
length point to, it's necessary to reach down to a common subobject,
(such as the file struct, address space struct, or inode) and mark
that.

If the vma is all that is marked, then when migrate_pages() is called
and as a result some other address space than the current one is examined,
it won't see the flags.

(Remember that the migrate_pages() system call takes a pid, a count,
and a list of old and new node so that this process is allowed to
migrate that process over there, which is what the batch manager needs
to do.  Running madvise() in the current process's address space doesn't
help much unless it marks something deeper in the address space hierarchy
than a vma.)

This is something quite a bit different than what madvise() or mbind()
do today.  (They just manipulate vma's AFAIK.)

Does that observation change y'all's thinking on this in any way?

> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by Oracle Space Sweepstakes
> Want to be the first software developer in space?
> Enter now for the Oracle Space Sweepstakes!
> http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
> _______________________________________________
> Lhms-devel mailing list
> Lhms-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lhms-devel
> 


-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>


-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
