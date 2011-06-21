Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E257E6B0150
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 10:51:32 -0400 (EDT)
Message-ID: <4E00AFE6.20302@5t9.de>
Date: Tue, 21 Jun 2011 16:51:18 +0200
From: Lutz Vieweg <lvml@5t9.de>
MIME-Version: 1.0
Subject: "make -j" with memory.(memsw.)limit_in_bytes smaller than required
 -> livelock,  even for unlimited processes
Content-Type: multipart/mixed;
 boundary="------------020802040702090000090002"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, lvml@5t9.de

This is a multi-part message in MIME format.
--------------020802040702090000090002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Dear Memory Ressource Controller maintainers,

by using per-user control groups with a limit on memory (and swap) I am
trying to secure a shared development server against memory exhaustion
by any one single user - as it happened before when somebody imprudently
issued "make -j" (which has the infamous habit to spawn an unlimited
number of processes) on a large software project with many source files.

The memory limitation using control groups works just fine when
only a few processes sum up to a usage that exceeds the limits - the
processes are OOM-killed, then, and the others users are unaffected.

But the original cause, a "make -j" on many source files, leads to
the following ugly symptom:

- make starts numerous (~ 100 < x < 200) gcc processes

- some of those gcc processes get OOM-killed quickly, then
   a few more are killed, but with increasing pauses in between

- then after a few seconds, no more gcc processes are killed, but
   the "make" process and its childs do not show any progress anymore

- at this time, top indicates 100% "system" CPU usage, mostly by
   "[kworker/*]" threads (one per CPU). But processes from other
   users, that only require CPU, proceed to run.

- but also at this time, if any other user (who has not exhausted
   his memory limits) tries to access any file (at least on /tmp/,
   as e.g. gcc does), even a simple "ls /tmp/", this operation
   waits forever. (But "iostat" does not indicate any I/O activity.)

- as soon as you press "CTRL-C" to abort the "make -j", everything
   goes back to normal, quickly - also the other users' processes proceed.


To reproduce the problem, the attached "Makefile" to a directory
on a filesystem with at least 70MB free space, then

  mount -o memory none /cgroup
  mkdir /cgroup/test
  echo 64M >/cgroup/test/memory.limit_in_bytes
  echo 64M >/cgroup/test/memory.memsw.limit_in_bytes

  cd /somewhere/with/70mb/free
  echo $$ >/cgroup/test/tasks
  make sources
  make -j compile

Notice that "make sources" will create 200 bogus "*.c" files from
/dev/urandom to make sure that "gcc" will use up some memory.

The "make -j compile" reliably reproduces the above mentioned syndrome,
here.

Please notice that the livelock does happen only with a significant
number of parallel compiler runs - it did e.g. not happen with
only 100 for me, and it also did not happen when I started "make"
with "strace" - so timing seems to be an issue, here.

Thanks for any hints towards a solution of this issue in advance!

Regards,

Lutz Vieweg

--------------020802040702090000090002
Content-Type: text/plain;
 name="Makefile"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="Makefile"


all:
	echo "first 'make sources', then 'make -j compile'


N=200 

clean:
	rm -f file_*.o lib.so


mrproper:
	rm -f file_*.c file_*.o lib.so
	

sources: clean
	for (( I=0 ; $$I < $(N) ; I=`expr $$I + 1` )) ; do \
		echo $$I; \
		echo "char array_$$I [] = " >file_$$I.c ;\
		dd if=/dev/urandom bs=256k count=1 | base64 | sed 's/^.*/"\0"/g' >>file_$$I.c ;\
		echo ";" >>file_$$I.c ;\
	done


OBJ = $(addsuffix .o, $(basename $(notdir $(wildcard file_*.c))))

compile: $(OBJ)
	gcc -shared -O3 -o lib.so $(OBJ)	

%.o: ./%.c
	gcc -O3 -c $< -o $@

--------------020802040702090000090002--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
