Message-ID: <428ABE4C.1020702@engr.sgi.com>
Date: Tue, 17 May 2005 23:02:20 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: manual page migration and madvise/mbind
References: <428A1F6F.2020109@engr.sgi.com> <20050518012627.GA33395@muc.de>
In-Reply-To: <20050518012627.GA33395@muc.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Christoph Hellwig <hch@engr.sgi.com>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> Sorry for late answer.
> 
> On Tue, May 17, 2005 at 11:44:31AM -0500, Ray Bryant wrote:
> 
>>(Remember that the migrate_pages() system call takes a pid, a count,
>>and a list of old and new node so that this process is allowed to
>>migrate that process over there, which is what the batch manager needs
>>to do.  Running madvise() in the current process's address space doesn't
>>help much unless it marks something deeper in the address space hierarchy
>>than a vma.)
>>
>>This is something quite a bit different than what madvise() or mbind()
>>do today.  (They just manipulate vma's AFAIK.)
> 
> 
> Nah, mbind manipulates backing objects too, in particular for shared 
> memory. It is not right now implemented for files, but that was planned
> and Steve L's patches went into that direction with some limitations.
>

That's what I need then.

> And yes, the state would need to be stored in the address_space, which
> is shared.  In my version it was in private backing store objects.
> Check Steve's patch.
> 

I'm in the process of building Steve's stuff for Altix.

> The main problem I see with the "hack ld.so" approach is that it 
> doesn't work for non program files. So if you really want to handle
> them you would need a daemon that sets the policies once a file 
> is mapped or hack all the programs to set the policies. I don't
> see that as being practicable. Ok you could always add a "sticky" process
> policy that actually allocates mempolicies for newly read files
> and so marks them using your new flags. But that would seem
> somewhat ugly to me and is probably incompatible with your batch manager
> anyways.  The only sane way to handle arbitary files like this
> would be the xattr.
> 
> If you ignore data files then it would be ok to keep it to 
> ELF loaders and ld.so I guess.
> 
> -Andi
> 
This turns out to be problematic.  For example, if I look at /proc/pid/maps
for /bin/tcsh, the following files are mapped in, but they are not elf files
at all, they are just data files (at least according to the "file" command):

/usr/lib/gconv/gconv-modules.cache
/usr/lib/locale/en_US.utf8/LC_IDENTIFICATION
/usr/lib/locale/en_US.utf8/LC_MEASUREMENT
/usr/lib/locale/en_US.utf8/LC_TELEPHONE
/usr/lib/locale/en_US.utf8/LC_ADDRESS
/usr/lib/locale/en_US.utf8/LC_NAME
/usr/lib/locale/en_US.utf8/LC_PAPER
/usr/lib/locale/en_US.utf8/LC_MESSAGES/SYS_LC_MESSAGES
/usr/lib/locale/en_US.utf8/LC_MONETARY
/usr/lib/locale/en_US.utf8/LC_COLLATE
/usr/lib/locale/en_US.utf8/LC_TIME
/usr/lib/locale/en_US.utf8/LC_NUMERIC
/usr/lib/locale/en_US.utf8/LC_CTYPE

Admittedly, most of this is National Language stuff, so not all programs
map this in, but nonetheless, it begs the question as to how to mark such
stuff as not-migratable, or at least migrate-non-shared, since that is how
they are marked now (we typically mark these files with the extended attribute
value "libr".)  So we want to migrate the anonymous pages found in those
vma's, but not the shared pages.

Also the files are all small (a couple of pages each), so migrating them all
the time would not be such a problem, but it seems untidy to do so.

What could be done (beware of ugly hack following) would be in the migration
application (e. g. the batch manager), to look at /proc/pid/maps for each
process to be migrated and examine the file names specified there.  The
batch manager could then do whatever algorithm it liked (it is just user code)
to determine whether or not, say, /usr/lib/locale/en_US.utf8/LC_TIME is
migratable or not.  It could then use a modified mbind() system call to reach
into the kernel and set a bit (or 2) in the address_space object.  (It would
have to map the file in first, but that is no big deal.)  Those bits could
be used to control the migration the way we do it now with extended
attributes.  There is a small performance hit here (mapping all of those files
in just before migration time and doing the mbind() system calls) but it is
probably doable and will be trivial in comparison to the actual time required
to do the migration.  (I suppose the batch manager could keep a cache of files
it has mapped in and marked and not have to do this every time a migration
call is made.)

(Andi -- I know you dislike bringing /proc/pid/maps back into this because of
the raciness of reading that file, but here we are reading it before the
migration operation itself starts.  And reading the file is a performance
assist, not required for correctness of the migration operation.)

This all can be done in preparation for using Steve Longerbeam's patches for
file numapolicy support and his patches for ld.so etc, which I believe I can
use, with only slight modifications, to support migration policies based on
information in elf program headers, at  which point the ugly hack above can
ignore all elf files.  The ugly hack, however, lives on forever for data
files, so I am not sure how much  simplicity we have bought ourselves through
this whole process.

The ugly hack in some sense replaces the logic in ld.so until we can get a
modified version of ld.so into the glibc trees.  The kernel interface
remains the same regardless of whether we use a modified ld.so or not.

(My personal preference is still just to set the user.migration extended
attribute on such data files; it just seems so much simpler than all of
the other approaches that have been suggested.)

Christoph, would the ugly hack above be acceptable or is that worse than the
original approach?

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
