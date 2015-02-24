Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id B64746B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 18:21:41 -0500 (EST)
Received: by qcyl6 with SMTP id l6so255811qcy.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:21:41 -0800 (PST)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id 22si32395689qhx.59.2015.02.24.15.21.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 15:21:40 -0800 (PST)
Date: Tue, 24 Feb 2015 17:54:01 -0500 (EST)
From: Laurence Oberman <loberman@redhat.com>
Message-ID: <929656406.8173168.1424818441544.JavaMail.zimbra@redhat.com>
In-Reply-To: <CA+55aFwa5YeW6T+Fo=CFs4RrtNAAy_snWxvG2CjS7KSwj07VOw@mail.gmail.com>
References: <9cc2b63100622f5fd17fa5e4adc59233a2b41877.1424779443.git.aquini@redhat.com> <CA+55aFz4D9fS1xt7fg0R9Bnngg+_TbNs3fSAaFwoV7eTeLfP5Q@mail.gmail.com> <20150224220843.GL19014@t510.redhat.com> <CA+55aFwa5YeW6T+Fo=CFs4RrtNAAy_snWxvG2CjS7KSwj07VOw@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: get back a sensible upper limit
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Larry Woodman <lwoodman@redhat.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

----- Original Message -----
From: "Linus Torvalds" <torvalds@linux-foundation.org>
To: "Rafael Aquini" <aquini@redhat.com>
Cc: "linux-mm" <linux-mm@kvack.org>, "Andrew Morton" <akpm@linux-foundation.org>, "Johannes Weiner" <jweiner@redhat.com>, "Rik van Riel" <riel@redhat.com>, "David Rientjes" <rientjes@google.com>, "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>, loberman@redhat.com, "Larry Woodman" <lwoodman@redhat.com>, "Raghavendra K T" <raghavendra.kt@linux.vnet.ibm.com>
Sent: Tuesday, February 24, 2015 5:12:28 PM
Subject: Re: [PATCH] mm: readahead: get back a sensible upper limit

On Tue, Feb 24, 2015 at 2:08 PM, Rafael Aquini <aquini@redhat.com> wrote:
>
> Would you consider bringing it back, but instead of node memory state,
> utilizing global memory state instead?

Maybe. At least it would be saner than picking random values that make
absolutely no sense.

> People filing bugs complaining their applications that memory map files
> are getting hurt by it.

Show them. And as mentioned, last time this came up (and it has come
up before), it wasn't actually a real load, but some benchmark that
just did the prefetch, and then people were upset because their
benchmark numbers changed.

Which quite frankly doesn't make me care. The benchmark could equally
well just be changed to do prefetching in saner chunks instead.

So I really want to see real numbers from real loads, not some
nebulous "people noticed and complain" that doesn't even specify what
they did.

                         Linus
Hello

Any way to get a change in even if its global would help this customer and others.
They noticed this change (they call it performance regression) when they went to the newer kernel.
I understand that we wont be able to revert.

Patch applied to our kernel

diff -Nurp linux-2.6.32-504.3.3.el6.orig/mm/readahead.c linux-2.6.32-504.3.3.el6/mm/readahead.c
--- linux-2.6.32-504.3.3.el6.orig/mm/readahead.c        2014-12-12 15:29:35.000000000 -0500
+++ linux-2.6.32-504.3.3.el6/mm/readahead.c        2015-02-03 11:05:15.103030796 -0500
@@ -228,14 +228,14 @@ int force_page_cache_readahead(struct ad
         return ret;
 }
 
-#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)
 /*
  * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
  * sensible upper limit.
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-        return min(nr, MAX_READAHEAD);
+        return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
+                + node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
 
 /*

This is the customers requirement:

Note:

The customer wants the default read_ahead_kb to be small 32, and control the size when necessary via posix_fadvise().

"
To reiterate, what we want is readahead to be small (we use 32KB in production), but leverage posix_fadvise if we need to load a big file.
In the past that worked since I/O size was only limited by max_sectors_kb.
In the newer kernel it does not work anymore, since readahead also limits I/O sizes
"

Test program used to reproduce.

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h> /* mmap() is defined in this header */
#include <fcntl.h>

int err_quit(char *msg)
{
    printf(msg);
    return 0;
}

int main (int argc, char *argv[])
{
 int fdin;
 char *src;
 char dst[262144];
 struct stat statbuf;
 int mode = 0x0777;
 unsigned long i;
 long ret;

 if (argc != 2)
   err_quit ("usage: a.out <fromfile> <tofile>\n");

 /* open the input file */
 if ((fdin = open (argv[1], O_RDONLY)) < 0)
   {printf("can't open %s for reading\n", argv[1]);
    return 0;
   }

 ret=posix_fadvise(fdin,0,0,POSIX_FADV_WILLNEED);
 printf("ret = %ld\n",ret);

 /* find size of input file */
 if (fstat (fdin,&statbuf) < 0)
   {printf ("fstat error\n");
    return 0;
   }
 printf("Size of input file = %ld\n",statbuf.st_size);

 /* mmap the input file */
 if ((src = mmap (0, statbuf.st_size, PROT_READ, MAP_SHARED, fdin, 0))
   == (caddr_t) -1)
   {printf ("mmap error for input");
    return 0;
   }

 /* this copies the input file to the data buffer using 256k blocks*/
 
 for (i=0;i< statbuf.st_size-262144; i+=262144) {
         memcpy (dst, src+i, 262144);
 }
 return 0;

} /* main */


