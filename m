Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD6BD6B025E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 10:56:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so24957391wmz.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 07:56:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l3si35146276wjt.78.2016.08.09.07.55.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 07:55:59 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v10 02/11] kthread: Kthread worker API cleanup
Date: Tue,  9 Aug 2016 16:55:36 +0200
Message-Id: <1470754545-17632-3-git-send-email-pmladek@suse.com>
In-Reply-To: <1470754545-17632-1-git-send-email-pmladek@suse.com>
References: <1470754545-17632-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

A good practice is to prefix the names of functions by the name
of the subsystem.

The kthread worker API is a mix of classic kthreads and workqueues.
Each worker has a dedicated kthread. It runs a generic function
that process queued works. It is implemented as part of
the kthread subsystem.

This patch renames the existing kthread worker API to use
the corresponding name from the workqueues API prefixed by
kthread_:

__init_kthread_worker()		-> __kthread_init_worker()
init_kthread_worker()		-> kthread_init_worker()
init_kthread_work()		-> kthread_init_work()
insert_kthread_work()		-> kthread_insert_work()
queue_kthread_work()		-> kthread_queue_work()
flush_kthread_work()		-> kthread_flush_work()
flush_kthread_worker()		-> kthread_flush_worker()

Note that the names of DEFINE_KTHREAD_WORK*() macros stay
as they are. It is common that the "DEFINE_" prefix has
precedence over the subsystem names.

Note that INIT() macros and init() functions use different
naming scheme. There is no good solution. There are several
reasons for this solution:

  + "init" in the function names stands for the verb "initialize"
    aka "initialize worker". While "INIT" in the macro names
    stands for the noun "INITIALIZER" aka "worker initializer".

  + INIT() macros are used only in DEFINE() macros

  + init() functions are used close to the other kthread()
    functions. It looks much better if all the functions
    use the same scheme.

  + There will be also kthread_destroy_worker() that will
    be used close to kthread_cancel_work(). It is related
    to the init() function. Again it looks better if all
    functions use the same naming scheme.

  + there are several precedents for such init() function
    names, e.g. amd_iommu_init_device(), free_area_init_node(),
    jump_label_init_type(),  regmap_init_mmio_clk(),

  + It is not an argument but it was inconsistent even before.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Petr Mladek <pmladek@suse.com>
---
 Documentation/RCU/lockdep-splat.txt         |  2 +-
 arch/x86/kvm/i8254.c                        | 14 ++++++------
 crypto/crypto_engine.c                      | 16 +++++++-------
 drivers/block/loop.c                        |  8 +++----
 drivers/infiniband/sw/rdmavt/cq.c           | 10 ++++-----
 drivers/md/dm-rq.c                          |  6 +++---
 drivers/md/dm.c                             |  4 ++--
 drivers/media/pci/ivtv/ivtv-driver.c        |  6 +++---
 drivers/media/pci/ivtv/ivtv-irq.c           |  2 +-
 drivers/net/ethernet/microchip/encx24j600.c | 10 ++++-----
 drivers/spi/spi.c                           | 18 ++++++++--------
 drivers/tty/serial/sc16is7xx.c              | 22 +++++++++----------
 include/linux/kthread.h                     | 18 ++++++++--------
 kernel/kthread.c                            | 33 +++++++++++++++--------------
 sound/soc/intel/baytrail/sst-baytrail-ipc.c |  2 +-
 sound/soc/intel/common/sst-ipc.c            |  6 +++---
 sound/soc/intel/haswell/sst-haswell-ipc.c   |  2 +-
 sound/soc/intel/skylake/skl-sst-ipc.c       |  2 +-
 18 files changed, 91 insertions(+), 90 deletions(-)

diff --git a/Documentation/RCU/lockdep-splat.txt b/Documentation/RCU/lockdep-splat.txt
index bf9061142827..238e9f61352f 100644
--- a/Documentation/RCU/lockdep-splat.txt
+++ b/Documentation/RCU/lockdep-splat.txt
@@ -57,7 +57,7 @@ Call Trace:
  [<ffffffff817db154>] kernel_thread_helper+0x4/0x10
  [<ffffffff81066430>] ? finish_task_switch+0x80/0x110
  [<ffffffff817d9c04>] ? retint_restore_args+0xe/0xe
- [<ffffffff81097510>] ? __init_kthread_worker+0x70/0x70
+ [<ffffffff81097510>] ? __kthread_init_worker+0x70/0x70
  [<ffffffff817db150>] ? gs_change+0xb/0xb
 
 Line 2776 of block/cfq-iosched.c in v3.0-rc5 is as follows:
diff --git a/arch/x86/kvm/i8254.c b/arch/x86/kvm/i8254.c
index 5fb6c620180e..16a7134eedac 100644
--- a/arch/x86/kvm/i8254.c
+++ b/arch/x86/kvm/i8254.c
@@ -212,7 +212,7 @@ static void kvm_pit_ack_irq(struct kvm_irq_ack_notifier *kian)
 	 */
 	smp_mb();
 	if (atomic_dec_if_positive(&ps->pending) > 0)
-		queue_kthread_work(&pit->worker, &pit->expired);
+		kthread_queue_work(&pit->worker, &pit->expired);
 }
 
 void __kvm_migrate_pit_timer(struct kvm_vcpu *vcpu)
