Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD4CD6B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 21:15:47 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f203so1727072itf.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:15:47 -0700 (PDT)
Received: from gate2.alliedtelesis.co.nz (gate2.alliedtelesis.co.nz. [2001:df5:b000:5::4])
        by mx.google.com with ESMTPS id u66si13018469pfg.220.2017.03.13.18.15.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 18:15:46 -0700 (PDT)
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id C181586060
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 14:15:42 +1300 (NZDT)
From: Mark Tomlinson <Mark.Tomlinson@alliedtelesis.co.nz>
Subject: MIPS: Memory corruption forking within pthread environment
Date: Tue, 14 Mar 2017 01:15:41 +0000
Message-ID: <7e632811-4ce5-7af9-6560-3d146984592c@alliedtelesis.co.nz>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-ID: <955F05536FC94445AC12EF935D13D34E@atlnz.lc>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

I am using a MIPS CPU running linux 4.4.6, and have a problem when=20
forking from a process which is also using pthreads. I believe this is=20
OK to do, although there are limits on what the forked process is=20
allowed to do.

The CPU is a BCM53003, which uses a MIPS32 74K core. Although we had to=20
bring in some patches from Broadcom for this CPU, there are no changes=20
in the memory managment that I can see. The kernel is compiled without=20
CONFIG_PREEMPT or CONFIG_SMP.

I have traced the problem down to the duplication of the memory map for=20
the newly forked process. As the parent has created pthreads, this=20
memory map is currently shared, since pthreads all share the same memory=20
space. In copy_pte_range() there is a cond_resched(), which will allow=20
other tasks to run while this copying is taking place. If I remove the=20
cond_resched (and associated logic), then the problem goes away.

So I guess my question is why this copy is not working successfully with=20
the reschedule in the middle of it (and yet works on other platforms).=20
The memory corruption is occurring in the original memory map, not the=20
copy, as it is the existing pthreads that segfault. I do know that some=20
pages will get set to write-only to allow COW, so am wondering whether=20
that is somehow related. Is there some extra cache flush or MMU=20
invalidation that needs to occur on this CPU?



Here is the test code which will segfault when run on this CPU. The same=20
code runs fine on other architectures (x86, MIPS64, PowerPC, ARM).

/**
  * Simple test app to reproduce a problem we were seeing with stack=20
corruption
  * within a pthread, while another thread is doing a fork() operation.
  */
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include <syslog.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <linux/if_packet.h>
#include <net/ethernet.h>
#include <arpa/inet.h>
#include <pthread.h>

/* If the corruption doesn't occur, this should be more like 1000000 to=20
avoid
  * screeds of debug output */
#define PERIODIC_DEBUG 1000

#define TEST_PKT_ID 3434
#define TEST_ETHERTYPE htonl(0xbeef)

struct test_packet
{
     uint8_t eth_dst[ETHER_ADDR_LEN];
     uint8_t eth_src[ETHER_ADDR_LEN];
     uint32_t eth_type;
     uint32_t sequence;
     uint8_t mac[ETHER_ADDR_LEN];
     uint32_t id;
     uint32_t time;
};

uint8_t test_dst_addr[ETHER_ADDR_LEN] =3D { 0x1, 0x00, 0x11, 0x22, 0x33,=20
0x44 };
uint8_t test_src_addr[ETHER_ADDR_LEN] =3D { 0x0b, 0xad, 0xde, 0xad, 0x0be,=
=20
0xef };
int test_sequence =3D 0;

uint32_t num_forks =3D 0;
uint32_t num_corruptions =3D 0;
uint32_t num_loops =3D 0;

/**
  * This is based off code that was originally sending a packet. It=20
turns out that
  * all we need to do to see the corruption problem is set a few fields=20
in the
  * packet, and then sanity-check that they're all still correct afterwards=
.
  * @note this achieves much the same as compiling with=20
-fstack-protector-all,
  * however it just casts a slightly wider net to check for stack=20
corruption.
  */
