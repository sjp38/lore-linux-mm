Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id C52726B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 09:15:06 -0400 (EDT)
Received: by wibg7 with SMTP id g7so46701393wib.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 06:15:06 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id cl5si23460737wjc.37.2015.03.17.06.15.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 06:15:05 -0700 (PDT)
Received: by wgbcc7 with SMTP id cc7so8202359wgb.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 06:15:04 -0700 (PDT)
Date: Tue, 17 Mar 2015 14:15:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
Message-ID: <20150317131501.GH28112@dhcp22.suse.cz>
References: <1426107294-21551-2-git-send-email-mhocko@suse.cz>
 <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
 <20150315121317.GA30685@dhcp22.suse.cz>
 <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
 <20150316074607.GA24885@dhcp22.suse.cz>
 <201503172013.HCI87500.QFHtOOMLOVFSJF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201503172013.HCI87500.QFHtOOMLOVFSJF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 17-03-15 20:13:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sun 15-03-15 22:06:54, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > [...]
> > > > this. I understand that the wording of the changelog might be confusing,
> > > > though.
> > > > 
> > > > It says: "This implementation counts only those retries which involved
> > > > OOM killer because we do not want to be too eager to fail the request."
> > > > 
> > > > Would it be more clear if I changed that to?
> > > > "This implemetnation counts only those retries when the system is
> > > > considered OOM because all previous reclaim attempts have resulted
> > > > in no progress because we do not want to be too eager to fail the
> > > > request."
> > > > 
> > > > We definitely _want_ to fail GFP_NOFS allocations.
> > > 
> > > I see. The updated changelog is much more clear.
> > 
> > Patch with the updated changelog (no other changes)
> 
> Now the changelog is clear that "Involved OOM killer" == "__GFP_FS allocation"
> and "Considered OOM" == "both __GFP_FS and !__GFP_FS allocation".
> 
> One more thing I want to confirm about this patch's changelog.
> This patch will generate the same result shown below.
> 
> Tetsuo Handa wrote:
> > I also tested on XFS. One is Linux 3.19 and the other is Linux 3.19
> > with debug printk patch shown above. According to console logs,
> > oom_kill_process() is trivially called via pagefault_out_of_memory()
> > for the former kernel. Due to giving up !GFP_FS allocations immediately?
> > 
> > (From http://I-love.SAKURA.ne.jp/tmp/serial-20150223-3.19-xfs-unpatched.txt.xz )
> > ---------- xfs / Linux 3.19 ----------
> > [  793.283099] su invoked oom-killer: gfp_mask=0x0, order=0, oom_score_adj=0
> > [  793.283102] su cpuset=/ mems_allowed=0
> > [  793.283104] CPU: 3 PID: 9552 Comm: su Not tainted 3.19.0 #40
> > [  793.283159] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> > [  793.283161]  0000000000000000 ffff88007ac03bf8 ffffffff816ae9d4 000000000000bebe
> > [  793.283162]  ffff880078b0d740 ffff88007ac03c98 ffffffff816ac7ac 0000000000000206
> > [  793.283163]  0000000481f30298 ffff880073e55850 ffff88007ac03c88 ffff88007a20bef8
> > [  793.283164] Call Trace:
> > [  793.283169]  [<ffffffff816ae9d4>] dump_stack+0x45/0x57
> > [  793.283171]  [<ffffffff816ac7ac>] dump_header+0x7f/0x1f1
> > [  793.283174]  [<ffffffff8114b36b>] oom_kill_process+0x22b/0x390
> > [  793.283177]  [<ffffffff810776d0>] ? has_capability_noaudit+0x20/0x30
> > [  793.283178]  [<ffffffff8114bb72>] out_of_memory+0x4b2/0x500
> > [  793.283179]  [<ffffffff8114bc37>] pagefault_out_of_memory+0x77/0x90
> > [  793.283180]  [<ffffffff816aab2c>] mm_fault_error+0x67/0x140
> > [  793.283182]  [<ffffffff8105a9f6>] __do_page_fault+0x3f6/0x580
> > [  793.283185]  [<ffffffff810aed1d>] ? remove_wait_queue+0x4d/0x60
> > [  793.283186]  [<ffffffff81070fcb>] ? do_wait+0x12b/0x240
> > [  793.283187]  [<ffffffff8105abb1>] do_page_fault+0x31/0x70
> > [  793.283189]  [<ffffffff816b83e8>] page_fault+0x28/0x30
> > ---------- xfs / Linux 3.19 ----------
> 
> Are all memory allocations caused by page fault __GFP_FS allocation?

They should be GFP_HIGHUSER_MOVABLE or GFP_KERNEL. There should be no
reason to have GFP_NOFS there because the page fault doesn't come from a
fs path.

> If memory allocations caused by page fault are !__GFP_FS allocation
> (e.g. 0x2015a == __GFP_HARDWALL | __GFP_COLD | __GFP_IO | __GFP_WAIT |
> __GFP_HIGHMEM | __GFP_MOVABLE), this patch will start trivially involving
> OOM killer for !__GFP_FS allocation.
> 
> I haven't tried how many processes can be killed by this path, but this path
> can potentially OOM-kill most of OOM-killable processes depending on how long
> the OOM condition lasts. It would be better to mention that a lot of processes
> might be OOM-killed by page faults due to this change.

Tasks being killed inside a page fault path is nothing new. The rate
would be higher if small allocations start failing as well but is this
worth special mentioning? Other small allocations would start failing as
well...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
