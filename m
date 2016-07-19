Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71FE86B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 11:33:39 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so14755325lfw.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 08:33:39 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id 88si17239979lfw.394.2016.07.19.08.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 08:33:37 -0700 (PDT)
Date: Tue, 19 Jul 2016 11:33:35 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: oom-reaper choosing wrong processes.
Message-ID: <20160719153335.GA11863@codemonkey.org.uk>
References: <20160718231850.GA23178@codemonkey.org.uk>
 <20160719090857.GB9490@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160719090857.GB9490@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Tue, Jul 19, 2016 at 11:08:58AM +0200, Michal Hocko wrote:
 > On Mon 18-07-16 19:18:50, Dave Jones wrote:
 > [...]
 > > [ 4607.765352] sendmail-mta invoked oom-killer: gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), order=0, oom_score_adj=0
 > > [ 4607.765359] sendmail-mta cpuset=/ mems_allowed=0
 > [...]
 > > [ 4607.765619] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
 > > [ 4607.765637] [  749]     0   749    13116      782      29       3      385             0 systemd-journal
 > > [ 4607.765641] [  793]     0   793    10640       10      23       3      285         -1000 systemd-udevd
 > > [ 4607.765647] [ 1647]     0  1647    11928       16      27       3      111             0 rpcbind
 > > [ 4607.765651] [ 1653]     0  1653     5841        0      15       3       54             0 rpc.idmapd
 > > [ 4607.765656] [ 1655]     0  1655    11052       24      26       3      114             0 systemd-logind
 > > [ 4607.765687] [ 1657]     0  1657    64579      181      28       3      161             0 rsyslogd
 > > [ 4607.765691] [ 1660]     0  1660     1058        0       8       3       38             0 acpid
 > > [ 4607.765696] [ 1661]     0  1661     7414       22      18       3       52             0 cron
 > > [ 4607.765700] [ 1662]     0  1662     6993        0      19       3       54             0 atd
 > > [ 4607.765704] [ 1664]   105  1664    10744       40      26       3       79          -900 dbus-daemon
 > > [ 4607.765708] [ 1671]     0  1671     6264       29      17       3      157             0 smartd
 > > [ 4607.765712] [ 1738]     0  1738    16948        0      37       3      204         -1000 sshd
 > > [ 4607.765716] [ 1742]     0  1742     9461        0      22       3      195             0 rpc.mountd
 > > [ 4607.765721] [ 1776]     0  1776     3624        0      12       3       39             0 agetty
 > > [ 4607.765725] [ 1797]     0  1797     3319        0      10       3       48             0 mcelog
 > > [ 4607.765729] [ 1799]     0  1799     4824       21      15       3       39             0 irqbalance
 > > [ 4607.765733] [ 1803]   108  1803    25492       42      24       3      124             0 ntpd
 > > [ 4607.765737] [ 1842]     0  1842    19793       48      39       3      410             0 sendmail-mta
 > > [ 4607.765746] [ 1878]     0  1878     5121        0      13       3      262             0 dhclient
 > > [ 4607.765752] [ 2145]  1000  2145    15627        0      33       3      213             0 systemd
 > > [ 4607.765756] [ 2148]  1000  2148    19584        4      40       3      438             0 (sd-pam)
 > > [ 4607.765760] [ 2643]  1000  2643     7465      433      19       3      152             0 tmux
 > > [ 4607.765764] [ 2644]  1000  2644     5864        0      16       3      508             0 bash
 > > [ 4607.765768] [ 2678]  1000  2678     3328       89      11       3       19             0 test-multi.sh
 > > [ 4607.765774] [ 2693]  1000  2693     5864        1      16       3      507             0 bash
 > > [ 4607.765782] [ 6456]  1000  6456     3091       21      11       3       24             0 dmesg
 > > [ 4607.765787] [18624]  1000 18624   750863    43368     520       6        0           500 trinity-c10
 > > [ 4607.765792] [21525]  1000 21525   797320    20517     493       7        0           500 trinity-c15
 > > [ 4607.765796] [22023]  1000 22023   797349     1985     319       7        0           500 trinity-c2
 > > [ 4607.765814] [22658]  1000 22658   797382        1     458       7        0           500 trinity-c0
 > > [ 4607.765818] [26334]  1000 26334   797217    34960     412       7        0           500 trinity-c4
 > > [ 4607.765823] [26388]  1000 26388   797383     9401     118       7        0           500 trinity-c11
 > > [ 4607.765826] oom_kill_process: would have killed process 749 (systemd-journal), but continuing instead...
 > > [ 4608.147644] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:136724kB
 > > [ 4608.148218] oom_reaper: reaped process 18624 (trinity-c10), now anon-rss:0kB, file-rss:0kB, shmem-rss:174356kB
 > > [ 4608.149795] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:86288kB
 > > [ 4608.150734] oom_reaper: reaped process 18624 (trinity-c10), now anon-rss:0kB, file-rss:0kB, shmem-rss:174348kB
 > > [ 4608.152489] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:86288kB
 > > [ 4608.156127] oom_reaper: reaped process 18624 (trinity-c10), now anon-rss:0kB, file-rss:0kB, shmem-rss:174336kB
 > > [ 4608.158798] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:136652kB
 > > [ 4608.161336] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:136652kB
 > > [ 4608.163836] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:136652kB
 > > 
 > > 
 > > Whoa. Why did it pick systemd-journal ?
 > 
 > Who has picked that? select_bad process?
 > 
 > > My 'skip over !trinity processes' code kicks in, and it then kills the
 > > right processes, and the box lives on, but if I hadn't have had that
 > > diff, the wrong process would have been killed.
 > 
 > Could you post your diff please? oom_reaper will reap not only the oom
 > victims but also tasks which hit the oom path and they are exiting.


commit fd1fe9a8ad00ee6a2e81a1152c3150d2289fdf10
Author: Dave Jones <davej@codemonkey.org.uk>
Date:   Mon Jun 15 23:41:09 2015 -0400

    only oom-kill tasks named trinity

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ddf74487f848..2635db037dd5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -767,6 +767,15 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p, memcg);
 
+	task_lock(p);
+	if (strncmp(p->comm, "trinity-", 8) != 0) {
+		printk(KERN_ERR "%s: would have killed process %d (%s), but continuing instead...\n",
+			__func__, task_pid_nr(p), p->comm);
+		task_unlock(p);
+		return;
+	}
+	task_unlock(p);
+
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
