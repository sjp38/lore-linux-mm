Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id CDFBB6B0036
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 06:57:41 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so7146721qae.33
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 03:57:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f77si6789595qge.35.2014.06.16.03.57.40
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 03:57:40 -0700 (PDT)
Date: Mon, 16 Jun 2014 11:57:34 +0100
From: "Bryn M. Reeves" <bmr@redhat.com>
Subject: Re: [linux-lvm] copying file results in out of memory, kills other
 processes, makes system unavailable
Message-ID: <20140616105733.GB2241@localhost.localdomain>
References: <539C275B.4010003@davidnewall.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539C275B.4010003@davidnewall.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LVM general discussion and development <linux-lvm@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Jun 14, 2014 at 08:13:39PM +0930, David Newall wrote:
> I'm running a qemu virtual machine, 2 x i686 with 2GB RAM.  VM's disks are
> managed via LVM2.  Most disk activity is on one LV, formatted as ext4.
> Backups are taken using snapshots, and at the time of the problem that I am
> about to describe, there were ten of them, or so.  OS is Ubuntu 12.04 with

You don't mention what type of snapshots you're using but by the sound
of it these are legacy LVM2 snapshots using the snapshot target. For
applications where you want to have this number of snapshots present
simultaneously you really want to be using the new snapshot
implementation ('thin snapshots').

Take a look at the RHEL docs for creating and managing these (the
commands work the same whay on Ubuntu):

  http://tinyurl.com/pjdovee  [access.redhat.com]

The problem with traditional snapshots is that they will issue separate
IO for each active snapshot so for one snap a write to the origin (that
triggers a CoW exception) will cause a read and a write of that block in
the snapshot table. With ten active snapshots you're writing that
changed block separately to the ten active CoW areas.

It doesn't take a large number of snapshots before this scheme becomes
unworkable as you've discovered. There are many threads on this topic in
the list archives, e.g.:

  https://www.redhat.com/archives/linux-lvm/2013-July/msg00044.html

> Let me be clear: Process A requests memory; processes B & C are killed;
> where B & C later become D, E & F!
> 
> I feel that over-committing memory is a foolish and odious practice, and
> makes problem determination very much harder than it need be. When a process
> requests memory, if that cannot be satisfied the system should return an
> error and that be the end of it.

You can disable memory over-commit by setting mode 3 in ('don't
overcommit') in vm.overcommit-memory but see:

  Documentation/vm/overcommit-accounting

As well as the documentation for the per-process OOM controls (oom_adj,
oom_score_adj, oom_score). These are discussed in:

  Documentation/filesystems/proc.txt
 
> Actual use of snapshots seems to beg denial of service.

Keeping that number of legacy snapshots present is certainly going to
cause you performance problems like this. Try using thin snapshots or
reducing the number that you keep active.

Regards,
Bryn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
