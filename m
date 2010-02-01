Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 414D36B004D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 17:02:46 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Improving OOM killer
Date: Mon, 1 Feb 2010 23:02:37 +0100
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201002012302.37380.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>


 Hello,

 I'd like to suggest some changes to the OOM killer code that I believe 
improve its behaviour - here it turns it from something completely useless and 
harmful into something that works very well. I'm first posting changes for 
review, I'll reformat the patch later as needed if approved. Given that it's 
been like this for about a decade, I get the feeling there must be some 
strange catch.

 My scenario is working in a KDE desktop session and accidentally running 
parallel make in doc/ subdirectory of sources of a KDE module. As I use 
distributed compiling, I run make with -j20 or more, but, as the tool used for 
processing KDE documentation is quite memory-intensive, running this many 
of them is more than enough to consume all the 2GB RAM in the machine. What 
happens in that case is that the machine becomes virtually unresponsible, 
where even Ctrl+Alt+F1 can take minutes, not to mention some action that'd 
actually redeem the situation. If I wait long enough for something to happen, 
which can be even hours, the action that ends the situation is killing one of 
the most vital KDE processes, rendering the whole session useless and making 
me lose all unsaved data.

 The process tree looks roughly like this:

init
  |- kdeinit
  |  |- ksmserver
  |  |  |- kwin
  |  |- <other>
  |- konsole
     |- make
        |- sh
        |  |- meinproc4
        |- sh
        |  |- meinproc4
        |- <etc>

 What happens is that OOM killer usually selects either ksmserver (KDE session 
manager) or kdeinit (KDE master process that spawns most KDE processes). Note 
that in either case OOM killer does not reach the point of killing the actual 
offender - it will randomly kill in the tree under kdeinit until it decides 
to kill ksmserver, which means terminating the desktop session. As konsole is 
a KUniqueApplication, it forks into background and gets reparented to init, 
thus getting away from the kdeinit subtree. Since the memory pressure is 
distributed among several meinproc4 processes, the badness does not get 
summed up in its make grandparent, as badness() does this only for direct 
parents.

 Each meinproc4 process still uses a considerable amount of memory, so one 
could assume that the situation would be solved by simply killing them one by 
one, but it is not so because of using what I consider poor metric for 
measuring memory usage - VmSize. VmSize, if I'm not mistaken, is the size of 
the address space taken by the process, which in practice does not say much 
about how much memory the process actually uses. For example, /proc/*/status 
for one selected KDE process:

VmPeak:   534676 kB
VmSize:   528340 kB
VmLck:         0 kB
VmHWM:     73464 kB
VmRSS:     73388 kB
VmData:   142332 kB
VmStk:        92 kB
VmExe:        44 kB
VmLib:     91232 kB
VmPTE:       716 kB

And various excerpts from /proc/*/smaps for this process:
...
7f7b3f800000-7f7b40000000 rwxp 00000000 00:00 0
Size:               8192 kB
Rss:                  16 kB
Referenced:           16 kB
...
7f7b40055000-7f7b44000000 ---p 00000000 00:00 0
Size:              65196 kB
Rss:                   0 kB
Referenced:            0 kB
...
7f7b443cd000-7f7b445cd000 ---p 0001c000 08:01 
790267                     /usr/lib64/kde4/libnsplugin.so
Size:               2048 kB
Rss:                   0 kB
Referenced:            0 kB
...
7f7b48300000-7f7b4927d000 rw-s 00000000 08:01 
58690                      /var/tmp/kdecache-seli/kpc/kde-icon-cache.data
Size:              15860 kB
Rss:                  24 kB
Referenced:           24 kB

 I assume the first one is stack, search me what the second and third ones are 
(there appears to be one such mapping as the third one for each .so used), 
the last one is a mapping of a large cache file that's nevertheless rarely 
used extensively and even then it's backed by a file. In other words, none of 
this actually uses much of real memory, yet right now it's the process that 
would get killed for using about 70MB memory, even though it's not the 
offender. The offender scores only about 1/3 of its badness, even though it 
uses almost the double amount of memory:

VmPeak:   266508 kB
VmSize:   266504 kB
VmLck:         0 kB
VmHWM:    118208 kB
VmRSS:    118208 kB
VmData:    98512 kB
VmStk:        84 kB
VmExe:        60 kB
VmLib:     48944 kB
VmPTE:       536 kB

