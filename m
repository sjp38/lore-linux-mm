Message-ID: <47BB0EDC.5000002@bull.net>
Date: Tue, 19 Feb 2008 18:16:12 +0100
From: Nadia Derbey <Nadia.Derbey@bull.net>
MIME-Version: 1.0
Subject: Re: [LTP] [PATCH 1/8] Scaling msgmni to the amount of lowmem
References: <20080211141646.948191000@bull.net>	 <20080211141813.354484000@bull.net>	 <20080215215916.8566d337.akpm@linux-foundation.org>	 <47B94D8C.8040605@bull.net>  <47B9835A.3060507@bull.net> <1203411055.4612.5.camel@subratamodak.linux.ibm.com>
In-Reply-To: <1203411055.4612.5.camel@subratamodak.linux.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------070801070409020708020001"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: subrata@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, ltp-list@lists.sourceforge.net, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmm@us.ibm.com, matthltc@us.ibm.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070801070409020708020001
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Subrata Modak wrote:
>>Nadia Derbey wrote:
>>
>>>Andrew Morton wrote:
>>>
>>>
>>>>On Mon, 11 Feb 2008 15:16:47 +0100 Nadia.Derbey@bull.net wrote:
>>>>
>>>>
>>>>
>>>>>[PATCH 01/08]
>>>>>
>>>>>This patch computes msg_ctlmni to make it scale with the amount of 
>>>>>lowmem.
>>>>>msg_ctlmni is now set to make the message queues occupy 1/32 of the 
>>>>>available
>>>>>lowmem.
>>>>>
>>>>>Some cleaning has also been done for the MSGPOOL constant: the msgctl 
>>>>>man page
>>>>>says it's not used, but it also defines it as a size in bytes (the code
>>>>>expresses it in Kbytes).
>>>>>
>>>>
>>>>
>>>>Something's wrong here.  Running LTP's msgctl08 (specifically:
>>>>ltp-full-20070228) cripples the machine.  It's a 4-way 4GB x86_64.
>>>>
>>>>http://userweb.kernel.org/~akpm/config-x.txt
>>>>http://userweb.kernel.org/~akpm/dmesg-x.txt
>>>>
>>>>Normally msgctl08 will complete in a second or two.  With this patch I
>>>>don't know how long it will take to complete, and the machine is horridly
>>>>bogged down.  It does recover if you manage to kill msgctl08.  Feels like
>>>>a terrible memory shortage, but there's plenty of memory free and it 
>>>>isn't
>>>>swapping.
>>>>
>>>>
>>>>
>>>
>>>Before the patchset, msgctl08 used to be run with the old msgmni value: 
>>>16. Now it is run with a much higher msgmni value (1746 in my case), 
>>>since it scales to the memory size.
>>>When I call "msgctl08 100000 16" it completes fast.
>>>
>>>Doing the follwing on the ref kernel:
>>>echo 1746 > /proc/sys/kernel/msgmni
>>>msgctl08 100000 1746
>>>
>>>makes th test block too :-(
>>>
>>>Will check to see where the problem comes from.
>>>
>>
>>Well, actually, the test does not block, it only takes much much more 
>>time to be executed:
>>
>>doing this:
>>date; ./msgctl08 100000 XXX; date
>>
>>
>>gives us the following results:
>>XXX           16   32   64   128   256   512   1024   1746
>>time(secs)     2    4    8    16    32    64    132    241
>>
>>XXX is the # of msg queues to be created = # of processes to be forked 
>>as readers = # of processes to be created as writers
>>time is approximative since it is obtained by a "date" before and after.
>>
>>XXX used to be 16 before the patchset  ---> 1st column
>>     --> 16 processes forked as reader
>>     --> + 16 processes forked as writers
>>     --> + 16 msg queues
>>XXX = 1746 (on my victim) after the patchset ---> last column
>>     --> 1746 reader processes forked
>>     --> + 1746 writers forked
>>     --> + 1746 msg queues created
>>
>>The same tests on the ref kernel give approximatly the same results.
>>
>>So if we don't want this longer time to appear as a regression, the LTP 
>>should be changed:
>>1) either by setting the result of get_max_msgqueues() as the MSGMNI 
>>constant (16) (that would be the best solution in my mind)
>>2) or by warning the tester that it may take a long time to finish.
>>
>>There would be 3 tests impacted:
>>
>>kernel/syscalls/ipc/msgctl/msgctl08.c
>>kernel/syscalls/ipc/msgctl/msgctl09.c
>>kernel/syscalls/ipc/msgget/msgget03.c
> 
> 
> We will change the test case if need that be. Nadia, kindly send us the
> patch set which will do the necessary changes.
> 
> Regards--
> Subrata
> 

