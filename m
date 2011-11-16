Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7ED6B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 00:35:54 -0500 (EST)
Received: by bke17 with SMTP id 17so139982bke.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 21:35:50 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 16 Nov 2011 11:05:49 +0530
Message-ID: <CAJ8eaTzOtgMzcZeRr6f=+WhtsykK1NZraOGBPoqGncwcAGcTyQ@mail.gmail.com>
Subject: Crash when memset of shared mapped memory in ARM
From: naveen yadav <yad.naveen@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>, linux-mm <linux-mm@kvack.org>, linux-arm-kernel-request@lists.arm.linux.org.uk, linux-arm-kernel@lists.infradead.org, linux-arm-request@lists.arm.linux.org.uk, linux-kernel@vger.kernel.org

Hi All,

I am running below Test program on ARM cortex a9/a8 on kernel version
2.6.35.14 as well as on 3.0.

Please find the test case where:

1. Create shared memory object using shm_open(If we use normal open
then no problem only problem with shm_open)

2. ftruncate to given size

3. memory map the shared object to given memory address ( I haved
tested without MAP_SHARED, MAP_FIXED as well, problem exist)

4. Memset the shared memory (got page fault when accessing the second page)




Observation: Only observed in ARM ( i.e not present in MIPS and X86)


#undef NDEBUG
#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <errno.h>
#include <pthread.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/mman.h>

enum {
 SHM_INIT,
 SHM_GET
 };

enum {
 PARENT,
 CHILD
 };

#define FIXED_MMAP_ADDR 0x20000000
#define MMAP_SIZE	0x10000

static int shmid;
static char shm_name[100];
static int sleep_period = 100000;
void * shmem_init(int flag)
{	
	int start = FIXED_MMAP_ADDR;
	int memory_size = MMAP_SIZE;
	int mode = 0666;
	void *addr;
	int ret;
	sprintf(shm_name, "/shmem_1234");
	shmid = shm_open (shm_name, O_RDWR | O_EXCL | O_CREAT | O_TRUNC, mode);
	if (shmid < 0) {
    		if (errno == EEXIST) {
			printf ("shm_open: %s\n", strerror(errno));
       			shmid = shm_open (shm_name, O_RDWR, mode);

		} else {
    			printf("failed to shm_open, err=%s\n", strerror(errno));
			return NULL;
  		}
	}
  	ret = fcntl (shmid, F_SETFD, FD_CLOEXEC);
  	if (ret < 0) {
    		printf("fcntl: %s\n", strerror(errno));
		return NULL;
  	}
	ret = ftruncate (shmid, memory_size);
	if (ret < 0) {
    		printf("ftruncate: %s\n", strerror(errno));
		return NULL;
  	}
	addr = mmap ((void *)start, memory_size, PROT_READ | PROT_WRITE,
 			     MAP_SHARED | MAP_FIXED, shmid, 0);
  	if (addr == MAP_FAILED) {
		printf ("mmap: %s\n", strerror(errno));
     		close (shmid);
    		shm_unlink (shm_name);
		return NULL;
	}
	
	if (flag == SHM_INIT){
		printf ("mmap: addr %p\n", addr);
		/* memset on arm creates a unhandled page fault, works fine on mips */
		memset(addr, 0, memory_size);
	}
	return (void *)addr;
}

pthread_mutex_t * shmem_mutex_init(int flag)
{
	pthread_mutex_t * pmutex = (pthread_mutex_t *)shmem_init(flag);
#if 0
	pthread_mutexattr_t attr;
	if (flag == SHM_INIT) {
		pthread_mutexattr_init (&attr);
		pthread_mutexattr_setpshared (&attr, PTHREAD_PROCESS_SHARED);
		pthread_mutexattr_setprotocol (&attr, PTHREAD_PRIO_INHERIT);
		pthread_mutexattr_setrobust_np (&attr,
 						PTHREAD_MUTEX_STALLED_NP);
		pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_ERRORCHECK);
		if (pthread_mutex_init (pmutex, &attr) != 0) {
    			printf("Init mutex failed, err=%s\n", strerror(errno));
			pthread_mutexattr_destroy (&attr);
			return NULL;
		}
	}
#endif
	return pmutex;
}

void long_running_task(int flag)
{	
	static int counter = 0;
	if (flag == PARENT)
 		usleep(5*sleep_period);
	else
		usleep(3*sleep_period);
	counter = (counter + 1) % 100;
	printf("%d: completed %d computing\n", getpid(), counter);
}

void sig_handler(int signum)
{
	close(shmid);
	shm_unlink(shm_name);
	exit(0);
}

int main(int argc, char *argv[])
{
	pthread_mutex_t *mutex_parent, *mutex_child;
//	signal(SIGUSR1, sig_handler);
//	if (fork()) {
		/* parent process */
		if ((mutex_parent = shmem_mutex_init(SHM_INIT)) == NULL) {
			printf("failed to get the shmem_mutex\n");
			exit(-1);
		}
#if 0
		while (1) {
			printf("%d: try to hold the lock\n", getpid());
 			pthread_mutex_lock(mutex_parent);
			printf("%d: got the lock\n", getpid());
 			long_running_task(PARENT);
			pthread_mutex_unlock(mutex_parent);
			printf("%d: released the lock\n", getpid());
		}
#endif
//	} else {
#if 0
		/* child process */
		usleep(sleep_period);
		if ((mutex_child = shmem_mutex_init(SHM_GET)) == NULL) {
			printf("failed to get the shmem_mutex\n");
			exit(-1);
		}
		while (1) {
			printf("%d: try to hold the lock\n", getpid());
 			pthread_mutex_lock(mutex_child);
			printf("%d: got the lock\n", getpid());
 			long_running_task(CHILD);
			pthread_mutex_unlock(mutex_child);
			printf("%d: released the lock\n", getpid());
		}
#endif
//	}
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
