Date: Wed, 3 Nov 1999 17:25:34 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: The 64GB memory thing
In-Reply-To: <99Nov3.094606gmt.66315@gateway.ukaea.org.uk>
Message-ID: <Pine.LNX.4.10.9911031654080.7408-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Conway <njcmail@fusrs5a.culham.ukaea.org.uk>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 1999, Neil Conway wrote:

> The recent thread about >4GB surprised me, as I didn't even think >2GB
> was very stable yet.  Am I wrong?  Are people out there using 4GB
> boxes with decent stability?  I presume it's a 2.3 feature, yes?

the 64GB stuff got included recently. It's a significant rewrite of the
lowlevel x86 MM and generic MM layer, here is a short description about
it:

my 'HIGHMEM patch' went into the 2.3 kernel starting at pre4-2.3.23. This
means a heavily rewritten VM subsystem (to deal with pte's bigger than
machine word size), and a much rewritten x86 memory and boot architecture.
In fact there is no bigmem anymore, it has been replaced by (the i think
more correct term) 'high memory'. It utilizes 3-level page tables on PPro+
CPUs called 'Physical Address Extension' (PAE) mode. In PAE mode the CPU
uses a completely different and incompatible page table structure, which
is 3-level and has 64-bit page table entries and cover up to 64GB physical
RAM. Virtual space is still unchanged, 4GB. Highmem is completely
transparent to user-space.

There is a new 'High Memory Support' option under 'Processor type and
features':
    
                      High Memory Support 
                            ( ) off                             
                            ( ) 4GB                             
                            (X) 64GB                            
 
'off' is up to 1GB RAM, utilizing 2-level page tables and no highmem
support. '4GB' is utilizing 2-level page tables and high memory support
for any <4GB physical RAM that cannot be permanently mapped by the kernel.
'64GB' mode utilizes 3-level page tables (for everything). The theoretical
limit of high memory on IA32 boxes is 16 TB - there is lots of space in
64-bit PAE pte's, although current CPUs only support up to 64GB RAM. (the
biggest current chipsets supports up to 32GB RAM)

about the structure of the patch/feature itself, kernel internals:

pgtable.h got split up into pgtable-2level.h and pgtable-3level.h, which
should be the only 'global #ifdef' distincting 3-level from 2-level page
tables on x86. There were lots of assumptions throughout the arch/i386
tree that assumed 2-level page tables, these places all had to be fixed
and converted to 'generic 3-level page table code'. There are only a few
CONFIG_X86_PAE #ifdefs left, i intend to cut down the number of these even
more, to keep the x86 lowlevel MM/boot code easy to maintain.

the generic kernel was almost safe wrt. 3-level page tables, but
nevertheless it had bugs which only triggered in PAE mode. For example,
one pgd entry in PAE mode covers 1GB of virtual memory, and some loops
which iterated through virtual memory had buggy exit conditions and broke
in subtle ways when they were running in the upper-most 1GB of virtual
memory. (ie. kernel space) There were about 20 of such buggy loops
throughout the MM code.

the much bigger generic change was that pte's got 64-bit, although the
architecture itself was still 32-bit. Lots of VM-internal code had to be
reworked to never assume that 'sizeof(pte_t) == sizeof(unsigned long)'.
Examples are the swapping code, IPC shared memory. Bigger than
machine-word ptes were not supported by Linux previously.

also i guess many of you have noticed the new mm/bootmem.c allocator -
this was necessery because on my 8GB box mem_map is more than 100 MB (!),
and the 'naive' boot-time allocation we did in earlier kernels simply did
not work on 'slightly noncontinous' physical maps like my box has. (at
64MB there is an ACPI area which caused problems)

[this short description should give you a scope of the changes, and i/we
are still fixing some of the impact in 2.3.25. (Christoph just posted his
problems with IPC shared memory)]

Backporting to 2.2: while the bigmem patch was small and simple and got
backported to 2.2, the highmem patch is basically impossible to be
backported in a maintainable way as it touches some 60 files all over the
kernel.


64 GB PAE mode works just fine on my 8GB RAM, 8-way Xeon box:

 11:25pm  up 5 min,  2 users,  load average: 7.78, 4.30, 1.77
30 processes: 21 sleeping, 9 running, 0 zombie, 0 stopped
CPU states:  0.0% user,  7.2% system, 92.8% nice, 0.0% idle
Mem: 8241152K av,7720960K used, 520192K free,      0K shrd,   2168K buff
Swap:      0K av,      0K used,      0K free                  9756K cached

  PID USER     PRI  NI  SIZE  RSS SHARE STAT  LIB %CPU %MEM   TIME COMMAND
  215 root      19  19 1000M 1.0G   232 R N  1.0G 11.6 12.4   0:11 db_serv
  180 root      19  19 1000M 1.0G   232 R N  1.0G 11.5 12.4   0:31 db_serv
  182 root      19  19 1000M 1.0G   232 R N  1.0G 11.5 12.4   0:30 db_serv
  183 root      19  19 1000M 1.0G   232 R N  1.0G 11.5 12.4   0:30 db_serv
  184 root      19  19 1000M 1.0G   232 R N  1.0G 11.5 12.4   0:30 db_serv
  185 root      19  19 1000M 1.0G   232 R N  1.0G 11.5 12.4   0:30 db_serv
  186 root      19  19 1000M 1.0G   232 R N  1.0G 11.5 12.4   0:29 db_serv
  247 root      19  19  500M 500M   232 R N     0 11.5  6.2   0:04 db_serv2
  181 root       1   0   996  996   828 R       0  7.2  0.0   0:16 top
  177 root       0   0   984  984   768 S       0  0.1  0.0   0:00 bash
    1 root       0   0   476  476   408 S       0  0.0  0.0   0:00 init

(these are 8x ~1G-RSS processes using up all 8GB physical RAM, one running
on each CPU)

future plans:

right now high memory is seriously underused on typical servers due to the
page cache still being in low memory. On 2.2 with bigmem the
lowmem:highmem ratio is around 5:1, this means that the 'effective' size
of my 8GB box in 2.2 is only ~2.4GB. The exception are workloads where
most memory is allocated as shared memory or user memory, but this is not
the case for a typical web or fileserver. On my box the pagecache is
already in high memory (and we are ready to add 64-bit DMA to device
drivers), and the lowmem:highmem ratio is up to 1:10. This means that 8GB
RAM is already fully utilized on a typical server workload.

	Ingo

ps. to have correct memory statistics (top, vmstat, free) with >4GB RAM
you need the newest procps package (or i can send the patches).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
