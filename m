Date: Wed, 3 Nov 2004 03:26:06 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
Message-ID: <20041103022606.GI3571@dualathlon.random>
References: <4187FA6D.3070604@us.ibm.com> <20041102220720.GV3571@dualathlon.random> <41880E0A.3000805@us.ibm.com> <4188118A.5050300@us.ibm.com> <20041103013511.GC3571@dualathlon.random> <418837D1.402@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <418837D1.402@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 02, 2004 at 05:43:45PM -0800, Dave Hansen wrote:
> Oh, crap.  I meant to clear ->mapped when change_attr(__pgprot(0)) was 
> done on it, and set it when it was changed back.  Doing that correctly 
> preserves the symmetry, right?

yes it should. I agree with Andrew a bitflag would be enough. I'd call
it PG_prot_none.

I realized if the page is in the freelist it's like if it's reserved,
since you're guaranteed there's no other pageattr working on it
(assuming every other pageattr is symmetric too, which we always depend
on). So I wonder why it's not symmetric already, despite the lack of
page->mapped. Would be nice to dump_stack when a __pg_prot(0) &&
page->mapped triggers.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
