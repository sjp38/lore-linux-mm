Date: Tue, 26 Sep 2000 07:30:15 -0600
From: yodaiken@fsmlabs.com
Subject: Re: the new VMt
Message-ID: <20000926073015.B22876@hq.fsmlabs.com>
References: <20000925143523.B19257@hq.fsmlabs.com> <Pine.LNX.3.96.1000925164556.9644A-100000@kanga.kvack.org> <20000925151250.B20586@hq.fsmlabs.com> <20000926110736.E1638@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000926110736.E1638@redhat.com>; from Stephen C. Tweedie on Tue, Sep 26, 2000 at 11:07:36AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: yodaiken@fsmlabs.com, "Benjamin C.R. LaHaise" <blah@kvack.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 26, 2000 at 11:07:36AM +0100, Stephen C. Tweedie wrote:
> Hi,
> 
> On Mon, Sep 25, 2000 at 03:12:50PM -0600, yodaiken@fsmlabs.com wrote:
> > > > 
> > > > I'm not too sure of what you have in mind, but if it is
> > > >      "process creates vast virtual space to generate many page table
> > > >       entries -- using mmap"
> > > > the answer is, virtual address space quotas and mmap should kill 
> > > > the process on low mem for page tables.
> > > 
> > > No.  Page tables are not freed after munmap (and for good reason).  The
> > > counting of page table "beans" is critical.
> > 
> > I've seen the assertion before, reasons would be interesting.
> 
> Reason 1: under DoS attack, you want to target not the process using
> the most resources, but the *user* using the most resources (else a
> fork-bomb style attack can work around your OOM-killer algorithms).

Ok.
      if(over_allocated_page_tables(task->uid) ) return ENOMEM;

makes sense in "fork".   I guess the argument here is not about whether
accounting is good, it's about where the accounting should be done. To me
the alternatives of

      if(preallocate_pages(page_table_size_for_this_process()) == -1)return error
         then actually allocate making sure to adjust counts if some other
         error turns up and with something taking care of how the pre-allocation
         works while we are sleeping waiting for possibly unrelated resources.

or
      just kmalloc with kmalloc magically juggling resources in some safe way


seem less clear.

       

     

> Reason 2: if you've got tasks stuck in low-level page allocation
> routines, then you can't immediately kill -9 them, so reactive OOM
> killing always has vulnerabilities --- to be robust in preventing
> resource exhaustion you want limits on the use of those resources
> before they are exhausted --- the necessary accounting being part of
> what we refer to as "beancounter".

doesn't the problem really come from low level page allocation at too high a level?
That is, if instead of select doing get_free_page, it maybe should do 
get_per_process_page(myprocess) or even get_per_process_file_use_page(myprocess)
Then we could have a config-optional per-process pinned page accounting with the 
possibility of doing something sensible in a user-space daemon when memory is low.

> 
> --Stephen

-- 
---------------------------------------------------------
Victor Yodaiken 
Finite State Machine Labs: The RTLinux Company.
 www.fsmlabs.com  www.rtlinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
