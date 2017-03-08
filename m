Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 479FC8320B
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 17:05:37 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l37so15173855wrc.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 14:05:37 -0800 (PST)
Received: from mail-wr0-x22e.google.com (mail-wr0-x22e.google.com. [2a00:1450:400c:c0c::22e])
        by mx.google.com with ESMTPS id 43si6056127wru.64.2017.03.08.14.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 14:05:35 -0800 (PST)
Received: by mail-wr0-x22e.google.com with SMTP id u108so32872387wrb.3
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 14:05:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161129020233.GE28177@dastard>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161125030059.GY31101@dastard> <20161128224651.GA1243@linux.intel.com> <20161129020233.GE28177@dastard>
From: Mike Marshall <hubcap@omnibond.com>
Date: Wed, 8 Mar 2017 17:05:34 -0500
Message-ID: <CAOg9mSSyq79jfi+UTRKGC348RH-Z=ruOPjhp39XTdYh38FTYdw@mail.gmail.com>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org

This is a reply to a thread from back in Nov 2016...

Linus> The thing is, with function tracing, you *can* get the return value
Linus> and arguments. Sure, you'll probably need to write eBPF and just
Linus> attach it to that fentry call point, and yes, if something is inlined
Linus> you're just screwed, but Christ, if you do debugging that way you
Linus> shouldn't be writing kernel code in the first place.

I've been thinking about this thread ever since then... lately I've been
reading about eBPF and looking at Brendan Gregg's bcc tool, and
reading about kprobes and I made some test tracepoints too...

Orangefs has a function:

orangefs_create(struct inode *dir,
                        struct dentry *dentry,
                        umode_t mode,
                        bool exclusive)

I found it was easy to use a kprobe to get a function's return code:

echo 'r:orangefs_create_retprobe orangefs_create $retval' >>
/sys/kernel/debug/tracing/kprobe_events

It was also easy to use a kprobe to print the arguments to a function,
but since arguments are often pointers, maybe the pointer value isn't
really what you want to see, rather you might wish you could "see into"
a structure that you have a pointer to...

Here's a kprobe for looking at the arguments to a function, the funny
di, si, dx, stack
stuff has to do with a particular architecture's parameter passing mechanism as
it relates to registers and the stack... I mention that because the
example in kprobetrace.txt
seems to be for a 32-bit computer and I'm (like most of us?) on a
64-bit computer.

echo 'p:orangefs_create_probe orangefs_create dir=%di dentry=%si
mode=%dx exclusive=+4($stack)' >
/sys/kernel/debug/tracing/kprobe_events

I wrote a bcc program to extract the name of an object from the dentry struct
passed into orangefs_create. The bcc program is kind of verbose, but is
mostly "templatey", here it is... is this the kind of thing Linus was
talking about?

Either way, I think it is kind of cool <g>...

#!/usr/bin/python
#
# Brendan Gregg's mdflush used as a template.
#

from __future__ import print_function
from bcc import BPF
from time import strftime
import ctypes as ct

# load BPF program
b = BPF(text="""
#include <uapi/linux/limits.h>
#include <uapi/linux/ptrace.h>
#include <linux/sched.h>
#include <linux/genhd.h>
#include <linux/dcache.h>

struct data_t {
    u64 pid;
    char comm[TASK_COMM_LEN];
    char objname[NAME_MAX];
};
BPF_PERF_OUTPUT(events);

int kprobe__orangefs_create(struct pt_regs *ctx,
                            void *dir,
                            struct dentry *dentry)
{
    struct data_t data = {};
    u32 pid = bpf_get_current_pid_tgid();
    data.pid = pid;
    bpf_get_current_comm(&data.comm, sizeof(data.comm));
    bpf_probe_read(&data.objname,
                   sizeof(data.objname),
                   (void *)dentry->d_name.name);
    events.perf_submit(ctx, &data, sizeof(data));
    return 0;
}
""")