@@ -233,7 +233,7 @@ void __kvm_migrate_pit_timer(struct kvm_vcpu *vcpu)
 static void destroy_pit_timer(struct kvm_pit *pit)
 {
 	hrtimer_cancel(&pit->pit_state.timer);
-	flush_kthread_work(&pit->expired);
+	kthread_flush_work(&pit->expired);
 }
 
 static void pit_do_work(struct kthread_work *work)
@@ -272,7 +272,7 @@ static enum hrtimer_restart pit_timer_fn(struct hrtimer *data)
 	if (atomic_read(&ps->reinject))
 		atomic_inc(&ps->pending);
 
-	queue_kthread_work(&pt->worker, &pt->expired);
+	kthread_queue_work(&pt->worker, &pt->expired);
 
 	if (ps->is_periodic) {
 		hrtimer_add_expires_ns(&ps->timer, ps->period);
@@ -324,7 +324,7 @@ static void create_pit_timer(struct kvm_pit *pit, u32 val, int is_period)
 
 	/* TODO The new value only affected after the retriggered */
 	hrtimer_cancel(&ps->timer);
-	flush_kthread_work(&pit->expired);
+	kthread_flush_work(&pit->expired);
 	ps->period = interval;
 	ps->is_periodic = is_period;
 
@@ -667,13 +667,13 @@ struct kvm_pit *kvm_create_pit(struct kvm *kvm, u32 flags)
 	pid_nr = pid_vnr(pid);
 	put_pid(pid);
 
-	init_kthread_worker(&pit->worker);
+	kthread_init_worker(&pit->worker);
 	pit->worker_task = kthread_run(kthread_worker_fn, &pit->worker,
 				       "kvm-pit/%d", pid_nr);
 	if (IS_ERR(pit->worker_task))
 		goto fail_kthread;
 
-	init_kthread_work(&pit->expired, pit_do_work);
+	kthread_init_work(&pit->expired, pit_do_work);
 
 	pit->kvm = kvm;
 
@@ -730,7 +730,7 @@ void kvm_free_pit(struct kvm *kvm)
 		kvm_io_bus_unregister_dev(kvm, KVM_PIO_BUS, &pit->speaker_dev);
 		kvm_pit_set_reinject(pit, false);
 		hrtimer_cancel(&pit->pit_state.timer);
-		flush_kthread_work(&pit->expired);
+		kthread_flush_work(&pit->expired);
 		kthread_stop(pit->worker_task);
 		kvm_free_irq_source_id(kvm, pit->irq_source_id);
 		kfree(pit);
diff --git a/crypto/crypto_engine.c b/crypto/crypto_engine.c
index a55c82dd48ef..6bfcb2e1407f 100644
--- a/crypto/crypto_engine.c
+++ b/crypto/crypto_engine.c
@@ -47,7 +47,7 @@ static void crypto_pump_requests(struct crypto_engine *engine,
 
 	/* If another context is idling then defer */
 	if (engine->idling) {
-		queue_kthread_work(&engine->kworker, &engine->pump_requests);
+		kthread_queue_work(&engine->kworker, &engine->pump_requests);
 		goto out;
 	}
 
@@ -58,7 +58,7 @@ static void crypto_pump_requests(struct crypto_engine *engine,
 
 		/* Only do teardown in the thread */
 		if (!in_kthread) {
-			queue_kthread_work(&engine->kworker,
+			kthread_queue_work(&engine->kworker,
 					   &engine->pump_requests);
 			goto out;
 		}
@@ -157,7 +157,7 @@ int crypto_transfer_request(struct crypto_engine *engine,
 	ret = ablkcipher_enqueue_request(&engine->queue, req);
 
 	if (!engine->busy && need_pump)
-		queue_kthread_work(&engine->kworker, &engine->pump_requests);
+		kthread_queue_work(&engine->kworker, &engine->pump_requests);
 
 	spin_unlock_irqrestore(&engine->queue_lock, flags);
 	return ret;
@@ -210,7 +210,7 @@ void crypto_finalize_request(struct crypto_engine *engine,
 
 	req->base.complete(&req->base, err);
 
-	queue_kthread_work(&engine->kworker, &engine->pump_requests);
+	kthread_queue_work(&engine->kworker, &engine->pump_requests);
 }
 EXPORT_SYMBOL_GPL(crypto_finalize_request);
 
@@ -234,7 +234,7 @@ int crypto_engine_start(struct crypto_engine *engine)
 	engine->running = true;
 	spin_unlock_irqrestore(&engine->queue_lock, flags);
 
-	queue_kthread_work(&engine->kworker, &engine->pump_requests);
+	kthread_queue_work(&engine->kworker, &engine->pump_requests);
 
 	return 0;
 }
@@ -311,7 +311,7 @@ struct crypto_engine *crypto_engine_alloc_init(struct device *dev, bool rt)
 	crypto_init_queue(&engine->queue, CRYPTO_ENGINE_MAX_QLEN);
 	spin_lock_init(&engine->queue_lock);
 
-	init_kthread_worker(&engine->kworker);
+	kthread_init_worker(&engine->kworker);
 	engine->kworker_task = kthread_run(kthread_worker_fn,
 					   &engine->kworker, "%s",
 					   engine->name);
@@ -319,7 +319,7 @@ struct crypto_engine *crypto_engine_alloc_init(struct device *dev, bool rt)
 		dev_err(dev, "failed to create crypto request pump task\n");
 		return NULL;
 	}
-	init_kthread_work(&engine->pump_requests, crypto_pump_work);
+	kthread_init_work(&engine->pump_requests, crypto_pump_work);
 
 	if (engine->rt) {
 		dev_info(dev, "will run requests pump with realtime priority\n");
@@ -344,7 +344,7 @@ int crypto_engine_exit(struct crypto_engine *engine)
 	if (ret)
 		return ret;
 
-	flush_kthread_worker(&engine->kworker);
+	kthread_flush_worker(&engine->kworker);
 	kthread_stop(engine->kworker_task);
 
 	return 0;
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index c9f2107f7095..9a21c024c390 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -840,13 +840,13 @@ static void loop_config_discard(struct loop_device *lo)
 
 static void loop_unprepare_queue(struct loop_device *lo)
 {
-	flush_kthread_worker(&lo->worker);
+	kthread_flush_worker(&lo->worker);
 	kthread_stop(lo->worker_task);
 }
 
 static int loop_prepare_queue(struct loop_device *lo)
 {
-	init_kthread_worker(&lo->worker);
+	kthread_init_worker(&lo->worker);
 	lo->worker_task = kthread_run(kthread_worker_fn,
 			&lo->worker, "loop%d", lo->lo_number);
 	if (IS_ERR(lo->worker_task))
@@ -1658,7 +1658,7 @@ static int loop_queue_rq(struct blk_mq_hw_ctx *hctx,
 		break;
 	}
 
-	queue_kthread_work(&lo->worker, &cmd->work);
+	kthread_queue_work(&lo->worker, &cmd->work);
 
 	return BLK_MQ_RQ_QUEUE_OK;
 }
@@ -1696,7 +1696,7 @@ static int loop_init_request(void *data, struct request *rq,
 	struct loop_cmd *cmd = blk_mq_rq_to_pdu(rq);
 
 	cmd->rq = rq;
-	init_kthread_work(&cmd->work, loop_queue_work);
+	kthread_init_work(&cmd->work, loop_queue_work);
 
 	return 0;
 }
diff --git a/drivers/infiniband/sw/rdmavt/cq.c b/drivers/infiniband/sw/rdmavt/cq.c
index f2f229efbe64..6d9904a4a0ab 100644
--- a/drivers/infiniband/sw/rdmavt/cq.c
+++ b/drivers/infiniband/sw/rdmavt/cq.c
@@ -129,7 +129,7 @@ void rvt_cq_enter(struct rvt_cq *cq, struct ib_wc *entry, bool solicited)
 		if (likely(worker)) {
 			cq->notify = RVT_CQ_NONE;
 			cq->triggered++;
-			queue_kthread_work(worker, &cq->comptask);
+			kthread_queue_work(worker, &cq->comptask);
 		}
 	}
 
@@ -265,7 +265,7 @@ struct ib_cq *rvt_create_cq(struct ib_device *ibdev,
 	cq->ibcq.cqe = entries;
 	cq->notify = RVT_CQ_NONE;
 	spin_lock_init(&cq->lock);
-	init_kthread_work(&cq->comptask, send_complete);
+	kthread_init_work(&cq->comptask, send_complete);
 	cq->queue = wc;
 
 	ret = &cq->ibcq;
@@ -295,7 +295,7 @@ int rvt_destroy_cq(struct ib_cq *ibcq)
 	struct rvt_cq *cq = ibcq_to_rvtcq(ibcq);
 	struct rvt_dev_info *rdi = cq->rdi;
 
-	flush_kthread_work(&cq->comptask);
+	kthread_flush_work(&cq->comptask);
 	spin_lock(&rdi->n_cqs_lock);
 	rdi->n_cqs_allocated--;
 	spin_unlock(&rdi->n_cqs_lock);
@@ -514,7 +514,7 @@ int rvt_driver_cq_init(struct rvt_dev_info *rdi)
 	rdi->worker = kzalloc(sizeof(*rdi->worker), GFP_KERNEL);
 	if (!rdi->worker)
 		return -ENOMEM;
-	init_kthread_worker(rdi->worker);
+	kthread_init_worker(rdi->worker);
 	task = kthread_create_on_node(
 		kthread_worker_fn,
 		rdi->worker,
@@ -547,7 +547,7 @@ void rvt_cq_exit(struct rvt_dev_info *rdi)
 	/* blocks future queuing from send_complete() */
 	rdi->worker = NULL;
 	smp_wmb(); /* See rdi_cq_enter */
-	flush_kthread_worker(worker);
+	kthread_flush_worker(worker);
 	kthread_stop(worker->task);
 	kfree(worker);
 }
diff --git a/drivers/md/dm-rq.c b/drivers/md/dm-rq.c
index 1ca7463e8bb2..917dde872d6b 100644
--- a/drivers/md/dm-rq.c
+++ b/drivers/md/dm-rq.c
@@ -553,7 +553,7 @@ static void init_tio(struct dm_rq_target_io *tio, struct request *rq,
 	if (!md->init_tio_pdu)
 		memset(&tio->info, 0, sizeof(tio->info));
 	if (md->kworker_task)
-		init_kthread_work(&tio->work, map_tio_request);
+		kthread_init_work(&tio->work, map_tio_request);
 }
 
 static struct dm_rq_target_io *dm_old_prep_tio(struct request *rq,
@@ -801,7 +801,7 @@ static void dm_old_request_fn(struct request_queue *q)
 		tio = tio_from_request(rq);
 		/* Establish tio->ti before queuing work (map_tio_request) */
 		tio->ti = ti;
-		queue_kthread_work(&md->kworker, &tio->work);
+		kthread_queue_work(&md->kworker, &tio->work);
 		BUG_ON(!irqs_disabled());
 	}
 }
@@ -823,7 +823,7 @@ int dm_old_init_request_queue(struct mapped_device *md)
 	blk_queue_prep_rq(md->queue, dm_old_prep_fn);
 
 	/* Initialize the request-based DM worker thread */
-	init_kthread_worker(&md->kworker);
+	kthread_init_worker(&md->kworker);
 	md->kworker_task = kthread_run(kthread_worker_fn, &md->kworker,
 				       "kdmwork-%s", dm_device_name(md));
 	if (IS_ERR(md->kworker_task))
diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index fa9b1cb4438a..8a0cae004dfc 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -1884,7 +1884,7 @@ static void __dm_destroy(struct mapped_device *md, bool wait)
 	spin_unlock(&_minor_lock);
 
 	if (dm_request_based(md) && md->kworker_task)
-		flush_kthread_worker(&md->kworker);
+		kthread_flush_worker(&md->kworker);
 
 	/*
 	 * Take suspend_lock so that presuspend and postsuspend methods
@@ -2139,7 +2139,7 @@ static int __dm_suspend(struct mapped_device *md, struct dm_table *map,
 	if (dm_request_based(md)) {
 		dm_stop_queue(md->queue);
 		if (md->kworker_task)
-			flush_kthread_worker(&md->kworker);
+			kthread_flush_worker(&md->kworker);
 	}
 
 	flush_workqueue(md->wq);
diff --git a/drivers/media/pci/ivtv/ivtv-driver.c b/drivers/media/pci/ivtv/ivtv-driver.c
index 374033a5bdaf..ee48c3e09de4 100644
--- a/drivers/media/pci/ivtv/ivtv-driver.c
+++ b/drivers/media/pci/ivtv/ivtv-driver.c
@@ -750,7 +750,7 @@ static int ivtv_init_struct1(struct ivtv *itv)
 	spin_lock_init(&itv->lock);
 	spin_lock_init(&itv->dma_reg_lock);
 
-	init_kthread_worker(&itv->irq_worker);
+	kthread_init_worker(&itv->irq_worker);
 	itv->irq_worker_task = kthread_run(kthread_worker_fn, &itv->irq_worker,
 					   "%s", itv->v4l2_dev.name);
 	if (IS_ERR(itv->irq_worker_task)) {
@@ -760,7 +760,7 @@ static int ivtv_init_struct1(struct ivtv *itv)
 	/* must use the FIFO scheduler as it is realtime sensitive */
 	sched_setscheduler(itv->irq_worker_task, SCHED_FIFO, &param);
 
-	init_kthread_work(&itv->irq_work, ivtv_irq_work_handler);
+	kthread_init_work(&itv->irq_work, ivtv_irq_work_handler);
 
 	/* Initial settings */
 	itv->cxhdl.port = CX2341X_PORT_MEMORY;
@@ -1441,7 +1441,7 @@ static void ivtv_remove(struct pci_dev *pdev)
 	del_timer_sync(&itv->dma_timer);
 
 	/* Kill irq worker */
-	flush_kthread_worker(&itv->irq_worker);
+	kthread_flush_worker(&itv->irq_worker);
 	kthread_stop(itv->irq_worker_task);
 
 	ivtv_streams_cleanup(itv);
diff --git a/drivers/media/pci/ivtv/ivtv-irq.c b/drivers/media/pci/ivtv/ivtv-irq.c
index 36ca2d67c812..6efe1f71262c 100644
--- a/drivers/media/pci/ivtv/ivtv-irq.c
+++ b/drivers/media/pci/ivtv/ivtv-irq.c
@@ -1062,7 +1062,7 @@ irqreturn_t ivtv_irq_handler(int irq, void *dev_id)
 	}
 
 	if (test_and_clear_bit(IVTV_F_I_HAVE_WORK, &itv->i_flags)) {
-		queue_kthread_work(&itv->irq_worker, &itv->irq_work);
+		kthread_queue_work(&itv->irq_worker, &itv->irq_work);
 	}
 
 	spin_unlock(&itv->dma_reg_lock);
diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index 42e34076d2de..b14f0305aa31 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -821,7 +821,7 @@ static void encx24j600_set_multicast_list(struct net_device *dev)
 	}
 
 	if (oldfilter != priv->rxfilter)
-		queue_kthread_work(&priv->kworker, &priv->setrx_work);
+		kthread_queue_work(&priv->kworker, &priv->setrx_work);
 }
 
 static void encx24j600_hw_tx(struct encx24j600_priv *priv)
