Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 2BDA038C8F
	for <linux-mm@kvack.org>; Tue, 31 Jul 2001 18:26:01 -0300 (EST)
Date: Tue, 31 Jul 2001 18:26:00 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: RFC:  2.4 VM statistics  -  vmstat
Message-ID: <Pine.LNX.4.33L.0107311824010.5582-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: procps-list@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here is the patch against vmstat, which uses the patch
against libproc and displays the kernel 2.4 VM statistics.

Yes, the vmstat code sucks, but since I need these stats
on a daily basis I'd like to get this thing supported
before starting on a vmstat.c cleanup (with marcelo?).

Any objections against applying it to the procps CVS
tree at sources.redhat.com ?

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


--- vmstat.c.orig	Mon Jul 10 19:02:43 2000
+++ vmstat.c	Tue Jul 31 18:06:57 2001
@@ -50,9 +50,10 @@
 void getstat(unsigned *, unsigned *, unsigned *, unsigned long *,
 	     unsigned *, unsigned *, unsigned *, unsigned *,
 	     unsigned *, unsigned *, unsigned *);
-void getmeminfo(unsigned *, unsigned *, unsigned *, unsigned *);
+void getmeminfo(unsigned *, unsigned *, unsigned *, unsigned *, unsigned int);
 void getrunners(unsigned *, unsigned *, unsigned *);
 static char buff[BUFFSIZE]; /* used in the procedures */
+static unsigned int actinact=FALSE;

 /***************************************************************
                              Main
@@ -60,7 +61,7 @@

 int main(int argc, char *argv[]) {

-  const char format[]="%2u %2u %2u %6u %6u %6u %6u %3u %3u %5u %5u %4u %5u %3u %3u %3u\n";
+  const char format[]="%2u %2u %2u %6u %6u %6u %6u %4u %4u %5u %5u %4u %5u %2u %2u %2u\n";
   unsigned int height=22; /* window height, reset later if needed. */
   unsigned long int args[2]={0,0};
   unsigned int moreheaders=TRUE;
@@ -90,6 +91,9 @@
       case 'n':
 	/* print only one header */
 	moreheaders=FALSE;
+      case 'a':
+	/* Print active/inactive instead of buff/cache */
+	actinact=TRUE;
       break;
       default:
 	/* no other aguments defined yet. */
@@ -120,7 +124,7 @@
   pero2=(per/2);
   showheader();
   getrunners(&running,&blocked,&swapped);
-  getmeminfo(&memfree,&membuff,&swapused,&memcache);
+  getmeminfo(&memfree,&membuff,&swapused,&memcache, actinact);
   getstat(cpu_use,cpu_nic,cpu_sys,cpu_idl,
 	  pgpgin,pgpgout,pswpin,pswpout,
 	  inter,ticks,ctxt);
@@ -146,7 +150,7 @@
     if (moreheaders && ((i%height)==0)) showheader();
     tog= !tog;
     getrunners(&running,&blocked,&swapped);
-    getmeminfo(&memfree,&membuff,&swapused,&memcache);
+    getmeminfo(&memfree,&membuff,&swapused,&memcache, actinact);
     getstat(cpu_use+tog,cpu_nic+tog,cpu_sys+tog,cpu_idl+tog,
 	  pgpgin+tog,pgpgout+tog,pswpin+tog,pswpout+tog,
 	  inter+tog,ticks+tog,ctxt+tog);
@@ -175,6 +179,7 @@
   fprintf(stderr,"usage: %s [-V] [-n] [delay [count]]\n",PROGNAME);
   fprintf(stderr,"              -V prints version.\n");
   fprintf(stderr,"              -n causes the headers not to be reprinted regularly.\n");
+  fprintf(stderr,"              -a print active/inactive page stats.\n");
   fprintf(stderr,"              delay is the delay between updates in seconds. \n");
   fprintf(stderr,"              count is the number of updates.\n");
   exit(EXIT_FAILURE);
@@ -197,9 +202,14 @@


 void showheader(void){
-  printf("%8s%28s%8s%12s%11s%12s\n",
+  printf("%8s%28s%10s%12s%11s%9s\n",
 	 "procs","memory","swap","io","system","cpu");
-  printf("%2s %2s %2s %6s %6s %6s %6s %3s %3s %5s %5s %4s %5s %3s %3s %3s\n",
+  if (actinact)
+     printf("%2s %2s %2s %6s %6s %6s %6s %4s %4s %5s %5s %4s %5s %2s %2s %2s\n",
+	 "r","b","w","swpd","free","inact","active","si","so","bi","bo",
+	 "in","cs","us","sy","id");
+  else
+     printf("%2s %2s %2s %6s %6s %6s %6s %4s %4s %5s %5s %4s %5s %2s %2s %2s\n",
 	 "r","b","w","swpd","free","buff","cache","si","so","bi","bo",
 	 "in","cs","us","sy","id");
 }
@@ -232,13 +242,20 @@
   }
 }

-void getmeminfo(unsigned *memfree, unsigned *membuff, unsigned *swapused, unsigned *memcache) {
+void getmeminfo(unsigned *memfree, unsigned *membuff, unsigned *swapused, unsigned *memcache, unsigned int actinact) {
   unsigned long long** mem;
   if (!(mem = meminfo())) crash("/proc/meminfo");
   *memfree  = mem[meminfo_main][meminfo_free]    >> 10;	/* bytes to k */
-  *membuff  = mem[meminfo_main][meminfo_buffers] >> 10;
   *swapused = mem[meminfo_swap][meminfo_used]    >> 10;
-  *memcache = mem[meminfo_main][meminfo_cached]  >> 10;
+  if (actinact) {
+	  /* Get alternate values instead... */
+	  *membuff  = mem[meminfo_main][meminfo_inact_dirty]  >> 10;
+	  *membuff += mem[meminfo_main][meminfo_inact_clean] >> 10;
+	  *memcache = mem[meminfo_main][meminfo_active] >> 10;
+  } else {
+	  *membuff  = mem[meminfo_main][meminfo_buffers] >> 10;
+	  *memcache = mem[meminfo_main][meminfo_cached]  >> 10;
+  }
 }

 void getrunners(unsigned int *running, unsigned int *blocked,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
