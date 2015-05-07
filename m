Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 746376B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 20:39:29 -0400 (EDT)
Received: by qcbgy10 with SMTP id gy10so13737409qcb.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 17:39:29 -0700 (PDT)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by mx.google.com with ESMTPS id l42si491925qgl.9.2015.05.06.17.39.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 17:39:28 -0700 (PDT)
Received: by qku63 with SMTP id 63so18083928qku.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 17:39:28 -0700 (PDT)
Message-ID: <554AB43A.1030709@hurleysoftware.com>
Date: Wed, 06 May 2015 20:39:22 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: [CONFIG_MULTIUSER] BUG: unable to handle kernel paging request
 at ffffffee
References: <20150428004320.GA19623@wfg-t540p.sh.intel.com> <20150506090850.GA30187@wfg-t540p.sh.intel.com> <20150506154429.GA21798@x> <20150506235936.GB23822@cloud>
In-Reply-To: <20150506235936.GB23822@cloud>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josh@joshtriplett.org, Fengguang Wu <fengguang.wu@intel.com>
Cc: Iulia Manda <iulia.manda21@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org

On 05/06/2015 07:59 PM, josh@joshtriplett.org wrote:
> On Wed, May 06, 2015 at 08:44:29AM -0700, Josh Triplett wrote:
>> On Wed, May 06, 2015 at 05:08:50PM +0800, Fengguang Wu wrote:
>>> FYI, the reported bug is still not fixed in linux-next 20150506.
>>
>> This isn't the same bug.  The previous one you mentioned was a userspace
>> assertion failure in libnih, likely caused because some part of upstart
>> didn't have appropriate error handling for some syscall returning
>> ENOSYS; that one wasn't an issue, since CONFIG_MULTIUSER=n is not
>> expected to boot a standard Linux distribution.
>>
>> This one, on the other hand, is a kernel panic, and does need fixing.
>>
>>> commit 2813893f8b197a14f1e1ddb04d99bce46817c84a
>>>
>>> +-----------------------------------------------------------+------------+------------+------------+
>>> |                                                           | c79574abe2 | 2813893f8b | cbdacaf0c1 |
>>> +-----------------------------------------------------------+------------+------------+------------+
>>> | boot_successes                                            | 60         | 0          | 0          |
>>> | boot_failures                                             | 0          | 22         | 1064       |
>>> | BUG:unable_to_handle_kernel                               | 0          | 22         | 1032       |
>>> | Oops                                                      | 0          | 22         | 1032       |
>>> | EIP_is_at_devpts_new_index                                | 0          | 22         | 1032       |
>>> | Kernel_panic-not_syncing:Fatal_exception                  | 0          | 22         | 1032       |
>>> | backtrace:do_sys_open                                     | 0          | 22         | 1032       |
>>> | backtrace:SyS_open                                        | 0          | 22         | 1032       |
>>> | WARNING:at_arch/x86/kernel/fpu/core.c:#fpu__clear()       | 0          | 0          | 32         |
>>> | Kernel_panic-not_syncing:Attempted_to_kill_init!exitcode= | 0          | 0          | 32         |
>>> +-----------------------------------------------------------+------------+------------+------------+
>>
>> Is this table saying the number of times the type of error in the first
>> column occurred in each commit?
>>
>> In any case, investigating.  Iulia, can you look at this as well?
>>
>> I'm digging through the call stack, and I'm having a hard time seeing
>> how the CONFIG_MULTIUSER patch could affect anything here.
> 
> Update: it looks like init_devpts_fs is getting ERR_PTR(-EINVAL) back
> from kern_mount and storing that in devpts_mnt; later, devpts_new_index
> pokes at devpts_mnt and explodes.
> 
> So, there are two separate bugs here.  On the one hand, CONFIG_MULTIUSER
> should not be causing kern_mount to fail with -EINVAL; tracking that
> down now.

The mount failure is probably from the devpts mount options specifying
gid= for devpts nodes:

devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0

The relevant code is fs/devpts/inode.c:parse_mount_options().
devpts also supports specifying the uid.

To me, kern_mount() appropriately fails with -EINVAL, since the mount
options failed.


> On the other hand, devpts and ptmx should handle the failure
> better, without crashing; ptmx_open should have gracefully failed back
> to userspace with -ENODEV or something, since ptmx doesn't make sense
> without devpts.  I'll send a patch for that too.

Yeah, crashing is bad, but I don't think we should even be init'ing
either BSD or SysV pty drivers if there is no devpts.

Regards,
Peter Hurley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
