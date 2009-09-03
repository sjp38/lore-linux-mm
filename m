Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D2E016B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 08:28:31 -0400 (EDT)
Message-ID: <4A9FB83F.2000605@redhat.com>
Date: Thu, 03 Sep 2009 15:36:15 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: improving checksum cpu consumption in ksm
References: <4A983C52.7000803@redhat.com> <Pine.LNX.4.64.0908312233340.23516@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908312233340.23516@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
>
> But the first thing to try (measure) would be Jozsef's patch, updating
> jhash.h from the 1996 Jenkins lookup2 to the 2006 Jenkins lookup3,
> which is supposed to be a considerable improvement from all angles.
>
> See http://lkml.org/lkml/2009/2/12/65
>
>   

Hi,
I just did small test of the new hash compare to the old

using the program below, i ran ksm (with nice -20)
at time_to_sleep_in_millisecs = 1
run = 1
pages_to_scan = 9999

(The program is designing just to  pressure the hash calcs and tree 
walking (and not to share any page really)

then i checked how many full_scans have ksm reached (i just checked 
/sys/kernel/mm/ksm/full_scans)

And i got the following results:
with the old jhash version ksm did 395 loops
with the new jhash version ksm did 455 loops
we got here 15% improvment for this case where we have pages that are 
static but are not shareable...
(And it will help in any case we got page we are not merging in the 
stable tree)

I think it is nice...

(I used  AMD Phenom(tm) II X3 720 Processor, but probably i didnt run 
the test enougth, i should rerun it again and see if the results are 
consistent)

(Another thing is that I had conflit with something of 
JHASH_GOLDEN_NUNBER? i just added back that define and the kernel was 
compiling)

Thanks.


#include <malloc.h>
#include <stdio.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

int main()
{
    int x;
    unsigned char *p, *tmp;
    unsigned char *p_end;

    p = (unsigned char *) malloc(1024 * 1024 * 100 + 4096);
    if (!p) {
        printf("error\n");
    }

    p_end = p + 1024 * 1024 * 100;
    p = (unsigned char *)((unsigned long)p & ~4095);

    tmp = p;
    for(; tmp != p_end; ++tmp) {
        *tmp = (unsigned char)random();
    }

    if (madvise(p, 1024 * 1024 * 100, 12) == -1) {
        perror("madvise");
    }

    sleep(60);

    return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
