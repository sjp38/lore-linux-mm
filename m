Date: Thu, 1 Dec 2005 13:20:29 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Better pagecache statistics ?
Message-ID: <20051201152029.GA14499@dmt.cnet>
References: <1133377029.27824.90.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1133377029.27824.90.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Badari,

On Wed, Nov 30, 2005 at 10:57:09AM -0800, Badari Pulavarty wrote:
> Hi,
> 
> Is there a effort/patches underway to provide better pagecache
> statistics ? 
> 
> Basically, I am interested in finding detailed break out of
> cached pages. ("Cached" in /proc/meminfo) 
> 
> Out of this "cached pages"
> 
> - How much is just file system cache (regular file data) ?
> - How much is shared memory pages ?

You could do that from userspace probably, by doing some math 
on all processes statistics versus global stats, but does not 
seem very practical.

> - How much is mmaped() stuff ?

That would be "nr_mapped".

> - How much is for text, data, bss, heap, malloc ?

Hum, the core pagecache code does not deal with such details, 
so adding (and maintaining) accounting there does not seem very 
practical either.

You could walk /proc/<pid>/{maps,smaps} and account for different
types of pages.

$ cat /proc/self/smaps

bf8df000-bf8f4000 rw-p bf8df000 00:00 0          [stack]
Size:                84 kB
Rss:                  8 kB
Shared_Clean:         0 kB
Shared_Dirty:         0 kB
Private_Clean:        0 kB
Private_Dirty:        8 kB

0975b000-0977c000 rw-p 0975b000 00:00 0          [heap]
Size:               132 kB
Rss:                  4 kB
Shared_Clean:         0 kB
Shared_Dirty:         4 kB
Private_Clean:        0 kB
Private_Dirty:        0 kB 

But doing it from userspace does not guarantee much precision
since the state can change while walking the proc stats.

> What is the right way of getting this kind of data ? 
> I was trying to add tags when we do add_to_page_cache()
> and quickly got ugly :(

Problem is that any kind of information maybe be valuable,
depending on what you're trying to do.

For example, one might want to break statistics in /proc/vmstat
and /proc/meminfo on a per-zone basis (for instance there is no 
per-zone "locked" accounting at the moment), per-uid basis,
per-process basis, or whatever.

Other than the pagecache stats you mention, there is a 
general lack of numbers in the MM code.

I think that SystemTap suits the requirement for creation
of detailed MM statistics, allowing creation of hooks outside the 
kernel in an easy manner. Hooks can be inserted on demand.

I just started playing with SystemTap yesterday. First
thing I want to record is "what is the latency of 
direct reclaim".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
