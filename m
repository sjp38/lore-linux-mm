Message-ID: <3E3AFA3A.6050205@us.ibm.com>
Date: Fri, 31 Jan 2003 14:35:38 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: [question] shm_nattch in sys_shmat?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

Hello all!
	In case it wasn't obvious from the subject, I've got a question about a 
piece of code in ipc/shm.c:sys_shmat(), more specifically about the use 
of the shm_nattch counter.  This is supposed to be used to count the 
number of times the shared memory segment has been attatched to a 
processes adress space.  For example, shm_open & shm_mmap both increment 
shm_nattch, and shm_close decrements shm_nattch.  I would be inclined to 
think that sys_shmat should increment this counter, to keep track of a 
new attatchment of the shared segment to a processes adress space. 
sys_shmat, does in fact increment shm_nattch, but only to decrement it 
again a few lines later, as seen in this code snippet.  Can anyone 
please explain why this is?

 >	file = shp->shm_file;
 >	size = file->f_dentry->d_inode->i_size;
 >>>	shp->shm_nattch++;
 >	shm_unlock(shp);
 >
 >	down_write(&current->mm->mmap_sem);
 >	if (addr && !(shmflg & SHM_REMAP)) {
 >		user_addr = ERR_PTR(-EINVAL);
 >		if (find_vma_intersection(current->mm, addr, addr + size))
 >			goto invalid;
 >		/*
 >		 * If shm segment goes below stack, make sure there is some
 >		 * space left for the stack to grow (at least 4 pages).
 >		 */
 >		if (addr < current->mm->start_stack &&
 >		    addr > current->mm->start_stack - size - PAGE_SIZE * 5)
 >			goto invalid;
 >	}
 >
 >	user_addr = (void*) do_mmap (file, addr, size, prot, flags, 0);
 >
 >invalid:
 >	up_write(&current->mm->mmap_sem);
 >
 >	down (&shm_ids.sem);
 >	if(!(shp = shm_lock(shmid)))
 >		BUG();
 >>>	shp->shm_nattch--;
 >	if(shp->shm_nattch == 0 &&
 >	   shp->shm_flags & SHM_DEST)
 >		shm_destroy (shp);
 >	else
 >		shm_unlock(shp);
 >	up (&shm_ids.sem);

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
