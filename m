Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 7B30538CAB
	for <linux-mm@kvack.org>; Tue, 31 Jul 2001 18:23:59 -0300 (EST)
Date: Tue, 31 Jul 2001 18:23:58 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: RFC:  2.4 VM statistics  -  libproc
Message-ID: <Pine.LNX.4.33L.0107311821540.5582-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: procps-list@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

the following patch makes libproc able to gather the new
(well, not so new any more ;)) VM statistics the 2.4 kernel
outputs.

Patches against top and vmstat will follow in the next
mails.

Any objections against applying this to the procps
CVS tree at sources.redhat.com ?

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


--- proc/sysinfo.h.orig	Tue Nov  2 13:44:58 1999
+++ proc/sysinfo.h	Tue Jul 31 18:09:12 2001
@@ -15,7 +15,9 @@
 		   meminfo_swap };

 enum meminfo_col { meminfo_total = 0, meminfo_used, meminfo_free,
-		   meminfo_shared, meminfo_buffers, meminfo_cached
+		   meminfo_shared, meminfo_buffers, meminfo_cached,
+		   meminfo_swapcached, meminfo_active, meminfo_inact_dirty,
+		   meminfo_inact_clean, meminfo_inact_target
 };

 extern unsigned read_total_main(void);
--- proc/sysinfo.c.orig	Wed Jul 26 18:30:32 2000
+++ proc/sysinfo.c	Tue Jul 31 18:20:13 2001
@@ -232,12 +232,12 @@
  * labels which do not *begin* with digits, though.
  */
 #define MAX_ROW 3	/* these are a little liberal for flexibility */
-#define MAX_COL 7
+#define MAX_COL 11
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
@@ -290,6 +290,36 @@
 	    		p+=k;
     			sscanf(p," %Ld",&(row[meminfo_main][meminfo_cached]));
     			row[meminfo_main][meminfo_cached]<<=10;
+    			while(*p++ != '\n');
+    		}
+	    	else if(!strcmp(fieldbuf,"SwapCached:")) {
+	    		p+=k;
+    			sscanf(p," %Ld",&(row[meminfo_main][meminfo_swapcached]));
+    			row[meminfo_main][meminfo_swapcached]<<=10;
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
