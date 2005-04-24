Date: Sat, 23 Apr 2005 21:18:19 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bug 4520] New: /proc/*/maps fragments too quickly compared to
 2.4
Message-Id: <20050423211819.3ec82cc7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@kvack.org, wwc@rentec.com
List-ID: <linux-mm.kvack.org>

Guys, Wolfgang has found what appears to be a serious mmap fragmentation
problem with the mm_struct.free_area_cache.


Begin forwarded message:

Date: Tue, 19 Apr 2005 11:55:44 -0700
From: bugme-daemon@osdl.org
To: akpm@digeo.com
Subject: [Bug 4520] New: /proc/*/maps fragments too quickly compared to 2.4


http://bugme.osdl.org/show_bug.cgi?id=4520

           Summary: /proc/*/maps fragments too quickly compared to 2.4
    Kernel Version: 2.6.11.4
            Status: NEW
          Severity: normal
             Owner: akpm@digeo.com
         Submitter: wwc@rentec.com


Distribution: Suse 9.2
Hardware Environment: Dual AMD64 / 8GB memory
Software Environment: 64 bit kernel 2.6.11.2 or .4 running 32 bit application
Problem Description: 
The appended c program, compiled in 32 bit mode, runs on our 2.6.11.4 (64bit
kernel) out of memory after a short while. 

Once this happens the programs copies /proc/self/maps to stdout which is large
and very fragmented.  

The same program runs 'forever' and after that ;-) /proc/self/maps only 
contains a few entries of very large mmapped regions.

Steps to reproduce:
Compile the program below in 32 bit mode, run on 2.4 and 2.6 kernels.


#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>

#define numMaps   600
#define largeArea 9500000
#define forEver   1000000
#define oneMeg    0x100000

void
aLLocator()
{

  char* bvec[numMaps];
  unsigned int i;
  memset( bvec,0,sizeof(bvec));
	 
  for(  i = 0; i < forEver ; ++i ) {
    unsigned oidx;
    unsigned kidx;
    int len;
    /* munmap old entries */
    oidx = (i+numMaps/10) % numMaps;
    len = (oidx & 7) ? ((oidx&7)* oneMeg) : largeArea; /* map size */
    if( bvec[oidx] ) { munmap( bvec[oidx], len ); bvec[oidx] = 0; }

    /* mmap new ones */
    kidx = i % numMaps;
    len = (kidx & 7) ? ((kidx&7)* oneMeg) : largeArea; /* map size */
    bvec[kidx] = (char*)(mmap(0, len, PROT_READ|PROT_WRITE,
			      MAP_PRIVATE|MAP_ANONYMOUS, -1, 0));

    if( bvec[kidx] == (char*)(-1) ) {
      printf("Failed after %d rounds\n", i);
      break;
    }
  }
}

int main() {
  FILE *f;
  int c;

  aLLocator();

  f = fopen( "/proc/self/maps", "r" );
  while( (c = fgetc(f)) != EOF )
    putchar(c);
  fclose(f);
  
  return 0;
}

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