@@ -879,7 +879,7 @@ static netdev_tx_t encx24j600_tx(struct sk_buff *skb, struct net_device *dev)
 	/* Remember the skb for deferred processing */
 	priv->tx_skb = skb;
 
-	queue_kthread_work(&priv->kworker, &priv->tx_work);
+	kthread_queue_work(&priv->kworker, &priv->tx_work);
 
 	return NETDEV_TX_OK;
 }
@@ -1037,9 +1037,9 @@ static int encx24j600_spi_probe(struct spi_device *spi)
 		goto out_free;
 	}
 
-	init_kthread_worker(&priv->kworker);
-	init_kthread_work(&priv->tx_work, encx24j600_tx_proc);
-	init_kthread_work(&priv->setrx_work, encx24j600_setrx_proc);
+	kthread_init_worker(&priv->kworker);
+	kthread_init_work(&priv->tx_work, encx24j600_tx_proc);
+	kthread_init_work(&priv->setrx_work, encx24j600_setrx_proc);
 
 	priv->kworker_task = kthread_run(kthread_worker_fn, &priv->kworker,
 					 "encx24j600");
diff --git a/drivers/spi/spi.c b/drivers/spi/spi.c
index 51ad42fad567..4845ec1f2446 100644
--- a/drivers/spi/spi.c
+++ b/drivers/spi/spi.c
@@ -1097,7 +1097,7 @@ static void __spi_pump_messages(struct spi_master *master, bool in_kthread)
 
 	/* If another context is idling the device then defer */
 	if (master->idling) {
-		queue_kthread_work(&master->kworker, &master->pump_messages);
+		kthread_queue_work(&master->kworker, &master->pump_messages);
 		spin_unlock_irqrestore(&master->queue_lock, flags);
 		return;
 	}
