From: Jeremy Hall <jhall@maoz.com>
Message-Id: <200304152302.h3FN2ck4027380@sith.maoz.com>
Subject: Re: interrupt context
In-Reply-To: <1050442843.3664.165.camel@localhost> from Robert Love at "Apr 15,
 2003 05:40:44 pm"
Date: Tue, 15 Apr 2003 19:02:38 -0400 (EDT)
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=ELM744963866-2088-29_
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Jeremy Hall <jhall@maoz.com>, linux-mm@kvack.org, paul@linuxaudiosystems.com
List-ID: <linux-mm.kvack.org>

--ELM744963866-2088-29_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

In the new year, Robert Love wrote:
> On Mon, 2003-04-14 at 23:44, Jeremy Hall wrote:
> 
> > My quandery is where to put the lock so that both cards will use it.  I 
> > need a layer that is visible to both and don't fully understand the alsa 
> > architecture enough to know where to put it.
> 
> OK, I understand you now. :)
> 
> What is the relationship between the two things that are conflicting?
> 
Two copies of snd_pcm_period_elapsed were running concurrently, one for 
one rme9652, one for the other.  Both are linked together as a single 
pcm_multi alsa device that an application is using.  Because both cards 
are on different interrupts, they can both run at the same time (the 
rme9652 interrupt handler calls snd_pcm_period_elapsed)

Somehow the second handler got called while the first was running, and the 
first had acquired a pcm spinlock.  Because the first had been suspended 
to run the second, deadlock occurred because the lock was never released.

There must be a common locking mechanism within the context of the 
interrupt handler so that two interrupt handlers running the same code 
don't deadlock.  The dependency occurs from within the pcm_multi layer, 
and that is where the "right" solution should be.

So to test, I wrote into the init routines, in the card discovery 
mechanism, a common lock, I called it dev_lock, and made it a requirement 
for running this function.

This was ok, except it meant that both devices can't run at the same time.

I wrote it up as a tasklet, which may or may not be the right solution 
either, but at least now it won't deadlock and maybe both will run at the 
same time.

I have attached both versions, and due to the way I applied it, you have 
to apply the irq diffs, then the tasklet diffs to get the current code.  
I'm not brave enough to say this should go in the alsa repository, but the 
tasklet version has not yet deadlocked and I have seen several XRUNs going 
by.  I cannot guarantee I have seen the special-case condition, but 
normally sooner or later deadlock occurs and it hasn't, running at LL 
settings for 00:10:09:32, which I consider a win.  Previously I'd see 
deadlock within the first couple minutes.

_J

> 	Robert Love
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 


--ELM744963866-2088-29_
Content-Type: text/plain; charset=ISO-8859-1
Content-Disposition: attachment; filename=irq-diffs
Content-Description: irq-diffs
Content-Transfer-Encoding: 7bit

--- rme9652.c	Tue Apr 15 09:40:41 2003
+++ rme9652.c.jhall	Tue Apr 15 09:37:15 2003
@@ -214,6 +214,7 @@
 	int dev;
 
 	spinlock_t lock;
+	spinlock_t *dev_lock;
 	int irq;
 	unsigned long port;
 	struct resource *res_port;
@@ -1950,13 +1951,13 @@
 void snd_rme9652_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	rme9652_t *rme9652 = (rme9652_t *) dev_id;
+	unsigned long flags;
 
 	if (!(rme9652_read(rme9652, RME9652_status_register) & RME9652_IRQ)) {
 		return;
 	}
 
-	rme9652_write(rme9652, RME9652_irq_clear, 0);
-
+	spin_lock_irqsave(rme9652->dev_lock, flags);
 	if (rme9652->capture_substream) {
 		snd_pcm_period_elapsed(rme9652->pcm->streams[SNDRV_PCM_STREAM_CAPTURE].substream);
 	}
@@ -1964,6 +1965,8 @@
 	if (rme9652->playback_substream) {
 		snd_pcm_period_elapsed(rme9652->pcm->streams[SNDRV_PCM_STREAM_PLAYBACK].substream);
 	}
+	spin_unlock_irqrestore(rme9652->dev_lock, flags);
+	rme9652_write(rme9652, RME9652_irq_clear, 0);
 }
 
 static snd_pcm_uframes_t snd_rme9652_hw_pointer(snd_pcm_substream_t *substream)
