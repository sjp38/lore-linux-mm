Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3E08C6B0047
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 15:42:28 -0500 (EST)
Received: by fxm8 with SMTP id 8so3094998fxm.6
        for <linux-mm@kvack.org>; Sat, 30 Jan 2010 12:42:25 -0800 (PST)
Subject: Re: [Update][PATCH] MM / PM: Force GFP_NOIO during
 suspend/hibernation and resume
From: Maxim Levitsky <maximlevitsky@gmail.com>
In-Reply-To: <201001301956.41372.rjw@sisk.pl>
References: <201001212121.50272.rjw@sisk.pl>
	 <201001252249.18690.rjw@sisk.pl> <4B5E1281.7090700@suse.de>
	 <201001301956.41372.rjw@sisk.pl>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 30 Jan 2010 22:42:20 +0200
Message-ID: <1264884140.13861.7.camel@maxim-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Alexey Starikovskiy <astarikovskiy@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2010-01-30 at 19:56 +0100, Rafael J. Wysocki wrote: 
> On Monday 25 January 2010, Alexey Starikovskiy wrote:
> > Rafael J. Wysocki D?D,N?DuN?:
> > > On Saturday 23 January 2010, Maxim Levitsky wrote:
> > >> On Fri, 2010-01-22 at 22:19 +0100, Rafael J. Wysocki wrote: 
> > >>> On Friday 22 January 2010, Maxim Levitsky wrote:
> > >>>> On Fri, 2010-01-22 at 10:42 +0900, KOSAKI Motohiro wrote: 
> > >>>>>>>> Probably we have multiple option. but I don't think GFP_NOIO is good
> > >>>>>>>> option. It assume the system have lots non-dirty cache memory and it isn't
> > >>>>>>>> guranteed.
> > >>>>>>> Basically nothing is guaranteed in this case.  However, does it actually make
> > >>>>>>> things _worse_?  
> > >>>>>> Hmm..
> > >>>>>> Do you mean we don't need to prevent accidental suspend failure?
> > >>>>>> Perhaps, I did misunderstand your intention. If you think your patch solve
> > >>>>>> this this issue, I still disagree. but If you think your patch mitigate
> > >>>>>> the pain of this issue, I agree it. I don't have any reason to oppose your
> > >>>>>> first patch.
> > >>>>> One question. Have anyone tested Rafael's $subject patch? 
> > >>>>> Please post test result. if the issue disapper by the patch, we can
> > >>>>> suppose the slowness is caused by i/o layer.
> > >>>> I did.
> > >>>>
> > >>>> As far as I could see, patch does solve the problem I described.
> > >>>>
> > >>>> Does it affect speed of suspend? I can't say for sure. It seems to be
> > >>>> the same.
> > >>> Thanks for testing.
> > >> I'll test that too, soon.
> > >> Just to note that I left my hibernate loop run overnight, and now I am
> > >> posting from my notebook after it did 590 hibernate cycles.
> > > 
> > > Did you have a chance to test it?
> > > 
> > >> Offtopic, but Note that to achieve that I had to stop using global acpi
> > >> hardware lock. I tried all kinds of things, but for now it just hands
> > >> from time to time.
> > >> See http://bugzilla.kernel.org/show_bug.cgi?id=14668
> > > 
> > > I'm going to look at that later this week, although I'm not sure I can do more
> > > than Alex about that.
> > > 
> > > Rafael
> > Rafael,
> > If you can point to where one may insert callback to be called just before handing control to resume kernel,
> > it may help...
> 
> Generally speaking, I'd do that in a .suspend() callback of one of devices.
> 
> If that's inconvenient, you can also place it in the .pre_restore() platform
> hibernate callback (drivers/acpi/sleep.c).  It only disables GPEs right now,
> it might release the global lock as well.
> 
> The .pre_restore() callback is executed after all devices have been suspended,
> so there's no danger any driver would re-acquire the global lock after that.


Well, I did that very late, very close to image restore.
Still, it didn't work (It hung after the resume, in the kernel that was
just restored, on access to the hardware lock, or in other words in same
way)

Here is what I did:

commit 71e0be39531ac01b99020ea139ef3c23aa6de415
Author: Maxim Levitsky <maximlevitsky@gmail.com>
Date:   Wed Jan 20 21:52:21 2010 +0200

    Kernel that does the resume from disk can take global hardware
    acpi lock, but not release it (for example if it is in middle of access to locked field)
    Always release it before passing control to resumed kernel

diff --git a/drivers/acpi/acpica/acglobal.h b/drivers/acpi/acpica/acglobal.h
index 29ba66d..29e1be0 100644
--- a/drivers/acpi/acpica/acglobal.h
+++ b/drivers/acpi/acpica/acglobal.h
@@ -195,6 +195,7 @@ ACPI_EXTERN acpi_semaphore acpi_gbl_global_lock_semaphore;
 ACPI_EXTERN u16 acpi_gbl_global_lock_handle;
 ACPI_EXTERN u8 acpi_gbl_global_lock_acquired;
 ACPI_EXTERN u8 acpi_gbl_global_lock_present;
