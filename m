Subject: Re: Allocation of kernel memory >128K
Message-ID: <OF1B7C1C46.B55EBB52-ON86256B1F.00536DEC@hou.us.ray.com>
From: Mark_H_Johnson@Raytheon.com
Date: Tue, 11 Dec 2001 09:27:36 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Amit S. Jain" <amitjain@tifr.res.in>, linux-mm@kvack.org, owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hmm. I don't know if this was necessarily a complete answer. Perhaps a few
extra questions are necessary to clarify what is requested by Amit.
 - do you [Amit] want a continuous range of physical pages? If so, why?
 - do you want a continuous range of pages in the kernel's virtual address
space? If so, why?
I would not necessarily say that "large amounts of continuous memory is a
bad thing" - rather that it is hard to get, and a costly operation (in
time). For example - a number of existing pages must be moved (or swapped)
to get the area you are requesting. Since this is a big performance hit,
you better have a really good reason for doing so.

If you really need contiguous physical pages - get the bigphysarea patch
and use it. We use it for a shared memory interface between a PC and single
board computers in a VME rack. It works well and is pretty easy to use. It
does have the disadvantage of taking memory away from general use.

If you think you need continuous virtual pages - I suggest putting a little
extra effort into your implementation so it also supports a set of smaller
address ranges. Use the code implementing kiobuf as an example. The added
code should not be much and will save the system a lot of effort in getting
your pages.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


                                                                                                                     
                    ebiederm@xmiss                                                                                   
                    ion.com (Eric         To:     "Amit S. Jain" <amitjain@tifr.res.in>                              
                    W. Biederman)         cc:     linux-mm@kvack.org                                                 
                    Sent by:              Subject:     Re: Allocation of kernel memory >128K                         
                    owner-linux-mm                                                                                   
                    @kvack.org                                                                                       
                                                                                                                     
                                                                                                                     
                    12/11/01 04:41                                                                                   
                    AM                                                                                               
                                                                                                                     
                                                                                                                     




"Amit S. Jain" <amitjain@tifr.res.in> writes:

> I have been working on a module in which I copy large amount of data
fromn
> the user to the kernel area.To do so I allocate using either kmaaloc or
> vmalloc or  get_free_pages()large amount of memory(in the range of
> MBytes) in the kernel space.However this attempt is not successful.One
ofmy
> colleagues informed me that in the kernel space it is safe not to
allocate
> large amount of memory at one time,should be kept upto 30K...is he
> right....could you throw more light on this issue.

large amounts of memory are o.k.
large amounts of continuous memory is generally a bad thing.

Allocating everything with multiple calls to get_free_page() should
get the job done.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