@@ -2674,6 +2677,7 @@
 {
 	static int dev;
 	rme9652_t *rme9652;
+	static spinlock_t dev_lock;
 	snd_card_t *card;
 	int err;
 
@@ -2693,6 +2697,9 @@
 	rme9652 = (rme9652_t *) card->private_data;
 	card->private_free = snd_rme9652_card_free;
 	rme9652->dev = dev;
+	if (!dev)
+		spin_lock_init(&dev_lock);
+	rme9652->dev_lock = &dev_lock;
 	rme9652->pci = pci;
 
 	if ((err = snd_rme9652_create(card, rme9652, precise_ptr[dev])) < 0) {

--ELM744963866-2088-29_
Content-Type: text/plain; charset=ISO-8859-1
Content-Disposition: attachment; filename=tasklet-diffs
Content-Description: tasklet-diffs
Content-Transfer-Encoding: 7bit

--- rme9652.c.jhall	Tue Apr 15 09:37:15 2003
+++ rme9652.c	Tue Apr 15 18:25:48 2003
@@ -214,7 +214,7 @@
 	int dev;
 
 	spinlock_t lock;
-	spinlock_t *dev_lock;
+	struct tasklet_struct interrupt_tasklet;
 	int irq;
 	unsigned long port;
 	struct resource *res_port;
@@ -326,6 +326,8 @@
 
 MODULE_DEVICE_TABLE(pci, snd_rme9652_ids);
 
+void rme9652_interrupt_tasklet(unsigned long arg);
+
 static inline void rme9652_write(rme9652_t *rme9652, int reg, int val)
 {
 	writel(val, rme9652->iobase + reg);
@@ -1951,13 +1953,20 @@
 void snd_rme9652_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	rme9652_t *rme9652 = (rme9652_t *) dev_id;
-	unsigned long flags;
 
 	if (!(rme9652_read(rme9652, RME9652_status_register) & RME9652_IRQ)) {
 		return;
 	}
 
-	spin_lock_irqsave(rme9652->dev_lock, flags);
+	tasklet_hi_schedule(&rme9652->interrupt_tasklet);
+	rme9652_write(rme9652, RME9652_irq_clear, 0);
+}
+
+void
+rme9652_interrupt_tasklet(unsigned long arg)
+{
+	rme9652_t *rme9652 = (rme9652_t*)arg;
+
 	if (rme9652->capture_substream) {
 		snd_pcm_period_elapsed(rme9652->pcm->streams[SNDRV_PCM_STREAM_CAPTURE].substream);
 	}
@@ -1965,8 +1974,6 @@
 	if (rme9652->playback_substream) {
 		snd_pcm_period_elapsed(rme9652->pcm->streams[SNDRV_PCM_STREAM_PLAYBACK].substream);
 	}
-	spin_unlock_irqrestore(rme9652->dev_lock, flags);
-	rme9652_write(rme9652, RME9652_irq_clear, 0);
 }
 
 static snd_pcm_uframes_t snd_rme9652_hw_pointer(snd_pcm_substream_t *substream)
@@ -2560,6 +2567,7 @@
 		return err;
 
 	spin_lock_init(&rme9652->lock);
+	tasklet_init(&rme9652->interrupt_tasklet, rme9652_interrupt_tasklet, (unsigned long) rme9652);
 
 	rme9652->port = pci_resource_start(pci, 0);
 	if ((rme9652->res_port = request_mem_region(rme9652->port, RME9652_IO_EXTENT, "rme9652")) == NULL) {
@@ -2677,7 +2685,6 @@
 {
 	static int dev;
 	rme9652_t *rme9652;
-	static spinlock_t dev_lock;
 	snd_card_t *card;
 	int err;
 
@@ -2697,9 +2704,6 @@
 	rme9652 = (rme9652_t *) card->private_data;
 	card->private_free = snd_rme9652_card_free;
 	rme9652->dev = dev;
-	if (!dev)
-		spin_lock_init(&dev_lock);
-	rme9652->dev_lock = &dev_lock;
 	rme9652->pci = pci;
 
 	if ((err = snd_rme9652_create(card, rme9652, precise_ptr[dev])) < 0) {

--ELM744963866-2088-29_--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
