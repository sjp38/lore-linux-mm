Message-ID: <47BD7648.5010309@bull.net>
Date: Thu, 21 Feb 2008 14:02:00 +0100
From: Nadia Derbey <Nadia.Derbey@bull.net>
MIME-Version: 1.0
Subject: Re: [LTP] [PATCH 1/8] Scaling msgmni to the amount of lowmem
References: <20080211141646.948191000@bull.net>	 <20080211141813.354484000@bull.net>	 <20080215215916.8566d337.akpm@linux-foundation.org>	 <47B94D8C.8040605@bull.net>  <47B9835A.3060507@bull.net>	 <1203411055.4612.5.camel@subratamodak.linux.ibm.com>	 <47BB0EDC.5000002@bull.net> <1203459418.7408.39.camel@localhost.localdomain> <47BD705A.9020309@bull.net>
In-Reply-To: <47BD705A.9020309@bull.net>
Content-Type: multipart/mixed;
 boundary="------------020009030007010503080503"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>
Cc: Matt Helsley <matthltc@us.ibm.com>, subrata@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, ltp-list@lists.sourceforge.net, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmm@us.ibm.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020009030007010503080503
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nadia Derbey wrote:
> Matt Helsley wrote:
> 
>> On Tue, 2008-02-19 at 18:16 +0100, Nadia Derbey wrote:
>>
>> <snip>
>>
>>> +#define MAX_MSGQUEUES  16      /* MSGMNI as defined in linux/msg.h */
>>> +
>>
>>
>>
>> It's not quite the maximum anymore, is it? More like the minumum
>> maximum ;). A better name might better document what the test is
>> actually trying to do.
>>
>> One question I have is whether the unpatched test is still valuable.
>> Based on my limited knowledge of the test I suspect it's still a correct
>> test of message queues. If so, perhaps renaming the old test (so it's
>> not confused with a performance regression) and adding your patched
>> version is best?
>>
> 
> So, here's the new patch based on Matt's points.
> 
> Subrata, it has to be applied on top of the original ltp-full-20080131. 
> Please tell me if you'd prefer one based on the merged version you've 
> got (i.e. with my Tuesday patch applied).
> 

Forgot the patch, sorry for that (thx Andrew).

Regards,
Nadia


--------------020009030007010503080503
Content-Type: text/x-patch;
 name="ipc_ltp_full_20080131.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipc_ltp_full_20080131.patch"

Since msgmni now scales to the memory size, it may reach big values.
To avoid forking 2*msgmni processes and create msgmni msg queues, take the min
between the procfs value and MSGMNI (as found in linux/msg.h).

Also fixed the Makefiles in ipc/lib and ipc/msgctl: there was no dependency
on the lib/ipc*.h header files.

Also integrated the following in libipc.a:
  . get_max_msgqueues()
  . get_used_msgqueues()

Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>

---
 testcases/kernel/syscalls/ipc/lib/Makefile      |    3 
 testcases/kernel/syscalls/ipc/lib/ipcmsg.h      |    7 
 testcases/kernel/syscalls/ipc/lib/libipc.c      |   54 +
 testcases/kernel/syscalls/ipc/msgctl/Makefile   |    3 
 testcases/kernel/syscalls/ipc/msgctl/msgctl08.c |   63 --
 testcases/kernel/syscalls/ipc/msgctl/msgctl09.c |   62 --
 testcases/kernel/syscalls/ipc/msgctl/msgctl10.c |  527 ++++++++++++++++++
 testcases/kernel/syscalls/ipc/msgctl/msgctl11.c |  696 ++++++++++++++++++++++++
 testcases/kernel/syscalls/ipc/msgget/Makefile   |    3 
 testcases/kernel/syscalls/ipc/msgget/msgget03.c |   22 
 10 files changed, 1326 insertions(+), 114 deletions(-)

Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/ipcmsg.h
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/lib/ipcmsg.h	2008-02-21 10:45:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/ipcmsg.h	2008-02-21 14:09:00.000000000 +0100
@@ -41,6 +41,10 @@ void setup(void);
 #define MSGSIZE	1024		/* a resonable size for a message */
 #define MSGTYPE 1		/* a type ID for a message */
 
+#define NR_MSGQUEUES	16	/* MSGMNI as defined in linux/msg.h */
+
+#define min(a, b)	(((a) < (b)) ? (a) : (b))
+
 typedef struct mbuf {		/* a generic message structure */
 	long mtype;
 	char mtext[MSGSIZE + 1];  /* add 1 here so the message can be 1024   */
@@ -59,4 +63,7 @@ void rm_queue(int);
 int getipckey();
 int getuserid(char *);
 
+int get_max_msgqueues(void);
+int get_used_msgqueues(void);
+
 #endif /* ipcmsg.h */
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/libipc.c
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/lib/libipc.c	2008-02-21 10:45:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/libipc.c	2008-02-21 13:35:41.000000000 +0100
@@ -201,3 +201,57 @@ rm_shm(int shm_id)
 		tst_resm(TINFO, "id = %d", shm_id);
 	}
 }
+
+#define BUFSIZE 512
+
+/*
+ * Get the number of message queues already in use
+ */
+int
+get_used_msgqueues()
+{
+	FILE *f;
+	int used_queues;
+	char buff[BUFSIZE];
+
+	f = popen("ipcs -q", "r");
+	if (!f) {
+		tst_resm(TBROK, "Could not run 'ipcs' to calculate used "
+			"message queues");
+		tst_exit();
+	}
+	/* FIXME: Start at -4 because ipcs prints four lines of header */
+	for (used_queues = -4; fgets(buff, BUFSIZE, f); used_queues++)
+		;
+	pclose(f);
+	if (used_queues < 0) {
+		tst_resm(TBROK, "Could not read output of 'ipcs' to "
+			"calculate used message queues");
+		tst_exit();
+	}
+	return used_queues;
+}
+
+/*
+ * Get the max number of message queues allowed on system
+ */
+int
+get_max_msgqueues()
+{
+	FILE *f;
+	char buff[BUFSIZE];
+
+	/* Get the max number of message queues allowed on system */
+	f = fopen("/proc/sys/kernel/msgmni", "r");
+	if (!f) {
+		tst_resm(TBROK, "Could not open /proc/sys/kernel/msgmni");
+		return -1;
+	}
+	if (!fgets(buff, BUFSIZE, f)) {
+		fclose(f);
+		tst_resm(TBROK, "Could not read /proc/sys/kernel/msgmni");
+		return -1;
+	}
+	fclose(f);
+	return atoi(buff);
+}
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl08.c
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/msgctl/msgctl08.c	2008-02-21 10:45:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl08.c	2008-02-21 14:18:23.000000000 +0100
@@ -50,6 +50,7 @@
 #include <sys/msg.h>
 #include "test.h"
 #include "usctest.h"
