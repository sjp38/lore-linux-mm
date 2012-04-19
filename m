Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 32D316B004A
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 12:30:41 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so6185338ghr.14
        for <linux-mm@kvack.org>; Thu, 19 Apr 2012 09:30:40 -0700 (PDT)
Date: Thu, 19 Apr 2012 09:29:23 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH v3 2/2] vmevent: Implement greater-than attribute and
 one-shot mode
Message-ID: <20120419162923.GA26630@lizard>
References: <20120418083208.GA24904@lizard>
 <20120418083523.GB31556@lizard>
 <alpine.LFD.2.02.1204182259580.11868@tux.localdomain>
 <20120418224629.GA22150@lizard>
 <alpine.LFD.2.02.1204190841290.1704@tux.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.02.1204190841290.1704@tux.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

This patch implements a new event type, it will trigger whenever a
value becomes greater than user-specified threshold, it complements
the 'less-then' trigger type.

Also, let's implement the one-shot mode for the events, when set,
userspace will only receive one notification per crossing the
boundaries.

Now when both LT and GT are set on the same level, the event type
works as a cross event type: it triggers whenever a value crosses
the threshold from a lesser values side to a greater values side,
and vice versa.

We use the event types in an userspace low-memory killer: we get a
notification when memory becomes low, so we start freeing memory by
killing unneeded processes, and we get notification when memory hits
the threshold from another side, so we know that we freed enough of
memory.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---

On Thu, Apr 19, 2012 at 08:42:14AM +0300, Pekka Enberg wrote:
> On Wed, 18 Apr 2012, Anton Vorontsov wrote:
> > Yep, with CONFIG_SWAP=n, and I had to a modify the test
> > since I saw the same thing, I believe. I'll try w/ the swap enabled,
> > and see how it goes. I think the vmevent-test.c needs some improvemnts
> > in general, but meanwhile...
> > 
> > > Physical pages: 109858
> > > read failed: Invalid argument
> > 
> > Can you send me the .config file that you used? Might be that
> > you have CONFIG_SWAP=n too?
> 
> No, I have CONFIG_SWAP=y. Here's the config I use.

Thanks! It appears that there was just another hard-coded value for
the counter in vmevent-test.c, I changed it to config.counter and
now everything should be fine.

 include/linux/vmevent.h              |   13 ++++++++++
 mm/vmevent.c                         |   44 +++++++++++++++++++++++++++++-----
 tools/testing/vmevent/vmevent-test.c |   24 ++++++++++++++-----
 3 files changed, 69 insertions(+), 12 deletions(-)

diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
index 64357e4..ca97cf0 100644
--- a/include/linux/vmevent.h
+++ b/include/linux/vmevent.h
@@ -22,6 +22,19 @@ enum {
 	 * Sample value is less than user-specified value
 	 */
 	VMEVENT_ATTR_STATE_VALUE_LT	= (1UL << 0),
+	/*
+	 * Sample value is greater than user-specified value
+	 */
+	VMEVENT_ATTR_STATE_VALUE_GT	= (1UL << 1),
+	/*
+	 * One-shot mode.
+	 */
+	VMEVENT_ATTR_STATE_ONE_SHOT	= (1UL << 2),
+
+	/* Saved state, used internally by the kernel for one-shot mode. */
+	__VMEVENT_ATTR_STATE_VALUE_WAS_LT	= (1UL << 30),
+	/* Saved state, used internally by the kernel for one-shot mode. */
+	__VMEVENT_ATTR_STATE_VALUE_WAS_GT	= (1UL << 31),
 };
 
 struct vmevent_attr {
diff --git a/mm/vmevent.c b/mm/vmevent.c
index 9ed6aca..3cce215 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -1,5 +1,6 @@
 #include <linux/anon_inodes.h>
 #include <linux/atomic.h>
+#include <linux/compiler.h>
 #include <linux/vmevent.h>
 #include <linux/syscalls.h>
 #include <linux/timer.h>
@@ -83,16 +84,47 @@ static bool vmevent_match(struct vmevent_watch *watch)
 
 	for (i = 0; i < config->counter; i++) {
 		struct vmevent_attr *attr = &config->attrs[i];
-		u64 value;
+		u32 state = attr->state;
+		bool attr_lt = state & VMEVENT_ATTR_STATE_VALUE_LT;
+		bool attr_gt = state & VMEVENT_ATTR_STATE_VALUE_GT;
 
-		if (!attr->state)
+		if (!state)
 			continue;
 
-		value = vmevent_sample_attr(watch, attr);
-
-		if (attr->state & VMEVENT_ATTR_STATE_VALUE_LT) {
-			if (value < attr->value)
+		if (attr_lt || attr_gt) {
+			bool one_shot = state & VMEVENT_ATTR_STATE_ONE_SHOT;
+			u32 was_lt_mask = __VMEVENT_ATTR_STATE_VALUE_WAS_LT;
+			u32 was_gt_mask = __VMEVENT_ATTR_STATE_VALUE_WAS_GT;
+			u64 value = vmevent_sample_attr(watch, attr);
+			bool lt = value < attr->value;
+			bool gt = value > attr->value;
+			bool was_lt = state & was_lt_mask;
+			bool was_gt = state & was_gt_mask;
+			bool ret = false;
+
+			if ((lt || gt) && !one_shot)
 				return true;
+
+			if (attr_lt && lt && was_lt) {
+				return false;
+			} else if (attr_gt && gt && was_gt) {
+				return false;
+			} else if (lt) {
+				state |= was_lt_mask;
+				state &= ~was_gt_mask;
+				if (attr_lt)
+					ret = true;
+			} else if (gt) {
+				state |= was_gt_mask;
+				state &= ~was_lt_mask;
+				if (attr_gt)
+					ret = true;
+			} else {
+				state &= ~was_lt_mask;
+				state &= ~was_gt_mask;
+			}
+			attr->state = state;
+			return ret;
 		}
 	}
 
diff --git a/tools/testing/vmevent/vmevent-test.c b/tools/testing/vmevent/vmevent-test.c
index 534f827..fd9a174 100644
--- a/tools/testing/vmevent/vmevent-test.c
+++ b/tools/testing/vmevent/vmevent-test.c
@@ -33,20 +33,32 @@ int main(int argc, char *argv[])
 
 	config = (struct vmevent_config) {
 		.sample_period_ns	= 1000000000L,
-		.counter		= 4,
+		.counter		= 6,
 		.attrs			= {
-			[0]			= {
+			{
 				.type	= VMEVENT_ATTR_NR_FREE_PAGES,
 				.state	= VMEVENT_ATTR_STATE_VALUE_LT,
 				.value	= phys_pages,
 			},
-			[1]			= {
+			{
+				.type	= VMEVENT_ATTR_NR_FREE_PAGES,
+				.state	= VMEVENT_ATTR_STATE_VALUE_GT,
+				.value	= phys_pages,
+			},
+			{
+				.type	= VMEVENT_ATTR_NR_FREE_PAGES,
+				.state	= VMEVENT_ATTR_STATE_VALUE_LT |
+					  VMEVENT_ATTR_STATE_VALUE_GT |
+					  VMEVENT_ATTR_STATE_ONE_SHOT,
+				.value	= phys_pages / 2,
+			},
+			{
 				.type	= VMEVENT_ATTR_NR_AVAIL_PAGES,
 			},
-			[2]			= {
+			{
 				.type	= VMEVENT_ATTR_NR_SWAP_PAGES,
 			},
-			[3]			= {
+			{
 				.type	= 0xffff, /* invalid */
 			},
 		},
@@ -59,7 +71,7 @@ int main(int argc, char *argv[])
 	}
 
 	for (i = 0; i < 10; i++) {
-		char buffer[sizeof(struct vmevent_event) + 4 * sizeof(struct vmevent_attr)];
+		char buffer[sizeof(struct vmevent_event) + config.counter * sizeof(struct vmevent_attr)];
 		struct vmevent_event *event;
 		int n = 0;
 		int idx;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
