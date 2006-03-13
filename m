Date: Mon, 13 Mar 2006 15:45:45 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
In-Reply-To: <1142270857.5210.50.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com>
References: <1142019195.5204.12.camel@localhost.localdomain>
 <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>
 <1142270857.5210.50.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 13 Mar 2006, Lee Schermerhorn wrote:

> > BTW, what happens against shared pages ?
> 
> I have made no changes to the way that 2.6.16-rc* migration code handles
> shared pages.  Note that migrate_task_memory()/migrate_vma_to_node()
> calls check_range() with the flag MPOL_MF_MOVE.  This will select for
> migration pages that are only mapped by the calling task--i.e., only in
> the calling task's page tables.  This includes shared pages that are
> only mapped by the calling task.  With the current migration code, we
> have 2 flags:  '_MOVE and '_MOVE_ALL.  '_MOVE behaves as described
> above; '_MOVE_ALL is more aggressive and migrates pages regardless of
> the # of mappings.  Christoph says that's primarily for cpusets, but the
> migrate_pages() sys call will also use 'MOVE_ALL when invoked as root.

cpusets uses _MOVE_ALL because Paul wanted it that way. I still think it 
is a bad idea to move shared libraries etc. _MOVE only moves the pages used
by the currently executing process. If you do a MOVE_ALL then you may 
cause delays in other processes because they have to wait for their pages 
to become available again. Also they may have to generate additional 
faults to restore their PTEs. So you are negatively impacting other 
processes. Note that these wait times can be extensive if _MOVE_ALL is 
f.e. just migrating a critical glibc page that all processes use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