+#include "ipcmsg.h"
 
 void setup();
 void cleanup();
@@ -454,57 +455,14 @@ sig_handler()
 {
 }
 
-#define BUFSIZE 512
-
-/** Get the number of message queues already in use */
-static int get_used_msgqueues()
-{
-        FILE *f;
-        int used_queues;
-        char buff[BUFSIZE];
-
-        f = popen("ipcs -q", "r");
-        if (!f) {
-                tst_resm(TBROK,"Could not run 'ipcs' to calculate used message queues");
-                tst_exit();
-        }
-        /* FIXME: Start at -4 because ipcs prints four lines of header */
-        for (used_queues = -4; fgets(buff, BUFSIZE, f); used_queues++)
-                ;
-        pclose(f);
-        if (used_queues < 0) {
-                tst_resm(TBROK,"Could not read output of 'ipcs' to calculate used message queues");
-                tst_exit();
-        }
-        return used_queues;
-}
-
-/** Get the max number of message queues allowed on system */
-static int get_max_msgqueues()
-{
-        FILE *f;
-        char buff[BUFSIZE];
-
-        /* Get the max number of message queues allowed on system */
-        f = fopen("/proc/sys/kernel/msgmni", "r");
-        if (!f){
-                tst_resm(TBROK,"Could not open /proc/sys/kernel/msgmni");
-                tst_exit();
-        }
-        if (!fgets(buff, BUFSIZE, f)) {
-                tst_resm(TBROK,"Could not read /proc/sys/kernel/msgmni");
-                tst_exit();
-        }
-        fclose(f);
-        return atoi(buff);
-}
-
 /***************************************************************
  * setup() - performs all ONE TIME setup for this test.
  *****************************************************************/
 void
 setup()
 {
+	int nr_msgqs;
+
 	tst_tmpdir();
  
         /* You will want to enable some signal handling so you can capture
@@ -520,11 +478,22 @@ setup()
 	 */
         TEST_PAUSE;
 
-        MSGMNI = get_max_msgqueues() - get_used_msgqueues();
-	if (MSGMNI <= 0){
+	nr_msgqs = get_max_msgqueues();
+	if (nr_msgqs < 0)
+		cleanup();
+
+	nr_msgqs -= get_used_msgqueues();
+	if (nr_msgqs <= 0){
 		tst_resm(TBROK,"Max number of message queues already used, cannot create more.");
 		cleanup(); 
 	}	
+
+	/*
+	 * Since msgmni scales to the memory size, it may reach huge values
+	 * that are not necessary for this test.
+	 * That's why we define NR_MSGQUEUES as a high boundary for it.
+	 */
+	MSGMNI = min(nr_msgqs, NR_MSGQUEUES);
 }
 
 
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl09.c
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/msgctl/msgctl09.c	2008-02-21 10:45:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl09.c	2008-02-21 13:38:42.000000000 +0100
@@ -49,6 +49,7 @@
 #include <unistd.h>
 #include "test.h"
 #include "usctest.h"
+#include "ipcmsg.h"
 
 #define MAXNREPS	1000
 #ifndef CONFIG_COLDFIRE
@@ -624,57 +625,14 @@ term(int sig)
 	}
 }
 
