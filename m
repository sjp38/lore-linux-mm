Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 5667D6B00EA
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 19:38:00 -0400 (EDT)
Date: Thu, 5 Apr 2012 16:37:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: revise the position of threshold index while
 unregistering event
Message-Id: <20120405163758.b2ef6c45.akpm@linux-foundation.org>
In-Reply-To: <20120405163530.a1a9c9f9.akpm@linux-foundation.org>
References: <1331035943-7456-1-git-send-email-handai.szj@taobao.com>
	<20120405163530.a1a9c9f9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

On Thu, 5 Apr 2012 16:35:30 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue,  6 Mar 2012 20:12:23 +0800
> Sha Zhengju <handai.szj@gmail.com> wrote:
> 
> > From: Sha Zhengju <handai.szj@taobao.com>
> > 
> > Index current_threshold should point to threshold just below or equal to usage.
> > See below:
> > http://www.spinics.net/lists/cgroups/msg00844.html
> 
> I have a bad feeling that I looked at a version of this patch
> yesterday, but I can't find it.

Found it!  Below.

I think we might as well fold "memcg: revise the position of threshold
index while unregistering event" into the below "memcg: make threshold
index in the right position" as a single patch?



From: Sha Zhengju <handai.szj@taobao.com>
Subject: memcg: make threshold index in the right position

Index current_threshold may point to threshold that just equal to usage
after last call of __mem_cgroup_threshold.  But after registering a new
event, it will change (pointing to threshold just below usage).  So make
it consistent here.

For example:
now:
	threshold array:  3  [5]  7  9   (usage = 6, [index] = 5)

next turn (after calling __mem_cgroup_threshold):
	threshold array:  3   5  [7]  9   (usage = 7, [index] = 7)

after registering a new event (threshold = 10):
	threshold array:  3  [5]  7  9  10 (usage = 7, [index] = 5)

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff -puN mm/memcontrol.c~memcg-make-threshold-index-in-the-right-position mm/memcontrol.c
--- a/mm/memcontrol.c~memcg-make-threshold-index-in-the-right-position
+++ a/mm/memcontrol.c
@@ -181,7 +181,7 @@ struct mem_cgroup_threshold {
 
 /* For threshold */
 struct mem_cgroup_threshold_ary {
-	/* An array index points to threshold just below usage. */
+	/* An array index points to threshold just below or equal to usage. */
 	int current_threshold;
 	/* Size of entries[] */
 	unsigned int size;
@@ -4267,7 +4267,7 @@ static void __mem_cgroup_threshold(struc
 	usage = mem_cgroup_usage(memcg, swap);
 
 	/*
-	 * current_threshold points to threshold just below usage.
+	 * current_threshold points to threshold just below or equal to usage.
 	 * If it's not true, a threshold was crossed after last
 	 * call of __mem_cgroup_threshold().
 	 */
@@ -4393,14 +4393,15 @@ static int mem_cgroup_usage_register_eve
 	/* Find current threshold */
 	new->current_threshold = -1;
 	for (i = 0; i < size; i++) {
-		if (new->entries[i].threshold < usage) {
+		if (new->entries[i].threshold <= usage) {
 			/*
 			 * new->current_threshold will not be used until
 			 * rcu_assign_pointer(), so it's safe to increment
 			 * it here.
 			 */
 			++new->current_threshold;
-		}
+		} else
+			break;
 	}
 
 	/* Free old spare buffer and save old primary buffer as spare */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
