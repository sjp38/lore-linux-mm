Message-ID: <3E49635A.70906@us.ibm.com>
Date: Tue, 11 Feb 2003 12:55:54 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: [rfc][api] Shared Memory Binding
Content-Type: multipart/mixed;
 boundary="------------040806080001090805070302"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech@lists.sourceforge.net, Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040806080001090805070302
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello All,
	I've got a pseudo manpage for a new call I'm attempting to implement: 
shmbind().  The idea of the call is to allow userspace processes to bind 
shared memory segments to particular nodes' memory and do so according 
to certain policies.  Processes would call shmget() as usual, but before 
calling shmat(), the process could call shmbind() to set up a binding 
for the segment.  Then, any time pages from the shared segment are 
faulted into memory, it would be done according to this binding.
	Any comments about the attatched manpage, the idea in general, how to 
improve it, etc. are definitely welcome.

Thanks!

-Matt

--------------040806080001090805070302
Content-Type: text/plain;
 name="shmbind.man.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="shmbind.man.txt"

SHMBIND(2)                Linux Programmer's Manual                  SHMBIND(2)

NAME
     shmbind - bind shared memory segment to a set of nodes

SYNOPSIS
     int shmbind(int shmid, int policy, unsigned long *mask_ptr, int mask_len);

DESCRIPTION
     The function shmbind() is meant to be called after a shmget() call which 
     creates a shared memory segment, and before any related shmat() calls, 
     which attatch the segment to processes address spaces.  shmbind() is used 
     to set an allocation policy and node set for pages from the shared memory 
     segment.  Once a binding is set up, pages faulted into the shared memory 
     area will be allocated from physical memory in a manner consistent with 
     the binding.

     The mask_ptr argument is used to specify the set of nodes that the pages 
     from the shared segment are allowed to be allocated from.  For example, 
     passing a mask_ptr that specifies the first two nodes in the system would 
     force all page faults to the shared segment to come from the physical 
     memory (memory blocks) on those two nodes.  The exception to this would 
     be if MEM_SOFTBIND flag is set in the policy, which would allow the page 
     allocator to fall back to other system memory.

     The mask_len argument specifies how many bits the area pointed to by 
     mask_ptr is.  This allows for variable length bitmasks, and thus systems 
     with MAX_NUMNODES > BITS_PER_LONG.

     The policy argument is used to specify the algorithm by which an 
     individual node's memory is selected from the set of nodes (mask_ptr) 
     when faulting in a page for the shared segment.  The policy flags are 
     as follows:

     ** It is unlikely that all of these options will be available in the 
     first attempt to implement this API.  The options that will definitely 
     be available in the initial implementation are noted, as well as possible 
     future options.  Suggestions for further future options are welcomed as 
     well. **

     MEM_FIRSTREF   Allocate the page from the memory of the node 
                    on which the faulting CPU lies.
                    **initial implementation**

     MEM_STRIPE     Allocate the pages evenly across all specified 
                    nodes' memory.
                    **initial implementation**

     MEM_MOSTFREE   Allocate the page from the memory of the node
                    with the most free memory at the time of the 
                    page fault.
                    **possible future option**

     MEM_HARDBIND   The specified set of nodes and policy _must_ 
                    be obeyed.  If there are no pages available 
                    on the node selected according to the mask_ptr 
                    and policy, the page allocation will fail.
                    **initial implementation**

     MEM_SOFTBIND   The specified set of nodes and policy will be 
                    obeyed, but if there are no pages available on 
                    the node selected according to the mask_ptr and 
                    policy, the allocator whill attempt to allocate 
                    a page from any of the remaining nodes in the 
                    system.
                    **probable initial implementation**

     Only one of MEM_STRIPE, MEM_FIRSTREF, and MEM_MOSTFREE; and one of 
     MEM_HARDBIND and MEM_SOFTBIND can be specified.  The default policy
     is MEM_FIRSTREF and MEM_SOFTBIND.

RETURN VALUE
     On failure, shmbind() returns -1, with errno indicating the error.  
     On success, shmbind() returns 0.

ERRORS
     When shmbind() fails, errno is set to one of the following:

     EINVAL   Invalid shmid value, invalid policy flag, invalid set of nodes, 
              invalid mask length specified, or the segment has already been 
              attatched to a process.

     EPERM    The caller does not have (write) permissions for the specified 
              shared memory segment.

     EFAULT   Error occurred while trying to read mask_ptr in kernel space.

NOTES
     Additional notes here?

SEE ALSO
     ipc(5), shmget(2), shmctl(2), shmat(2), shmdt(2)

--------------040806080001090805070302--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
