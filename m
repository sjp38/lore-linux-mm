Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA18926
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 19:54:58 -0500
Date: Mon, 30 Nov 1998 21:02:05 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Update shared mappings
In-Reply-To: <199811301352.NAA03313@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981130204515.498H-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko.Calusic@CARNet.hr, Linux-MM List <linux-mm@kvack.org>, Andi Kleen <andi@zero.aec.at>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Nov 1998, Stephen C. Tweedie wrote:

>The mmap_semaphore is already taken out _much_ earlier on in msync(), or
>the vm_area_struct can be destroyed by another thread.  Is this patch

Infact the down you see is done on a different mmstruct. It has to be a
diffent mm struct.

>tested?  Won't we deadlock immediately on doing this extra down()

Sure.

>operation? 

No.

>The only reason that this patch works in its current state is that
>exit_mmap() skips the down(&mm->mmap_sem).  It can safely do so only

I guess you have not read the patch well...

>because if we are exiting the mmap, we know we are the last thread and
>so no other thread can be playing games with us.  So, exit_mmap()
>doesn't deadlock, but a sys_msync() on the region looks as if it will.

???

I reproduced the StarOffice deadlock here also without my patch. And the
guy that said me that my patch was deadlocking staroffice then said me
that now staroffice was working also with my patch applyed...

Stephen I can' t see the obvious deadlocking you are tolking about. The
mmap semphore can be held for many processes but not two times for the
same one and never for the current one. The code should work fine also
with CLONE_VM. I have no pending bug reports btw. 

I am using the patch from day 0 and I never deadlocked. The only proggy I
used specifically to try my update_shared_mappings() code is this though:

#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>

/* file size, should be half of the size of the physical memory  */
#define FILESIZE (5 * 1024 * 1024)

int main(void)
{
  char *ptr;
  int fd, i;
  char c = 'A';
  pid_t pid;

  if ((fd = open("foo", O_RDWR | O_CREAT | O_EXCL, 0666)) == -1) {
    perror("open");
    exit(1);
  }
  lseek(fd, FILESIZE - 1, SEEK_SET);
  /* write one byte to extend the file */
  write(fd, &fd, 1);
  ptr = mmap(0, FILESIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (ptr == NULL) {
    perror("mmap");
    exit(1);
  }

  /* dirty every page in the mapping */
  for (i = 0; i < FILESIZE; i += 4096)
    ptr[i] = c;

  while (1) {
    if ((pid = fork())) { /* parent, wait */
      waitpid(pid, NULL, 0);
    } else { /* child, exec away */
	    msync(ptr, FILESIZE, MS_SYNC);
    }
    sleep(5);
  }
}

Let me know if the code still need fixing. A proggy that trigger the bug
would be helpful btw ;)

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
