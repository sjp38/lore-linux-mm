Received: from skynet.csn.ul.ie (skynet [136.201.105.2])
	by holly.csn.ul.ie (Postfix) with ESMTP id F21242B67E
	for <linux-mm@kvack.org>; Tue, 25 Sep 2001 16:19:49 +0100 (IST)
Received: from localhost (localhost [127.0.0.1])
	by skynet.csn.ul.ie (Postfix) with ESMTP id 929B4E8A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2001 16:19:49 +0100 (IST)
Date: Tue, 25 Sep 2001 16:19:49 +0100 (IST)
From: Mel <mel@csn.ul.ie>
Subject: When is oom_kill in 2.4.10?
Message-ID: <Pine.LNX.4.32.0109251536010.22098-100000@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm still getting to grips on various parts of the VM even if that usually
means trying to decipher discussions on the main kernel-list so pardon me
if this comes across as excessively clueless.

I was looking briefly at when oom_kill gets called in 2.4.10 and have
found that it doesn't appear to be called from anywhere.

In 2.4.9, we had the kswapd loop to do something like

for eternity do
  once a second calculate VM statistics

  do_try_to_free_pages()

  if there is still a shortage
    if out_of_memory() then oom_kill()
  end if

end for

fine, thats straight forward enough. In 2.4.10, it has changed to

for eternity do
  put kswapd on the wait queue

  /* We can sleep when no zone needs to be balanced.
  if kswapd_can_sleep() then schedule();

  /* We are woken up when we run out of pages in a particular zone.... I
   * think
   */
  remove kswapd from the wait queue

  kswapd_balance()
  run_task_queue(&tq_disk); /* Flush dirty buffers to disk and free them
                             * from the buffer cache if possible? Not
                             * positive, I'm guessing because so many fs
                             * related code appears to add it'self to the
                             * tq_disk wait queue
                             */
next

I still get parts of that although it's only in the last two days I've
managed to read any decent amount of the code. I still can't see where
oom_kill gets called. Is it a case that 2.4.10 will never admit it's out
of memory and endlessly try to flush buffers or am I missing something
thats obvious to a VM guru?

If this is a really dim question, flame me off-list.

--
		Mel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
