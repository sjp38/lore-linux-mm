Message-ID: <4220BE72.2010400@sgi.com>
Date: Sat, 26 Feb 2005 12:22:42 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview
 II
References: <20050218130232.GB13953@wotan.suse.de> <42168FF0.30700@sgi.com> <20050220214922.GA14486@wotan.suse.de> <20050220143023.3d64252b.pj@sgi.com> <20050220223510.GB14486@wotan.suse.de> <42199EE8.9090101@sgi.com> <20050221121010.GC17667@wotan.suse.de> <421AD3E6.8060307@sgi.com> <20050222180122.GO23433@wotan.suse.de> <421B7DC1.8070504@sgi.com> <20050222184915.GA8981@wotan.suse.de>
In-Reply-To: <20050222184915.GA8981@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, ak@muc.de, raybry@austin.rr.com, linux-mm@kvack.org, Nathan Scott <nathans@sgi.com>, Dave Hansen <haveblue@us.ibm.com>Paul Jackson <pj@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Dean Roe <roe@sgi.com>
List-ID: <linux-mm.kvack.org>

Andi,

Just to give you an update on where what our thinking is on the
page migration system call.  Our current proposal would be the
following:

(1)  The system call would look like:
	migrate_pages(pid, count, old_nodes, new_nodes);

(2)  The old nodes and new nodes lists would have to be disjoint.
      A library routine has been written to convert the case where
      the lists are not disjoint to a series of migrations each of
      which only uses disjoint lists.

      This has the advantage that the system call is restartable
      and can be repeated if an error condition occurs that causes
      the system call to return before completing the migration
      without fear of migrating a page more than once.

      In extreme situations, this can cause an O(N**2) effect to
      occur, but we think that these extreme situations are less
      likely to occur than we had previously thought.

(3)  We have a patch for xfs (thanks to Nathan Scott) that supports
      the "system.migration" extended attribute for files stored in
      xfs.  We intend to use two values for this extended attribute:
      "none" and "libr".  "none" implies that no pages of this file
      should be migrated if it is found as a mapped file in a pid that
      is being migrated, and "libr" implies that only writable pages
      should be migrated.  The latter is intended to support per
      process read/write data associated with a process, as well as
      handle some special edge cases (e. g. what happens if you put
      a breakpont in a shared library?).

Part of the reason for making this change is your concern about
adding va_start and length fields to the system call could produce
a "ptrace()" like system call and the problems that this entails.

The other part is the realization that the information required to
figure out what to migrate is not sufficiently encoded in the
/proc/pid/maps files.  As an example, it is impossible to figure
out whether an anoymous page range contains COW pages shared with
the process parent or pages at the same address range that have
been written and the COW sharing has been broken.  While there are
ways around this, I'd rather handle all such cases rather than
special case each such edge condition.

I should have a new patch with this implementation done by the
end of next week.

While the resulting system call will not require the target pid
to be suspended, because the underlying page migration code will
work even if the target is suspended, there is no guarentee that
all of the pages will be migrated off of the old_nodes unless this
is the case, since the process could allocate new pages on the
target nodes after that portion of the address space has been
scanned.

I don't have a good solution for this at the moment, other than
to require that the target task be suspended.  We could add the
suspend/resume logic to the system call, but given that we are
using a library call to handle the overlapped node list cases,
we probably want to do the suspend/resume as part of that library
call rather than the base system call.
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