-#define BUFSIZE 512
-
-/** Get the number of message queues already in use */
-static int get_used_msgqueues()
-{
-        FILE *f;
-        int used_queues;
-        char buff[BUFSIZE];
-
-        f = popen("ipcs -q", "r");
-        if (!f) {
-                tst_resm(TBROK,"Could not run 'ipcs' to calculate used message queues");
-                tst_exit();
-        }
-        /* FIXME: Start at -4 because ipcs prints four lines of header */
-        for (used_queues = -4; fgets(buff, BUFSIZE, f); used_queues++)
-                ;
-        pclose(f);
-        if (used_queues < 0) {
-                tst_resm(TBROK,"Could not read output of 'ipcs' to calculate used message queues");
-                tst_exit();
-        }
-        return used_queues;
-}
-
-/** Get the max number of message queues allowed on system */
-static int get_max_msgqueues()
-{
-        FILE *f;
-        char buff[BUFSIZE];
-
-        /* Get the max number of message queues allowed on system */
-        f = fopen("/proc/sys/kernel/msgmni", "r");
-        if (!f){
-                tst_resm(TBROK,"Could not open /proc/sys/kernel/msgmni");
-                tst_exit();
-        }
-        if (!fgets(buff, BUFSIZE, f)) {
-                tst_resm(TBROK,"Could not read /proc/sys/kernel/msgmni");
-                tst_exit();
-        }
-        fclose(f);
-        return atoi(buff);
-}
-
 /***************************************************************
  * setup() - performs all ONE TIME setup for this test.
  *****************************************************************/
 void
 setup()
 {
+	int nr_msgqs;
+
 	tst_tmpdir();
         /* You will want to enable some signal handling so you can capture
          * unexpected signals like SIGSEGV.
@@ -689,12 +647,22 @@ setup()
          */
         TEST_PAUSE;
 
-        MSGMNI = get_max_msgqueues() - get_used_msgqueues();
-        if (MSGMNI <= 0){
+        nr_msgqs = get_max_msgqueues();
+	if (nr_msgqs < 0)
+		cleanup();
+
+	nr_msgqs -= get_used_msgqueues();
+	if (nr_msgqs <= 0) {
                 tst_resm(TBROK,"Max number of message queues already used, cannot create more.");
                 cleanup();
         }
 
+	/*
+	 * Since msgmni scales to the memory size, it may reach huge values
+	 * that are not necessary for this test.
+	 * That's why we define NR_MSGQUEUES as a high boundary for it.
+	 */
+	MSGMNI = min(nr_msgqs, NR_MSGQUEUES);
 }
 
 
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/msgget/msgget03.c
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/msgget/msgget03.c	2008-02-21 10:45:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgget/msgget03.c	2008-02-21 12:10:25.000000000 +0100
@@ -68,8 +68,6 @@ int exp_enos[] = {ENOSPC, 0};	/* 0 termi
 int *msg_q_arr = NULL;		/* hold the id's that we create */
 int num_queue = 0;		/* count the queues created */
 
-static int get_max_msgqueues();
-
 int main(int ac, char **av)
 {
 	int lc;				/* loop counter */
@@ -121,24 +119,6 @@ int main(int ac, char **av)
 	return(0);
 }
 
-/** Get the max number of message queues allowed on system */
-int get_max_msgqueues()
-{
-        FILE *f;
-        char buff[512];
-
-        /* Get the max number of message queues allowed on system */
-        f = fopen("/proc/sys/kernel/msgmni", "r");
-        if (!f){
-                tst_brkm(TBROK, cleanup, "Could not open /proc/sys/kernel/msgmni");
-        }
-        if (!fgets(buff, 512, f)) {
-                tst_brkm(TBROK, cleanup, "Could not read /proc/sys/kernel/msgmni");
-        }
-        fclose(f);
-        return atoi(buff);
-}
-
 /*
  * setup() - performs all the ONE TIME setup for this test.
  */
@@ -166,6 +146,8 @@ setup(void)
 	msgkey = getipckey();
 
 	maxmsgs = get_max_msgqueues();
+	if (maxmsgs < 0)
+		tst_brkm(TBROK, cleanup, "");
 
 	msg_q_arr = (int *)calloc(maxmsgs, sizeof (int));
 	if (msg_q_arr == NULL) {
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/Makefile
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/lib/Makefile	2008-02-21 10:45:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/Makefile	2008-02-21 12:14:39.000000000 +0100
@@ -19,6 +19,7 @@
 SRCS   = libipc.c
 OBJS   = $(SRCS:.c=.o)
 LIBIPC = ../libipc.a
+LIBIPC_HEADERS = ipcmsg.h ipcsem.h
 
 CFLAGS += -I../../../../../include -Wall
 
@@ -27,6 +28,8 @@ all: $(LIBIPC)
 $(LIBIPC): $(OBJS)
 	$(AR) -rc $@ $(OBJS)
 
+$(OBJS): $(LIBIPC_HEADERS)
+
 install:
 
 clean:
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/Makefile
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/msgctl/Makefile	2008-02-21 10:45:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/Makefile	2008-02-21 14:11:46.000000000 +0100
@@ -18,12 +18,15 @@
 
 CFLAGS += -I../lib -I../../../../../include -Wall
 LDLIBS += -L../../../../../lib -lltp -L.. -lipc
+LIBIPC_HEADERS	= ../lib/ipcmsg.h
 
 SRCS    = $(wildcard *.c)
 TARGETS = $(patsubst %.c,%,$(SRCS))
 
 all: $(TARGETS)
 
+$(TARGETS): $(LIBIPC_HEADERS)
+
 install:
 	@set -e; for i in $(TARGETS); do ln -f $$i ../../../../bin/$$i ; done
 
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl10.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl10.c	2008-02-21 13:56:10.000000000 +0100
@@ -0,0 +1,527 @@
+/*
+ *
+ *   Copyright (c) International Business Machines  Corp., 2002
+ *
+ *   This program is free software;  you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; either version 2 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ *   the GNU General Public License for more details.
+ *
+ *   You should have received a copy of the GNU General Public License
+ *   along with this program;  if not, write to the Free Software
+ *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+/* 06/30/2001	Port to Linux	nsharoff@us.ibm.com */
+/* 11/06/2002   Port to LTP     dbarrera@us.ibm.com */
+
+/*
+ * NAME
+ *	msgctl10
+ *
+ * CALLS
+ *	msgget(2) msgctl(2)
+ *
+ * ALGORITHM
+ *	Get and manipulate a message queue.
+ *	Same as msgctl08 but gets the actual msgmni value under procfs.
+ *
+ * RESTRICTIONS
+ *
+ */
+
+#define _XOPEN_SOURCE 500
+#include <signal.h>
+#include <errno.h>
+#include <string.h>
+#include <fcntl.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <values.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/stat.h>
+#include <sys/ipc.h>
+#include <sys/msg.h>
+#include "test.h"
+#include "usctest.h"
+#include "ipcmsg.h"
+
+void setup();
+void cleanup();
+/*
+ *  *  *  * These globals must be defined in the test.
+ *   *   *   */
+
+
+char *TCID="msgctl10";           /* Test program identifier.    */
+int TST_TOTAL=1;                /* Total number of test cases. */
+extern int Tst_count;           /* Test Case counter for tst_* routines */
+
+int exp_enos[]={0};     /* List must end with 0 */
+
+#ifndef CONFIG_COLDFIRE
+#define MAXNPROCS	1000000  /* This value is set to an arbitrary high limit. */
+#else
+#define MAXNPROCS	 100000   /* Coldfire can't deal with 1000000 */
+#endif
+#define MAXNREPS	100000
+#define FAIL		1
+#define PASS		0
+
+key_t	keyarray[MAXNPROCS];
+
+struct {
+	long	type;
+	struct {
+		char	len;
+		char	pbytes[99];
+		} data;
+	} buffer;
+
+int	pidarray[MAXNPROCS];
+int tid;
+int MSGMNI,nprocs, nreps;
+int procstat;
+int dotest(key_t key, int child_process);
+int doreader(int id, long key, int child);
+int dowriter(int id,long key, int child);
+int fill_buffer(register char *buf, char val, register int size);
+int verify(register char *buf,char val, register int size,int child);
+void sig_handler();             /* signal catching function */
+int mykid;
+#ifdef UCLINUX
+static char *argv0;
+
+void do_child_1_uclinux();
+static key_t key_uclinux;
+static int i_uclinux;
+
+void do_child_2_uclinux();
+static int id_uclinux;
+static int child_process_uclinux;
+#endif
+
+/*-----------------------------------------------------------------*/
+int main(argc, argv)
+int	argc;
+char	*argv[];
+{
+	register int i, j, ok, pid;
+	int count, status;
+	struct sigaction act;
+
+#ifdef UCLINUX
+	char *msg;			/* message returned from parse_opts */
+
+	argv0 = argv[0];
+
+	/* parse standard options */
+	if ((msg = parse_opts(argc, argv, (option_t *)NULL, NULL)) != (char *)NULL)
+	{
+		tst_brkm(TBROK, cleanup, "OPTION PARSING ERROR - %s", msg);
+	}
+
+	maybe_run_child(&do_child_1_uclinux, "ndd", 1, &key_uclinux, &i_uclinux);
+	maybe_run_child(&do_child_2_uclinux, "nddd", 2, &id_uclinux, &key_uclinux,
+			&child_process_uclinux);
+#endif
+
+	setup();
+
+	if (argc == 1 )
+	{
+		/* Set default parameters */
+		nreps = MAXNREPS;
+		nprocs = MSGMNI;
+	}
+	else if (argc == 3 )
+	{
+		if ( atoi(argv[1]) > MAXNREPS )
+		{
+			tst_resm(TCONF,"Requested number of iterations too large, setting to Max. of %d", MAXNREPS);
+			nreps = MAXNREPS;
+		}
+		else
+		{
+			nreps = atoi(argv[1]);
+		}
+		if (atoi(argv[2]) > MSGMNI )
+		{
+			tst_resm(TCONF,"Requested number of processes too large, setting to Max. of %d", MSGMNI);
+			nprocs = MSGMNI;
+		}
+		else
+		{
+			nprocs = atoi(argv[2]);
+		}
+	}
+	else
+	{
+		tst_resm(TCONF," Usage: %s [ number of iterations  number of processes ]", argv[0]);
+		tst_exit();
+	}
+
+	srand(getpid());
+	tid = -1;
+
+	/* Setup signal handleing routine */
+	memset(&act, 0, sizeof(act));
+	act.sa_handler = sig_handler;
+	sigemptyset(&act.sa_mask);
+	sigaddset(&act.sa_mask, SIGTERM);
+	if (sigaction(SIGTERM, &act, NULL) < 0)
+	{
+		tst_resm(TFAIL, "Sigset SIGTERM failed");
+		tst_exit();
+	}
+	/* Set up array of unique keys for use in allocating message
+	 * queues
+	 */
+	for (i = 0; i < nprocs; i++)
+	{
+		ok = 1;
+		do
+		{
+			/* Get random key */
+			keyarray[i] = (key_t)rand();
+			/* Make sure key is unique and not private */
+			if (keyarray[i] == IPC_PRIVATE)
+			{
+				ok = 0;
+				continue;
+			}
+			for (j = 0; j < i; j++)
+			{
+				if (keyarray[j] == keyarray[i])
+				{
+					ok = 0;
+					break;
+				}
+				ok = 1;
+			}
+		} while (ok == 0);
+	}
+
+	/* Fork a number of processes, each of which will
+	 * create a message queue with one reader/writer
+	 * pair which will read and write a number (iterations)
+	 * of random length messages with specific values.
+	 */
+
+	for (i = 0; i <  nprocs; i++)
+	{
+		fflush(stdout);
+		if ((pid = FORK_OR_VFORK()) < 0)
+		{
+			tst_resm(TFAIL, "\tFork failed (may be OK if under stress)");
+			tst_exit();
+		}
+		/* Child does this */
+		if (pid == 0)
+		{
+#ifdef UCLINUX
+			if (self_exec(argv[0], "ndd", 1, keyarray[i], i) < 0)
+			{
+				tst_resm(TFAIL, "\tself_exec failed");
+				tst_exit();
+			}
+#else
+			procstat = 1;
+			exit( dotest(keyarray[i], i) );
+#endif
+		}
+		pidarray[i] = pid;
+	}
+
+	count = 0;
+	while(1)
+	{
+		if (( wait(&status)) > 0)
+		{
+			if (status>>8 != 0 )
+			{
+				tst_resm(TFAIL, "Child exit status = %d", status>>8);
+				tst_exit();
+			}
+			count++;
+		}
+		else
+		{
+			if (errno != EINTR)
+			{
+				break;
+			}
+#ifdef DEBUG
+			tst_resm(TINFO,"Signal detected during wait");
+#endif
+		}
+	}
+	/* Make sure proper number of children exited */
+	if (count != nprocs)
+	{
+		tst_resm(TFAIL, "Wrong number of children exited, Saw %d, Expected %d", count, nprocs);
+		tst_exit();
+	}
+
+	tst_resm(TPASS,"msgctl10 ran successfully!");
+
+	cleanup();
+	return (0);
+
+}
+/*--------------------------------------------------------------------*/
+
+#ifdef UCLINUX
+void
+do_child_1_uclinux()
+{
+	procstat = 1;
+	exit(dotest(key_uclinux, i_uclinux));
+}
+
+void
+do_child_2_uclinux()
+{
+	exit(doreader(id_uclinux, key_uclinux % 255, child_process_uclinux));
+}
+#endif
+
+int dotest(key, child_process)
+key_t 	key;
+int	child_process;
+{
+	int id, pid;
+
+	sighold(SIGTERM);
+	TEST(msgget(key, IPC_CREAT | S_IRUSR | S_IWUSR));
+	if (TEST_RETURN < 0)
+	{
+		tst_resm(TFAIL, "Msgget error in child %d, errno = %d", child_process, TEST_ERRNO);
+		tst_exit();
+	}
+	tid = id = TEST_RETURN;
+	sigrelse(SIGTERM);
+
+	fflush(stdout);
+	if ((pid = FORK_OR_VFORK()) < 0)
+	{
+		tst_resm(TWARN, "\tFork failed (may be OK if under stress)");
+		TEST(msgctl(tid, IPC_RMID, 0));
+		if (TEST_RETURN < 0)
+		{
+			tst_resm(TFAIL, "Msgctl error in cleanup, errno = %d", errno);
+		}
+		tst_exit();
+	}
+	/* Child does this */
+	if (pid == 0)
+	{
+#ifdef UCLINUX
+		if (self_exec(argv0, "nddd", 2, id, key, child_process) < 0) {
+			tst_resm(TWARN, "self_exec failed");
+			TEST(msgctl(tid, IPC_RMID, 0));
+			if (TEST_RETURN < 0)
+			{
+				tst_resm(TFAIL, "\tMsgctl error in cleanup, "
+					"errno = %d\n", errno);
+			}
+			tst_exit();
+		}
+#else
+		exit( doreader(id, key % 255, child_process) );
+#endif
+	}
+	/* Parent does this */
+	mykid = pid;
+	procstat = 2;
+	dowriter(id, key % 255, child_process);
+	wait(0);
+	TEST(msgctl(id, IPC_RMID, 0));
+	if (TEST_RETURN < 0)
+	{
+		tst_resm(TFAIL, "msgctl errno %d", TEST_ERRNO);
+		tst_exit();
+	}
+	exit(PASS);
+}
+
+int doreader(id, key, child)
+int id, child;
+long key;
+{
+	int i, size;
+
+	for (i = 0; i < nreps; i++)
+	{
+		if ((size = msgrcv(id, &buffer, 100, 0, 0)) < 0)
+		{
+			tst_brkm(TBROK, cleanup, "Msgrcv error in child %d, read # = %d, errno = %d", (i + 1), child, errno);
+			tst_exit();
+		}
+		if (buffer.data.len + 1 != size)
+		{
+			tst_resm(TFAIL, "Size mismatch in child %d, read # = %d", child, (i + 1));
+			tst_resm(TFAIL, "for message size got  %d expected  %d %s",size ,buffer.data.len);
+			tst_exit();
+		}
+		if ( verify(buffer.data.pbytes, key, size - 1, child) )
+		{
+			tst_resm(TFAIL, "in read # = %d,key =  %x", (i + 1), child, key);
+			tst_exit();
+		}
+		key++;
+	}
+	return (0);
+}
+
+int dowriter(id, key, child)
+int id,child;
+long key;
+{
+	int i, size;
+
+	for (i = 0; i < nreps; i++)
+	{
+		do
+		{
+			size = (rand() % 99);
+		} while (size == 0);
+		fill_buffer(buffer.data.pbytes, key, size);
+		buffer.data.len = size;
+		buffer.type = 1;
+		TEST(msgsnd(id, &buffer, size + 1, 0));
+		if (TEST_RETURN < 0)
+		{
+			tst_brkm(TBROK, cleanup, "Msgsnd error in child %d, key =   %x errno  = %d", child, key, TEST_ERRNO);
+		}
+		key++;
+	}
+	return (0);
+}
+
+int fill_buffer(buf, val, size)
+register char *buf;
+char	val;
+register int size;
+{
+	register int i;
+
+	for(i = 0; i < size; i++)
+	{
+		buf[i] = val;
+	}
+
+	return (0);
+}
+
+
+/*
+ * verify()
+ *	Check a buffer for correct values.
+ */
+
+int verify(buf, val, size, child)
+	register char *buf;
+	char	val;
+	register int size;
+	int	child;
+{
+	while(size-- > 0)
+	{
+		if (*buf++ != val)
+		{
+			tst_resm(TWARN, "Verify error in child %d, *buf = %x, val = %x, size = %d", child, *buf, val, size);
+			return(FAIL);
+		}
+	}
+	return(PASS);
+}
+
+/*
+ *  * void
+ *  * sig_handler() - signal catching function for 'SIGUSR1' signal.
+ *  *
+ *  *   This is a null function and used only to catch the above signal
+ *  *   generated in parent process.
+ *  */
+void
+sig_handler()
+{
+}
+
+/***************************************************************
+ * setup() - performs all ONE TIME setup for this test.
+ *****************************************************************/
+void
+setup()
+{
+	int nr_msgqs;
+
+	tst_tmpdir();
+
+	/* You will want to enable some signal handling so you can capture
+	 * unexpected signals like SIGSEGV.
+	 */
+	tst_sig(FORK, DEF_HANDLER, cleanup);
+
+
+	/* Pause if that option was specified */
+	/* One cavet that hasn't been fixed yet.  TEST_PAUSE contains the code to
+	 * fork the test with the -c option.  You want to make sure you do this
+	 * before you create your temporary directory.
+	 */
+	TEST_PAUSE;
+
+	nr_msgqs = get_max_msgqueues();
+	if (nr_msgqs < 0)
+		cleanup();
+
+	MSGMNI = nr_msgqs - get_used_msgqueues();
+	if (MSGMNI <= 0){
+		tst_resm(TBROK,"Max number of message queues already used, cannot create more.");
+		cleanup();
+	}
+}
+
+
+/***************************************************************
+ * cleanup() - performs all ONE TIME cleanup for this test at
+ *             completion or premature exit.
+ ****************************************************************/
+void
+cleanup()
+{
+	int status;
+	/*
+	 *  Remove the message queue from the system
+	 */
+#ifdef DEBUG
+	tst_resm(TINFO,"Removing the message queue");
+#endif
+	fflush (stdout);
+	(void) msgctl(tid, IPC_RMID, (struct msqid_ds *)NULL);
+	if ((status = msgctl(tid, IPC_STAT, (struct msqid_ds *)NULL)) != -1)
+	{
+		(void) msgctl(tid, IPC_RMID, (struct msqid_ds *)NULL);
+		tst_resm(TFAIL, "msgctl(tid, IPC_RMID) failed");
+		tst_exit();
+	}
+
+	fflush (stdout);
+	/*
+	 * print timing stats if that option was specified.
+	 * print errno log if that option was specified.
+	 */
+	TEST_CLEANUP;
+	tst_rmdir();
+	/* exit with return code appropriate for results */
+	tst_exit();
+}
+
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/msgget/Makefile
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/msgget/Makefile	2008-02-21 10:45:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgget/Makefile	2008-02-21 12:22:43.000000000 +0100
@@ -21,9 +21,12 @@ LDLIBS += -L../../../../../lib -lltp -L.
 
 SRCS    = $(wildcard *.c)
 TARGETS = $(patsubst %.c,%,$(SRCS))
+LIBIPC_HEADERS	= ../lib/ipcmsg.h
 
 all: $(TARGETS)
 
+$(TARGETS):	$(LIBIPC_HEADERS)
+
 install:
 	@set -e; for i in $(TARGETS); do ln -f $$i ../../../../bin/$$i ; done
 
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl11.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl11.c	2008-02-21 14:04:14.000000000 +0100
@@ -0,0 +1,696 @@
+/*
+ *
+ *   Copyright (c) International Business Machines  Corp., 2002
+ *
+ *   This program is free software;  you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; either version 2 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ *   the GNU General Public License for more details.
+ *
+ *   You should have received a copy of the GNU General Public License
+ *   along with this program;  if not, write to the Free Software
+ *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+/* 06/30/2001	Port to Linux	nsharoff@us.ibm.com */
+/* 11/11/2002   Port to LTP     dbarrera@us.ibm.com */
+
+
+/*
+ * NAME
+ *	msgctl11
+ *
+ * CALLS
+ *	msgget(2) msgctl(2) msgop(2)
+ *
+ * ALGORITHM
+ *	Get and manipulate a message queue.
+ *	Same as msgctl09 but gets the actual msgmni value under procfs.
+ *
+ * RESTRICTIONS
+ *
+ */
+
+#define _XOPEN_SOURCE 500
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <sys/ipc.h>
+#include <sys/msg.h>
+#include <sys/wait.h>
+#include <signal.h>
+#include <errno.h>
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include "test.h"
+#include "usctest.h"
+#include "ipcmsg.h"
+
+#define MAXNREPS	1000
+#ifndef CONFIG_COLDFIRE
+#define MAXNPROCS	 1000000  /* This value is set to an arbitrary high limit. */
+#else
+#define MAXNPROCS	 100000   /* Coldfire can't deal with 1000000 */
+#endif
+#define MAXNKIDS	10
+#define FAIL		1
+#define PASS		0
+
+int dotest(key_t,int);
+int doreader(long,int,int);
+int dowriter(long,int,int);
+int fill_buffer(char*,char,int);
+int verify(char*,char,int,int);
+void setup();
+void cleanup();
+
+/*
+ * These globals must be defined in the test.
+ * */
+
+
+char *TCID="msgctl11";           /* Test program identifier.    */
+int TST_TOTAL=1;                /* Total number of test cases. */
+extern int Tst_count;           /* Test Case counter for tst_* routines */
+
+int exp_enos[]={0};     /* List must end with 0 */
+
+
+key_t	keyarray[MAXNPROCS];
+
+struct {
+	long	type;
+	struct {
+		char	len;
+		char	pbytes[99];
+		} data;
+	} buffer;
+
+int	pidarray[MAXNPROCS];
+int	rkidarray[MAXNKIDS];
+int	wkidarray[MAXNKIDS];
+int 	tid;
+int 	nprocs, nreps, nkids, MSGMNI;
+int 	procstat;
+void 	term(int);
+#ifdef UCLINUX
+static char *argv0;
+
+void do_child_1_uclinux();
+static key_t key_uclinux;
+static int i_uclinux;
+
+void do_child_2_uclinux();
+static int pid_uclinux;
+static int child_process_uclinux;
+
+void do_child_3_uclinux();
+static int rkid_uclinux;
+#endif
+void cleanup_msgqueue(int i, int tid);
+
+/*-----------------------------------------------------------------*/
+int main(argc, argv)
+int	argc;
+char	*argv[];
+{
+	register int i, j, ok, pid;
+	int count, status;
+
+#ifdef UCLINUX
+	char *msg;			/* message returned from parse_opts */
+
+	argv0 = argv[0];
+
+	/* parse standard options */
+	if ((msg = parse_opts(argc, argv, (option_t *)NULL, NULL)) != (char *)NULL)
+	{
+		tst_brkm(TBROK, cleanup, "OPTION PARSING ERROR - %s", msg);
+	}
+
+	maybe_run_child(&do_child_1_uclinux, "ndd", 1, &key_uclinux, &i_uclinux);
+	maybe_run_child(&do_child_2_uclinux, "nddd", 2, &key_uclinux,
+			&pid_uclinux, &child_process_uclinux);
+	maybe_run_child(&do_child_3_uclinux, "nddd", 3, &key_uclinux,
+			&rkid_uclinux, &child_process_uclinux);
+#endif
+
+	setup();
+
+	if (argc == 1 )
+	{
+		/* Set default parameters */
+		nreps = MAXNREPS;
+		nprocs = MSGMNI;
+		nkids = MAXNKIDS;
+	}
+	else if (argc == 4 )
+	{
+		if ( atoi(argv[1]) > MAXNREPS )
+		{
+			tst_resm(TCONF,"Requested number of iterations too large, setting to Max. of %d", MAXNREPS);
+			nreps = MAXNREPS;
+		}
+		else
+		{
+			nreps = atoi(argv[1]);
+		}
+		if (atoi(argv[2]) > MSGMNI )
+		{
+			tst_resm(TCONF,"Requested number of processes too large, setting to Max. of %d", MSGMNI);
+			nprocs = MSGMNI;
+		}
+		else
+		{
+			nprocs = atoi(argv[2]);
+		}
+		if (atoi(argv[3]) > MAXNKIDS )
+		{
+			tst_resm(TCONF,"Requested number of read/write pairs too large; setting to Max. of %d", MAXNKIDS);
+			nkids = MAXNKIDS;
+		}
+		else
+		{
+			nkids = atoi(argv[3]);
+		}
+	}
+	else
+	{
+		tst_resm(TCONF," Usage: %s [ number of iterations  number of processes number of read/write pairs ]", argv[0]);
+		tst_exit();
+	}
+
+	procstat = 0;
+	srand48((unsigned)getpid() + (unsigned)(getppid() << 16));
+	tid = -1;
+
+	/* Setup signal handleing routine */
+	if (sigset(SIGTERM, term) == SIG_ERR)
+	{
+		tst_resm(TFAIL, "Sigset SIGTERM failed");
+		tst_exit();
+	}
+	/* Set up array of unique keys for use in allocating message
+	 * queues
+	 */
+	for (i = 0; i < nprocs; i++)
+	{
+		ok = 1;
+		do
+		{
+			/* Get random key */
+			keyarray[i] = (key_t)lrand48();
+			/* Make sure key is unique and not private */
+			if (keyarray[i] == IPC_PRIVATE)
+			{
+				ok = 0;
+				continue;
+			}
+			for (j = 0; j < i; j++)
+			{
+				if (keyarray[j] == keyarray[i])
+				{
+					ok = 0;
+					break;
+				}
+				ok = 1;
+			}
+		} while (ok == 0);
+	}
+/*-----------------------------------------------------------------*/
+	/* Fork a number of processes (nprocs), each of which will
+	 * create a message queue with several (nkids) reader/writer
+	 * pairs which will read and write a number (iterations)
+	 * of random length messages with specific values (keys).
+	 */
+
+	for (i = 0; i <  nprocs; i++)
+	{
+		fflush(stdout);
+		if ((pid = FORK_OR_VFORK()) < 0)
+		{
+			tst_resm(TFAIL, "\tFork failed (may be OK if under stress)");
+			tst_exit();
+		}
+		/* Child does this */
+		if (pid == 0)
+		{
+#ifdef UCLINUX
+			if (self_exec(argv[0], "ndd", 1, keyarray[i], i) < 0)
+			{
+				tst_resm(TFAIL, "\tself_exec failed");
+				tst_exit();
+			}
+#else
+			procstat = 1;
+			exit( dotest(keyarray[i], i) );
+#endif
+		}
+		pidarray[i] = pid;
+	}
+
+	count = 0;
+	while(1)
+	{
+		if (( wait(&status)) > 0)
+		{
+			if (status>>8 != PASS )
+			{
+				tst_resm(TFAIL, "Child exit status = %d", status>>8);
+				tst_exit();
+			}
+			count++;
+		}
+		else
+		{
+			if (errno != EINTR)
+			{
+				break;
+			}
+#ifdef DEBUG
+			tst_resm(TINFO,"Signal detected during wait");
+#endif
+		}
+	}
+	/* Make sure proper number of children exited */
+	if (count != nprocs)
+	{
+		tst_resm(TFAIL, "Wrong number of children exited, Saw %d, Expected %d", count, nprocs);
+		tst_exit();
+	}
+
+	tst_resm(TPASS,"msgctl11 ran successfully!");
+
+	cleanup();
+
+	return (0);
+
+
+
+}
+/*--------------------------------------------------------------------*/
+
+#ifdef UCLINUX
+void
+do_child_1_uclinux()
+{
+	procstat = 1;
+	exit(dotest(key_uclinux, i_uclinux));
+}
+
+void
+do_child_2_uclinux()
+{
+	procstat = 2;
+	exit(doreader(key_uclinux, pid_uclinux, child_process_uclinux));
+}
+
+void
+do_child_3_uclinux()
+{
+	procstat = 2;
+	exit(dowriter(key_uclinux, rkid_uclinux, child_process_uclinux));
+}
+#endif
+
+void
+cleanup_msgqueue(int i, int tid)
+{
+	/*
+	 * Decrease the value of i by 1 because it
+	 * is getting incremented even if the fork
+	 * is failing.
+	 */
+
+	i--;
+	/*
+	 * Kill all children & free message queue.
+	 */
+	for (; i >= 0; i--) {
+		(void)kill(rkidarray[i], SIGKILL);
+		(void)kill(wkidarray[i], SIGKILL);
+	}
+
+	if (msgctl(tid, IPC_RMID, 0) < 0) {
+		tst_resm(TFAIL, "Msgctl error in cleanup, errno = %d", errno);
+		tst_exit();
+	}
+}
+
+int dotest(key, child_process)
+key_t 	key;
+int	child_process;
+{
+	int id, pid;
+	int i, count, status, exit_status;
+
+	sighold(SIGTERM);
+	if ((id = msgget(key, IPC_CREAT | S_IRUSR | S_IWUSR )) < 0)
+	{
+		tst_resm(TFAIL, "Msgget error in child %d, errno = %d", child_process, errno);
+		tst_exit();
+	}
+	tid = id;
+	sigrelse(SIGTERM);
+
+	exit_status = PASS;
+
+	for (i=0; i < nkids; i++)
+	{
+		fflush(stdout);
+		if ((pid = FORK_OR_VFORK()) < 0)
+		{
+			tst_resm(TWARN, "Fork failure in first child of child group %d", child_process);
+			cleanup_msgqueue(i, tid);
+			tst_exit();
+		}
+		/* First child does this */
+		if (pid == 0)
+		{
+#ifdef UCLINUX
+			if (self_exec(argv0, "nddd", 2, key, getpid(),
+							child_process) < 0) {
+				tst_resm(TWARN, "self_exec failed");
+				cleanup_msgqueue(i, tid);
+				tst_exit();
+			}
+#else
+			procstat = 2;
+			exit( doreader( key, getpid(), child_process) );
+#endif
+		}
+		rkidarray[i] = pid;
+		fflush(stdout);
+		if ((pid = FORK_OR_VFORK()) < 0)
+		{
+			tst_resm(TWARN, "Fork failure in first child of child group %d", child_process);
+			/*
+			 * Kill the reader child process
+			 */
+			(void)kill(rkidarray[i], SIGKILL);
+
+			cleanup_msgqueue(i, tid);
+			tst_exit();
+		}
+		/* Second child does this */
+		if (pid == 0)
+		{
+#ifdef UCLINUX
+			if (self_exec(argv0, "nddd", 3, key, rkidarray[i],
+							child_process) < 0) {
+				tst_resm(TWARN, "\tFork failure in first child "
+					"of child group %d \n", child_process);
+				/*
+				 * Kill the reader child process
+				 */
+				(void)kill(rkidarray[i], SIGKILL);
+
+				cleanup_msgqueue(i, tid);
+				tst_exit();
+			}
+#else
+			procstat = 2;
+			exit( dowriter( key, rkidarray[i], child_process) );
+#endif
+		}
+		wkidarray[i] = pid;
+	}
+	/* Parent does this */
+	count = 0;
+	while(1)
+	{
+		if (( wait(&status)) > 0)
+		{
+			if (status>>8 != PASS )
+			{
+				tst_resm(TFAIL, "Child exit status = %d from child group %d", status>>8, child_process);
+				for (i = 0; i < nkids; i++)
+				{
+					kill(rkidarray[i], SIGTERM);
+					kill(wkidarray[i], SIGTERM);
+				}
+				if (msgctl(tid, IPC_RMID, 0) < 0) {
+					tst_resm(TFAIL, "Msgctl error, errno = %d", errno);
+				}
+				tst_exit();
+			}
+			count++;
+		}
+		else
+		{
+			if (errno != EINTR)
+			{
+				break;
+			}
+		}
+	}
+	/* Make sure proper number of children exited */
+	if (count != (nkids * 2))
+	{
+		tst_resm(TFAIL, "Wrong number of children exited in child group %d, Saw %d Expected %d", child_process, count, (nkids * 2));
+		if (msgctl(tid, IPC_RMID, 0) < 0) {
+			tst_resm(TFAIL, "Msgctl error, errno = %d", errno);
+		}
+		tst_exit();
+	}
+	if (msgctl(id, IPC_RMID, 0) < 0)
+	{
+		tst_resm(TFAIL, "Msgctl failure in child group %d, errno %d", child_process, errno);
+		tst_exit();
+	}
+	exit(exit_status);
+}
+
+int doreader( key, type, child)
+int type, child;
+long key;
+{
+	int i, size;
+	int id;
+
+	if ((id = msgget(key, 0)) < 0)
+	{
+		tst_resm(TFAIL, "Msgget error in reader of child group %d, errno = %d", child, errno);
+		tst_exit();
+	}
+	if (id != tid)
+	{
+		tst_resm(TFAIL, "Message queue mismatch in reader of child group %d for message queue id %d", child, id);
+		tst_exit();
+	}
+	for (i = 0; i < nreps; i++)
+	{
+		if ((size = msgrcv(id, &buffer, 100, type, 0)) < 0)
+		{
+			tst_resm(TFAIL, "Msgrcv error in child %d, read # = %d, errno = %d", (i + 1), child, errno);
+			tst_exit();
+		}
+		if (buffer.type != type)
+		{
+			tst_resm(TFAIL, "Size mismatch in child %d, read # = %d", child, (i + 1));
+			tst_resm(TFAIL, "\tfor message size got  %d expected  %d %s",size ,buffer.data.len);
+			tst_exit();
+		}
+		if (buffer.data.len + 1 != size)
+		{
+			tst_resm(TFAIL, "Size mismatch in child %d, read # = %d, size = %d, expected = %d", child, (i + 1), buffer.data.len, size);
+			tst_exit();
+		}
+		if ( verify(buffer.data.pbytes, (key % 255), size - 1, child) )
+		{
+			tst_resm(TFAIL, "in read # = %d,key =  %x", (i + 1), child, key);
+			tst_exit();
+		}
+		key++;
+	}
+	exit(PASS);
+}
+
+int dowriter( key, type, child)
+int type,child;
+long key;
+{
+	int i, size;
+	int id;
+
+	if ((id = msgget(key, 0)) < 0)
+	{
+		tst_resm(TFAIL, "Msgget error in writer of child group %d, errno = %d", child, errno);
+		tst_exit();
+	}
+	if (id != tid)
+	{
+		tst_resm(TFAIL, "Message queue mismatch in writer of child group %d", child);
+		tst_resm(TFAIL, "\tfor message queue id %d expected  %d",id, tid);
+		tst_exit();
+	}
+
+	for (i = 0; i < nreps; i++)
+	{
+		do
+		{
+			size = (lrand48() % 99);
+		} while (size == 0);
+		fill_buffer(buffer.data.pbytes, (key % 255), size);
+		buffer.data.len = size;
+		buffer.type = type;
+		if (msgsnd(id, &buffer, size + 1, 0) < 0)
+		{
+			tst_resm(TFAIL, "Msgsnd error in child %d, key =   %x errno  = %d", child, key, errno);
+			tst_exit();
+		}
+		key++;
+	}
+	exit(PASS);
+}
+
+int fill_buffer(buf, val, size)
+register char *buf;
+char	val;
+register int size;
+{
+	register int i;
+
+	for(i = 0; i < size; i++)
+		buf[i] = val;
+	return(0);
+}
+
+
+/*
+ * verify()
+ *	Check a buffer for correct values.
+ */
+
+int verify(buf, val, size, child)
+	register char *buf;
+	char	val;
+	register int size;
+	int	child;
+{
+	while(size-- > 0)
+		if (*buf++ != val)
+		{
+			tst_resm(TWARN, "Verify error in child %d, *buf = %x, val = %x, size = %d", child, *buf, val, size);
+			return(FAIL);
+		}
+	return(PASS);
+}
+
+/* ARGSUSED */
+void
+term(int sig)
+{
+	int i;
+
+	if (procstat == 0)
+	{
+#ifdef DEBUG
+		tst_resm(TINFO,"SIGTERM signal received, test killing kids");
+#endif
+		for (i = 0; i < nprocs; i++)
+		{
+			if ( pidarray[i] > 0){
+				if ( kill(pidarray[i], SIGTERM) < 0)
+				{
+					tst_resm(TBROK,"Kill failed to kill child %d", i);
+					exit(FAIL);
+				}
+			}
+		}
+		return;
+	}
+
+	if (procstat == 2)
+	{
+		fflush(stdout);
+		exit(PASS);
+	}
+
+	if (tid == -1)
+	{
+		exit(FAIL);
+	}
+	for (i = 0; i < nkids; i++)
+	{
+		if (rkidarray[i] > 0)
+			kill(rkidarray[i], SIGTERM);
+		if (wkidarray[i] > 0)
+			kill(wkidarray[i], SIGTERM);
+	}
+}
+
+/***************************************************************
+ * setup() - performs all ONE TIME setup for this test.
+ *****************************************************************/
+void
+setup()
+{
+	int nr_msgqs;
+
+	tst_tmpdir();
+	/* You will want to enable some signal handling so you can capture
+	 * unexpected signals like SIGSEGV.
+	 */
+	tst_sig(FORK, DEF_HANDLER, cleanup);
+
+
+	/* Pause if that option was specified */
+	/* One cavet that hasn't been fixed yet.  TEST_PAUSE contains the code to
+	 * fork the test with the -c option.  You want to make sure you do this
+	 * before you create your temporary directory.
+	 */
+	TEST_PAUSE;
+
+	nr_msgqs = get_max_msgqueues();
+	if (nr_msgqs < 0)
+		cleanup();
+
+	MSGMNI = nr_msgqs - get_used_msgqueues();
+	if (MSGMNI <= 0){
+		tst_resm(TBROK,"Max number of message queues already used, cannot create more.");
+		cleanup();
+	}
+}
+
+
+/***************************************************************
+ * cleanup() - performs all ONE TIME cleanup for this test at
+ * completion or premature exit.
+ ****************************************************************/
+void
+cleanup()
+{
+	int status;
+	/*
+	 * print timing stats if that option was specified.
+	 * print errno log if that option was specified.
+	 */
+	TEST_CLEANUP;
+
+	/*
+	 * Remove the message queue from the system
+	 */
+#ifdef DEBUG
+	tst_resm(TINFO,"Removing the message queue");
+#endif
+	fflush (stdout);
+	(void) msgctl(tid, IPC_RMID, (struct msqid_ds *)NULL);
+	if ((status = msgctl(tid, IPC_STAT, (struct msqid_ds *)NULL)) != -1) {
+		(void) msgctl(tid, IPC_RMID, (struct msqid_ds *)NULL);
+		tst_resm(TFAIL, "msgctl(tid, IPC_RMID) failed");
+		tst_exit();
+	}
+
+	fflush (stdout);
+	tst_rmdir();
+	/* exit with return code appropriate for results */
+	tst_exit();
+}
+

--------------020009030007010503080503--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
