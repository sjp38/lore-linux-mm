Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B16326B0007
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 02:10:32 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id x30so6776176qtm.0
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 23:10:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s66si3263020qkf.380.2018.02.26.23.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 23:10:31 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1R78rKY043139
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 02:10:31 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gcwfe2k6m-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 02:10:31 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 27 Feb 2018 07:10:28 -0000
Date: Tue, 27 Feb 2018 09:10:20 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [OMPI devel] [PATCH v5 0/4] vm: add a syscall to map a process
 memory into a pipe
References: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180220164406.3ec34509376f16841dc66e34@linux-foundation.org>
 <3122ec5a-7f73-f6b4-33ea-8c10ef32e5b0@virtuozzo.com>
 <B9A6330F-48FE-4260-A505-3FF043874F0F@me.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B9A6330F-48FE-4260-A505-3FF043874F0F@me.com>
Message-Id: <20180227071020.GA24633@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Hjelm <hjelmn@me.com>
Cc: Open MPI Developers <devel@lists.open-mpi.org>, Andrei Vagin <avagin@openvz.org>, Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>, rr-dev@mozilla.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>, criu@openvz.org, linux-mm@kvack.org, gdb@sourceware.org, Alexander Viro <viro@zeniv.linux.org.uk>, Greg KH <gregkh@linuxfoundation.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Michael Kerrisk <mtk.manpages@gmail.com>

On Mon, Feb 26, 2018 at 09:38:19AM -0700, Nathan Hjelm wrote:
> All MPI implementations have support for using CMA to transfer data
> between local processes. The performance is fairly good (not as good as
> XPMEM) but the interface limits what we can do with to remote process
> memory (no atomics). I have not heard about this new proposal. What is
> the benefit of the proposed calls over the existing calls?

The proposed system call call that combines functionality of
process_vm_read and vmsplice [1] and it's particularly useful when one
needs to read the remote process memory and then write it to a file
descriptor. In this case a sequence of process_vm_read() + write() calls
that involves two copies of data can be replaced with process_vm_splice() +
splice() which does not involve copy at all.

[1] https://lkml.org/lkml/2018/1/9/32
 
> -Nathan
> 
> > On Feb 26, 2018, at 2:02 AM, Pavel Emelyanov <xemul@virtuozzo.com> wrote:
> > 
> > On 02/21/2018 03:44 AM, Andrew Morton wrote:
> >> On Tue,  9 Jan 2018 08:30:49 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> >> 
> >>> This patches introduces new process_vmsplice system call that combines
> >>> functionality of process_vm_read and vmsplice.
> >> 
> >> All seems fairly strightforward.  The big question is: do we know that
> >> people will actually use this, and get sufficient value from it to
> >> justify its addition?
> > 
> > Yes, that's what bothers us a lot too :) I've tried to start with finding out if anyone
> > used the sys_read/write_process_vm() calls, but failed :( Does anybody know how popular
> > these syscalls are? If its users operate on big amount of memory, they could benefit from
> > the proposed splice extension.
> > 
> > -- Pavel

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
