Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6864C5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:45:29 -0400 (EDT)
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2ED6AC> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Tue, 2 Jun 2009 17:58:42 -0400
Date: Tue, 2 Jun 2009 14:52:41 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 18/23] vfs: Teach epoll to use file_hotplug_lock
In-Reply-To: <m1eiu2qqho.fsf@fess.ebiederm.org>
Message-ID: <alpine.DEB.1.10.0906021429570.12866@makko.or.mcafeemobile.com>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-18-git-send-email-ebiederm@xmission.com> <alpine.DEB.1.10.0906020944540.12866@makko.or.mcafeemobile.com> <m1eiu2qqho.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Jun 2009, Eric W. Biederman wrote:

> Davide Libenzi <davidel@xmailserver.org> writes:
> 
> > On Mon, 1 Jun 2009, Eric W. Biederman wrote:
> >
> >> From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>
> >> 
> >> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
> >> ---
> >>  fs/eventpoll.c |   39 ++++++++++++++++++++++++++++++++-------
> >>  1 files changed, 32 insertions(+), 7 deletions(-)
> >
> > This patchset gives me the willies for the amount of changes and possible 
> > impact on many subsystems.
> 
> It both is and is not that bad.  It is the cost of adding a lock.

We both know that it is not only the cost of a lock, but also the 
sprinkling over a pretty vast amount of subsystems, of another layer of 
code.



> I thought of doing something more uniform to user space.  But I observed
> that the existing epoll punts on the case of a file descriptor being closed
> and locking to go from a file to the other epoll datastructures is pretty
> horrid I said forget it and used the existing close behaviour.

Well, you cannot rely on the caller to tidy up the epoll fd by issuing an 
epoll_ctl(DEL), so you do *need* to "punt" on close in order to not leave 
lingering crap around. You cannot even hold a reference of the file, since 
otherwise the epoll hooking will have to trigger not only at ->release() 
time, but at every close, where you'll have to figure out if this is the 
last real userspace reference or not. Plus all the issues related to 
holding permanent extra references to userspace files.
And since a file can be added in many epoll devices, you need to 
unregister it from all of them (hence the other datastructures lookup). 
Better this, on the slow path, with locks acquired only in the epoll usage 
case, than some other thing and on the fast path, for every file.



- Davide


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