Without the patch
-----------------
Here we land up being constrained to 32, see reads (Size) below.

read_ahead set to 32.
queue]# cat read_ahead_kb
32

echo 3 > /proc/sys/vm/drop_caches

time ./mmapexe ./xaa
Size of input file = 1048576000

Run time is > 3 times the time seen when the patch is applied.

real        0m21.101s
user        0m0.295s
sys        0m0.744s

I/O size below is constrained to 32, see reads (Size)

# DISK STATISTICS (/sec)
#                   <---------reads---------><---------writes---------><--------averages--------> Pct
#Time     Name       KBytes Merged  IOs Size  KBytes Merged  IOs Size  RWSize  QLen  Wait SvcTim Util
09:47:43 sdg              0      0    0    0       0      0    0    0       0     0     0      0    0
09:47:44 sdg           3660      0   59   62       0      0    0    0      62     2     3      1    7
09:47:45 sdg          59040      0 1845   32       0      0    0    0      32     1     1      0  100
09:47:46 sdg          58624      0 1832   32       0      0    0    0      32     1     1      0   99
09:47:47 sdg          63072      0 1971   32       0      0    0    0      32     1     1      0   99
09:47:48 sdg          61856      0 1933   32       0      0    0    0      32     1     1      0   99
09:47:49 sdg          59488      0 1859   32       0      0    0    0      32     1     1      0   99
09:47:50 sdg          62240      0 1945   32       0      0    0    0      32     1     1      0   99
09:47:51 sdg          42080      0 1315   32       0      0    0    0      32     1     1      0   99
09:47:52 sdg          22112      0  691   32       0      0    0    0      32     1     3      1   99
09:47:53 sdg          42240      0 1320   32       0      0    0    0      32     1     1      0   99
09:47:54 sdg          41472      0 1296   32       0      0    0    0      32     1     1      0   99
09:47:55 sdg          42080      0 1315   32       0      0    0    0      32     1     1      0   99
09:47:56 sdg          42112      0 1316   32       0      0    0    0      32     1     1      0   99
09:47:57 sdg          42144      0 1317   32       0      0    0    0      32     1     1      0   99
09:47:58 sdg          42176      0 1318   32       0      0    0    0      32     1     1      0   99
09:47:59 sdg          42048      0 1314   32       0      0    0    0      32     1     1      0   99
09:48:00 sdg          40384      0 1262   32       0      0    0    0      32     1     1      0   99
09:48:01 sdg          29792      0  931   32       0      0    0    0      32     1     1      1   99
09:48:02 sdg          49984      0 1562   32       0      0    0    0      32     1     1      0   99
09:48:03 sdg          59488      0 1859   32       0      0    0    0      32     1     1      0   99
09:48:04 sdg          59520      0 1860   32       0      0    0    0      32     1     1      0   99
09:48:05 sdg          57664      0 1802   32       0      0    0    0      32     1     1      0  100
..

With the revert patch.
----------------------

read_ahead set to 32.
queue]# cat read_ahead_kb
32

[queue]# echo 3 > /proc/sys/vm/drop_caches

I/O sizes are able to use the larger size (512) using to the posix_fadvise()

[queue]# collectl -sD -oT -i1 | grep -e "#" -e sdg
# DISK STATISTICS (/sec)
#                   <---------reads---------><---------writes---------><--------averages--------> Pct
#Time     Name       KBytes Merged  IOs Size  KBytes Merged  IOs Size  RWSize  QLen  Wait SvcTim Util
21:49:11 sdg              0      0    0    0       0      0    0    0       0     0     0      0    0
21:49:12 sdg              0      0    0    0       0      0    0    0       0     0     0      0    0
21:49:13 sdg              0      0    0    0       0      0    0    0       0     0     0      0    0
21:49:14 sdg              0      0    0    0       0      0    0    0       0     0     0      0    0
21:49:15 sdg              0      0    0    0       0      0    0    0       0     0     0      0    0
21:49:16 sdg              0      0    0    0       0      0    0    0       0     0     0      0    0
21:49:17 sdg          23568    183   53  445       0      0    0    0     444   130   100      3   20
21:49:18 sdg         162304    320  317  512       0      0    0    0     512   143   418      3   99
21:49:19 sdg         163840    320  320  512       0      0    0    0     512   143   447      3   99
21:49:20 sdg         163840    320  320  512       0      0    0    0     512   143   447      3   99
21:49:21 sdg         163840    320  320  512       0      0    0    0     512   143   447      3   99
21:49:22 sdg         163840    320  320  512       0      0    0    0     512   143   447      3   99
21:49:23 sdg         163840    213  320  512       0      0    0    0     512   125   447      3   99
21:49:24 sdg          18944      0   37  512       0      0    0    0     512    19   442      2    9
21:49:25 sdg              0      0    0    0       0      0    0    0       0     0     0      0    0

time ./mmapexe ./xaa

Size of input file = 1048576000

real        0m6.329s
user        0m0.243s
sys        0m0.260s


Laurence Oberman
Red Hat Global Support Service
SEG Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
