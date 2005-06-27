Message-ID: <42BFA591.1070503@engr.sgi.com>
Date: Mon, 27 Jun 2005 02:06:57 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable
 for other purposes
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net> <1104805430.20050625113534@sw.ru>
In-Reply-To: <1104805430.20050625113534@sw.ru>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirill Korotaev <dev@sw.ru>
Cc: Christoph Lameter <christoph@lameter.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pavel@suse.cz, torvalds@osdl.org, raybry@engr.sgi.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Kirill Korotaev wrote:
> CL> The process freezing used by software suspend currently relies on modifying
> current->>flags from outside of the processes context. This makes freezing and
> CL> unfreezing SMP unsafe since a process may change the flags at any time without
> CL> locking. The following patch introduces a new atomic_t field in task_struct
> CL> to allow SMP safe freezing and unfreezing.
> 
> CL> It provides a simple API for process freezing:
> 
> CL> frozen(process)             Check for frozen process
> CL> freezing(process)   Check if a process is being frozen
> CL> freeze(process)             Tell a process to freeze (go to refrigerator)
> CL> thaw_process(process)       Restart process
> 
> CL> I only know that this boots correctly since I have no system that can do
> CL> suspend. But Ray needs an effective means of process suspension for
> CL> his process migration patches.

The process migration patches that Christoph mentions are avaialable at

http://marc.theaimsgroup.com/?l=linux-mm&m=111945947315561&w=2

and subsequent notes to the -mm or lhms-devel lists.  The problem there is
that this code depends on user space code to suspend and then resume the
processes to be migrated before/after the migration.  Christoph suggested
using PF_FREEZE, but I pointed out that was broken on SMP so hence the
current patch.

The idea would be to use PF_FREEZE to cause the process suspension.
A minor flaw in this approach is what happens if a process migration
is in progress when the machine is suspended/resumed.  (Probably not
a common occurrence on Altix... :-), but anyway...).  If the processes
are PF_FROZEN by the migration code, then unfrozen by the resume code,
and then the migration code continues, then we have unstopped processes
being migratated again.  Not a good thing.  On the other hand, the
manual page migration stuff is only existent on NUMA boxes, so the
question is whether any NUMA boxes support suspend/resume.  (Anyone
have a NUMA laptop handy to test this on?   Thought not....)

Is the above scenario even possible?  manual page migration runs as a system
call.  Do system calls all complete before suspend starts?  If that is
the case, then the above is not something to worry about.

The other approach would be to fix the manual page migration code to
handle non-suspended processes, but that hasn't been achieved yet,
in spite of the fact that the underlying page migration code from the
memory hotplug project is designed to support that.  Even then,
there is still a potential race if the migrated application also uses
SIGTOP/SIGCONT, which is how the migrated processes are suspended
today.

Finally, how comfortable are people about using the PF_FREEZE stuff
to start and resume processes for purposes unrelated to suspend/resume?
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