And the offender is only 14th in the list of badness candidates. Speaking of 
which, the following is quite useful for seeing all processes sorted by 
badness:

ls /proc/*/oom_score | grep -v self | sed 's/\(.*\)\/\(.*\)/echo -n "\1 "; \
echo -n "`cat \1\/\2 2>\/dev\/null` "; readlink \1\/exe || echo/'| sh | \
sort -nr +1


 Therefore, I suggest doing the following changes in mm/oom_kill.c :

=====
--- linux-2.6.31/mm/oom_kill.c.sav      2010-02-01 22:00:41.614838540 +0100
+++ linux-2.6.31/mm/oom_kill.c  2010-02-01 22:01:08.773757932 +0100
@@ -69,7 +69,7 @@ unsigned long badness(struct task_struct
        /*
         * The memory size of the process is the basis for the badness.
         */
-       points = mm->total_vm;
+       points = get_mm_rss(mm);

        /*
         * After this unlock we can no longer dereference local variable `mm'
@@ -83,21 +83,6 @@ unsigned long badness(struct task_struct
                return ULONG_MAX;

        /*
-        * Processes which fork a lot of child processes are likely
-        * a good choice. We add half the vmsize of the children if they
-        * have an own mm. This prevents forking servers to flood the
-        * machine with an endless amount of children. In case a single
-        * child is eating the vast majority of memory, adding only half
-        * to the parents will make the child our kill candidate of choice.
-        */
-       list_for_each_entry(child, &p->children, sibling) {
-               task_lock(child);
-               if (child->mm != mm && child->mm)
-                       points += child->mm->total_vm/2 + 1;
-               task_unlock(child);
-       }
-
-       /*
         * CPU time is in tens of seconds and run time is in thousands
          * of seconds. There is no particular reason for this other than
          * that it turned out to work very well in practice.
=====

 In other words, use VmRSS for measuring memory usage instead of VmSize, and 
remove child accumulating.

 I hope the above is good enough reason for the first change. VmSize includes 
things like read-only mappings, memory mappings that is actually unused, 
mappings backed by a file, mappings from video drivers, and so on. VmRSS is 
actual real memory used, which is what mostly matters here. While it may not 
be perfect, it is certainly an improvement.

 The second change should be done on the basis that it does more harm than 
good. In this specific case, it does not help to identify the source of the 
problem, and it incorrectly identifies kdeinit as the problem solely on the 
basis that it spawned many other processes. I think it's already quite hinted 
that this is a problem by the fact that you had to add a special protection 
for init - any session manager, process launcher or even xterm used for 
launching apps is yet another init.

 I also have problems finding a case where the child accounting would actually 
help. I mean, in practice, I can certainly come up with something in theory, 
and this looks to me like a solution to a very synthesized problem. In which 
realistic case will one process launch a limited number of children, where 
all of them will consume memory, but just killing the children one by one 
won't avoid the problem reasonably? This is unlikely to avoid a forkbomb, as 
in that case the number of children will be the problem. It is not necessary 
for just one children misbehaving and being restarted, nor will it work 
there. So what is that supposed to fix, and is it more likely than the case 
of a process launching several unrelated children?

 If the children accounting is supposed to handle cases like forked children 
of Apache, then I suggest it is adjusted only to count children that have 
been forked from the parent but there has been no exec(). I'm afraid I don't 
know how to detect that.


 When running a kernel with these changes applied, I can safely do the 
above-described case of running parallel doc generation in KDE. No clearly 
innocent process is selected for killing, the first choice is always an 
offender.

 Moreover, the remedy is almost instant, there is only a fraction of second of 
when the machine is overloaded by the I/O of swapping pages in and out (I do 
not use swap, but there is a large amount of memory used by read-only 
mappings of binaries, libraries or various other files that is in the 
original case rendering the machine unresponsive - I assume this is because 
the kernel tries to kill an innocent process, but the offenders immediatelly 
consume anything that is freed, requiring even memory used by code that is to 
be executed to be swapped in from files again).

 I consider the patches to be definite improvements, so if they are ok, I will 
format them as necessary. Now, what is the catch?

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
