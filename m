Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 5E3146B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 08:39:52 -0400 (EDT)
Message-ID: <51B0834A.8020606@parallels.com>
Date: Thu, 6 Jun 2013 16:40:42 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 03/35] dcache: convert dentry_stat.nr_unused to per-cpu
 counters
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-4-git-send-email-glommer@openvz.org> <20130605160731.91a5cd3ff700367f5e155d83@linux-foundation.org> <20130606014509.GN29338@dastard> <20130605194801.f9b25abf.akpm@linux-foundation.org>
In-Reply-To: <20130605194801.f9b25abf.akpm@linux-foundation.org>
Content-Type: multipart/mixed;
	boundary="------------090100080903040700090200"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

--------------090100080903040700090200
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 06/06/2013 06:48 AM, Andrew Morton wrote:
> On Thu, 6 Jun 2013 11:45:09 +1000 Dave Chinner <david@fromorbit.com> wrote:
> 
>> Andrew, if you want to push the changes back to generic per-cpu
>> counters through to Linus, then I'll write the patches for you.  But
>> - and this is a big but - I'll only do this if you are going to deal
>> with the "performance trumps all other concerns" fanatics over
>> whether it should be merged or not. I have better things to do
>> with my time have a flamewar over trivial details like this.
> 
> Please view my comments as a critique of the changelog, not of the code. 
> 
> There are presumably good (but undisclosed) reasons for going this way,
> but this question is so bleeding obvious that the decision should have
> been addressed up-front and in good detail.
> 
> And, preferably, with benchmark numbers.  Because it might have been
> the wrong decision - stranger things have happened.
> 

I have folded the attached patch here. Let me know if it still needs
more love.


--------------090100080903040700090200
Content-Type: text/x-patch; name="3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="3.patch"

diff --git a/fs/dcache.c b/fs/dcache.c
index 9f2aa96..0466dbd 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -121,7 +121,19 @@ static DEFINE_PER_CPU(long, nr_dentry);
 static DEFINE_PER_CPU(long, nr_dentry_unused);
 
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
-/* scan possible cpus instead of online and avoid worrying about CPU hotplug. */
+
+/*
+ * Here we resort to our own counters instead of using generic per-cpu counters
+ * for consistency with what the vfs inode code does. We are expected to harvest
+ * better code and performance by having our own specialized counters.
+ *
+ * Please note that the loop is done over all possible CPUs, not over all online
+ * CPUs. The reason for this is that we don't want to play games with CPUs going
+ * on and off. If one of them goes off, we will just keep their counters.
+ *
+ * glommer: See cffbc8a for details, and if you ever intend to change this,
+ * please update all vfs counters to match.
+ */
 static long get_nr_dentry(void)
 {
 	int i;

--------------090100080903040700090200--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
