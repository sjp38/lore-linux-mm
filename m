Subject: Re: New Memory Test Suite v0.0.1
References: <yttya60l9r8.fsf@vexeta.dc.fi.udc.es>
From: Christoph Rohland <cr@sap.com>
Date: 27 Apr 2000 19:57:45 +0200
In-Reply-To: "Juan J. Quintela"'s message of "27 Apr 2000 01:31:39 +0200"
Message-ID: <qww3do71l5y.fsf@sap.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-=-=

"Juan J. Quintela" <quintela@fi.udc.es> writes:
> Any comments/suggestions/code are welcome.

Here comes my shm test proggy.

Greetings
		Christoph


--=-=-=
Content-Disposition: attachment; filename=ipctst.c

#include <stdlib.h>
#include <stdio.h>

#include <errno.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>

int main (int ac, char **av) {
	int segs, size, proc, rmpr;
	unsigned long long iter;
	struct shmid_ds buf;
	pid_t pid;

	if (ac < 6) {
		printf ("usage: shmtst segs size proc iter rm%%\n");
		exit (1);
	}
	segs = atoi (av[1]);
	size = atoi (av[2]);
	proc = atoi (av[3]);
	iter = atoi (av[4]);
	rmpr = atoi (av[5]);

	iter = 1 << iter;
	printf ("using %d segs of size %d (%llu iterations)\n", 
		segs, size, iter);
	while (-- proc) {
		if ((pid = fork()) > 0) {
			printf ("started process %d\n", (int) pid);
		} else {
			break;
		}
	}
	srandom (getpid());
	while (iter--) {
		key_t key;
		int seg, i, rm;
		unsigned char c, *ptr;
		volatile unsigned char *p;

		key = random() % segs +1;
		if ((seg = shmget (key, size, IPC_CREAT| 0600)) == -1) {
			perror("shmget");
			if (errno != EIDRM && errno != ENOSPC)
				exit (1);
			continue;
		}
		if (1) sched_yield();
		if ((ptr = shmat (seg, 0, 0)) == (unsigned char *) -1) {
			perror ("shmat");
			continue;
		}
		if (random () % 100 < rmpr) {
			if (random() % 1)
				rm = 1;
			else
				rm = -1;
		} else {
			rm = 0;
		}

		if (rm < 0 &&
		    shmctl (seg, IPC_RMID, NULL) == -1) 
			perror("pre: shmctl IPC_RMID");
		for (p = ptr; p < ptr + size; p += 4097)
			*p = (unsigned char) (p - ptr);
		for (p = ptr; p < ptr + size; p += 4097) {
			c = *p;
			if (c == (unsigned char)(p-ptr)) 
				continue;
			shmctl (seg, IPC_STAT, &buf);
			printf ("n=%i, m = %i: %i != %i", (int) buf.shm_nattch,
				(int)buf.shm_perm.mode,
				(int)(unsigned char)(p-ptr), (int) c);
			for (i = 0 ; i < 5; i++) {
				printf (", %i", (int)*p);
				sched_yield();
			}
			printf ("\n");
		}

		if (shmdt (ptr) != 0) {
			perror("shmdt");
			exit (1);
		}

		if (rm > 0 &&
		    shmctl (seg, IPC_RMID, NULL) == -1) 
			perror("post shmctl IPC_RMID");
	}
}	

--=-=-=--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
