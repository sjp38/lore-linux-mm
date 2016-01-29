Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 19B9D6B0253
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:35:29 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id ny8so40071579obc.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 04:35:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t186si13712549oig.51.2016.01.29.04.35.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 04:35:27 -0800 (PST)
Subject: Re: [LTP] [BUG] oom hangs the system, NMI backtrace shows most CPUs in shrink_slab
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <56A724B1.3000407@redhat.com>
	<201601262346.BFB30785.VOQOFFHJLMtFSO@I-love.SAKURA.ne.jp>
	<201601272002.FFF21524.OLFVQHFSOtJFOM@I-love.SAKURA.ne.jp>
	<201601290048.IHF21869.OSJOQVOMLFFFHt@I-love.SAKURA.ne.jp>
	<443846857.13955817.1454052773098.JavaMail.zimbra@redhat.com>
In-Reply-To: <443846857.13955817.1454052773098.JavaMail.zimbra@redhat.com>
Message-Id: <201601292135.DHG60988.SOQFJFOHFVMLOt@I-love.SAKURA.ne.jp>
Date: Fri, 29 Jan 2016 21:35:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jstancek@redhat.com
Cc: mhocko@suse.com, tj@kernel.org, clameter@sgi.com, js1304@gmail.com, arekm@maven.pl, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org

Jan Stancek wrote:
> > Jan, can you reproduce your problem with below patch applied?
> 
> I took v4.5-rc1, applied your memalloc patch and then patch below.
> 
> I have mixed results so far. First attempt hanged after ~15 minutes,
> second is still running (for 12+ hours).
> 
> The way it hanged is different from previous ones, I don't recall seeing
> messages like these before:
>   SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
>   NMI watchdog: Watchdog detected hard LOCKUP on cpu 0
> 
> Full log from one that hanged:
>   http://jan.stancek.eu/tmp/oom_hangs/console.log.4-v4.5-rc1_and_wait_iff_congested_patch.txt
> 

The first attempt's failure is not a OOM bug. It's a hard lockup due to
flood of memory allocation failure messages which lasted for 10 seconds
with IRQ disabled. The caller which requested these atomic allocation
did not expect such situation. I think dma_active_cacheline can consider
adding __GFP_NOWARN. Please consult lib/dma-debug.c maintainers.

  static RADIX_TREE(dma_active_cacheline, GFP_NOWAIT);

----------
int ata_scsi_queuecmd(struct Scsi_Host *shost, struct scsi_cmnd *cmd) {
  spin_lock_irqsave(ap->lock, irq_flags); /* Disable IRQ. */
  __ata_scsi_queuecmd(cmd, dev) {
    ata_scsi_translate(dev, scmd, xlat_func) {
      ata_qc_issue(qc) {
        ata_sg_setup(qc) {
          dma_map_sg(ap->dev, qc->sg, qc->n_elem, qc->dma_dir) {
            debug_dma_map_sg(dev, sg, nents, ents, dir) {
              add_dma_entry(entry) { /* Iterate the loop for "ents" times. */
                rc = active_cacheline_insert(entry); /* "SLUB: Unable to allocate memory" message */
                if (rc == -ENOMEM) {
                        pr_err("DMA-API: cacheline tracking ENOMEM, dma-debug disabled\n");
                        global_disable = true;
                }
              }
            }
          }
        }
      }
    }
  }
  spin_unlock_irqrestore(ap->lock, irq_flags); /* Enable IRQ */
}
----------

By the way, I think there is no need to print these error messages
again after global_disable became true.

----------
[ 1053.123934] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1053.147529] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1053.796970] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1053.820563] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1054.469776] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1054.493371] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1055.142562] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1055.166156] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1055.815330] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1055.838924] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1056.495796] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1056.519400] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1057.168741] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1057.192333] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1057.841671] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1057.865264] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1058.514604] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1058.538200] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1059.187551] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1059.211142] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1059.860486] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1059.884080] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1060.533430] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1060.557023] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1061.206393] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1061.229984] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1061.879330] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1061.902924] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1062.552266] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1062.575857] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1063.219374] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1063.242967] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
[ 1063.892314] SLUB: Unable to allocate memory on node -1 (gfp=0x2000000)
[ 1063.915908] DMA-API: cacheline tracking ENOMEM, dma-debug disabled
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
