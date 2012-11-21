Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id D4F826B00B1
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:38:13 -0500 (EST)
Date: Wed, 21 Nov 2012 23:37:21 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [memcg:since-3.6 456/496] drivers/virtio/virtio_balloon.c:145:10: warning: format '%zu' expects argument of type 'size_t', but argument 4 has type 'unsigned int'
Message-ID: <50acf531.zaJ8wmQW+6NHVbhr%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.6
head:   223cdc1faeea55aa70fef23d54720ad3fdaf4c93
commit: 12cf48af8968fa1d0cc4c06065d7c37c3560c171 [456/496] virtio_balloon: introduce migration primitives to balloon pages
config: make ARCH=x86_64 allmodconfig

All warnings:

drivers/virtio/virtio_balloon.c: In function 'fill_balloon':
drivers/virtio/virtio_balloon.c:145:10: warning: format '%zu' expects argument of type 'size_t', but argument 4 has type 'unsigned int' [-Wformat]

vim +145 drivers/virtio/virtio_balloon.c

6b35e407 Rusty Russell      2008-02-04  129  static void fill_balloon(struct virtio_balloon *vb, size_t num)
6b35e407 Rusty Russell      2008-02-04  130  {
12cf48af Rafael Aquini      2012-11-21  131  	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
12cf48af Rafael Aquini      2012-11-21  132  
6b35e407 Rusty Russell      2008-02-04  133  	/* We can only do one array worth at a time. */
6b35e407 Rusty Russell      2008-02-04  134  	num = min(num, ARRAY_SIZE(vb->pfns));
6b35e407 Rusty Russell      2008-02-04  135  
12cf48af Rafael Aquini      2012-11-21  136  	mutex_lock(&vb->balloon_lock);
3ccc9372 Michael S. Tsirkin 2012-04-12  137  	for (vb->num_pfns = 0; vb->num_pfns < num;
3ccc9372 Michael S. Tsirkin 2012-04-12  138  	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
12cf48af Rafael Aquini      2012-11-21  139  		struct page *page = balloon_page_enqueue(vb_dev_info);
12cf48af Rafael Aquini      2012-11-21  140  
6b35e407 Rusty Russell      2008-02-04  141  		if (!page) {
6b35e407 Rusty Russell      2008-02-04  142  			if (printk_ratelimit())
6b35e407 Rusty Russell      2008-02-04  143  				dev_printk(KERN_INFO, &vb->vdev->dev,
4f2ac849 Michal Hocko       2012-11-21  144  					   "Out of puff! Can't get %zu pages\n",
12cf48af Rafael Aquini      2012-11-21 @145  					    VIRTIO_BALLOON_PAGES_PER_PAGE);
6b35e407 Rusty Russell      2008-02-04  146  			/* Sleep for at least 1/5 of a second before retry. */
6b35e407 Rusty Russell      2008-02-04  147  			msleep(200);
6b35e407 Rusty Russell      2008-02-04  148  			break;
6b35e407 Rusty Russell      2008-02-04  149  		}
3ccc9372 Michael S. Tsirkin 2012-04-12  150  		set_page_pfns(vb->pfns + vb->num_pfns, page);
3ccc9372 Michael S. Tsirkin 2012-04-12  151  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
6b35e407 Rusty Russell      2008-02-04  152  		totalram_pages--;
6b35e407 Rusty Russell      2008-02-04  153  	}

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