# event data
TASK_COMM_LEN = 16  # linux/sched.h
NAME_MAX = 255  # uapi/linux/limits.h
class Data(ct.Structure):
    _fields_ = [
        ("pid", ct.c_ulonglong),
        ("comm", ct.c_char * TASK_COMM_LEN),
        ("objname", ct.c_char * NAME_MAX)
    ]

# header
print("orangefs creates... Hit Ctrl-C to end.")
print("%-8s %-6s %-16s %s" % ("TIME", "PID", "COMM", "OBJNAME"))

# process event
# print_event is the callback invoked from open_perf_buffers...
# cpu refers to a set of per-cpu ring buffers that will receive the event data.
def print_event(cpu, data, size):
    event = ct.cast(data, ct.POINTER(Data)).contents
    print("%-8s %-6d %-16s %s" % (strftime("%H:%M:%S"), event.pid, event.comm,
        event.objname))

# read events
b["events"].open_perf_buffer(print_event)
while 1:
    b.kprobe_poll()




-Mike

On Mon, Nov 28, 2016 at 9:02 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, Nov 28, 2016 at 03:46:51PM -0700, Ross Zwisler wrote:
>> On Fri, Nov 25, 2016 at 02:00:59PM +1100, Dave Chinner wrote:
>> > On Wed, Nov 23, 2016 at 11:44:19AM -0700, Ross Zwisler wrote:
>> > > Tracepoints are the standard way to capture debugging and tracing
>> > > information in many parts of the kernel, including the XFS and ext4
>> > > filesystems.  Create a tracepoint header for FS DAX and add the first DAX
>> > > tracepoints to the PMD fault handler.  This allows the tracing for DAX to
>> > > be done in the same way as the filesystem tracing so that developers can
>> > > look at them together and get a coherent idea of what the system is doing.
>> > >
>> > > I added both an entry and exit tracepoint because future patches will add
>> > > tracepoints to child functions of dax_iomap_pmd_fault() like
>> > > dax_pmd_load_hole() and dax_pmd_insert_mapping(). We want those messages to
>> > > be wrapped by the parent function tracepoints so the code flow is more
>> > > easily understood.  Having entry and exit tracepoints for faults also
>> > > allows us to easily see what filesystems functions were called during the
>> > > fault.  These filesystem functions get executed via iomap_begin() and
>> > > iomap_end() calls, for example, and will have their own tracepoints.
>> > >
>> > > For PMD faults we primarily want to understand the faulting address and
>> > > whether it fell back to 4k faults.  If it fell back to 4k faults the
>> > > tracepoints should let us understand why.
>> > >
>> > > I named the new tracepoint header file "fs_dax.h" to allow for device DAX
>> > > to have its own separate tracing header in the same directory at some
>> > > point.
>> > >
>> > > Here is an example output for these events from a successful PMD fault:
>> > >
>> > > big-2057  [000] ....   136.396855: dax_pmd_fault: shared mapping write
>> > > address 0x10505000 vm_start 0x10200000 vm_end 0x10700000 pgoff 0x200
>> > > max_pgoff 0x1400
>> > >
>> > > big-2057  [000] ....   136.397943: dax_pmd_fault_done: shared mapping write
>> > > address 0x10505000 vm_start 0x10200000 vm_end 0x10700000 pgoff 0x200
>> > > max_pgoff 0x1400 NOPAGE
>> >
>> > Can we make the output use the same format as most of the filesystem
>> > code? i.e. the output starts with backing device + inode number like
>> > so:
>> >
>> >     xfs_ilock:            dev 8:96 ino 0x493 flags ILOCK_EXCL....
>> >
>> > This way we can filter the output easily across both dax and
>> > filesystem tracepoints with 'grep "ino 0x493"'...
>>
>> I think I can include the inode number, which I have via mapping->host.  Am I
>> correct in assuming "struct inode.i_ino" will always be the same as
>> "struct xfs_inode.i_ino"?
>
> Yes - just use inode.i_ino.
>
>> Unfortunately I don't have access to the major/minor (the dev_t) until I call
>> iomap_begin().
>
> In general, filesystem tracing uses inode->sb->s_dev as the
> identifier. NFS, gfs2, XFS, ext4 and others all use this.
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
