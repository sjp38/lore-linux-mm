Date: Tue, 9 Jan 2001 14:44:19 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.21.0101091654040.7377-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101091436520.2633-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 9 Jan 2001, Marcelo Tosatti wrote:
> 
> The "while (!inactive_shortage())" should be "while (inactive_shortage())"
> as Benjamin noted on lk.

Yes. Also, it does need something to make sure that it doesn't end up
being an endless loop. 

Now, the oom_killer() thing should make sure it's not endless, but the
fact is that kswapd() (who calls the oom-killer) also calls the very same
do_try_to_free_pages(), so we really do have to make sure that it doesn't
loop forever trying to find a page. 

The priority countdown used to handle this, and while I disagree with the
_other_ uses of the priority (it used to make the freeing action
"chunkier" by walking bigger pieces of the VM or the active lists), I
think we need to rename "priority" to "maxtry", and use that to give up
gracefully when we truly do run out of memory.

(I _suspect_ that the oom killer would be invoced before this happens in
practice, and refill_inactive_scan() would find _something_ to make
slight progress on all the time, but the fact is that we shouldn't have
those kinds of assumptions in the VM code).

This would make the return value (that you removed in this patch) still a
valid thing. So I don't think it should go away.

> The second problem is that background scanning is being done
> unconditionally, and it should not. You end up getting all pages with the
> same age if the system is idle. Look at this example (2.4.1-pre1):

I agree. However, I think that we do want to do some background scanning
to push out dirty pages in the background, kind of like bdflush. It just
shouldn't age the pages (and thus not move them to the inactive list).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
