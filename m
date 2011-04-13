Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3651B900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 09:56:02 -0400 (EDT)
Message-ID: <112566.51053.qm@web162019.mail.bf1.yahoo.com>
Date: Wed, 13 Apr 2011 06:56:00 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Re: Regarding memory fragmentation using malloc....
In-Reply-To: <BANLkTi=7KHMA_JOwQcMQj5M+XU=qO07s2g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

Hi,

My requirement is, I wanted to measure memory fragmentation level in linux =
kernel2.6.29 (ARM cortex A8 without swap).
How can I measure fragmentation level(percentage) from /proc/buddyinfo ?

Example : After each page allocation operation, I need to measure fragmenta=
tion level. If the level is above 80%, I will trigger a OOM or something to=
 the user.
How can I reproduce this memory fragmentation scenario using a sample progr=
am?

Here is my sample program: (to check page allocation using malloc)
----------------------------------------------
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<errno.h>
#include<unistd.h>


#define PAGE_SIZE       (4*1024)

#define MEM_BLOCK       (64*PAGE_SIZE)


#define MAX_LIMIT       (16)

int main()
{
        char *ptr[MAX_LIMIT+1] =3D {NULL,};
        int i =3D 0;

        printf("Requesting <%d> blocks of memory of block size <%d>........=
\n",MAX_LIMIT,MEM_BLOCK);
        system("cat /proc/buddyinfo");
        system("cat /proc/zoneinfo | grep free_pages");
        printf("*****************************************\n\n\n");
        for(i=3D0; i<MAX_LIMIT; i++)
        {
                ptr[i] =3D (char *)malloc(sizeof(char)*MEM_BLOCK);
                if(ptr[i] =3D=3D NULL)
                {
                        printf("ERROR : malloc failed(counter %d) <%s>\n",i=
,strerror(errno));
                        system("cat /proc/buddyinfo");
                        system("cat /proc/zoneinfo | grep free_pages");
                        printf("press any key to terminate......");
                        getchar();
                        exit(0);
                }
                memset(ptr[i],1,MEM_BLOCK);
                sleep(1);
                //system("cat /proc/buddyinfo");
                //system("cat /proc/zoneinfo | grep free_pages");
                //printf("-----------------------------------------\n");
        }

        sleep(1);
        system("cat /proc/buddyinfo");
        system("cat /proc/zoneinfo | grep free_pages");
        printf("-----------------------------------------\n");

        printf("press any key to end......");
        getchar();

        for(i=3D0; i<MAX_LIMIT; i++)
        {
                if(ptr[i] !=3D NULL)
                {
                        free(ptr[i]);
                }
        }

        printf("DONE !!!\n");

        return 0;
}
EACH BLOCK SIZE =3D 64 Pages =3D=3D> (64 * 4 * 1024)
TOTAL BLOCKS =3D 16
----------------------------------------------
In my linux2.6.29 ARM machine, the initial /proc/buddyinfo shows the follow=
ing:
Node 0, zone      DMA     17     22      1      1      0      1      1     =
 0      0      0      0      0
Node 1, zone      DMA     15    320    423    225     97     26      1     =
 0      0      0      0      0

After running my sample program (with 16 iterations) the buddyinfo output i=
s as follows:
Requesting <16> blocks of memory of block size <262144>........
Node 0, zone      DMA     17     22      1      1      0      1      1     =
 0      0      0      0      0
Node 1, zone      DMA     15    301    419    224     96     27      1     =
 0      0      0      0      0
    nr_free_pages 169
    nr_free_pages 6545
*****************************************


Node 0, zone      DMA     17     22      1      1      0      1      1     =
 0      0      0      0      0
Node 1, zone      DMA     18      2    305    226     96     27      1     =
 0      0      0      0      0
    nr_free_pages 169
    nr_free_pages 5514
-----------------------------------------

The requested block size is 64 pages (2^6) for each block.=20
But if we see the output after 16 iterations the buddyinfo allocates pages =
only from Node 1 , (2^0, 2^1, 2^2, 2^3).
But the actual allocation should happen from (2^6) block in buddyinfo.

Questions:
1) How to analyse buddyinfo based on each page block size?
2) How and in what scenario the buddyinfo changes?
3) Can we rely completely on buddyinfo information for measuring the level =
of fragmentation?

Can somebody through some more lights on this???

Thanks,
Pintu

--- On Wed, 4/13/11, Am=E9rico Wang <xiyou.wangcong@gmail.com> wrote:

> From: Am=E9rico Wang <xiyou.wangcong@gmail.com>
> Subject: Re: Regarding memory fragmentation using malloc....
> To: "Pintu Agarwal" <pintu_agarwal@yahoo.com>
> Cc: "Andrew Morton" <akpm@linux-foundation.org>, "Eric Dumazet" <eric.dum=
azet@gmail.com>, "Changli Gao" <xiaosuo@gmail.com>, "Jiri Slaby" <jslaby@su=
se.cz>, "azurIt" <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@=
kvack.org, linux-fsdevel@vger.kernel.org, "Jiri Slaby" <jirislaby@gmail.com=
>
> Date: Wednesday, April 13, 2011, 6:44 AM
> On Wed, Apr 13, 2011 at 2:54 PM,
> Pintu Agarwal <pintu_agarwal@yahoo.com>
> wrote:
> > Dear All,
> >
> > I am trying to understand how memory fragmentation
> occurs in linux using many malloc calls.
> > I am trying to reproduce the page fragmentation
> problem in linux 2.6.29.x on a linux mobile(without Swap)
> using a small malloc(in loop) test program of BLOCK_SIZE
> (64*(4*K)).
> > And then monitoring the page changes in
> /proc/buddyinfo after each operation.
> > From the output I can see that the page values under
> buddyinfo keeps changing. But I am not able to relate these
> changes with my malloc BLOCK_SIZE.
> > I mean with my BLOCK_SIZE of (2^6 x 4K =3D=3D> 2^6
> PAGES) the 2^6 th block under /proc/buddyinfo should change.
> But this is not the actual behaviour.
> > Whatever is the blocksize, the buddyinfo changes only
> for 2^0 or 2^1 or 2^2 or 2^3.
> >
> > I am trying to measure the level of fragmentation
> after each page allocation.
> > Can somebody explain me in detail, how actually
> /proc/buddyinfo changes after each allocation and
> deallocation.
> >
>=20
> What malloc() sees is virtual memory of the process, while
> buddyinfo
> shows physical memory pages.
>=20
> When you malloc() 64K memory, the kernel may not allocate a
> 64K
> physical memory at one time
> for you.
>=20
> Thanks.
> =0A=0A=0A      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
