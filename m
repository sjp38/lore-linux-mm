Date: Tue, 30 Jan 2001 12:08:42 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] new VM stats in procps
Message-ID: <Pine.LNX.4.21.0101301203470.1321-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: johnsonm@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[CC'd to linux-mm because people there will want it ;)]

Hi,

the following patch updates libproc, top and vmstat to
display the statistics from the new VM in 2.4.

Chances are that especially the top output is not in a
format you like, so feel free to change whatever you
want. It would be nice if some of the new VM statistics
could make it into a next release of procfs.

(and yes, I'll try to do documentation when I have time)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/



--- procps-2.0.7/proc/sysinfo.h.orig	Wed Nov  3 02:44:58 1999
+++ procps-2.0.7/proc/sysinfo.h	Fri Jan 12 12:43:04 2001
@@ -15,7 +15,9 @@
 		   meminfo_swap };
 
 enum meminfo_col { meminfo_total = 0, meminfo_used, meminfo_free,
-		   meminfo_shared, meminfo_buffers, meminfo_cached
+		   meminfo_shared, meminfo_buffers, meminfo_cached,
+		   meminfo_active, meminfo_inact_dirty, meminfo_inact_clean,
+		   meminfo_inact_target
 };
 
 extern unsigned read_total_main(void);
--- procps-2.0.7/proc/sysinfo.c.orig	Fri Jan 12 12:43:04 2001
+++ procps-2.0.7/proc/sysinfo.c	Fri Jan 12 12:43:04 2001
@@ -232,12 +232,12 @@
  * labels which do not *begin* with digits, though.
  */
 #define MAX_ROW 3	/* these are a little liberal for flexibility */
-#define MAX_COL 7
+#define MAX_COL 10 
 unsigned long long **meminfo(void){
     static unsigned long long *row[MAX_ROW + 1];		/* row pointers */
     static unsigned long long num[MAX_ROW * MAX_COL];	/* number storage */
     char *p;
-    char fieldbuf[12];		/* bigger than any field name or size in kb */
+    char fieldbuf[15];		/* bigger than any field name or size in kb */
     int i, j, k, l;
     
     FILE_TO_BUF(MEMINFO_FILE,meminfo_fd);
@@ -261,7 +261,7 @@
     }
     else {
 	    while(*p) {
-	    	sscanf(p,"%11s%n",fieldbuf,&k);
+	    	sscanf(p,"%13s%n",fieldbuf,&k);
 	    	if(!strcmp(fieldbuf,"MemTotal:")) {
 	    		p+=k;
 	    		sscanf(p," %Ld",&(row[meminfo_main][meminfo_total]));
@@ -290,6 +290,30 @@
 	    		p+=k;
     			sscanf(p," %Ld",&(row[meminfo_main][meminfo_cached]));
     			row[meminfo_main][meminfo_cached]<<=10;
+    			while(*p++ != '\n');
+    		}
+	    	else if(!strcmp(fieldbuf,"Active:")) {
+	    		p+=k;
+    			sscanf(p," %Ld",&(row[meminfo_main][meminfo_active]));
+    			row[meminfo_main][meminfo_active]<<=10;
+    			while(*p++ != '\n');
+    		}
+	    	else if(!strcmp(fieldbuf,"Inact_dirty:")) {
+	    		p+=k;
+    			sscanf(p," %Ld",&(row[meminfo_main][meminfo_inact_dirty]));
+    			row[meminfo_main][meminfo_inact_dirty]<<=10;
+    			while(*p++ != '\n');
+    		}
+	    	else if(!strcmp(fieldbuf,"Inact_clean:")) {
+	    		p+=k;
+    			sscanf(p," %Ld",&(row[meminfo_main][meminfo_inact_clean]));
+    			row[meminfo_main][meminfo_inact_clean]<<=10;
+    			while(*p++ != '\n');
+    		}
+	    	else if(!strcmp(fieldbuf,"Inact_target:")) {
+	    		p+=k;
+    			sscanf(p," %Ld",&(row[meminfo_main][meminfo_inact_target]));
+    			row[meminfo_main][meminfo_inact_target]<<=10;
     			while(*p++ != '\n');
     		}
     		else if(!strcmp(fieldbuf,"SwapTotal:")) {
--- procps-2.0.7/top.c.orig	Fri Jan 12 12:43:04 2001
+++ procps-2.0.7/top.c	Fri Jan 12 12:43:04 2001
@@ -166,7 +166,7 @@
 	    break;
 	  case 'm':
 	    show_memory = 0;
-	    header_lines -= 2;
+	    header_lines -= 3;
 	    break;
 	  case 'M':
 	    sort_type = S_MEM;
@@ -250,7 +250,7 @@
     cpu_mapping = (int *) xmalloc (sizeof (int) * nr_cpu);
     /* read cpuname */
     for (i=0; i< nr_cpu; i++) cpu_mapping[i]=i;
-    header_lines = 6 + nr_cpu;
+    header_lines = 7 + nr_cpu;
     strcpy(rcfile, SYS_TOPRC);
     fp = fopen(rcfile, "r");
     if (fp != NULL) {
@@ -1260,6 +1260,13 @@
 	       mem[meminfo_main][meminfo_free] >> 10,
 	       mem[meminfo_main][meminfo_shared] >> 10,
 	       mem[meminfo_main][meminfo_buffers] >> 10);
+	PUTP(top_clrtoeol);
+	putchar('\n');
+	printf("                   %7LdK actv, %7LdK in_d, %7LdK in_c, %7LdK target",
+		mem[meminfo_main][meminfo_active] >> 10,
+		mem[meminfo_main][meminfo_inact_dirty] >> 10,
+		mem[meminfo_main][meminfo_inact_clean] >> 10,
+		mem[meminfo_main][meminfo_inact_target] >> 10);
 	PUTP(top_clrtoeol);
 	putchar('\n');
 	printf("Swap: %7LdK av, %7LdK used, %7LdK free                 %7LdK cached",
--- procps-2.0.7/vmstat.c.orig	Tue Jul 11 08:02:43 2000
+++ procps-2.0.7/vmstat.c	Sat Jan 13 15:38:35 2001
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
see: http://www.linux.eu.org/Linux-MM/
