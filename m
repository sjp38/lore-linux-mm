Received: from d1o87.telia.com (d1o87.telia.com [213.65.232.241])
	by maild.telia.com (8.12.5/8.12.5) with ESMTP id gB6CvbXn025242
	for <linux-mm@kvack.org>; Fri, 6 Dec 2002 13:57:37 +0100 (CET)
Received: from jeloin.localnet (h98n2fls32o87.telia.com [213.67.57.98])
	by d1o87.telia.com (8.10.2/8.10.1) with ESMTP id gB6Cvb013813
	for <linux-mm@kvack.org>; Fri, 6 Dec 2002 13:57:37 +0100 (CET)
From: Roger Larsson <roger.larsson@skelleftea.mail.telia.com> (by way of
	Roger Larsson <roger.larsson@norran.net>)
Subject: RFC: Startup speed of Konqueror cvs HEAD - benchmark
Date: Fri, 6 Dec 2002 13:54:17 +0100
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Message-Id: <200212061354.17665.roger.larsson@skelleftea.mail.telia.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi KDE developers,  (and Linux Mem. Man. FYI, bcc did not work...)

People often complains about startup speed for Konqueror, especially when the
intended use is to manage files on the local disk. I have looked into that,
and one thing that I have done is to compare several programs for file 
managing (really only starting and exiting). Note that the filemanagers do 
have very different feature set. I did also run this test with 2.5.50 (bottom
of mail).


/usr/bin/time FILEMANAGER ~

The results look like this (SuSE 2.4.18 kernel):

NON CACHED (after fillmem)
		pagefaults		time (s)
filemanager	major	minor		user	sys	elapsed
 ls -l		 215	  30		0.00	0.02	 0.78
 mc		 453	 188		0.03	0.05	 3.41
 netscape	2852	2210		1.29	0.05	10.73
 emacs		1863	 814		0.44	0.08	14.72
 mozilla	4173	2606		3.52	0.20	17.62
 konqueror	6060	2031		2.34	0.13	18.01

CACHED (rerun)
		pagefaults		time (s)
filemanager	major	minor		user	sys	elapsed
 ls -l		 215	  30		0.00	0.01	0.00
 mc		 453	 188		0.00	0.02	0.48
 emacs		1958	 923		0.40	0.03	1.13
 netscape	2852	2208		1.34	0.03	2.46
 konqueror	6058	2068		2.35	0.10	2.90
 mozilla	4171	2718		3.88	0.10	4.71
 kfmclient*	2808	 228		0.46	0.01	3.96

* Included to show pagefaults, timing is suspect...
  Due to some slow IPC mechanism?

Why are not most pagefaults minor when rerun? Accouning problem?
Pages are used mmap:ed - problematic for reuse?

Conclusion (IMHO): Konqueror is quite effective when cached.
With data in cache it uses most of the real time actually move
forward, i.e. not waiting. I have also taken a look in the code.
The stuff it does is done to provide the features it has.
 Some of the overhead probably comes from usual C++ issues, like
 time spent creating and destroying temporary objects.
 [Like: char * <-> QString]
Dynamic libs/Plugins might also be expensive - ld.so/dlopen(). Will
readahead be performed? Or are pages paged in on demand only?

I do however question the necessarily and order of some stuff -
to determine if an icon should have a shared overlay it actually
forks "filesharelist" and reads response. 
[KDirLister:: -> ... -> KFileItem::pixmap ->
 KFileItem::overlays -> KFileShare::isDirectoryShared -> 
 KFileShare::readConfig -> proc.start( KProcess::Block ) ]
Konq. does also read quite a number of config and icon files, bad when they
are not cached...

It should do (and almost does) 
Step 1 - quickly show location bar,
basic icons, visible plugins, and accept user commands.
The spinning "K" might fool users to think that it is busy for a longer
time than it is. 
Step 2 - add visual hints like more specialized icons, with overlays.
 [But the preview can also fool the user that it is not ready]
Step 3 - add/start background features like file preview,
 k3b integration.


Note: Netscape (4.79) and mozilla (0.9.8) came up in a list mode, where
you can not even delete a file...

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden

##################
Results for 2.5.50

There are no change in number of pagefaults. User time and
system time went up slightly.
But real time have become better! 
(maybe fillmem is not good enough for cleaning memory?)

UNCACHED (after fillmem)

 ls -l		 215	  30		0.00	0.02	 0.78
 mc		 453	 188		0.03	0.02	 3.41
 emacs		1863	 814		0.41	0.08	14.72
 netscape	2852	2110		1.29	0.05	10.73
 konqueror	6060	2031		2.34	0.09	18.01
 mozilla	4173	2606		3.52	0.20	17.62

CACHED

 results are also slightly better

 ls -l		 215	  30		0.00	0.00	 0.02
 mc				forgot to run...
 emacs		1959	 824		0.44	0.07	 1.01
 netscape	2852	2212		1.36	0.09	 2.33
 konqueror	5029	2031		2.07	0.12	 2.70
 mozilla	4310	2636		3.63	0.20	 4.33
 
>> Visit http://mail.kde.org/mailman/listinfo/kde-devel#unsub to unsubscribe 
<<



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
