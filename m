Message-ID: <32781.194.247.51.251.1021567466.squirrel@lbbrown.homeip.net>
Date: Thu, 16 May 2002 17:44:26 +0100 (BST)
Subject: Re: [RFC][PATCH] iowait statistics
From: "Leigh Brown" <leigh@solinno.co.uk>
In-Reply-To: <Pine.LNX.4.44L.0205161149180.32261-100000@imladris.surriel.com>
References: <Pine.LNX.4.44L.0205161149180.32261-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Today, Rik van Riel wrote:
> On Thu, 16 May 2002, Leigh Brown wrote:
>
>> I've tried this patch against Red Hat's 2.4.18 kernel on my laptop,
>> and patched top to display the results.  It certainly seems to be
>> working correctly running a few little contrived tests.
>
> Cool, could you please post the patch to top so other people
> can enjoy it too ? ;)

I'd call it a hack rather than a patch.  I might be able to look at
it later.

[...]
>> CPU states: 0.3% user,  8.9% system,  0.0% nice, 77.2% idle, 13.3%
>> wait
>>
>> I'm not sure if that can be explained by the way the raw I/O stuff
>> works, or because I'm running it against 2.4.  Anyway, overall it's
>> looking good.
>
> Most likely the patch forgets to increment nr_iowait_tasks in
> some raw IO code path...

Ah yes, could this be it?  It makes the output look right:

--- linux-2.4.18-3/fs/iobuf.c	Fri Apr 27 22:23:25 2001
+++ linux-2.4.18-5/fs/iobuf.c	Thu May 16 16:07:32 2002
@@ -136,7 +136,9 @@
 	set_task_state(tsk, TASK_UNINTERRUPTIBLE);
 	if (atomic_read(&kiobuf->io_count) != 0) {

	run_task_queue(&tq_disk);
+
	atomic_inc(&nr_iowait_tasks);

	schedule();
+
	atomic_dec(&nr_iowait_tasks);

	if (atomic_read(&kiobuf->io_count) != 0)

		goto repeat;
 	}


Cheers,

Leigh.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
