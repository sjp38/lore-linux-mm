Date: Fri, 5 Nov 2004 05:03:09 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
Message-ID: <20041105040308.GJ8229@dualathlon.random>
References: <418837D1.402@us.ibm.com> <20041103022606.GI3571@dualathlon.random> <418846E9.1060906@us.ibm.com> <20041103030558.GK3571@dualathlon.random> <1099612923.1022.10.camel@localhost> <1099615248.5819.0.camel@localhost> <20041105005344.GG8229@dualathlon.random> <1099619740.5819.65.camel@localhost> <20041105020831.GI8229@dualathlon.random> <1099621391.5819.72.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1099621391.5819.72.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 04, 2004 at 06:23:11PM -0800, Dave Hansen wrote:
> I'm not quite sure if this has any other weird effects, so I'll hold on
> to it for a week or so and see if anything turns up.  

this fixed the problem for me too.

However I'm not convinced this is correct, nothing in the kernel should
ever free a bootmem piece of memory after the machine has booted.

If this helps, it also means we found an existing pte (not pmd) with
page_count 0 during the first unmap event (bootmem allocated). The
transition from mapped to unmapped works fine, but the transition from
unmapped to mapped will thorw the pte away and we'll regenerate a 2M pmd
where there was a pte instead. I wonder why there are 4k pages there in
the first place.

Anyways I understand what's going on now thanks to your debugging, and I
believe the only real fix is to use PageReserved to catch if we're
working on a newly allocated page or not, I don't like to depend on the
page_count being 0 for the bootmem pages like the previous code was
doing. I believe my code would now fall apart even if you were using it
with PSE disabled (nopentium or something). So I've to fix that bit at
least and I will use PageReserved for that.

The page_count of bootmem pages really doesn't matter since they must
never be freed. It really should remain 0 so we catch if anybody
executes a put_page on it.

I'll fix it up...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
