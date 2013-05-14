Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 1351F6B00B0
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:00:44 -0400 (EDT)
Message-ID: <519243B2.8030102@parallels.com>
Date: Tue, 14 May 2013 18:01:22 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 09/31] dcache: convert to use new lru list infrastructure
References: <1368382432-25462-1-git-send-email-glommer@openvz.org> <1368382432-25462-10-git-send-email-glommer@openvz.org> <20130514065902.GG29466@dastard>
In-Reply-To: <20130514065902.GG29466@dastard>
Content-Type: multipart/mixed;
	boundary="------------010708050508050409090900"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

--------------010708050508050409090900
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 05/14/2013 10:59 AM, Dave Chinner wrote:
> On Sun, May 12, 2013 at 10:13:30PM +0400, Glauber Costa wrote:
>> From: Dave Chinner <dchinner@redhat.com>
>>
>> [ glommer: don't reintroduce double decrement of nr_unused_dentries,
>>   adapted for new LRU return codes ]
>> Signed-off-by: Dave Chinner <dchinner@redhat.com>
>> Signed-off-by: Glauber Costa <glommer@openvz.org>
>> ---
> 
> I'm seeing a panic on startup in d_kill() with an invalid d_child
> list entry with this patch. I haven't got to the bottom of it yet.
> 

My wild guess is that your patch does not prune correctly, as I
described in my last message.

> .....
> 
>>  void shrink_dcache_sb(struct super_block *sb)
>>  {
>> -	LIST_HEAD(tmp);
>> -
>> -	spin_lock(&sb->s_dentry_lru_lock);
>> -	while (!list_empty(&sb->s_dentry_lru)) {
>> -		list_splice_init(&sb->s_dentry_lru, &tmp);
>> -
>> -		/*
>> -		 * account for removal here so we don't need to handle it later
>> -		 * even though the dentry is no longer on the lru list.
>> -		 */
>> -		this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
>> -		sb->s_nr_dentry_unused = 0;
>> -
>> -		spin_unlock(&sb->s_dentry_lru_lock);
>> -		shrink_dcache_list(&tmp);
>> -		spin_lock(&sb->s_dentry_lru_lock);
>> -	}
>> -	spin_unlock(&sb->s_dentry_lru_lock);
>> +	list_lru_dispose_all(&sb->s_dentry_lru, shrink_dcache_list);
>>  }
>>  EXPORT_SYMBOL(shrink_dcache_sb);
> 
> And here comes the fun part. This doesn't account for the
> dentries that are freed from the superblock here.
> 
> So, it needs to be something like:
> 
> void shrink_dcache_sb(struct super_block *sb)
> {
> 	unsigned long disposed;
> 
> 	disposed = list_lru_dispose_all(&sb->s_dentry_lru,
> 					shrink_dcache_list);
> 
> 	this_cpu_sub(nr_dentry_unused, disposed);
> }
> 
> But, therein lies a problem. nr_dentry_unused is a 32 bit counter,
> and we can return a 64 bit value here. So that means we have to bump
> nr_dentry_unused to a long, not an int for these per-cpu counters to
> work.
> 
> And then there's the problem that the sum of these counters only
> uses an int. Which means if we get large numbers of negative values
> on different CPU from unmounts, the summation will end up
> overflowing and it'll all suck.
> 
> So, Glauber, what do you reckon? I've never likes this stupid
> hand-rolled per-cpu counter stuff, and it's causing issues. Should
> we just convert them to generic per-cpu counters because they are
> 64bit clean and just handle out-of-range sums in the /proc update
> code?
> 

One option would be to add the following patch to the beginning of the
series.




--------------010708050508050409090900
Content-Type: text/x-patch; name="dentry.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="dentry.patch"

diff --git a/fs/dcache.c b/fs/dcache.c
index 3a3adc4..a8be4c9 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -116,12 +116,12 @@ struct dentry_stat_t dentry_stat = {
 	.age_limit = 45,
 };
 
-static DEFINE_PER_CPU(unsigned int, nr_dentry);
-static DEFINE_PER_CPU(unsigned int, nr_dentry_unused);
+static DEFINE_PER_CPU(long, nr_dentry);
+static DEFINE_PER_CPU(long, nr_dentry_unused);
 
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
 /* scan possible cpus instead of online and avoid worrying about CPU hotplug. */
-static int get_nr_dentry(void)
+static long get_nr_dentry(void)
 {
 	int i;
 	int sum = 0;
@@ -130,7 +130,7 @@ static int get_nr_dentry(void)
 	return sum < 0 ? 0 : sum;
 }
 
-static int get_nr_dentry_unused(void)
+static long get_nr_dentry_unused(void)
 {
 	int i;
 	int sum = 0;
@@ -144,7 +144,7 @@ int proc_nr_dentry(ctl_table *table, int write, void __user *buffer,
 {
 	dentry_stat.nr_dentry = get_nr_dentry();
 	dentry_stat.nr_unused = get_nr_dentry_unused();
-	return proc_dointvec(table, write, buffer, lenp, ppos);
+	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 }
 #endif
 
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 4d24a12..bd08285 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -54,11 +54,11 @@ struct qstr {
 #define hashlen_len(hashlen)  ((u32)((hashlen) >> 32))
 
 struct dentry_stat_t {
-	int nr_dentry;
-	int nr_unused;
-	int age_limit;          /* age in seconds */
-	int want_pages;         /* pages requested by system */
-	int dummy[2];
+	long nr_dentry;
+	long nr_unused;
+	long age_limit;          /* age in seconds */
+	long want_pages;         /* pages requested by system */
+	long dummy[2];
 };
 extern struct dentry_stat_t dentry_stat;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 67e1040..e875f60 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1267,12 +1267,12 @@ struct super_block {
 	/* s_dentry_lru_lock protects s_dentry_lru and s_nr_dentry_unused */
 	spinlock_t		s_dentry_lru_lock ____cacheline_aligned_in_smp;
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
-	int			s_nr_dentry_unused;	/* # of dentry on lru */
+	long			s_nr_dentry_unused;	/* # of dentry on lru */
 
 	/* s_inode_lru_lock protects s_inode_lru and s_nr_inodes_unused */
 	spinlock_t		s_inode_lru_lock ____cacheline_aligned_in_smp;
 	struct list_head	s_inode_lru;		/* unused inode lru */
-	int			s_nr_inodes_unused;	/* # of inodes on lru */
+	long			s_nr_inodes_unused;	/* # of inodes on lru */
 
 	struct block_device	*s_bdev;
 	struct backing_dev_info *s_bdi;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9edcf45..0dc51c0 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1493,7 +1493,7 @@ static struct ctl_table fs_table[] = {
 	{
 		.procname	= "dentry-state",
 		.data		= &dentry_stat,
-		.maxlen		= 6*sizeof(int),
+		.maxlen		= 6*sizeof(long),
 		.mode		= 0444,
 		.proc_handler	= proc_nr_dentry,
 	},

--------------010708050508050409090900--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
