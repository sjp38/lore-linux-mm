Date: Mon, 27 Jun 2005 15:17:09 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable for other purposes
Message-ID: <20050627131709.GA30467@atrey.karlin.mff.cuni.cz>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net> <1104805430.20050625113534@sw.ru> <42BFA591.1070503@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42BFA591.1070503@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Kirill Korotaev <dev@sw.ru>, Christoph Lameter <christoph@lameter.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi!

> >CL> frozen(process)             Check for frozen process
> >CL> freezing(process)   Check if a process is being frozen
> >CL> freeze(process)             Tell a process to freeze (go to 
> >refrigerator)
> >CL> thaw_process(process)       Restart process
> >
> >CL> I only know that this boots correctly since I have no system that can 
> >do
> >CL> suspend. But Ray needs an effective means of process suspension for
> >CL> his process migration patches.
> 
> The process migration patches that Christoph mentions are avaialable at
> 
> http://marc.theaimsgroup.com/?l=linux-mm&m=111945947315561&w=2
> 
> and subsequent notes to the -mm or lhms-devel lists.  The problem there is
> that this code depends on user space code to suspend and then resume the
> processes to be migrated before/after the migration.  Christoph suggested
> using PF_FREEZE, but I pointed out that was broken on SMP so hence the
> current patch.
> 
> The idea would be to use PF_FREEZE to cause the process suspension.
> A minor flaw in this approach is what happens if a process migration
> is in progress when the machine is suspended/resumed.  (Probably not
> a common occurrence on Altix... :-), but anyway...).  If the processes
> are PF_FROZEN by the migration code, then unfrozen by the resume code,
> and then the migration code continues, then we have unstopped processes
> being migratated again.  Not a good thing.  On the other hand, the

Should be very easy to solve with one semaphore. Simply make swsusp
wait until all migrations are done.  

> Is the above scenario even possible?  manual page migration runs as a system
> call.  Do system calls all complete before suspend starts?  If that is
> the case, then the above is not something to worry about.

Yes, are normal system calls complete before suspend starts -- but
that's what refrigerator cares about.

> Finally, how comfortable are people about using the PF_FREEZE stuff
> to start and resume processes for purposes unrelated to suspend/resume?

No problem with that...

BTW smp notebooks will come, sooner or later, and 2-core 2-way-HT
notebook is already NUMA system.
								Pavel
-- 
Boycott Kodak -- for their patent abuse against Java.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