Subrata,

You'll find the patch in attachment.
FYI I didn't change msgget03.c since we need to get the actual max value 
in order to generate an error.

Regards,
Nadia


--------------070801070409020708020001
Content-Type: text/x-patch;
 name="ipc_ltp_full_20080131.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipc_ltp_full_20080131.patch"

Since msgmni now scales to the memory size, it may reach big values.
To avoid forking 2*msgmni processes and create msgmni msg queues, do not take
msgmni from procfs anymore.
Just define it as 16 (which is the MSGMNI constant value in linux/msg.h)

Also fixed the Makefiles in ipc/lib and ipc/msgctl: there was no dependency
on the lib/ipc*.h header files.

Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>

---
 testcases/kernel/syscalls/ipc/lib/Makefile      |    3 +++
 testcases/kernel/syscalls/ipc/lib/ipcmsg.h      |    2 ++
 testcases/kernel/syscalls/ipc/msgctl/Makefile   |    3 +++
 testcases/kernel/syscalls/ipc/msgctl/msgctl08.c |   23 ++---------------------
 testcases/kernel/syscalls/ipc/msgctl/msgctl09.c |   24 ++----------------------
 5 files changed, 12 insertions(+), 43 deletions(-)

Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl08.c
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/msgctl/msgctl08.c	2006-02-11 05:46:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl08.c	2008-02-19 18:45:27.000000000 +0100
@@ -50,6 +50,7 @@
 #include <sys/msg.h>
 #include "test.h"
 #include "usctest.h"
+#include "ipcmsg.h"
 
 void setup();
 void cleanup();
@@ -479,26 +480,6 @@ static int get_used_msgqueues()
         return used_queues;
 }
 
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
@@ -520,7 +501,7 @@ setup()
 	 */
         TEST_PAUSE;
 
-        MSGMNI = get_max_msgqueues() - get_used_msgqueues();
+        MSGMNI = MAX_MSGQUEUES - get_used_msgqueues();
 	if (MSGMNI <= 0){
 		tst_resm(TBROK,"Max number of message queues already used, cannot create more.");
 		cleanup(); 
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl09.c
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/msgctl/msgctl09.c	2006-02-11 05:46:36.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/msgctl09.c	2008-02-19 18:46:44.000000000 +0100
@@ -49,6 +49,7 @@
 #include <unistd.h>
 #include "test.h"
 #include "usctest.h"
+#include "ipcmsg.h"
 
 #define MAXNREPS	1000
 #ifndef CONFIG_COLDFIRE
@@ -649,26 +650,6 @@ static int get_used_msgqueues()
         return used_queues;
 }
 
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
@@ -689,12 +670,11 @@ setup()
          */
         TEST_PAUSE;
 
-        MSGMNI = get_max_msgqueues() - get_used_msgqueues();
+        MSGMNI = MAX_MSGQUEUES - get_used_msgqueues();
         if (MSGMNI <= 0){
                 tst_resm(TBROK,"Max number of message queues already used, cannot create more.");
                 cleanup();
         }
-
 }
 
 
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/ipcmsg.h
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/lib/ipcmsg.h	2005-12-22 21:18:23.000000000 +0100
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/ipcmsg.h	2008-02-19 18:51:38.000000000 +0100
@@ -41,6 +41,8 @@ void setup(void);
 #define MSGSIZE	1024		/* a resonable size for a message */
 #define MSGTYPE 1		/* a type ID for a message */
 
+#define MAX_MSGQUEUES	16	/* MSGMNI as defined in linux/msg.h */
+
 typedef struct mbuf {		/* a generic message structure */
 	long mtype;
 	char mtext[MSGSIZE + 1];  /* add 1 here so the message can be 1024   */
Index: ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/Makefile
===================================================================
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/lib/Makefile	2006-08-21 08:58:39.000000000 +0200
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/lib/Makefile	2008-02-19 18:50:19.000000000 +0100
@@ -19,6 +19,7 @@
 SRCS   = libipc.c
 OBJS   = $(SRCS:.c=.o)
 LIBIPC = ../libipc.a
+LIBIPC_HEADERS	= ipcmsg.h ipcsem.h
 
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
--- ltp-full-20080131.orig/testcases/kernel/syscalls/ipc/msgctl/Makefile	2006-08-23 07:46:27.000000000 +0200
+++ ltp-full-20080131/testcases/kernel/syscalls/ipc/msgctl/Makefile	2008-02-19 19:02:26.000000000 +0100
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
 

--------------070801070409020708020001--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
