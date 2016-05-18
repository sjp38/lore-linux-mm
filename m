Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC746B007E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 21:02:18 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t140so57134690oie.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 18:02:18 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id 67si2224986otl.76.2016.05.17.18.02.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 18:02:16 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id x201so53164603oif.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 18:02:16 -0700 (PDT)
Date: Tue, 17 May 2016 18:02:01 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: unhide vmstat_text definition for CONFIG_SMP
In-Reply-To: <20160517070555.GA14453@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1605171750010.24624@eggly.anvils>
References: <1462978517-2972312-1-git-send-email-arnd@arndb.de> <20160516142332.GL23146@dhcp22.suse.cz> <20160516153656.2cf37a2f4af4b30cee6a7c86@linux-foundation.org> <20160517070555.GA14453@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 17 May 2016, Michal Hocko wrote:
> On Mon 16-05-16 15:36:56, Andrew Morton wrote:
> > On Mon, 16 May 2016 16:23:33 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > Andrew, I think that the following is more straightforward fix and
> > > should be folded in to the patch which has introduced vmstat_refresh.
> > > ---
> > > >From b8dd18fb7df040e1bfe61aadde1d903589de15e4 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Mon, 16 May 2016 16:19:53 +0200
> > > Subject: [PATCH] mmotm: mm-proc-sys-vm-stat_refresh-to-force-vmstat-update-fix
> > > 
> > > Arnd has reported:
> > > In randconfig builds with sysfs, procfs and numa all disabled,
> > > but SMP enabled, we now get a link error in the newly introduced
> > > vmstat_refresh function:
> > > 
> > > mm/built-in.o: In function `vmstat_refresh':
> > > :(.text+0x15c78): undefined reference to `vmstat_text'
> > > 
> > > vmstat_refresh is proc_fs specific so there is no reason to define it
> > > when !CONFIG_PROC_FS.
> > 
> > I already had this:
> > 
> > From: Christoph Lameter <cl@linux.com>
> > Subject: Do not build vmstat_refresh if there is no procfs support
> > 
> > It makes no sense to build functionality into the kernel that
> > cannot be used and causes build issues.
> > 
> > Link: http://lkml.kernel.org/r/alpine.DEB.2.20.1605111011260.9351@east.gentwo.org
> > Signed-off-by: Christoph Lameter <cl@linux.com>
> > Reported-by: Arnd Bergmann <arnd@arndb.de>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> But this is broken:
> http://lkml.kernel.org/r/20160516073144.GA23146@dhcp22.suse.cz and
> kbuild robot agrees
> http://lkml.kernel.org/r/201605171333.ANqJcwpy%fengguang.wu@intel.com

Sorry for my noise, sorry for my silence, thanks to Arnd and everyone
for chipping in.  But now I try it, I find that even Michal's is not
quite right: if you build without CONFIG_PROC_FS, then it gives you
mm/vmstat.c:1381:13: warning: `refresh_vm_stats' defined but not used [-Wunused-function]
(well, that was on a tree with different line numbering).
So here's my attempt...

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Fix to merge into mm-proc-sys-vm-stat_refresh-to-force-vmstat-update.patch

 mm/vmstat.c |    2 ++
 1 file changed, 2 insertions(+)

--- 4.6-rc7-mm1/mm/vmstat.c	2016-05-14 08:29:10.609386264 -0700
+++ linux/mm/vmstat.c	2016-05-17 17:43:02.861862648 -0700
@@ -1365,6 +1365,7 @@ static struct workqueue_struct *vmstat_w
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
 
+#ifdef CONFIG_PROC_FS
 static void refresh_vm_stats(struct work_struct *work)
 {
 	refresh_cpu_vm_stats(true);
@@ -1422,6 +1423,7 @@ int vmstat_refresh(struct ctl_table *tab
 		*lenp = 0;
 	return 0;
 }
+#endif /* CONFIG_PROC_FS */
 
 static void vmstat_update(struct work_struct *w)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
