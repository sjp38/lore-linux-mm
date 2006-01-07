Date: Fri, 6 Jan 2006 23:00:29 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] use local_t for page statistics
Message-ID: <20060107010029.GA5087@dmt.cnet>
References: <20060106215332.GH8979@kvack.org> <20060106163313.38c08e37.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060106163313.38c08e37.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 06, 2006 at 04:33:13PM -0800, Andrew Morton wrote:
> Benjamin LaHaise <bcrl@kvack.org> wrote:
> >
> > The patch below converts the mm page_states counters to use local_t.  
> > mod_page_state shows up in a few profiles on x86 and x86-64 due to the 
> > disable/enable interrupts operations touching the flags register.  On 
> > both my laptop (Pentium M) and P4 test box this results in about 10 
> > additional /bin/bash -c exit 0 executions per second (P4 went from ~759/s 
> > to ~771/s).  Tested on x86 and x86-64.  Oh, also add a pgcow statistic 
> > for the number of COW page faults.
> 
> Bah.  I think this is a better approach than the just-merged
> mm-page_state-opt.patch, so I should revert that patch first?

Don't think so - local_t operations are performed atomically, which is
not required for most hotpath page statistics operations since proper
locks are already held.

What is wanted for these cases are simple inc/dec (non-atomic)
instructions, which is what Nick's patch does by introducing
__mod_page_state.

Ben, have you tested mm-page_state-opt.patch? It should get rid of
most "flags" save/restore on stack.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
