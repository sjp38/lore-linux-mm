Date: Wed, 27 Aug 2008 11:46:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/14]  delay page_cgroup freeing
Message-Id: <20080827114646.66a01083.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48B4BB2D.1000305@linux.vnet.ibm.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203324.409635c6.kamezawa.hiroyu@jp.fujitsu.com>
	<48B3ED0C.6050409@linux.vnet.ibm.com>
	<20080827085501.291f79b6.kamezawa.hiroyu@jp.fujitsu.com>
	<48B4AB47.7040209@linux.vnet.ibm.com>
	<20080827103933.b39cedc5.kamezawa.hiroyu@jp.fujitsu.com>
	<48B4BB2D.1000305@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Aug 2008 07:55:49 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > And there will be race with 
> >  - move_list,
> >  - isolate_pages,
> >  - (new) force_empty
> > 
> 
> I was suggesting that we could mark the page as obsolete and then move it on to
> another queue, if the page_cgroup was marked as obsolete.
> 
I can't understand this point. What is another queue ? Can it be a help
for avoiding lru_lock ?

following is my current version.
==
+/*
+ * per-cpu slot for freeing page_cgroup in lazy manner.
+ * All page_cgroup linked to this vec is OBSOLETE.
+ * This vector size is determined to be within 128 bytes on 64bit archs.
+ */
+#define MEMCG_LRU_THRESH       (15)
+struct mem_cgroup_sink_vec {
+       unsigned long nr;
+       struct page_cgroup *vec[MEMCG_LRU_THRESH];
+};
+DEFINE_PER_CPU(struct mem_cgroup_sink_vec, memcg_sink_vec);
+

record Obsolete page_cgroup in vec and free them in batched manner.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
