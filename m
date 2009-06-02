Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CE0AA6B005A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:51:25 -0400 (EDT)
Subject: Re: [PATCH 18/23] vfs: Teach epoll to use file_hotplug_lock
References: <m1oct739xu.fsf@fess.ebiederm.org>
	<1243893048-17031-18-git-send-email-ebiederm@xmission.com>
	<alpine.DEB.1.10.0906020944540.12866@makko.or.mcafeemobile.com>
	<m1eiu2qqho.fsf@fess.ebiederm.org>
	<alpine.DEB.1.10.0906021429570.12866@makko.or.mcafeemobile.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 02 Jun 2009 15:51:14 -0700
In-Reply-To: <alpine.DEB.1.10.0906021429570.12866@makko.or.mcafeemobile.com> (Davide Libenzi's message of "Tue\, 2 Jun 2009 14\:52\:41 -0700 \(PDT\)")
Message-ID: <m13aaintb1.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

Davide Libenzi <davidel@xmailserver.org> writes:

> On Tue, 2 Jun 2009, Eric W. Biederman wrote:
>
>> Davide Libenzi <davidel@xmailserver.org> writes:
>> 
>> > On Mon, 1 Jun 2009, Eric W. Biederman wrote:
>> >
>> >> From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>
>> >> 
>> >> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
>> >> ---
>> >>  fs/eventpoll.c |   39 ++++++++++++++++++++++++++++++++-------
>> >>  1 files changed, 32 insertions(+), 7 deletions(-)
>> >
>> > This patchset gives me the willies for the amount of changes and possible 
>> > impact on many subsystems.
>> 
>> It both is and is not that bad.  It is the cost of adding a lock.
>
> We both know that it is not only the cost of a lock, but also the 
> sprinkling over a pretty vast amount of subsystems, of another layer of 
> code.

I am not clear what problem you have.

Is it the sprinkling the code that takes and removes the lock?  Just
the VFS needs to be involved with that.  It is a slightly larger
surface area than doing the work inside the file operations as we
sometimes call the same method from 3-4 different places but it is
definitely a bounded problem.

Is it putting in the handful lines per subsystem to actually use this
functionality?  At that level something generic that is maintained
outside of the subsystem is better than the mess we have with 4-5
different implementations in the subsystems that need it, each having
a different assortment of bugs.

>> I thought of doing something more uniform to user space.  But I observed
>> that the existing epoll punts on the case of a file descriptor being closed
>> and locking to go from a file to the other epoll datastructures is pretty
>> horrid I said forget it and used the existing close behaviour.
>
> Well, you cannot rely on the caller to tidy up the epoll fd by issuing an 
> epoll_ctl(DEL), so you do *need* to "punt" on close in order to not leave 
> lingering crap around. You cannot even hold a reference of the file, since 
> otherwise the epoll hooking will have to trigger not only at ->release() 
> time, but at every close, where you'll have to figure out if this is the 
> last real userspace reference or not. Plus all the issues related to 
> holding permanent extra references to userspace files.
> And since a file can be added in many epoll devices, you need to 
> unregister it from all of them (hence the other datastructures lookup). 
> Better this, on the slow path, with locks acquired only in the epoll usage 
> case, than some other thing and on the fast path, for every file.

Sure, and that is largely and I am preserving those semantics.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
