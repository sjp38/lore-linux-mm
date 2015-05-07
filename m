Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id A69D66B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 13:10:40 -0400 (EDT)
Received: by qcbgy10 with SMTP id gy10so24450905qcb.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 10:10:40 -0700 (PDT)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [2001:4b98:c:538::195])
        by mx.google.com with ESMTPS id b102si2659722qga.35.2015.05.07.10.10.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 May 2015 10:10:40 -0700 (PDT)
Date: Thu, 7 May 2015 10:10:35 -0700
From: josh@joshtriplett.org
Subject: Re: [CONFIG_MULTIUSER] BUG: unable to handle kernel paging request
 at ffffffee
Message-ID: <20150507171035.GA30670@cloud>
References: <20150428004320.GA19623@wfg-t540p.sh.intel.com>
 <20150506090850.GA30187@wfg-t540p.sh.intel.com>
 <20150506154429.GA21798@x>
 <20150506235936.GB23822@cloud>
 <554AB43A.1030709@hurleysoftware.com>
 <20150507155640.GA30083@cloud>
 <554B91A7.7020904@hurleysoftware.com>
 <20150507170319.GA30497@cloud>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150507170319.GA30497@cloud>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Iulia Manda <iulia.manda21@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org

On Thu, May 07, 2015 at 10:03:19AM -0700, josh@joshtriplett.org wrote:
> On Thu, May 07, 2015 at 12:24:07PM -0400, Peter Hurley wrote:
> > On 05/07/2015 11:56 AM, josh@joshtriplett.org wrote:
> > > On Wed, May 06, 2015 at 08:39:22PM -0400, Peter Hurley wrote:
> > >> On 05/06/2015 07:59 PM, josh@joshtriplett.org wrote:
> > >>> On Wed, May 06, 2015 at 08:44:29AM -0700, Josh Triplett wrote:
> > >>>> On Wed, May 06, 2015 at 05:08:50PM +0800, Fengguang Wu wrote:
> > >>>>> FYI, the reported bug is still not fixed in linux-next 20150506.
> > >>>>
> > >>>> This isn't the same bug.  The previous one you mentioned was a userspace
> > >>>> assertion failure in libnih, likely caused because some part of upstart
> > >>>> didn't have appropriate error handling for some syscall returning
> > >>>> ENOSYS; that one wasn't an issue, since CONFIG_MULTIUSER=n is not
> > >>>> expected to boot a standard Linux distribution.
> > >>>>
> > >>>> This one, on the other hand, is a kernel panic, and does need fixing.
> > >>>>
> > >>>>> commit 2813893f8b197a14f1e1ddb04d99bce46817c84a
> > >>>>>
> > >>>>> +-----------------------------------------------------------+------------+------------+------------+
> > >>>>> |                                                           | c79574abe2 | 2813893f8b | cbdacaf0c1 |
> > >>>>> +-----------------------------------------------------------+------------+------------+------------+
> > >>>>> | boot_successes                                            | 60         | 0          | 0          |
> > >>>>> | boot_failures                                             | 0          | 22         | 1064       |
> > >>>>> | BUG:unable_to_handle_kernel                               | 0          | 22         | 1032       |
> > >>>>> | Oops                                                      | 0          | 22         | 1032       |
> > >>>>> | EIP_is_at_devpts_new_index                                | 0          | 22         | 1032       |
> > >>>>> | Kernel_panic-not_syncing:Fatal_exception                  | 0          | 22         | 1032       |
> > >>>>> | backtrace:do_sys_open                                     | 0          | 22         | 1032       |
> > >>>>> | backtrace:SyS_open                                        | 0          | 22         | 1032       |
> > >>>>> | WARNING:at_arch/x86/kernel/fpu/core.c:#fpu__clear()       | 0          | 0          | 32         |
> > >>>>> | Kernel_panic-not_syncing:Attempted_to_kill_init!exitcode= | 0          | 0          | 32         |
> > >>>>> +-----------------------------------------------------------+------------+------------+------------+
> > >>>>
> > >>>> Is this table saying the number of times the type of error in the first
> > >>>> column occurred in each commit?
> > >>>>
> > >>>> In any case, investigating.  Iulia, can you look at this as well?
> > >>>>
> > >>>> I'm digging through the call stack, and I'm having a hard time seeing
> > >>>> how the CONFIG_MULTIUSER patch could affect anything here.
> > >>>
> > >>> Update: it looks like init_devpts_fs is getting ERR_PTR(-EINVAL) back
> > >>> from kern_mount and storing that in devpts_mnt; later, devpts_new_index
> > >>> pokes at devpts_mnt and explodes.
> > >>>
> > >>> So, there are two separate bugs here.  On the one hand, CONFIG_MULTIUSER
> > >>> should not be causing kern_mount to fail with -EINVAL; tracking that
> > >>> down now.
> > >>
> > >> The mount failure is probably from the devpts mount options specifying
> > >> gid= for devpts nodes:
> > >>
> > >> devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
> > >>
> > >> The relevant code is fs/devpts/inode.c:parse_mount_options().
> > >> devpts also supports specifying the uid.
> > >>
> > >> To me, kern_mount() appropriately fails with -EINVAL, since the mount
> > >> options failed.
> > > 
> > > Except that init_devpts_fs is called at module_init time, long before
> > > the actual mount syscall; it appears to be creating a kernel-internal
> > > mount, and I don't see how mount options provided by userspace much
> > > later would cause the earlier kern_mount to fail.
> > 
> > Yeah, I realized that later; that the userspace mount is really a rebind
> > to that initial root kernel mount.
> >  
> > > Also, I don't see anything in parse_mount_options that should actually
> > > fail with CONFIG_MULTIUSER unset.
> > 
> > I didn't look deeper than that, but it seemed likely that it stemmed from
> > that. Maybe it's related to CONFIG_DEVPTS_MULTIPLE_INSTANCES (documented
> > in Documentation/fs/devpts.txt) and FS_USERNS_MOUNT?
> 
> Looks like it's actually mknod_ptmx that's failing; it's returning
> EINVAL from the uid_valid/gid_valid checks, which shouldn't happen.

Oh.  Found it.  Looks like {u,g}id_valid call {u,g}id_eq, which compares
__k{u,g}id_val, which unconditionally returns 0 for all k{u,g}ids,
including INVALID_{U,G}ID.  So uid_valid and gid_valid always return
false.

Easily fixed; patch momentarily.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
