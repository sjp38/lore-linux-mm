Subject: PATCH: Re: Helding the Kernel lock while doing IO???
References: <yttpur0wjlk.fsf@vexeta.dc.fi.udc.es>
	<20000506124809.C4994@redhat.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Stephen C. Tweedie"'s message of "Sat, 6 May 2000 12:48:09 +0100"
Date: 15 May 2000 00:02:45 +0200
Message-ID: <yttbt2823ju.fsf_-_@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

>>>>> "stephen" == Stephen C Tweedie <sct@redhat.com> writes:

stephen> Hi,
stephen> On Sat, May 06, 2000 at 03:30:47AM +0200, Juan J. Quintela wrote:
>> 
>> read_swap_cache is called synchronously, then we can have to wait
>> until we read the page to liberate the lock kernel.  It is intended?
>> I am losing some detail?

stephen> Holding the big kernel lock while we sleep is quite legal.  The 
stephen> scheduler drops the lock while we sleep and reacquires it when we
stephen> are rescheduled.  The lock_kernel() lock is not at all like other
stephen> spinlocks.

Thanks again for the comment, what do you think about add a comment
about that?  Patch attached.

Later, Juan.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude work/include/linux/smp_lock.h testing/include/linux/smp_lock.h
--- work/include/linux/smp_lock.h	Sun May 14 20:20:41 2000
+++ testing/include/linux/smp_lock.h	Mon May 15 00:00:29 2000
@@ -5,6 +5,11 @@
 
 #ifndef CONFIG_SMP
 
+/* We can hold the big kernel lock while we sleep.  The scheduler
+ * drops the lock while we sleep and re-acquires it when we are
+ * rescheduled.  
+ */
+
 #define lock_kernel()				do { } while(0)
 #define unlock_kernel()				do { } while(0)
 #define release_kernel_lock(task, cpu)		do { } while(0)


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
