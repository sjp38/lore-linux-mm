Date: Tue, 18 Mar 2008 00:36:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-Id: <20080318003620.d84efb95.akpm@linux-foundation.org>
In-Reply-To: <20080318209.039112899@firstfloor.org>
References: <20080318209.039112899@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 02:09:34 +0100 (CET) Andi Kleen <andi@firstfloor.org> wrote:

> This patchkit is an experimental optimization I played around with 
> some time ago.
> 
> This is more a prototype still, but I wanted to push it out 
> so that other people can play with it.
> 
> The basic idea is that most programs have the same working set
> over multiple runs. So instead of demand paging all the text pages
> in the order the program runs save the working set to disk and prefetch
> it at program start and then save it at program exit.
> 
> This allows some optimizations: 
> - it can avoid unnecessary disk seeks because the blocks will be fetched in 
> sorted offset order instead of program execution order. 
> - batch kernel entries (each demand page exception has some
> overhead just for entering the kernel). This keeps the caches hot too.
> - The prefetch could be in theory done in the background while the program 
> runs (although that is not implemented currently)

Should be worthwhile for some things.

> Some details on the implementation:

Can't this all be done in userspace?  Hook into exit() with an LD_PRELOAD,
use /proc/self/maps and the new pagemap code to work out which pages of
which files were faulted in, write that info into the elf file (or a
separate per-executable shadow file), then use that info the next time the
app is executed, either with an LD_PRELOAD or just a wrapper.

> Drawbacks: 
> - No support for dynamic libraries right now (except very clumpsily
> through the mmap_slurp hack). This is the main reason it is not 
> very useful for speed up desktops currently. 
> 
> - Executable files have to be writable by the user executing it
> currently to get bitmap updates. It would be possible to let the 
> kernel bypass this, but I haven't thought too much about the security 
> implications of it.
> However any user can use the bitmap data written by a user with
> write rights.

Those all get fixed with the userspace version?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
