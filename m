Message-ID: <41DAD2AF.80604@sgi.com>
Date: Tue, 04 Jan 2005 11:30:23 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration
References: <41D99743.5000601@sgi.com>	<1104781061.25994.19.camel@localhost>	<41D9A7DB.2020306@sgi.com> <20050104.234207.74734492.taka@valinux.co.jp>
In-Reply-To: <20050104.234207.74734492.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: haveblue@us.ibm.com, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hirokazu Takahashi wrote:

> 
> I also think we should rewrite page allocation in the memory migration
> code, as the latest -mm tree includes NUMA aware page allocator. I guess
> you should also care about mm/mempolicy.c and expand it for your purpose.
> If memory migration is called after moving a process, a new page would
> be allocated form a proper node automatically.
> 
> Have you checked mm/mempolicy.c?
> 
> Thanks,
> Hirokazu Takahashi.

My thinking on this was to update the mempolicy after page migration.
This works for my purposes since my plan is to

(1)  suspend the process via SIGSTOP
(2)  update the mempolicy
(3)  migrate the process's pages
(4)  migrate the process to the new cpu via set_schedaffinity()
(5)  resume the process via SIGCONT

These steps are to be performed via a user space program that implements
the actual migration function; the (2)-(4) are just the system calls that
implement this.  This keeps some of the function (i. e. which processes to
migrate) out of the kernel and allows the user some flexibility in what
order operations are performed as well as other functions that may go
along with this migration request.  (The actual function we are trying
to implement is to support >>job<< migration from one set of NUMA nodes to
another, and a job may consist of several processes.)

Given the order defined above, its not absolutely necessary to suspend
and resume the process (another reason for letting a user program coordinate
this) but that is part of the approach we are taking since this is being
initiated for scheduling reasons in a large NUMA system.

(2) is new function AFAIK; its on my TODO list.
-- 
Best Regards,
Ray
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
