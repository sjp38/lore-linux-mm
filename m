Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id EABC738CA4
	for <linux-mm@kvack.org>; Tue, 31 Jul 2001 18:27:50 -0300 (EST)
Date: Tue, 31 Jul 2001 18:27:50 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: RFC:  2.4 VM statistics  -  top
Message-ID: <Pine.LNX.4.33L.0107311826030.5582-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: procps-list@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

the following patch adds an extra line to the memory output of top,
displaying the Linux 2.4 VM statistics as follows:

  6:26pm  up 24 days,  1:38,  9 users,  load average: 0.02, 0.16, 0.38
90 processes: 89 sleeping, 1 running, 0 zombie, 0 stopped
CPU states:  1.5% user,  1.2% system,  0.0% nice, 97.2% idle
Mem:   174212K av,  165104K used,    9108K free,       8K shrd,   50552K buff
                     51220K actv,   74172K in_d,     300K in_c,      32K target
Swap:  208804K av,  118164K used,   90640K free                   75132K cached

Any objections to adding this patch to the code base ?

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"



--- top.c.orig	Wed Jul 26 18:30:32 2000
+++ top.c	Tue Jul 31 18:06:57 2001
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
