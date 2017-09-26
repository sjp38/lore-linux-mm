Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4F046B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 08:15:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p87so18001093pfj.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:15:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p67si5537802pfj.614.2017.09.26.05.15.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 05:15:12 -0700 (PDT)
Subject: [PATCH] mm,oom: Warn on racing with MMF_OOM_SKIP at task_will_free_mem(current).
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1506070646-4549-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170925143052.a57bqoiw6yuckwee@dhcp22.suse.cz>
In-Reply-To: <20170925143052.a57bqoiw6yuckwee@dhcp22.suse.cz>
Message-Id: <201709262027.IJC34322.tMFOJFSOFVLHQO@I-love.SAKURA.ne.jp>
Date: Tue, 26 Sep 2017 20:27:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Fri 22-09-17 17:57:26, Tetsuo Handa wrote:
> [...]
> > Michal Hocko has nacked this patch [3], and he suggested an alternative
> > patch [4]. But he himself is not ready to clarify all the concerns with
> > the alternative patch [5]. In addition to that, nobody is interested in
> > either patch; we can not make progress here. Let's choose this patch for
> > now, for this patch has smaller impact than the alternative patch.
> 
> My Nack stands and it is really annoying you are sending a patch for
> inclusion regardless of that fact. An alternative approach has been
> proposed and the mere fact that I do not have time to pursue this
> direction is not reason to go with a incomplete solution. This is not an
> issue many people would be facing to scream for a quick and dirty
> workarounds AFAIK (there have been 0 reports from non-artificial
> workloads).
> 

You again said there is no report, without providing a mean to tell
whether they actually hit it. Then, this patch must get merged now.
----------------------------------------

>From b67f6482db0f973ae7ecaa1d9873ccfd6dd151b7 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 26 Sep 2017 20:09:36 +0900
Subject: [PATCH] mm,oom: Warn on racing with MMF_OOM_SKIP at
 task_will_free_mem(current).

There still is a race window where next OOM victim is selected needlessly,
but we are intentionally leaving that window open because Michal Hocko has
never heard about a report from non-artificial workloads. However, it is
too difficult for normal users to tell whether they actually hit that race.
Thus, add a WARN_ON() to task_will_free_mem(current) if they hit that race
in order to encourage them to report it. This patch will tell us whether we
need to care about that race.

[   83.504172] Out of memory: Kill process 2899 (a.out) score 930 or sacrifice child
[   83.506794] Killed process 2899 (a.out) total-vm:16781904kB, anon-rss:88kB, file-rss:0kB, shmem-rss:3519864kB
[   83.513499] oom_reaper: reaped process 2899 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:3520204kB
[   83.516494] Racing OOM victim selection. Please report to linux-mm@kvack.org if you saw this warning from non-artificial workloads.
[   83.519793] ------------[ cut here ]------------
[   83.522008] WARNING: CPU: 0 PID: 2934 at mm/oom_kill.c:798 task_will_free_mem+0x11a/0x130
[   83.524881] Modules linked in: coretemp pcspkr sg i2c_piix4 vmw_vmci shpchp sd_mod ata_generic pata_acpi serio_raw vmwgfx drm_kms_helper mptspi syscopyarea scsi_transport_spi sysfillrect mptscsih ahci libahci mptbase sysimgblt fb_sys_fops ttm e1000 ata_piix drm i2c_core libata ipv6
[   83.532023] CPU: 0 PID: 2934 Comm: a.out Not tainted 4.14.0-rc2-next-20170926+ #672

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dee0f75..ac3c63d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -794,8 +794,10 @@ static bool task_will_free_mem(struct task_struct *task)
 	 * This task has already been drained by the oom reaper so there are
 	 * only small chances it will free some more
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+		WARN(1, "Racing OOM victim selection. Please report to linux-mm@kvack.org if you saw this warning from non-artificial workloads.\n");
 		return false;
+	}
 
 	if (atomic_read(&mm->mm_users) <= 1)
 		return true;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
