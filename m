Message-ID: <429217F8.5020202@mwwireless.net>
Date: Mon, 23 May 2005 10:50:48 -0700
From: Steve Longerbeam <stevel@mwwireless.net>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> <20050511125932.GW25612@wotan.suse.de> <42825236.1030503@engr.sgi.com> <20050511193207.GE11200@wotan.suse.de> <20050512104543.GA14799@infradead.org> <428E6427.7060401@engr.sgi.com>
In-Reply-To: <428E6427.7060401@engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@wildopensource.com>, Steve Longerbeam <stevel@mwwireless.net>
List-ID: <linux-mm.kvack.org>


Ray Bryant wrote:

> Christoph Hellwig wrote:
>
>> On Wed, May 11, 2005 at 09:32:07PM +0200, Andi Kleen wrote:
>>
>>> A minor change for that is probably ok, as long as the actual logic
>>> who uses this is generic.
>>> hch: if you still are against this please reread the original thread
>>> with me and Ray and see why we decided that ld.so changes are not
>>> a good idea.
>>
>>
>>
>> So reading through the thread I think using mempolicies to mark shared
>> libraries is better than the mmap flag I proposed.  I still don't think
>> xattrs interpreted by the kernel is a good way to store them.  Setting
>> up libraries is the job of the dynamic linker, and reading pre-defined
>> memory policies from an ELF header fits the approach we do for related
>> things.
>>
>>
>>
>
> Christoph and Andi,
>
> OK, here are the alternatives I have figured out, I'd appreciate feedback
> on which of these would be acceptable.  (In each case, the migration
> attributes being set are either:  MIGRATE_NONE to indicate that nothing
> in this mapped file should be migrated, or MIGRATE_NS to indicate that
> the non-shared pages should be migrated, this is the normal setting for
> shared library files.  And, since madvise() is mostly about I/O related
> things, I'm assuming here that I extend mbind() to set the migration
> attributes.):
>
> (1)  Use mbind() to set "shallow" vm attributes.  (I use shallow
> versus deep here to indicate whether or not other processes that map
> the same object can see the attributes -- this basically also maps
> to whether we put the attributes in the vma [shallow] or in the
> memory_object [deep].)
>
> In the shallow case, mbind() has to be called in
> each address space in order to properly set the migration flags the
> same way in each address space that maps a shared object.  So, we
> basically have to call mbind() from ld.so.

>
> As far as I am concerned this is a fundamental show stopper, since we
> without broad glibc support, we will never get the changes
> into ld.so for just Altix and page migration.  It also doesn't handle
> the case of shared, mapped r/o data files.   We can leverage Steve
> Longerbeam's work here, but he also doesn't have a time frame as to
> when his ld.so changes might be accepted by the glibc developers.
>
> It does allow one to mark anonymous memory with migration policy.
> However, any use of that  I've been able to think of (e. g. marking
> some anonymous pages as MIGRATE_NONE and then calling migrat_pages())
> could equally well be handled by mbind(.., MPOL_MF_STRICT | 
> MPOL_MF_MOVE) (MPOL_MF_MOVE is in Steve Longerbeams patch and says to 
> move the pages
> that don't match the memory policy -- we plan to hook this up to the 
> migration
> code at some point in the future.)


right, but I should add that mbind(MPOL_MF_MOVE) will also attempt to
migrate shared pages (in the page cache), not just anonymous pages. It uses
invalidate_mapping_pages() in mm/truncate.c to do this. As this routine
states, it will not remove pages from the cache which are dirty, locked, 
under
writeback or mapped into pagetables, so the shared page migration is
rudimentary. It doesn't actually migrate the shared page, it just frees it
from the pagecache, which is fine because later a page fault will 
re-allocate
a new page for the cache using the new mempolicy, which completes the
migration.

Also, invalidate_mapping_pages() should always succeed when used
with the patch to load_elf_binary() and ld.so that search for and apply
mempolicies from a special ELF .note.numapolicy PT_NOTE in executables
and shared libraries (which Ray mentioned above). That's because the
policy will be applied before any process has ever touched the shared
page (which means that, if a page was located in the cache for that
address_space and that page offset, it must be left over from an earlier
regular file I/O on the object, and not from a mapping).

I agree that we should hook up SGI's migration code with MPOL_MF_MOVE.
The only additional feature I see that mbind() would need to complete SGI's
migration API is the ability to migrate pages for other process spaces 
besides
the calling process.



>
> (2)  Use mbind() to set "deep" vm attributes.  There appear to be
> two places where the deep attributes could be set:  in the
> address space object vma->file->f_mapping or in the inode
> vma->file->f_mapping->host.  Some upper order bits of address_space.
> flags could be used, but there appear to be concurrency issues
> there.  Bits in inode.i_flags also appear to be available.
>
> The advantage of setting "deep" vm attributes is that this interface
> could be used by ld.so, but in advance of getting the changes
> accepted there, we could also set the deep attributes in a migration
> library before calling migrate_pages().  (deep attrbutes are be
> seen from any address space that maps the object.)  Then when ld.so
> changes are in, we can reduce the work done by the migration library.


it seems to me that, since you are marking a _shared_ object with
migration attributes that all processes that map that object need
to see, it makes sense to make the attributes "deep", ie. put them
in address_space. It should not go in a private object (vma) that
only one process can see. So (1) above just isn't the correct way
to go.

>
> (3)  The problem with (2) is that to set a deep attribute, one has
> to do 4 system calls: open, mmap, mbind, munmap.  If we add the
> migration attributes to fcntl() [such as Paul Jackson has suggested],
> then it we could set them directly in the inode with one system call.
> Perhaps not a big deal, but something to think about.  It's also
> simpler, easier to maintain code.
>
> (4)  Then there is the original, extended attribute approach.  I'm
> including this one last time just to observe that:
>      (i)  This correctly handles regular data (non-elf) files.
>     (ii)  If one wants to migrate just a portion of anonymous
>           memory, one could still use mbind(...MPOL_MF_STRICT | 
> MPOL_MF_MOVE)
>    (iii)  How to set the migration policy is based on how a shared file
>           is mapped in multiple address spaces.  It is not so much
>           a characterstic of an individual address space's usage of
>           the file.  So, it seems natural to associate these with
>           the file and not the particular instance in one address space
>           (that is alternative (1)).
>       If using a system attribute is too much change to fs code,
> then let's use a user attribute here.  It's not perfect, but it is
> doable, and doesn't require any fs changes.  (We'll just not support
> migration policy in file systems that don't have extended attributes.)
>
> In short, as near as I can tell, alternative (1) really doesn't do
> what we want, and is the hardest to implement and get into a production
> kernel.  I still like (4) best, but I can live with (2) or (3).
> Both (2) and (3) have interim approaches that can be made to work
> until Steve Longerbeam's stuff makes it into ld.so, at which point
> I can easily merge my required changes in with his.


I like (2), and I agree that (1) is out.

We're still going to try getting out glibc patch accepted. The glibc
maintainers are very reluctant to add new interfaces that are not
backed by any widely-used standards (such as POSIX, or in this case,
the Solaris and SVR4 ELF documentation). However our patch doesn't
add a new libc interface - it's a new ELF note, which is parsed and
dealt with internally by ld.so without changing or adding any libc APIs.

I have a question about the migration attributes. Are these attributes
needed because your migration code is not _capable_ of migrating
shared pages? Or is it that you just want to selectively choose which
shared object memory should and should not be migrated?

Steve
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
