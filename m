Message-ID: <42039E19.9060609@sgi.com>
Date: Fri, 04 Feb 2005 10:08:57 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: migration cache, updated
References: <42014605.4060707@sgi.com>	<20050203.115911.119293038.taka@valinux.co.jp>	<420240F8.6020308@sgi.com> <20050204.163248.41633006.taka@valinux.co.jp>
In-Reply-To: <20050204.163248.41633006.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: marcelo.tosatti@cyclades.com, linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hirokazu Takahashi wrote:
> 
> 
>>If I take out the migration cache patch, this "VM: killing ..." problem
>>goes away.   So it has something to do specifically with the migration
>>cache code.
> 
> 
> I've never seen the message though the migration cache code may have
> some bugs. May I ask you some questions about it?
> 
>  - Which version of kernel did you use for it?

2.6.10.  I pulled enough of the mm fixes (2 patches) so that the base
migration patch from the hotplug tree would work on top of 2.6.10.  AFAIK
the same problem occurs on 2.6.11-mm2 which is where I started with the
migration cache patch.  But I admit I haven't tested it there recently.

>  - Which migration cache code did you choose?

I'm using a version from Dec 8 I grabbed from an email from you to Marcello
titled:  Subject: Re: migration cache, updated

>  - How many nodes, CPUs and memory does your box have?

8 CPU, 4 Node Altix, but I really don't think that is significant.

>  - What kind of applications were running on your box?

Machine was running single user.  The only thing that was running was the
test program that calls the page migration system call I wrote.

>  - How often did this happened?

Every time.

>  - Did this message appear right after starting the migration?

The pages all get migrated and then when the system call initiating all
of this returns, the calling process gets killed. There is a printf following
the system call that doesn't happen; the VM kill occurs first.

>    Or it appeared some short while later?

Immediately on return.

>  - How the target pages to be migrated were selected?

The system call interface specifes a virtual address range and pid.  We
scan through all pages in the vma specified by the address range (the range
is required to be withing one vma).  All resident pages in the range are
pulled off of the lru list and added to the list to be passed in to
try_to_migrate_pages().

>  - How did you kick memory migration started?

Via the system call mentioned above.

>  - Please show me /proc/meminfo when the problem happened.

Unfortunately, I don't have that data.  There was lots of memory free,
since I was running single user.

>  - Is it possible to make the same problem on my machine?

I think so.  I'd have to send you my system call code and test programs.
Its not a lot of code on top of the existing page migration patch.

> 
> And, would you please make your project proceed without the
> migration cache code for a while?

I've already done that.  :-)

> 
> Thanks,
> Hirokazu Takahashi.
> 


-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
