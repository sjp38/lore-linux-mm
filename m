Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE656B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 03:05:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e201so5317470wme.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 00:05:59 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id i62si24673987wma.21.2016.05.17.00.05.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 00:05:57 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w143so2170349wmw.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 00:05:57 -0700 (PDT)
Date: Tue, 17 May 2016 09:05:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: unhide vmstat_text definition for CONFIG_SMP
Message-ID: <20160517070555.GA14453@dhcp22.suse.cz>
References: <1462978517-2972312-1-git-send-email-arnd@arndb.de>
 <20160516142332.GL23146@dhcp22.suse.cz>
 <20160516153656.2cf37a2f4af4b30cee6a7c86@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516153656.2cf37a2f4af4b30cee6a7c86@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-05-16 15:36:56, Andrew Morton wrote:
> On Mon, 16 May 2016 16:23:33 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Andrew, I think that the following is more straightforward fix and
> > should be folded in to the patch which has introduced vmstat_refresh.
> > ---
> > >From b8dd18fb7df040e1bfe61aadde1d903589de15e4 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Mon, 16 May 2016 16:19:53 +0200
> > Subject: [PATCH] mmotm: mm-proc-sys-vm-stat_refresh-to-force-vmstat-update-fix
> > 
> > Arnd has reported:
> > In randconfig builds with sysfs, procfs and numa all disabled,
> > but SMP enabled, we now get a link error in the newly introduced
> > vmstat_refresh function:
> > 
> > mm/built-in.o: In function `vmstat_refresh':
> > :(.text+0x15c78): undefined reference to `vmstat_text'
> > 
> > vmstat_refresh is proc_fs specific so there is no reason to define it
> > when !CONFIG_PROC_FS.
> 
> I already had this:
> 
> From: Christoph Lameter <cl@linux.com>
> Subject: Do not build vmstat_refresh if there is no procfs support
> 
> It makes no sense to build functionality into the kernel that
> cannot be used and causes build issues.
> 
> Link: http://lkml.kernel.org/r/alpine.DEB.2.20.1605111011260.9351@east.gentwo.org
> Signed-off-by: Christoph Lameter <cl@linux.com>
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

But this is broken:
http://lkml.kernel.org/r/20160516073144.GA23146@dhcp22.suse.cz and
kbuild robot agrees
http://lkml.kernel.org/r/201605171333.ANqJcwpy%fengguang.wu@intel.com
> ---
> 
>  mm/vmstat.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff -puN mm/vmstat.c~mm-proc-sys-vm-stat_refresh-to-force-vmstat-update-fix mm/vmstat.c
> --- a/mm/vmstat.c~mm-proc-sys-vm-stat_refresh-to-force-vmstat-update-fix
> +++ a/mm/vmstat.c
> @@ -1371,7 +1371,6 @@ static const struct file_operations proc
>  	.llseek		= seq_lseek,
>  	.release	= seq_release,
>  };
> -#endif /* CONFIG_PROC_FS */
>  
>  #ifdef CONFIG_SMP
>  static struct workqueue_struct *vmstat_wq;
> @@ -1436,7 +1435,10 @@ int vmstat_refresh(struct ctl_table *tab
>  		*lenp = 0;
>  	return 0;
>  }
> +#endif /* CONFIG_SMP */
> +#endif /* CONFIG_PROC_FS */
>  
> +#ifdef CONFIG_SMP
>  static void vmstat_update(struct work_struct *w)
>  {
>  	if (refresh_cpu_vm_stats(true)) {
> _

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
