Message-ID: <42BC1573.90201@engr.sgi.com>
Date: Fri, 24 Jun 2005 09:15:15 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc5 0/10] mm: manual page migration-rc3
 -- overview
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com> <Pine.LNX.4.62.0506231428330.23673@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0506231428330.23673@graphe.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

> 
> 
> There is PF_FREEZE flag used by the suspend feature that could 
> be used here to send the process into the "freezer" first. Using regular 
> signals to stop a process may cause races with user space code also doing
> SIGSTOP SIGCONT on a process while migrating it.
> 
> 

In general, process flags are only updatable by the current process.
There is no locking applied.  Having the migrating task set the PF_FREEZE
bit in the migrated process runs the risk of losing the update to some other
flags bit that is simultaneously set by the (running) migrated process.

I suppose this could be fixed as well by introducing a second flags word
in the task_struct.  But this starts to sound like a reimplemtnation of
signals.

The other concern (probably not a problem on Altix  :-) ), is what happens
if a process migration is underway at the time of a suspend.  When the
resume occurs, all processes will be unfrozen, including the task that
is under migration.

At the moment, I'm not convinced that this is a better path than depending
on SIGSTOP/SIGCONT.  It is a resonable restriction that processes eligble for
migration are not allowed to use those signals themselves, in particular for
the batch environment this is targeted at.

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
