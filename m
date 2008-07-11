Date: Fri, 11 Jul 2008 12:17:04 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: swapon/swapoff in a loop -- ever-decreasing priority field
In-Reply-To: <19f34abd0807100354o4f79b75bo174d756da8459d37@mail.gmail.com>
References: <19f34abd0807100354o4f79b75bo174d756da8459d37@mail.gmail.com>
Message-Id: <20080711121227.F694.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> I find that running swapon/swapoff in a loop will decrement the
> "Priority" field of the swap partition once per iteration. This
> doesn't seem quite correct, as it will eventually lead to an
> underflow.
> 
> (Though, by my calculations, it would take around 620 days of constant
> swapoff/swapon to reach this condition, so it's hardly a real-life
> problem.)
> 
> Is this something that should be fixed, though?

I am not sure about your intention.
Do following patch fill your requirement?




Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/swapfile.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

Index: b/mm/swapfile.c
===================================================================
--- a/mm/swapfile.c	2008-07-10 22:58:44.000000000 +0900
+++ b/mm/swapfile.c	2008-07-10 23:22:42.000000000 +0900
@@ -49,6 +49,8 @@ static struct swap_info_struct swap_info
 
 static DEFINE_MUTEX(swapon_mutex);
 
+static int least_priority;
+
 /*
  * We need this because the bdev->unplug_fn can sleep and we cannot
  * hold swap_lock while calling the unplug_fn. And swap_lock
@@ -1232,6 +1234,7 @@ asmlinkage long sys_swapoff(const char _
 	char * pathname;
 	int i, type, prev;
 	int err;
+	int min_prio;
 	
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
@@ -1329,6 +1332,15 @@ asmlinkage long sys_swapoff(const char _
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
+	p->prio = 0;
+
+	min_prio = 0;
+	for (i = 0; i < MAX_SWAPFILES; i++) {
+		if (min_prio > swap_info[i].prio)
+			min_prio = swap_info[i].prio;
+	}
+	least_priority = min_prio;
+
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
@@ -1466,7 +1478,6 @@ asmlinkage long sys_swapon(const char __
 	unsigned int type;
 	int i, prev;
 	int error;
-	static int least_priority;
 	union swap_header *swap_header = NULL;
 	int swap_header_version;
 	unsigned int nr_good_pages = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