void
test_packet_send (void)
{
     struct test_packet pktPt;
     uint8_t buf[32];

     /* construct a test pkt */
     memcpy (pktPt.eth_dst, test_dst_addr, ETHER_ADDR_LEN);
     memcpy (pktPt.eth_src, test_src_addr, ETHER_ADDR_LEN);
     pktPt.eth_type =3D TEST_ETHERTYPE;
     pktPt.sequence =3D test_sequence++;
     memcpy (pktPt.mac, test_src_addr, ETHER_ADDR_LEN);
     pktPt.id =3D TEST_PKT_ID;
     pktPt.time =3D 0;

     /* this line/variable isn't strictly needed. It just seems to make the
      * corruption more likely to occur in the pktPt variable, where we can
      * detect it more easily */
     memset (buf, 0, sizeof (buf));

     /* Sanity-check the pkt values set at the start of the function are=20
still
      * intact, i.e. the stack hasn't been stomped on */
     if (memcmp (pktPt.eth_dst, test_dst_addr, ETHER_ADDR_LEN) !=3D 0 ||
         memcmp (pktPt.eth_src, test_src_addr, ETHER_ADDR_LEN) !=3D 0 ||
         pktPt.eth_type !=3D TEST_ETHERTYPE ||
         memcmp (pktPt.mac, test_src_addr, ETHER_ADDR_LEN) !=3D 0 ||
         pktPt.id !=3D TEST_PKT_ID ||
         pktPt.time !=3D 0)
     {
         fprintf (stdout, "%u corruptions out of %u loops (%u forks)\n",
                  ++num_corruptions, num_loops, num_forks);
         fflush (stdout);
     }
}

static void *
test_send_thread (void *unused)
{
     while (true)
     {
         /* without some sort of yield here, the problem doesn't seem to=20
occur.
          * The original code did a select() here, but a 1us sleep seems to
          * reproduce the problem a lot better */
         usleep (1);

         test_packet_send ();

         /* Report on the progress of the test every so often. One=20
problem that
          * sometimes occurs is that a corruption causes a system call=20
to lock-up.
          * So it looks like no corruptions are detected, when really=20
the test
          * isn't running properly */
         if ((++num_loops % PERIODIC_DEBUG) =3D=3D 0)
         {
             fprintf (stdout, "%u corruptions out of %u loops (%u forks)\n"=
,
                      num_corruptions, num_loops, num_forks);
             fflush (stdout);
         }
     }

     return NULL;
}


/**
  * Polls to see if the last child process forked has been cleaned up.=20
If so,
  * then it fork()s new a child again (the child process does nothing -=20
it just
  * exits).
  * @note the problem also occurs if the parent process does a blocking=20
call to
  * waitpid() - it just seems more reproducible using a non-blocking=20
waitpid().
  */
void
try_fork_again (void)
{
     static pid_t last_pid =3D -1;
     int status;

     if (last_pid >=3D 0)
     {
         /* wait for the child process to exit before proceeding (to=20
make sure
          * the zombie process gets cleaned up properly) */
         if (waitpid (last_pid, &status, WNOHANG) > 0)
         {
             last_pid =3D -1;
         }
     }

     /* if any previous children are now cleaned up, then fork() again */
     if (last_pid < 0)
     {
         last_pid =3D fork ();
         num_forks++;

         if (last_pid < 0)
         {
             fprintf (stderr, "fork() failed - %s", strerror(errno));
         }
         else if (last_pid =3D=3D 0)
         {
             _exit (0);
         }
     }
}


int
main (int argc, char *argv[])
{
     pthread_t tid;

     /* create a separate thread that pretends to send packets */
     if (pthread_create (&tid, NULL, test_send_thread, NULL) !=3D 0)
     {
         fprintf (stderr, "Could not create pthread - %s\n", strerror=20
(errno));
         return EXIT_FAILURE;
     }

     /* meanwhile in the main thread do lots and lots of forks */
     while (true)
     {
         try_fork_again ();
     }

     return EXIT_FAILURE;
}=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
