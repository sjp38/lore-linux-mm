Date: Sun, 4 Jul 1999 10:11:07 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fix for OOM deadlock in swap_in (2.2.10) [Re: [test
 program] for OOM situations ]
In-Reply-To: <Pine.LNX.4.03.9907041142420.216-100000@mirkwood.nl.linux.org>
Message-ID: <Pine.LNX.4.10.9907041002520.1352-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Bernd Kaindl <bk@suse.de>, Linux Kernel <linux-kernel@vger.rutgers.edu>, kernel@suse.de, linux-mm@kvack.org, Alan Cox <alan@redhat.com>
List-ID: <linux-mm.kvack.org>


On Sun, 4 Jul 1999, Rik van Riel wrote:

> On Sat, 3 Jul 1999, Andrea Arcangeli wrote:
> 
> > +void oom(void)
> >  {
> ...
> > +	force_sig(SIGKILL, current);
> 
> > I would like to get some feedback about the patch. Thanks :).
> 
> I'm curious why you haven't yet included my process
> selection algoritm. I know it can select a blocked
> or otherwise unkillable process the way the code is
> in right now, but a workaround for that can be made
> in about 5 minutes.

Andreas patch has a much more serious problem: it changes accepted UNIX
semantics. Try this before and after the patch:

#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define PAGE_SIZE 4096

int main(int argc, char **argv)
{
        int fd;
        char * map;

        fd = open("/tmp/duh", O_RDWR | O_CREAT, 0666);
        if (fd < 0)
                exit(1);
        ftruncate(fd, PAGE_SIZE);
        map = mmap(NULL, PAGE_SIZE*2, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        *(volatile char *)(map+PAGE_SIZE);
        return 0;
}

and see the difference..

I have tried to fix this _correctly_ in 2.3.10-pre2. That fix could be
back-ported to 2.2.x, but Andreas patch really is not acceptable.

And Andrea, I told you this once already in private email. I told you why.
Why don't you listen? "Fixing" a bug badly is worse than leaving it as a
known bug.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
