Received: from scsfmr101.sc.intel.com (scsfmr101.sc.intel.com [10.3.253.10])
	by scsfmr004.sc.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id j7OJTamk024147
	for <linux-mm@kvack.org>; Wed, 24 Aug 2005 19:29:36 GMT
Received: from laptop.localdomain (vpn-10-3-132-228.sc.intel.com [10.3.132.228])
	by scsfmr101.sc.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id j7OJL8SR019334
	for <linux-mm@kvack.org>; Wed, 24 Aug 2005 19:21:09 GMT
Received: from laptop.localdomain (laptop.localdomain [127.0.0.1])
	by laptop.localdomain (8.13.1/8.13.1) with ESMTP id j7OIE9pT007009
	for <linux-mm@kvack.org>; Wed, 24 Aug 2005 14:14:09 -0400
Received: (from bcrl@localhost)
	by laptop.localdomain (8.13.1/8.13.1/Submit) id j7OIE9lf007006
	for linux-mm@kvack.org; Wed, 24 Aug 2005 14:14:09 -0400
Date: Wed, 24 Aug 2005 14:14:09 -0400
From: Benjamin LaHaise <bcrl@linux.intel.com>
Subject: [fucillo@intersystems.com: process creation time increases linearly with shmem]
Message-ID: <20050824181409.GC6932@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

----- Forwarded message from Ray Fucillo <fucillo@intersystems.com> -----

Subject: process creation time increases linearly with shmem
From: Ray Fucillo <fucillo@intersystems.com>
To: linux-kernel@vger.kernel.org
Date: 	Wed, 24 Aug 2005 14:43:29 -0400
Resent-Message-Id: <200508241914.j7OJE7wm027367@orsfmr002.jf.intel.com>
Resent-Sender: Benjamin LaHaise <bcrl@kvack.org>
Resent-From: bcrl@kvack.org
Resent-Date: Wed, 24 Aug 2005 15:13:51 -0400
Resent-To: bcrl@linux.intel.com

I am seeing process creation time increase linearly with the size of the 
shared memory segment that the parent touches.  The attached forktest.c 
is a very simple user program that illustrates this behavior, which I 
have tested on various kernel versions from 2.4 through 2.6.  Is this a 
known issue, and is it solvable?

TIA,
Ray

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/time.h>
#include <errno.h>
#include <sys/shm.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <signal.h>

#define MAXJOBS 50
#define MAXMALLOC 1024

#define USESIGCHLDHND
/* USESIGCHLDHND feature code changes how the parent waits
   for the children.  When this feature code is on we define
   a signal handler for SIGCHLD and call waitpid to clean up
   the child process.  If this feature code is off, we wait
   until all children are forked and then loop through the 
   array of child pids and call waitpid() on each.  The
   purpose of this feature code was to see if there is any
   difference in timing based on cleaning up zombies faster.
   Test have shown no appreciable difference.  */

/* Return a floating point number of seconds since the start
   time in the timeval structure pointed to by starttv */
float elapsedtime(struct timeval *starttv) {
	struct timeval currenttime;
	gettimeofday(&currenttime,NULL);
	return ((currenttime.tv_sec - starttv->tv_sec) +
	       ((float)(currenttime.tv_usec - starttv->tv_usec)/1000000));
}

#ifdef USESIGCHLDHND
int childexitcnt = 0;
void sigchldhnd(int signum) {
	if (waitpid(-1,NULL,WNOHANG)) ++childexitcnt;
	return;
}
#endif

int main(void) {
	pid_t childpid[MAXJOBS];
	int x,i;
	int childcnt = 0;
        float endfork, endwait;
	struct shmid_ds myshmid_ds;
	unsigned int mb;
	int myshmid;
	key_t mykey = 0xf00df00d;
	char *mymem = 0;
	struct timeval starttime;
#ifdef USESIGCHLDHND
	struct sigaction sa;
	sa.sa_handler = sigchldhnd;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_RESTART;
	if (sigaction(SIGCHLD, &sa, NULL) == -1) {
	   printf("sigaction() failed, errno %d - exiting\n",errno);
	   exit(1);
	}
#endif
        printf("\nNumber of jobs to fork (max %d):  ",MAXJOBS);
        scanf("%d",&x);
        if ((x < 1) || (x > MAXJOBS)) {
           printf("\ninvalid input - exiting\n");
           exit(1);
        }
        printf("\nNumber of MB to allocate (0-%d):  ",MAXMALLOC);
        scanf("%d",&mb);
        if (mb > MAXMALLOC) {
           printf("\ninvalid input - exiting\n");
           exit(1);
        }
	/* allocate and initialize shared memory if number
	   of MB is not zero */
	if (mb) {
	   myshmid = shmget(mykey,mb*1024*1024,IPC_CREAT|0777);
	   if (myshmid == -1) {
	      printf("\nshmget() failed, errno %d. - exiting\n",errno);
	      exit(1);
	   }
	   mymem = (char *) shmat(myshmid,0,0);
	   if (mymem == (char *) -1) {
	      printf("\nshmat() failed, errno %d. - exiting\n",errno);
	      exit(1);
	   }
	   if (shmctl(myshmid,IPC_STAT,&myshmid_ds)) {
	      printf("\nshmctl() failed, errno %d. - exiting\n",errno);
	      exit(1);
	   }
	   /* write a pattern in the new shmem segment*/
	   for (i=0; i < (mb*1024*1024); i+=32) mymem[i]='R';
	}	
	printf("\nStarting %d jobs.  time:0.0", x);
	fflush(stdout);
	gettimeofday(&starttime,NULL); 
	for (i=0; i<x; i++) {
	   childpid[i] = fork();
	   if (!childpid[i]) {
	      /* child process */
	      printf("\n - Child %d         time:%f",i,elapsedtime(&starttime));
	      exit(1);
	   } else if (childpid[i] == -1) {
	      /* failure */
	      printf("\nfork failed, errno = %d");
	   } else childcnt++;
	}
	endfork = elapsedtime(&starttime);
#ifndef USESIGCHLDHND
	for (i=0; i<x; i++) waitpid(childpid[i],0,0);
#else
	while (childexitcnt < childcnt) {
	   if (waitpid(-1,NULL,0)) ++childexitcnt;
	}
#endif	   
	endwait = elapsedtime(&starttime);
	printf("\nTime to fork all processes in seconds: %f", endfork);
        printf("\nTime for all processes to complete: %f\n", endwait);

	/* kill shmem segment */
	if ((mb) && (shmctl(myshmid,IPC_RMID,&myshmid_ds))) {
	   printf("\nshmctl() failed, errno %d. - exiting\n",errno);
	   exit(1);
	}
}




----- End forwarded message -----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
