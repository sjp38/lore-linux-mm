Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2826B0005
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 12:41:14 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id d32so14799865qgd.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 09:41:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e7si14075071qkb.94.2016.02.26.09.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 09:41:13 -0800 (PST)
Message-ID: <56D08E33.2080100@redhat.com>
Date: Fri, 26 Feb 2016 12:41:07 -0500
From: lwoodman@redhat.com
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: fork on processes with lots of memory
References: <20160126160641.GA530@qarx.de> <20160126162853.GA1836@qarx.de> <alpine.LSU.2.11.1601271905210.2349@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1601271905210.2349@eggly.anvils>
Content-Type: multipart/mixed;
 boundary="------------080009060704040005080706"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Felix von Leitner <felix-linuxkernel@fefe.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------080009060704040005080706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 01/27/2016 10:09 PM, Hugh Dickins wrote:
> On Tue, 26 Jan 2016, Felix von Leitner wrote:
>>> Dear Linux kernel devs,
>>> I talked to someone who uses large Linux based hardware to run a
>>> process with huge memory requirements (think 4 GB), and he told me that
>>> if they do a fork() syscall on that process, the whole system comes to
>>> standstill. And not just for a second or two. He said they measured a 45
>>> minute (!) delay before the system became responsive again.
>> I'm sorry, I meant 4 TB not 4 GB.
>> I'm not used to working with that kind of memory sizes.
>>
>>> Their working theory is that all the pages need to be marked copy-on-write
>>> in both processes, and if you touch one page, a copy needs to be made,
>>> and than just takes a while if you have a billion pages.
>>> I was wondering if there is any advice for such situations from the
>>> memory management people on this list.
>>> In this case the fork was for an execve afterwards, but I was going to
>>> recommend fork to them for something else that can not be tricked around
>>> with vfork.
>>> Can anyone comment on whether the 45 minute number sounds like it could
>>> be real? When I heard it, I was flabberghasted. But the other person
>>> swore it was real. Can a fork cause this much of a delay? Is there a way
>>> to work around it?
>>> I was going to recommend the fork to create a boundary between the
>>> processes, so that you can recover from memory corruption in one
>>> process. In fact, after the fork I would want to munmap almost all of
>>> the shared pages anyway, but there is no way to tell fork that.
> You might find madvise(addr, length, MADV_DONTFORK) helpful:
> that tells fork not to duplicate the given range in the child.
>
> Hugh

I dont know exactly what program they are running but we test RHEL with 
up to 24TB
of memory and have not seen this problem.  I have mmap()'d 12TB of 
memory into a
parent process private, touched every page then forked a child which 
wrote to every
page thereby incurring tons of ZFOD and COW faults.  It takes a while to 
process the
6 billion faults but the system didnt come to a halt.  The time I do see 
significant pauses
is when we overcommit RAM and swap space and get into an OOMkill storm.

Attached is the program:

>
>>> Thanks,
>>> Felix
>>> PS: Please put me on Cc if you reply, I'm not subscribed to this mailing
>>> list.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--------------080009060704040005080706
Content-Type: text/plain; charset=UTF-8;
 name="forkoff.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="forkoff.c"

#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <errno.h>
#include <stdio.h>
main(int argc,char *argv[])
{
	unsigned long siz, procs, itterations, cow;
	char	*ptr1;
	char	*i;
	int	pid, j, k, status;

	if ((argc <= 1)||(argc >4)) {
		printf("bad args, usage: forkoff <memsize-in-GB> #children #itterations cow:0|1\n");
		exit(-1);
	}
	siz = ((long)atol(argv[1])*1024*1024*1024);
	procs = atol(argv[2]);
	itterations = atol(argv[3]);
	cow = atol(argv[4]);
	printf("mmaping %ld anonymous bytes\n", siz); 
	ptr1 = (char *)mmap((void *)0,siz,PROT_READ|PROT_WRITE,MAP_ANONYMOUS|MAP_PRIVATE,-1,0);
	if (ptr1 == (char *)-1) {
		printf("ptr1 = %lx\n", ptr1);
		perror("");
	}
	if (cow) {
		printf("priming parent for child COW faults\n");
		// This will cause the ZFOD faults in the parent & COW faults in the children.
		for (i=ptr1; i<ptr1+siz-1; i+=4096)
			*i=(char)'i';
	}
	printf("forking %ld processes\n", procs);
	k = procs;
	do{
		pid = fork();
		if (pid == -1) {
			printf("fork failure\n");
			exit(-1);
		} else if (!pid) {
			printf("PID %d touching %d pages\n", getpid(), siz/4096);
			// This will ZFOD fault if the parent didnt otherwise it will COW fault.
			for (j=0; j<itterations; j++) {
				for (i=ptr1; i<ptr1+siz-1; i+=4096) {
						*i=(char)'i';
				}
			}
			printf("All done, exiting\n");
			exit(0);
		}
	
	} while(--k);

	while (procs-- && wait(&status));	
}

--------------080009060704040005080706--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
