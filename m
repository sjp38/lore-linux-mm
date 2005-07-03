Date: Sun, 3 Jul 2005 13:06:39 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable for other purposes
Message-ID: <20050703110638.GA1312@elf.ucw.cz>
References: <20050625025122.GC22393@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506242311220.7971@graphe.net> <20050626023053.GA2871@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506251954470.26198@graphe.net> <20050626030925.GA4156@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506261928010.1679@graphe.net> <Pine.LNX.4.58.0506262121070.19755@ppc970.osdl.org> <Pine.LNX.4.62.0506262249080.4374@graphe.net> <42C1C627.5040404@engr.sgi.com> <Pine.LNX.4.62.0506281450490.5895@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0506281450490.5895@graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Ray Bryant <raybry@engr.sgi.com>, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi!

> > >  -			freeze(p);
> > > +			set_thread_flag(TIF_FREEZE);
> > 
> > Shouldn't that be "set_ti_thread_flag(p->thread_info, TIF_FREEZE)"?
> > Otherwise you freeze current, not the thread "p".
> 
> Correct. Which also means that we have not progressed yet beyond an 
> academic version of the patch:
> 
> ---
> 
> Revise handling of freezing in the suspend code
> 
> The current suspend code modifies thread flags from outside the context of process.
> This creates a SMP race.
> 
> The patch fixes that by introducing a TIF_FREEZE flag (for all arches). Also
> 
> - Uses a completion handler instead of waiting in a schedule loop in the refrigerator.
> 
> - Introduces a semaphore freezer_sem to provide a way that multiple kernel
>   subsystems can use the freezing ability without interfering with one another.
> 
> - Include necessary definitions for the migration code if CONFIG_MIGRATE is set.
> 
> - Removes PF_FREEZE
> 
> Signed-off-by: Christoph Lameter <christoph@lameter.com>

This patch breaks suspend for me (first suspend works, second suspend
fails to freeze processes). [I was offline, that's why it took so
long.]

I see patches 1/2 and 2/2 submitted; if you still feel I should apply
some of them, tell me.
								Pavel

-- 
teflon -- maybe it is a trademark, but it should not be.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
