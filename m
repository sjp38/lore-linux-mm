Received: from megami.veritas.com (megami.veritas.com [10.182.128.180])
	by svldns02.veritas.com (8.11.6/8.11.6) with SMTP id g1EFUOc29298
	for <linux-mm@kvack.org>; Thu, 14 Feb 2002 07:30:24 -0800 (PST)
Received: from vxindia.veritas.com(revati.vxindia.veritas.com[202.41.69.12]) (3613 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <abhijitk@veritas.com>)
	id <m16bNu3-0005gNC@megami.veritas.com>
	for <linux-mm@kvack.org>; Thu, 14 Feb 2002 07:34:31 -0800 (PST)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Thu, 14 Feb 2002 21:03:16 +0530 (IST)
From: Abhijit Karmarkar <abhijitk@veritas.com>
Subject: doing large malloc's, parallelly crashes the machine.
Message-ID: <Pine.GSO.4.21.0202142010220.24956-100000@revati>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Abhijit Karmarkar <abhijitk@veritas.com>
List-ID: <linux-mm.kvack.org>

Hello Gurus,

would be glad if someone could explain this phenomenon.

here's a program (c++) that allocates ~1M of mem continiously (without
freeing it):
-------------
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char*argv[]) 
{
	int *p;

	while(1) {
		p = (int*) new int [1000000];
		for(int j=0; j < 1000000; j++) p[j]=j;
		sleep(1);
	}
}
-------------

If I try to run this program (as root), after sometime the program
terminates with a "Terminated" message. I think that's because, it tries
to eat away all the free/swap memory available, and finally after reaching
the limits, the kernel _kills_ it. 

IMO good behaviour, as prevents a user-space (buggy) application from
getting the whole system down.

BUT, if I try to run _multiple_ such programs (in background) the system
hangs... does not respond to keyboard and becomes un-interactable.

here's the script:
-------------
#!/bin/sh
i=0
# put 400 such buggy programs in background...
while [ $i -lt 400 ]; do 
	above_program &
        let i=$i+1
done
------------
it hangs after putting about 20 such processes in background.

Why does this happen? if the single buggy program is terminated
(correctly) by the OS, what goes wrong when i put them in background?

Moreover the whole expriement does not happen on a Solaris box (SunOS
5.7), i.e. the shell _is_ able to spawn so many buggy programs (which do
terminate), and still the box is accessible (does not hang)?

Is this a bug in linux VM subsystem... or i'am i doing something wrong?
Isn't the OOM killer not supposed to handle this? 

Can such kind of phenomenon be prevented by setting certain VM related
parameters? How does Solaris handle this??


Details of the setup:
----
kernel: linux-2.4.9-13 (RedHat 7.2 errata) [non SMP]
mem config: (of a normal working system, before staring the experiment)

[1] cat /proc/meminfo:
        total:    used:    free:  shared: buffers:  cached:
Mem:  261259264 86876160 174383104    73728 25280512 27410432
Swap: 271392768        0 271392768
MemTotal:       255136 kB
MemFree:        170296 kB
MemShared:          72 kB
Buffers:         24688 kB
Cached:          26768 kB
SwapCached:          0 kB
Active:          50604 kB
Inact_dirty:       924 kB
Inact_clean:         0 kB
Inact_target:    65532 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       255136 kB
LowFree:        170296 kB
SwapTotal:      265032 kB
SwapFree:       265032 kB

[2] vmstat -1
  procs                   memory    swap        io     system    cpu
r  b  w  swpd   free  buff cache  si  so   bi   bo   in cs us  sy id
0  0  0    0  170264 24704 26768   0   0  252  133  143 89  3   4 93
----
can give any other stat/info if something is missing out here.


thanks in advance,

regards,
-Abhijit.

Please Cc: me the reply, I am not subscribed to the list. 





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
