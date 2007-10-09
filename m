Date: Tue, 9 Oct 2007 08:39:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 9138] New: kernel overwrites MAP_PRIVATE mmap
Message-Id: <20071009083913.212fb3e3.akpm@linux-foundation.org>
In-Reply-To: <bug-9138-27@http.bugzilla.kernel.org/>
References: <bug-9138-27@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bonzini@gnu.org
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(switching to email - please reply via emailed reply-to-all, not via the
bugzilla web interface)

On Tue,  9 Oct 2007 06:28:28 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9138
> 
>            Summary: kernel overwrites MAP_PRIVATE mmap
>            Product: Memory Management
>            Version: 2.5
>      KernelVersion: 2.6.20, 2.6.22
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@osdl.org
>         ReportedBy: bonzini@gnu.org
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution: Debian 2.6.8
> Hardware Environment:
> Software Environment:
> Problem Description:
> 
> Steps to reproduce:
> 
> 1) Download http://www.inf.unisi.ch/phd/bonzini/smalltalk-2.95d.tar.gz
> 2) Compile it with "./configure && make CFLAGS=-g" (the cflags is only for
> easier debuggability, the bug also reproduces without).
> 3) Run "./gst"
> 4) Type "ObjectMemory snapshot"
> 
> It crashes. To reproduce again:
> 
> 5) Run "rm gst.im; make gst.im"
> 6) Go to step 4.
> 
> The code that crashes is in save.c; it dereferences a NULL pointer:
> 
> Program received signal SIGBUS, Bus error.
> 0x08083bf3 in make_oop_table_to_be_saved (header=0xbff29934) at save.c:345
> 345 int numPointers = NUM_OOPS (oop->object);
> (gdb) p oop->object->objClass
> $1 = (OOP) 0x0
> 
> However, going on in the debugging session, you can see that the memory is
> zeroed *by the kernel*:
> 
> (gdb) p &oop->object->objClass
> $2 = (OOP *) 0xb7cb8784
> 
> We set up a breakpoint a little earlier:
> 
> (gdb) b 279
> Breakpoint 1 at 0x8083a5d: file save.c, line 279.
> (gdb) shell rm gst.im; make gst.im
> (gdb) run
> Starting program: /home/bonzinip/smalltalk-2.95d/gst
> GNU Smalltalk ready
> st> ObjectMemory snapshot
> "Global garbage collection... done"
> 
> Breakpoint 1, _gst_save_to_file (
>     fileName=0x812a118 "/home/bonzinip/smalltalk-2.95d/gst.im") at save.c:279
> 279 ftruncate (imageFd, 0);
> 
> Now we set a watchpoint on the location that triggered the NULL access:
> 
> (gdb) set can-use-hw-watchpoints 0
> (gdb) watch *$2
> Watchpoint 2: *$2
> (gdb) n
> Watchpoint 2: *$2
> 
> Old value = (OOP) 0x126
> New value = (OOP) 0x0
> 0xb7ee9438 in ftruncate64 () from /lib/libc.so.6
> 
> >From a disassembly, you can see that it was zeroed by the kernel:
> 
> (gdb) disass 0xb7ee9431 0xb7ee94ec
> 0xb7ee9431 <ftruncate64+49>: mov $0xc2,%eax
> 0xb7ee9436 <ftruncate64+54>: int $0x80 <---
> 0xb7ee9438 <ftruncate64+56>: xchg %edi,%ebx
> 0xb7ee943a <ftruncate64+58>: mov %eax,%esi
> 
> I believe the reason is a bad interaction between the private mmap established
> in save.c:
> 
>   buf = mmap (NULL, file_size, PROT_READ, MAP_PRIVATE, imageFd, 0);
> 
> and truncating the inode on which the mmap was done. Indeed, if the gst.im file
> is unlinked before opening it, the bug disappears. You can try this from the
> Smalltalk interpreter, without patching the source code:
> 
> $ ./gst
> GNU Smalltalk ready
> 
> st> (File name: 'gst.im') remove
> a RealFileHandler
> st> ObjectMemory snapshot
> "Global garbage collection... done"
> ObjectMemory
> st>
> 
> (no bus error anymore).
> 
> I hope this long explanation is understandable!

So can you confirm that this behaviour was not present in 2.6.8 but is
present in 2.6.20?

Would it be possible to prevail upon you to cook up a little standalone
testcase?  

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
