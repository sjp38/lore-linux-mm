Date: Sat, 5 Jul 2003 15:21:02 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: 2.5.74-mm1
Message-ID: <20030705052102.GB13308@krispykreme>
References: <20030703023714.55d13934.akpm@osdl.org> <20030704210737.GI955@holomorphy.com> <20030704181539.2be0762a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030704181539.2be0762a.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Look at select_bad_process(), and the ->mm test in badness().  pdflush
> can never be chosen.
> 
> Nevertheless, there have been several report where kernel threads _are_ 
> being hit my the oom killer.  Any idea why that is?

Milton and I were just looking at this and it seems there is no locking
to prevent p->mm ending up NULL due to exit. And if p->mm does end up
NULL, you go off and kill all your kernel threads :)

Anton

	read_lock(&tasklist_lock);
	p = select_bad_process();

...

        oom_kill_task(p);
        /*
         * kill all processes that share the ->mm (i.e. all threads),
         * but are in a different thread group
         */
        do_each_thread(g, q)
                if (q->mm == p->mm && q->tgid != p->tgid)
                        oom_kill_task(q);
        while_each_thread(g, q);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
