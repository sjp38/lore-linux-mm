Date: Wed, 20 Sep 2006 10:53:17 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
Message-Id: <20060920105317.7c3eb5f4.akpm@osdl.org>
In-Reply-To: <1158735299.6002.273.camel@localhost.localdomain>
References: <1158274508.14473.88.camel@localhost.localdomain>
	<20060915001151.75f9a71b.akpm@osdl.org>
	<45107ECE.5040603@google.com>
	<1158709835.6002.203.camel@localhost.localdomain>
	<1158710712.6002.216.camel@localhost.localdomain>
	<20060919172105.bad4a89e.akpm@osdl.org>
	<1158717429.6002.231.camel@localhost.localdomain>
	<20060919200533.2874ce36.akpm@osdl.org>
	<1158728665.6002.262.camel@localhost.localdomain>
	<20060919222656.52fadf3c.akpm@osdl.org>
	<1158735299.6002.273.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Mike Waychison <mikew@google.com>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2006 16:54:59 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> > It's a choice between two behaviours:
> > 
> > a) get stuck in the kernel until someone kills you and
> > 
> > b) fault the page in and proceed as expected.
> > 
> > Option b) is better, no?
> 
> That's what I don't understand... where is the actual race that can
> cause the livelock you are mentioning.

Suppose a program (let's call it "DoS") is written which sits in a loop
doing fadvise(FADV_DONTNEED) against some parts of /lib/libc.so.

Now suppose another process (let's call it "bash") tries to execute that
page.  bash will take a major fault, will submit a read and then it will do
wait_on_page().  I/O completes and the page comes unlocked.  Now there is a
time window in which DoS can shoot that page down again.  And it's quite a
lengthy window - bash need to wake up, get scheduled, take mmap_sem, return
to do_page_fault(), redo the vma lookup and the pagetable walk and the
pagecache lookup.

That's plenty of time in which DoS can shoot down the page again. 
Particularly since every other program in the machine is stuck in disk wait
in its pagefault handler ;)

All of this will cause bash to get permanently stuck in the kernel.  And I
don't think it's acceptable to just allow bash to be killed off:

- one would need a statically-linked shell to be able to do this.

- if one didn't kill off DoS first, it wouldn't help.  A statically
  linked `ps' is also needed.

- having to kill off sshd, xinetd, httpd, etc isn't a very happy solution.

- you can't kill off /sbin/init.


So I think there's a nasty DoS here if we permit infinite retries.  But
it's not just that - there might be other situations under really heavy
memory pressure where livelocks like this can occur.  It's just a general
robustness-of-implementation issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
