Received: from mail.ccr.net (ccr@alogconduit1am.ccr.net [208.130.159.13])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA19469
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 21:19:46 -0500
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
References: <199811261236.MAA14785@dax.scot.redhat.com> 	<Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com> 	<199811271602.QAA00642@dax.scot.redhat.com> 	<m1ogpsp93f.fsf@flinx.ccr.net> <199811301113.LAA02870@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 Nov 1998 15:40:18 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 30 Nov 1998 11:13:44 GMT"
Message-ID: <m1r9uk97wc.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> Looks like I have a handle on what's wrong with the 2.1.130 vm (in
ST> particular, its tendency to cache too much at the expense of
ST> swapping).

>> I really should look and play with this but I have one question.

>> Why does it make sense when we want memory, to write every page
>> we can to swap before we free any memory?

ST> What makes you think we do?

Reading the code, and a test I just performed.
The limit on the page cache size appears to be the only thing that throttles
this at all.

ST> 2.1.130 tries to shrink cache until a shrink_mmap() pass fails.  Then it
ST> gives the swapper a chance, swapping a batch of pages and unlinking them
ST> from the ptes.  The pages so release still stay in the page cache at
ST> this point, btw, and will be picked up again from memory if they get
ST> referenced before the page finally gets discarded.  We then go back to
ST> shrink_mmap(), hopefully with a larger population of recyclable pages as
ST> a result of the swapout, and we start using that again.

ST> We only run one batch of swapouts before returning to shrink_mmap.

As has been noted elsewhere the size of a batch of swapouts appears to be
controlled by chance.  So it has not boundary on worst case behavior.

I have just performed a small test based upon my observations of the code.
The practical result of this appears to be that we spend way to much time
in kswapd.

This is my test program. 
When it runs it takes kswapd takes 30%-50% of the processor.
Memory is maxed out.
And it's resident set size gets absolutely huge. 12M on a 32M box.

I won't argue that all of this is broken but I will say that this does seen
to be a little too much time spent in the swap_out routines.

Further this program takes about 0.02 seconds if the write to memory
is disabled.

0.08user 56.68system 3:36.40elapsed 26%CPU (0avgtext+0avgdata 0maxresident)k
0inputs+0outputs (6936major+32788minor)pagefaults 30430swaps

#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdlib.h>

#define PAGE_SIZE 4096
#define GET_SIZE (128*1024*1024)

int main(int argc, char **argv)
{
	char *buffer;
	int i;
	buffer = mmap(NULL, GET_SIZE, PROT_WRITE | PROT_READ | PROT_EXEC,
		      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	for(i = 0; i < GET_SIZE; i+= PAGE_SIZE) {
		buffer[i] = '\0';
	}
	return 0;

}


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