@@ -1111,7 +1111,7 @@ static void __spi_pump_messages(struct spi_master *master, bool in_kthread)
 
 		/* Only do teardown in the thread */
 		if (!in_kthread) {
-			queue_kthread_work(&master->kworker,
+			kthread_queue_work(&master->kworker,
 					   &master->pump_messages);
 			spin_unlock_irqrestore(&master->queue_lock, flags);
 			return;
@@ -1233,7 +1233,7 @@ static int spi_init_queue(struct spi_master *master)
 	master->running = false;
 	master->busy = false;
 
-	init_kthread_worker(&master->kworker);
+	kthread_init_worker(&master->kworker);
 	master->kworker_task = kthread_run(kthread_worker_fn,
 					   &master->kworker, "%s",
 					   dev_name(&master->dev));
@@ -1241,7 +1241,7 @@ static int spi_init_queue(struct spi_master *master)
 		dev_err(&master->dev, "failed to create message pump task\n");
 		return PTR_ERR(master->kworker_task);
 	}
-	init_kthread_work(&master->pump_messages, spi_pump_messages);
+	kthread_init_work(&master->pump_messages, spi_pump_messages);
 
 	/*
 	 * Master config will indicate if this controller should run the
@@ -1314,7 +1314,7 @@ void spi_finalize_current_message(struct spi_master *master)
 	spin_lock_irqsave(&master->queue_lock, flags);
 	master->cur_msg = NULL;
 	master->cur_msg_prepared = false;
-	queue_kthread_work(&master->kworker, &master->pump_messages);
+	kthread_queue_work(&master->kworker, &master->pump_messages);
 	spin_unlock_irqrestore(&master->queue_lock, flags);
 
 	trace_spi_message_done(mesg);
@@ -1340,7 +1340,7 @@ static int spi_start_queue(struct spi_master *master)
 	master->cur_msg = NULL;
 	spin_unlock_irqrestore(&master->queue_lock, flags);
 
-	queue_kthread_work(&master->kworker, &master->pump_messages);
+	kthread_queue_work(&master->kworker, &master->pump_messages);
 
 	return 0;
 }
@@ -1387,7 +1387,7 @@ static int spi_destroy_queue(struct spi_master *master)
 	ret = spi_stop_queue(master);
 
 	/*
-	 * flush_kthread_worker will block until all work is done.
+	 * kthread_flush_worker will block until all work is done.
 	 * If the reason that stop_queue timed out is that the work will never
 	 * finish, then it does no good to call flush/stop thread, so
 	 * return anyway.
@@ -1397,7 +1397,7 @@ static int spi_destroy_queue(struct spi_master *master)
 		return ret;
 	}
 
-	flush_kthread_worker(&master->kworker);
+	kthread_flush_worker(&master->kworker);
 	kthread_stop(master->kworker_task);
 
 	return 0;
@@ -1421,7 +1421,7 @@ static int __spi_queued_transfer(struct spi_device *spi,
 
 	list_add_tail(&msg->queue, &master->queue);
 	if (!master->busy && need_pump)
-		queue_kthread_work(&master->kworker, &master->pump_messages);
+		kthread_queue_work(&master->kworker, &master->pump_messages);
 
 	spin_unlock_irqrestore(&master->queue_lock, flags);
 	return 0;
diff --git a/drivers/tty/serial/sc16is7xx.c b/drivers/tty/serial/sc16is7xx.c
index f36e6df2fa90..1f6b9f641455 100644
--- a/drivers/tty/serial/sc16is7xx.c
+++ b/drivers/tty/serial/sc16is7xx.c
@@ -708,7 +708,7 @@ static irqreturn_t sc16is7xx_irq(int irq, void *dev_id)
 {
 	struct sc16is7xx_port *s = (struct sc16is7xx_port *)dev_id;
 
-	queue_kthread_work(&s->kworker, &s->irq_work);
+	kthread_queue_work(&s->kworker, &s->irq_work);
 
 	return IRQ_HANDLED;
 }
@@ -784,7 +784,7 @@ static void sc16is7xx_ier_clear(struct uart_port *port, u8 bit)
 
 	one->config.flags |= SC16IS7XX_RECONF_IER;
 	one->config.ier_clear |= bit;
-	queue_kthread_work(&s->kworker, &one->reg_work);
+	kthread_queue_work(&s->kworker, &one->reg_work);
 }
 
 static void sc16is7xx_stop_tx(struct uart_port *port)
@@ -802,7 +802,7 @@ static void sc16is7xx_start_tx(struct uart_port *port)
 	struct sc16is7xx_port *s = dev_get_drvdata(port->dev);
 	struct sc16is7xx_one *one = to_sc16is7xx_one(port, port);
 
-	queue_kthread_work(&s->kworker, &one->tx_work);
+	kthread_queue_work(&s->kworker, &one->tx_work);
 }
 
 static unsigned int sc16is7xx_tx_empty(struct uart_port *port)
@@ -828,7 +828,7 @@ static void sc16is7xx_set_mctrl(struct uart_port *port, unsigned int mctrl)
 	struct sc16is7xx_one *one = to_sc16is7xx_one(port, port);
 
 	one->config.flags |= SC16IS7XX_RECONF_MD;
-	queue_kthread_work(&s->kworker, &one->reg_work);
+	kthread_queue_work(&s->kworker, &one->reg_work);
 }
 
 static void sc16is7xx_break_ctl(struct uart_port *port, int break_state)
@@ -957,7 +957,7 @@ static int sc16is7xx_config_rs485(struct uart_port *port,
 
 	port->rs485 = *rs485;
 	one->config.flags |= SC16IS7XX_RECONF_RS485;
-	queue_kthread_work(&s->kworker, &one->reg_work);
+	kthread_queue_work(&s->kworker, &one->reg_work);
 
 	return 0;
 }
@@ -1030,7 +1030,7 @@ static void sc16is7xx_shutdown(struct uart_port *port)
 
 	sc16is7xx_power(port, 0);
 
-	flush_kthread_worker(&s->kworker);
+	kthread_flush_worker(&s->kworker);
 }
 
 static const char *sc16is7xx_type(struct uart_port *port)
@@ -1176,8 +1176,8 @@ static int sc16is7xx_probe(struct device *dev,
 	s->devtype = devtype;
 	dev_set_drvdata(dev, s);
 
-	init_kthread_worker(&s->kworker);
-	init_kthread_work(&s->irq_work, sc16is7xx_ist);
+	kthread_init_worker(&s->kworker);
+	kthread_init_work(&s->irq_work, sc16is7xx_ist);
 	s->kworker_task = kthread_run(kthread_worker_fn, &s->kworker,
 				      "sc16is7xx");
 	if (IS_ERR(s->kworker_task)) {
@@ -1230,8 +1230,8 @@ static int sc16is7xx_probe(struct device *dev,
 				     SC16IS7XX_EFCR_RXDISABLE_BIT |
 				     SC16IS7XX_EFCR_TXDISABLE_BIT);
 		/* Initialize kthread work structs */
-		init_kthread_work(&s->p[i].tx_work, sc16is7xx_tx_proc);
-		init_kthread_work(&s->p[i].reg_work, sc16is7xx_reg_proc);
+		kthread_init_work(&s->p[i].tx_work, sc16is7xx_tx_proc);
+		kthread_init_work(&s->p[i].reg_work, sc16is7xx_reg_proc);
 		/* Register port */
 		uart_add_one_port(&sc16is7xx_uart, &s->p[i].port);
 		/* Go to suspend mode */
@@ -1281,7 +1281,7 @@ static int sc16is7xx_remove(struct device *dev)
 		sc16is7xx_power(&s->p[i].port, 0);
 	}
 
