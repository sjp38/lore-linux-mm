Date: Thu, 19 Oct 2000 21:06:50 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: mapping user space buffer to kernel address space
Message-ID: <20001019210650.A1984@redhat.com>
References: <20001018015949.C4635@athlon.random> <Pine.LNX.4.10.10010172129290.6732-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10010172129290.6732-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Tue, Oct 17, 2000 at 09:42:36PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Rogier Wolff <R.E.Wolff@BitWizard.nl>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Oct 17, 2000 at 09:42:36PM -0700, Linus Torvalds wrote:

> Now, the way I'v ealways envisioned this to work is that the VM scanning
> function basically always does the equivalent of just
> 
>  - get PTE entry, clear it out.
>  - if PTE was dirty, add the page to the swap cache, and mark it dirty,
>    but DON'T ACTUALLY START THE IO!
>  - free the page.
> 
> Then, we'd move the "writeout" part into the LRU queue side, and at that
> point I agree with you 100% that we probably should just delay it until
> there are no mappings available

I've just been talking about this with Ben LaHaise and Rik van Riel,
and Ben brought up a nasty problem --- NFS, which because of its
credentials requirements needs to have the struct file available in
its writepage function.  Of course, if we defer the write then we
don't necessarily have the file available when we come to flush the
page from cache.

One answer is to say "well then NFS is broken, fix it".  It's not too
hard --- NFS mmaps need a wp_page function which registers the
caller's credentials against the page when we dirty it so that we can
use those credentials on flush.  That means that writes to a
multiply-mapped file essentially get random credentials, but I don't
think we care --- the credentials eventually used will be enough to
avoid the root_squash problems and the permissions at open make sure
we're not doing anything illegal.  

(Changing permissions on an already-mmaped file and causing the NFS
server to refuse the write raises problems which are ... interesting,
but I'm not convinced that that is a new problem; I suspect we can
fabricate such a failure today.)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