+ACPI_EXTERN u8 acpi_gbl_global_lock_suspended;
 
 /*
  * Spinlocks are used for interfaces that can be possibly called at
diff --git a/drivers/acpi/acpica/evmisc.c b/drivers/acpi/acpica/evmisc.c
index ce224e1..f3569db 100644
--- a/drivers/acpi/acpica/evmisc.c
+++ b/drivers/acpi/acpica/evmisc.c
@@ -456,7 +456,7 @@ acpi_status acpi_ev_acquire_global_lock(u16 timeout)
 	 * Make sure that a global lock actually exists. If not, just treat the
 	 * lock as a standard mutex.
 	 */
-	if (!acpi_gbl_global_lock_present) {
+	if (!acpi_gbl_global_lock_present || acpi_gbl_global_lock_suspended) {
 		acpi_gbl_global_lock_acquired = TRUE;
 		return_ACPI_STATUS(AE_OK);
 	}
diff --git a/drivers/acpi/acpica/evxface.c b/drivers/acpi/acpica/evxface.c
index 2fe0809..b27904e 100644
--- a/drivers/acpi/acpica/evxface.c
+++ b/drivers/acpi/acpica/evxface.c
@@ -820,3 +820,29 @@ acpi_status acpi_release_global_lock(u32 handle)
 }
 
 ACPI_EXPORT_SYMBOL(acpi_release_global_lock)
+
+
+/*******************************************************************************
+ *
+ * FUNCTION:    acpi_bust_global_lock
+ *
+ * PARAMETERS:  None
+ *
+ * RETURN:      Status
+ *
+ * DESCRIPTION: Release global lock and ignore it from now on
+ *
+ ******************************************************************************/
+
+acpi_status acpi_bust_global_lock(void)
+{
+	acpi_status status;
+
+	status = acpi_ex_acquire_mutex_object(ACPI_WAIT_FOREVER,
+					      acpi_gbl_global_lock_mutex,
+					      acpi_os_get_thread_id());
+
+	acpi_gbl_global_lock_suspended = TRUE;
+
+	status = acpi_ex_release_mutex_object(acpi_gbl_global_lock_mutex);
+}
diff --git a/drivers/acpi/acpica/utglobal.c b/drivers/acpi/acpica/utglobal.c
index 3f2c68f..e4cafea 100644
--- a/drivers/acpi/acpica/utglobal.c
+++ b/drivers/acpi/acpica/utglobal.c
@@ -782,6 +782,7 @@ acpi_status acpi_ut_init_globals(void)
 	acpi_gbl_global_lock_acquired = FALSE;
 	acpi_gbl_global_lock_handle = 0;
 	acpi_gbl_global_lock_present = FALSE;
+	acpi_gbl_global_lock_suspended = FALSE;
 
 	/* Miscellaneous variables */
 
diff --git a/drivers/acpi/sleep.c b/drivers/acpi/sleep.c
index 79d33d9..6e41954 100644
--- a/drivers/acpi/sleep.c
+++ b/drivers/acpi/sleep.c
@@ -119,6 +119,23 @@ static int acpi_pm_disable_gpes(void)
 }
 
 /**
+ *	acpi_pm_pre_restore - called just before the restore
+ */
+
+static int acpi_pm_pre_restore(void)
+{
+	u32 glk;
+
+	acpi_pm_disable_gpes();
+
+	/* We can't let the resuming kernel see the global
+		lock locked, so bust it */
+
+	acpi_bust_global_lock();
+	return 0;
+}
+
+/**
  *	__acpi_pm_prepare - Prepare the platform to enter the target state.
  *
  *	If necessary, set the firmware waking vector and do arch-specific
@@ -565,7 +582,7 @@ static struct platform_hibernation_ops acpi_hibernation_ops = {
 	.prepare = acpi_pm_prepare,
 	.enter = acpi_hibernation_enter,
 	.leave = acpi_hibernation_leave,
-	.pre_restore = acpi_pm_disable_gpes,
+	.pre_restore = acpi_pm_pre_restore,
 	.restore_cleanup = acpi_pm_enable_gpes,
 };
 
diff --git a/include/acpi/acpixf.h b/include/acpi/acpixf.h
index 86e9735..63132b0 100644
--- a/include/acpi/acpixf.h
+++ b/include/acpi/acpixf.h
@@ -270,6 +270,8 @@ acpi_status acpi_acquire_global_lock(u16 timeout, u32 * handle);
 
 acpi_status acpi_release_global_lock(u32 handle);
 
+acpi_status acpi_bust_global_lock(void);
+
 acpi_status acpi_enable_event(u32 event, u32 flags);
 
 acpi_status acpi_disable_event(u32 event, u32 flags);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