-	flush_kthread_worker(&s->kworker);
+	kthread_flush_worker(&s->kworker);
 	kthread_stop(s->kworker_task);
 
 	if (!IS_ERR(s->clk))
diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index c792ee1628d0..e2b095b8ca47 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -57,7 +57,7 @@ extern int tsk_fork_get_node(struct task_struct *tsk);
  * Simple work processor based on kthread.
  *
  * This provides easier way to make use of kthreads.  A kthread_work
- * can be queued and flushed using queue/flush_kthread_work()
+ * can be queued and flushed using queue/kthread_flush_work()
  * respectively.  Queued kthread_works are processed by a kthread
  * running kthread_worker_fn().
  */
@@ -99,23 +99,23 @@ struct kthread_work {
  */
 #ifdef CONFIG_LOCKDEP
 # define KTHREAD_WORKER_INIT_ONSTACK(worker)				\
-	({ init_kthread_worker(&worker); worker; })
+	({ kthread_init_worker(&worker); worker; })
 # define DEFINE_KTHREAD_WORKER_ONSTACK(worker)				\
 	struct kthread_worker worker = KTHREAD_WORKER_INIT_ONSTACK(worker)
 #else
 # define DEFINE_KTHREAD_WORKER_ONSTACK(worker) DEFINE_KTHREAD_WORKER(worker)
 #endif
 
-extern void __init_kthread_worker(struct kthread_worker *worker,
+extern void __kthread_init_worker(struct kthread_worker *worker,
 			const char *name, struct lock_class_key *key);
 
-#define init_kthread_worker(worker)					\
+#define kthread_init_worker(worker)					\
 	do {								\
 		static struct lock_class_key __key;			\
-		__init_kthread_worker((worker), "("#worker")->lock", &__key); \
+		__kthread_init_worker((worker), "("#worker")->lock", &__key); \
 	} while (0)
 
-#define init_kthread_work(work, fn)					\
+#define kthread_init_work(work, fn)					\
 	do {								\
 		memset((work), 0, sizeof(struct kthread_work));		\
 		INIT_LIST_HEAD(&(work)->node);				\
@@ -124,9 +124,9 @@ extern void __init_kthread_worker(struct kthread_worker *worker,
 
 int kthread_worker_fn(void *worker_ptr);
 
-bool queue_kthread_work(struct kthread_worker *worker,
+bool kthread_queue_work(struct kthread_worker *worker,
 			struct kthread_work *work);
-void flush_kthread_work(struct kthread_work *work);
-void flush_kthread_worker(struct kthread_worker *worker);
+void kthread_flush_work(struct kthread_work *work);
+void kthread_flush_worker(struct kthread_worker *worker);
 
 #endif /* _LINUX_KTHREAD_H */
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 0bec14aa844e..20bdf2c8d0f5 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -536,7 +536,7 @@ int kthreadd(void *unused)
 	return 0;
 }
 
-void __init_kthread_worker(struct kthread_worker *worker,
+void __kthread_init_worker(struct kthread_worker *worker,
 				const char *name,
 				struct lock_class_key *key)
 {
@@ -545,7 +545,7 @@ void __init_kthread_worker(struct kthread_worker *worker,
 	INIT_LIST_HEAD(&worker->work_list);
 	worker->task = NULL;
 }
-EXPORT_SYMBOL_GPL(__init_kthread_worker);
+EXPORT_SYMBOL_GPL(__kthread_init_worker);
 
 /**
  * kthread_worker_fn - kthread function to process kthread_worker
@@ -602,7 +602,7 @@ repeat:
 EXPORT_SYMBOL_GPL(kthread_worker_fn);
 
 /* insert @work before @pos in @worker */
-static void insert_kthread_work(struct kthread_worker *worker,
+static void kthread_insert_work(struct kthread_worker *worker,
 			       struct kthread_work *work,
 			       struct list_head *pos)
 {
@@ -615,7 +615,7 @@ static void insert_kthread_work(struct kthread_worker *worker,
 }
 
 /**
- * queue_kthread_work - queue a kthread_work
+ * kthread_queue_work - queue a kthread_work
  * @worker: target kthread_worker
  * @work: kthread_work to queue
  *
@@ -623,7 +623,7 @@ static void insert_kthread_work(struct kthread_worker *worker,
  * must have been created with kthread_worker_create().  Returns %true
  * if @work was successfully queued, %false if it was already pending.
  */
-bool queue_kthread_work(struct kthread_worker *worker,
+bool kthread_queue_work(struct kthread_worker *worker,
 			struct kthread_work *work)
 {
 	bool ret = false;
@@ -631,13 +631,13 @@ bool queue_kthread_work(struct kthread_worker *worker,
 
 	spin_lock_irqsave(&worker->lock, flags);
 	if (list_empty(&work->node)) {
-		insert_kthread_work(worker, work, &worker->work_list);
+		kthread_insert_work(worker, work, &worker->work_list);
 		ret = true;
 	}
 	spin_unlock_irqrestore(&worker->lock, flags);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(queue_kthread_work);
+EXPORT_SYMBOL_GPL(kthread_queue_work);
 
 struct kthread_flush_work {
 	struct kthread_work	work;
@@ -652,12 +652,12 @@ static void kthread_flush_work_fn(struct kthread_work *work)
 }
 
 /**
- * flush_kthread_work - flush a kthread_work
+ * kthread_flush_work - flush a kthread_work
  * @work: work to flush
  *
  * If @work is queued or executing, wait for it to finish execution.
  */
-void flush_kthread_work(struct kthread_work *work)
+void kthread_flush_work(struct kthread_work *work)
 {
 	struct kthread_flush_work fwork = {
 		KTHREAD_WORK_INIT(fwork.work, kthread_flush_work_fn),
@@ -678,9 +678,10 @@ retry:
 	}
 
 	if (!list_empty(&work->node))
-		insert_kthread_work(worker, &fwork.work, work->node.next);
+		kthread_insert_work(worker, &fwork.work, work->node.next);
 	else if (worker->current_work == work)
-		insert_kthread_work(worker, &fwork.work, worker->work_list.next);
+		kthread_insert_work(worker, &fwork.work,
+				    worker->work_list.next);
 	else
 		noop = true;
 
@@ -689,23 +690,23 @@ retry:
 	if (!noop)
 		wait_for_completion(&fwork.done);
 }
-EXPORT_SYMBOL_GPL(flush_kthread_work);
+EXPORT_SYMBOL_GPL(kthread_flush_work);
 
 /**
- * flush_kthread_worker - flush all current works on a kthread_worker
+ * kthread_flush_worker - flush all current works on a kthread_worker
  * @worker: worker to flush
  *
  * Wait until all currently executing or pending works on @worker are
  * finished.
  */
-void flush_kthread_worker(struct kthread_worker *worker)
+void kthread_flush_worker(struct kthread_worker *worker)
 {
 	struct kthread_flush_work fwork = {
 		KTHREAD_WORK_INIT(fwork.work, kthread_flush_work_fn),
 		COMPLETION_INITIALIZER_ONSTACK(fwork.done),
 	};
 
-	queue_kthread_work(worker, &fwork.work);
+	kthread_queue_work(worker, &fwork.work);
 	wait_for_completion(&fwork.done);
 }
-EXPORT_SYMBOL_GPL(flush_kthread_worker);
+EXPORT_SYMBOL_GPL(kthread_flush_worker);
diff --git a/sound/soc/intel/baytrail/sst-baytrail-ipc.c b/sound/soc/intel/baytrail/sst-baytrail-ipc.c
index 5bbaa667bec1..c66a5ec18182 100644
--- a/sound/soc/intel/baytrail/sst-baytrail-ipc.c
+++ b/sound/soc/intel/baytrail/sst-baytrail-ipc.c
@@ -344,7 +344,7 @@ static irqreturn_t sst_byt_irq_thread(int irq, void *context)
 	spin_unlock_irqrestore(&sst->spinlock, flags);
 
 	/* continue to send any remaining messages... */
-	queue_kthread_work(&ipc->kworker, &ipc->kwork);
+	kthread_queue_work(&ipc->kworker, &ipc->kwork);
 
 	return IRQ_HANDLED;
 }
diff --git a/sound/soc/intel/common/sst-ipc.c b/sound/soc/intel/common/sst-ipc.c
index a12c7bb08d3b..6c672ac79cce 100644
--- a/sound/soc/intel/common/sst-ipc.c
+++ b/sound/soc/intel/common/sst-ipc.c
@@ -111,7 +111,7 @@ static int ipc_tx_message(struct sst_generic_ipc *ipc, u64 header,
 	list_add_tail(&msg->list, &ipc->tx_list);
 	spin_unlock_irqrestore(&ipc->dsp->spinlock, flags);
 
-	queue_kthread_work(&ipc->kworker, &ipc->kwork);
+	kthread_queue_work(&ipc->kworker, &ipc->kwork);
 
 	if (wait)
 		return tx_wait_done(ipc, msg, rx_data);
@@ -281,7 +281,7 @@ int sst_ipc_init(struct sst_generic_ipc *ipc)
 		return -ENOMEM;
 
 	/* start the IPC message thread */
-	init_kthread_worker(&ipc->kworker);
+	kthread_init_worker(&ipc->kworker);
 	ipc->tx_thread = kthread_run(kthread_worker_fn,
 					&ipc->kworker, "%s",
 					dev_name(ipc->dev));
@@ -292,7 +292,7 @@ int sst_ipc_init(struct sst_generic_ipc *ipc)
 		return ret;
 	}
 
-	init_kthread_work(&ipc->kwork, ipc_tx_msgs);
+	kthread_init_work(&ipc->kwork, ipc_tx_msgs);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(sst_ipc_init);
diff --git a/sound/soc/intel/haswell/sst-haswell-ipc.c b/sound/soc/intel/haswell/sst-haswell-ipc.c
index 91565229d074..e432a31fd9f2 100644
--- a/sound/soc/intel/haswell/sst-haswell-ipc.c
+++ b/sound/soc/intel/haswell/sst-haswell-ipc.c
@@ -818,7 +818,7 @@ static irqreturn_t hsw_irq_thread(int irq, void *context)
 	spin_unlock_irqrestore(&sst->spinlock, flags);
 
 	/* continue to send any remaining messages... */
-	queue_kthread_work(&ipc->kworker, &ipc->kwork);
+	kthread_queue_work(&ipc->kworker, &ipc->kwork);
 
 	return IRQ_HANDLED;
 }
diff --git a/sound/soc/intel/skylake/skl-sst-ipc.c b/sound/soc/intel/skylake/skl-sst-ipc.c
index 96f2f6889b18..dd41bb0b84aa 100644
--- a/sound/soc/intel/skylake/skl-sst-ipc.c
+++ b/sound/soc/intel/skylake/skl-sst-ipc.c
@@ -458,7 +458,7 @@ irqreturn_t skl_dsp_irq_thread_handler(int irq, void *context)
 	skl_ipc_int_enable(dsp);
 
 	/* continue to send any remaining messages... */
-	queue_kthread_work(&ipc->kworker, &ipc->kwork);
+	kthread_queue_work(&ipc->kworker, &ipc->kwork);
 
 	return IRQ_HANDLED;
 }
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
