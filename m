Received: from chaos.analogic.com (chaos.analogic.com [204.178.40.224])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA11212
	for <linux-mm@kvack.org>; Wed, 17 Mar 1999 18:12:51 -0500
Date: Wed, 17 Mar 1999 18:12:22 -0500 (EST)
From: "Richard B. Johnson" <root@chaos.analogic.com>
Reply-To: root@chaos.analogic.com
Subject: Re: weird calloc problem
In-Reply-To: <199903171547.PAA00908@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990317180745.629A-100000@chaos.analogic.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: saraniti@ece.iit.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Mar 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Tue, 9 Mar 1999 19:51:32 -0600 (EST), marco saraniti
> <saraniti@neumann.ece.iit.edu> said:
> 
> > I'm having a calloc problem that made me waste three weeks, at this point
> > I'm out of options, and I was wondering if this can be a kernel- or
> > MM-related problem. Furthermore, the system is a relatively big machine and
> > I'd like to share my experience with other people who are interested in
> > using Linux for number crunching.
> 
> > The problem is trivial: calloc returns a NULL, even if there is a lot
> > of free memory. Yes, both arguments of calloc are always > 0.
> 

Here is a simple program and its output that, on my system, clearly
shows that if I want more array-space I just need to increase the size
of my swap file.

Script started on Wed Mar 17 18:05:00 1999
# show
         Crunching 1048576 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 17907712 312451072  2613248  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 1572864 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 20004864 310353920  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 2359296 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 23150592 307208192  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 3538944 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 27869184 302489600  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 5308416 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 34947072 295411712  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 7962624 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 45563904 284794880  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 11943936 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 61489152 268869632  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 17915904 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 85381120 244977664  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 26873856 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 121245696 209113088  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 40310784 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 175046656 155312128  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 60466176 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 255746048 74612736  2621440  5787648  2535424
SwapTotal:   248996 kB
SwapFree:    248996 kB

         Crunching 90699264 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 327876608  2482176  2293760  5787648  7868416
SwapTotal:   248996 kB
SwapFree:    196036 kB

         Crunching 136048896 elements
        total:    used:    free:  shared: buffers:  cached:
Mem:  330358784 328028160  2330624   569344  5787648  4739072
SwapTotal:   248996 kB
SwapFree:     21924 kB

calloc(816293376) failed
# exit
exit

Script done on Wed Mar 17 18:06:20 1999



Here is the test program.

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#define ARRAY 0x100000
#define BUF_LEN 0x100

int main(void);
int main()
{
    char buf[BUF_LEN];
    size_t len, i, half;
    size_t *pf;
    FILE *file;

    len = ARRAY;
    for(;;)
    {
        if((pf = (size_t *) calloc(len, sizeof(size_t))) == NULL)
        {
            fprintf(stderr, "calloc(%lu) failed\n", len * sizeof(size_t));
            exit(EXIT_FAILURE);
        }
        fprintf(stdout, "         Crunching %u elements\n", len);
        for(i=0; i< len; i++)
            pf[i] = i;

/*
 * seek and rewind don't work on proc (files have no size)
 */
        if((file = fopen ("/proc/meminfo", "r")) == NULL)
        {
            fprintf(stderr, "You need the /proc file system mounted");
            exit(EXIT_FAILURE);
        }
        fgets(buf,BUF_LEN, file);
        fprintf(stdout, buf);
        fgets(buf,BUF_LEN, file);
        fprintf(stdout, buf);
        fgets(buf,BUF_LEN, file);
        fgets(buf,BUF_LEN, file);
        fgets(buf,BUF_LEN, file);
        fgets(buf,BUF_LEN, file);
        fgets(buf,BUF_LEN, file);
        fgets(buf,BUF_LEN, file);
        fgets(buf,BUF_LEN, file);
        fprintf(stdout, buf);
        fgets(buf,BUF_LEN, file);
        fprintf(stdout, buf);
        puts("");
        fclose(file);
        free(pf);
        len += (len / 2);
    }
   return 0;
}



Cheers,
Dick Johnson
                 ***** FILE SYSTEM WAS MODIFIED *****
Penguin : Linux version 2.2.3 on an i686 machine (400.59 BogoMips).
Warning : It's hard to remain at the trailing edge of technology.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
