Date: Fri, 20 Oct 2000 10:34:53 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: mapping user space buffer to kernel address space
In-Reply-To: <20001019210650.A1984@redhat.com>
Message-ID: <Pine.LNX.4.10.10010201019030.1354-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Tweedie <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Rogier Wolff <R.E.Wolff@BitWizard.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 19 Oct 2000, Stephen Tweedie wrote:
> > 
> > Then, we'd move the "writeout" part into the LRU queue side, and at that
> > point I agree with you 100% that we probably should just delay it until
> > there are no mappings available
> 
> I've just been talking about this with Ben LaHaise and Rik van Riel,
> and Ben brought up a nasty problem --- NFS, which because of its
> credentials requirements needs to have the struct file available in
> its writepage function.  Of course, if we defer the write then we
> don't necessarily have the file available when we come to flush the
> page from cache.

Yes. But that doesn't mean that swapping couldn't do it (swapping
fundamentally doesn't have credentials).

And note that this is not about "NFS is broken" - any remote filesystem
will have some issues like this, and shared mappings will always have to
handle this case.

So basically I agree that shared mappings cannot be converted to this
setup, I was only talking about the specific case of the swapping (and
anonymous shared memory, which along with SysV IPC shm is basically the
same thing and already uses the swap cache).

So what I was thinking of was the very end of try_to_swap_out(), where we
have noticed that we do not have a "swapout()" function, and we need to
add the page to the swap cache. I would suggest moving _that_ code to the
LRU queue, and handling it conceptually together with the stuff that
handles the buffer cache writeout.

--

And no, I haven't forgotten about the case of direct IO into a shared
mapping. That _is_ going to be different in many ways, and I suspect that
a solution to that particular issue may be to move the "vm_file"
information from when we do the virtual kiobuf lookup into the kiobuf's,
because otherwise we'd basically lose that information.

(We _already_ lose that information, in fact. Keeping the page in the
virtual mapping doesn't really even fix it - because the page can be in
multiple virtual mappings with different vm_file's and thus different
credentials. And the kiobuf's do not really contain any information of
_which_ of the credentials we looked up. It happens to work, but it's
conceptually not very correct).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
