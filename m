Received: from ren.cs.wm.edu (ren [128.239.26.12])
	by zimbo.cs.wm.edu (8.12.8/8.12.8) with ESMTP id h5N5Ef16019160
	for <linux-mm@kvack.org>; Mon, 23 Jun 2003 01:14:41 -0400
Received: from localhost (sren@localhost)
	by ren.cs.wm.edu (8.12.8/8.12.8/Submit) with ESMTP id h5N5Ee8Q028255
	for <linux-mm@kvack.org>; Mon, 23 Jun 2003 01:14:41 -0400
Date: Mon, 23 Jun 2003 01:14:40 -0400 (EDT)
From: Shansi Ren <sren@CS.WM.EDU>
Subject: 2.4.5: to fix total buffer cache size?
Message-ID: <Pine.LNX.4.44.0306230024410.28075-100000@ren.cs.wm.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,

   I'm writing to ask for your help.

   I'm trying to fix the total size of buffer cache in RAM so that I can 
further implement a new block replacement algorithm. My intent is not to 
modify the kernel and release some patch, but rather to use Linux as a 
platform for my research project.  I'm working on 2.4.5 since it's the 
only stable version of kernel available in our system lab.

   The assumption of this new block replacement algorithm is: There is a 
fixed amount of RAM used exclusively as disk I/O buffer cache, say, 32M 
buffer cache. When the OS needs to read or write a block on disk, it 
brings that block into the buffer cache. If the buffer cache is full, it 
selects one of the block, evicts it, and puts the new block into the 
release space. 

   So my first step is to fix the size of buffer cache. My idea is: Since 
all block I/O calls bread() service function, and bread() calls getblk() 
at the first place, I add some code in getblk() function. In psuedocode, 
the getblk() now is:

  1. traverse lru_list[BUF_CLEAN], lru_list[BUF_DIRTY] and 
lru_list[BUF_LOCKED], count the buffers in these three list. they are the 
total number of I/O buffers at current point of time.
  2. If the number of buffers is below a threshold, continue to do the 
normal buffer allocation as in the original getblk() function.
  3. If the number of buffers reaches that threshold:
     a) check the lru_list[BUF_DIRTY] from the tail to the head, try to 
find a buffer with no reference(i.e. b_count is 0). If it succeeds, 
write this dirty buffer back to disk, assign this buffer head to the new 
disk block requested. Move the buffer head from DIRTY list to CLEAN list. 
Return this buffer head.
     b) if step a) fails, try to find a non-referenced buffer in
lru_list[BUF_CLEAN] list. Return this buffer head.
     c) if step b) also fails, do the normal buffer cache allocation as in 
the original getblk() function. 

   I thought it made sense, but after I stated debugging, a lot of 
unexpected errors appeared, different each time. Since I'm new to kernel 
hacking, the only way I know as how to debug is to insert printk between 
statements. However, it doesn't do much help here, since getblk() is 
called so frequently: almost every time I type new command, it gets 
called. Can anybody throw me a point how to debug efficiently? Thank you.

   Also, I put part of the code here, in case somebody want to take a 
look.

In buffer.c: 

#define MAX_BUFFERS 512
spinlock_t nr_buff_lock;            

int nr_bcaches() {  
  int i;
  struct buffer_head *bh;
  int localcounter;


  spin_lock(&nr_buff_lock);
  localcounter = 0;
  for(i = BUF_CLEAN; i<NR_LIST; i++) {

    bh = lru_list[i];
    if(!bh) continue;
    
    do {
      localcounter++;
      bh = bh->b_next_free;

    } while (bh != lru_list[i]);
  }

  spin_unlock(&nr_buff_lock);

  return localcounter;
}

struct buffer_head * getblk(kdev_t dev, int block, int size)
{
	struct buffer_head * bh;
	int isize;
	int nr_bufs;
	int buf_count;

repeat:
	spin_lock(&lru_list_lock);
	write_lock(&hash_table_lock);
	bh = __get_hash_table(dev, block, size);
	if (bh)
	  goto out;
	
	if((nr_bufs = nr_bcaches()) >= MAX_BUFFERS) {

	  buf_count = nr_buffers_type[BUF_DIRTY];

	  if(buf_count) {
	    bh = lru_list[BUF_DIRTY];
	    while (buf_count && atomic_read(&bh->b_count) != 0) { 
	      bh = bh->b_next_free;
	      buf_count--;
	    }
	    
	    if(buf_count && atomic_read(&bh->b_count) == 0) {

	      __remove_from_queues(bh);

	      atomic_inc(&bh->b_count);

	      spin_unlock(&lru_list_lock);

	      ll_rw_block(WRITE, 1, &bh);

	      atomic_dec(&bh->b_count);
	      
	      init_buffer(bh, NULL, NULL);
	      bh->b_dev = dev;
	      bh->b_blocknr = block;
	      bh->b_state = 1 << BH_Mapped;
	      
	      __insert_into_queues(bh);
	      write_unlock(&hash_table_lock);
	      touch_buffer(bh);

	      return bh;


	    }
	  }
	  else {
	    buf_count = nr_buffers_type[BUF_CLEAN];
	    printk("There are %d buffers in BUF_CLEAN LRU list.\n",
buf_count);

	    if(buf_count) {
	      bh = lru_list[BUF_CLEAN];
	      while(buf_count && atomic_read(&bh->b_count) != 0) {
		bh = bh->b_next_free;
		buf_count--;
	      }

	      if(buf_count && atomic_read(&bh->b_count) == 0) {

		__remove_from_queues(bh);
		
		atomic_inc(&bh->b_count);

		spin_unlock(&lru_list_lock);
		atomic_dec(&bh->b_count);

		init_buffer(bh, NULL, NULL);
		bh->b_dev = dev;
		bh->b_blocknr = block;
		bh->b_state = 1 << BH_Mapped;

		__insert_into_queues(bh);

		write_unlock(&hash_table_lock);
		touch_buffer(bh);

		return bh;
	      }
	    }
	  }

	}
	else {
	  
	  isize = BUFSIZE_INDEX(size);
	  spin_lock(&free_list[isize].lock);
	  bh = free_list[isize].list;
	  if (bh) {
	    __remove_from_free_list(bh, isize);
	    atomic_set(&bh->b_count, 1);
	  }
	  spin_unlock(&free_list[isize].lock);
	  
	  /*
	   * OK, FINALLY we know that this buffer is the only one of
	   * its kind, we hold a reference (b_count>0), it is unlocked,
	   * and it is clean.
	   */
	  if (bh) {
	    init_buffer(bh, NULL, NULL);
	    bh->b_dev = dev;
	    bh->b_blocknr = block;
	    bh->b_state = 1 << BH_Mapped;
	    
	    /* Insert the buffer into the regular lists */
	    __insert_into_queues(bh);
	  out:
	    write_unlock(&hash_table_lock);
	    spin_unlock(&lru_list_lock);
	    touch_buffer(bh);
	    return bh;
	  }

	  /*
	   * If we block while refilling the free list, somebody may
	   * create the buffer first ... search the hashes again.
	   */
	  write_unlock(&hash_table_lock);
	  spin_unlock(&lru_list_lock);
	  refill_freelist(size);
	  /* FIXME: getblk should fail if there's no enough memory */
	  goto repeat;
	}
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
