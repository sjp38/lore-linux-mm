Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mA4IiGHI000868
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 11:44:16 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA4Iic48149868
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 11:44:38 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA4Ii8Pn005398
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 11:44:09 -0700
Date: Tue, 4 Nov 2008 12:44:36 -0600
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v8][PATCH 0/12] Kernel based checkpoint/restart
Message-ID: <20081104184436.GA16328@us.ibm.com>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Quoting Oren Laadan (orenl@cs.columbia.edu):
> Basic checkpoint-restart [C/R]: v8 adds support for "external" checkpoint
> and improves documentation. Older announcements below.

The following test-program seems to reliably trigger a bug.  Run it in a
new set of namespaces, i.e.
	ns_exec -cmpiuU ./runme > /tmp/o
then control-c it.  The second time I do that, I get the dcache.c:666
BUG().

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/syscall.h>

#define __NR_checkpoint 333
int main (int argc, char *argv[])
{
	pid_t pid = getpid();
	int ret;

	close(0); close(2);
	ret = syscall (__NR_checkpoint, pid, STDOUT_FILENO, 0);

	if (ret < 0)
		perror ("checkpoint");
	else
		printf ("checkpoint id %d\n", ret);

	sleep(200);
	return (ret > 0 ? 0 : 1);
}

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
