Date: Sat, 11 Sep 2004 02:08:16 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3375] New: NUMA memory allocation issue:
 set_memorypolicy to MPOL_BIND do not work.
Message-Id: <20040911020816.4ac226cd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: jean-marie.verdun@hp.com, Andi Kleen <ak@muc.de>
List-ID: <linux-mm.kvack.org>


Begin forwarded message:

Date: Sat, 11 Sep 2004 02:01:13 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3375] New: NUMA memory allocation issue: set_memorypolicy to MPOL_BIND do not work. 


http://bugme.osdl.org/show_bug.cgi?id=3375

           Summary: NUMA memory allocation issue: set_memorypolicy to
                    MPOL_BIND do not work.
    Kernel Version: 2.6.8.1
            Status: NEW
          Severity: high
             Owner: mm_numa-discontigmem@kernel-bugs.osdl.org
         Submitter: jean-marie.verdun@hp.com


Distribution: Suse 9.1 Pro
Hardware Environment: 4P Opteron server running at 2.0 Ghz with 32 GB of main memory
Software Environment: glibc library 2.3.4
Problem Description:

I am trying to use the most efficient NUMA features by forcing memory allocation
of a compute process to the current node on which it runs. I would like that the
process die in the case the cpu runs out of memory explain why I do want to use
explicit binding.

When setting the memory allocation policy inside wrapper which execute the
target process through an excevp system call then after, if the policy is setup
to MPOL_BIND, the execvp fails with an out of memory messages while the binary
used is very small and the node still have plenty of memory.

Steps to reproduce:

Here is the small piece of code I use

#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <sched.h>
#include <sys/types.h>
#include "/root/linux-2.6.8.1/include/asm-x86_64/unistd.h"
#include "/root/glibc-2.3.3/sysdeps/unix/sysv/linux/x86_64/sysdep.h"
# define __set_errno(val) (errno = (val))
#ifndef __SYSCALL
#define __SYSCALL(a,b)
#endif
 
__SYSCALL(__NR_sched_setaffinity, sys_sched_setaffinity)
int main(int argc, char * argv[])
{
        unsigned long *new_mask;
        unsigned long cur_mask;
        unsigned long processor;
        unsigned long value=1;
        int value2=1;
        int i;
        unsigned int len = sizeof(new_mask);
        pid_t pid;
        pid_t mypid;
        processor=atol(argv[1]);
        new_mask=(unsigned long *)malloc(sizeof(unsigned long));
        *new_mask=1;
        for( i=0; i < processor ; i++ )
                *new_mask=*new_mask*2;
        printf("procesor %d Mask %d\n",processor,*new_mask);
        mypid=getpid();
                mypid=getpid();
                printf("coucou %d %d\n",mypid,getpid());
                puts(argv[2]);
                printf("%d\n",INLINE_SYSCALL (sched_setaffinity, 3, mypid,
sizeof (unsigned long),new_mask));
                printf("%d %d %d %d %d\n",errno,EFAULT,ESRCH,EPERM,EINVAL);
                printf("%d\n",INLINE_SYSCALL (set_mempolicy, 3, value2,
new_mask,value));
                printf("%d %d %d %d %d\n",errno,EFAULT,ESRCH,EPERM,EINVAL);
 
                printf("%d\n",execvp(argv[2],NULL));
                printf("%d %d %d %d %d\n",errno,EFAULT,ESRCH,EPERM,EINVAL);
                exit(0);
 
 
}

I do directly the system call wrapper inide the code as the glibc 2.3.4 provided
by Suse contains bugs which avoid to use it for such task.
To compile:
cc -I/root/glibc-2.3.3/  -I . runon.c
 
You need as well kernel source code into /roo/linux-2.6.8.1
and glibc-2.3.3 into root directory

To execute

./a.out <processor_id> <myprogram_name>

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
