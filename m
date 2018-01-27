Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 683C56B026C
	for <linux-mm@kvack.org>; Sat, 27 Jan 2018 09:14:11 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 82so2349543pfs.8
        for <linux-mm@kvack.org>; Sat, 27 Jan 2018 06:14:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d64si5205571pfa.40.2018.01.27.06.14.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Jan 2018 06:14:10 -0800 (PST)
Subject: Re: Possible deadlock in v4.14.15 contention on shrinker_rwsem in
 shrink_slab()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net>
 <20180125083516.GA22396@dhcp22.suse.cz>
 <alpine.LRH.2.11.1801261846520.7450@mail.ewheeler.net>
 <4e9300f9-14c4-84a9-2258-b7e52bb6f753@I-love.SAKURA.ne.jp>
Message-ID: <733de86f-91f1-f5fd-2bbf-18cd9ff23091@I-love.SAKURA.ne.jp>
Date: Sat, 27 Jan 2018 23:13:59 +0900
MIME-Version: 1.0
In-Reply-To: <4e9300f9-14c4-84a9-2258-b7e52bb6f753@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wheeler <linux-mm@lists.ewheeler.net>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>, Tejun Heo <tj@kernel.org>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>

On 2018/01/27 15:34, Tetsuo Handa wrote:
> Although most of them were idle, and the system had enough free memory
> for creating workqueues, is there possibility that waiting for a work
> item to complete get stuck due to workqueue availability?
> ( Was there no "Showing busy workqueues and worker pools:" line?
> http://lkml.kernel.org/r/20170502041235.zqmywvj5tiiom3jk@merlins.org had it. )

"Showing busy workqueues and worker pools:" line should be there, for
SysRq-t calls show_workqueue_state().

  static void sysrq_handle_showstate(int key)
  {
  	show_state();
  	show_workqueue_state();
  }

> 
> One of workqueue threads was waiting at
> 
> ----------
> static void *new_read(struct dm_bufio_client *c, sector_t block,
> 		      enum new_flag nf, struct dm_buffer **bp)
> {
> 	int need_submit;
> 	struct dm_buffer *b;
> 
> 	LIST_HEAD(write_list);
> 
> 	dm_bufio_lock(c);
> 	b = __bufio_new(c, block, nf, &need_submit, &write_list);
> #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
> 	if (b && b->hold_count == 1)
> 		buffer_record_stack(b);
> #endif
> 	dm_bufio_unlock(c);
> 
> 	__flush_write_list(&write_list);
> 
> 	if (!b)
> 		return NULL;
> 
> 	if (need_submit)
> 		submit_io(b, READ, read_endio);
> 
> 	wait_on_bit_io(&b->state, B_READING, TASK_UNINTERRUPTIBLE); // <= here
> 
> 	if (b->read_error) {
> 		int error = blk_status_to_errno(b->read_error);
> 
> 		dm_bufio_release(b);
> 
> 		return ERR_PTR(error);
> 	}
> 
> 	*bp = b;
> 
> 	return b->data;
> }
> ----------
> 
> but what are possible reasons? Does this request depend on workqueue availability?
> 
> ----------
> kworker/u16:1   D    0  9752      2 0x80000080
> Workqueue: dm-thin do_worker [dm_thin_pool]
> Call Trace:
> ? __schedule+0x1dc/0x770
> ? out_of_line_wait_on_atomic_t+0x110/0x110
> schedule+0x32/0x80
> io_schedule+0x12/0x40
> bit_wait_io+0xd/0x50
> __wait_on_bit+0x5a/0x90
> out_of_line_wait_on_bit+0x8e/0xb0
> ? bit_waitqueue+0x30/0x30
> new_read+0x9f/0x100 [dm_bufio]
> dm_bm_read_lock+0x21/0x70 [dm_persistent_data]
> ro_step+0x31/0x60 [dm_persistent_data]
> btree_lookup_raw.constprop.7+0x3a/0x100 [dm_persistent_data]
> dm_btree_lookup+0x71/0x100 [dm_persistent_data]
> __find_block+0x55/0xa0 [dm_thin_pool]
> dm_thin_find_block+0x48/0x70 [dm_thin_pool]
> process_cell+0x67/0x510 [dm_thin_pool]
> ? dm_bio_detain+0x4c/0x60 [dm_bio_prison]
> process_bio+0xaa/0xc0 [dm_thin_pool]
> do_worker+0x632/0x8b0 [dm_thin_pool]
> ? __switch_to+0xa8/0x480
> process_one_work+0x141/0x340
> worker_thread+0x47/0x3e0
> kthread+0xfc/0x130
> ? rescuer_thread+0x380/0x380
> ? kthread_park+0x60/0x60
> ? SyS_exit_group+0x10/0x10
> ret_from_fork+0x35/0x40
> ----------

Well, I should not say "One of workqueue threads was waiting"
unless we can confirm that situation did not change over time.

Please take SysRq-t twice with some delay between them

# echo t > /proc/sysrq-trigger
# sleep 30
# echo t > /proc/sysrq-trigger

so that we can "diff" in order to check whether situation
changed over time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
