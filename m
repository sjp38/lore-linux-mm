Message-ID: <7FAAE4DE7248554ABD8C69DD4A18289B80305A@srnamath>
From: "swayampakulaa, sudhindra" <swayampakulaa_sudhindra@emc.com>
Subject: mmap enrty point in a driver
Date: Tue, 8 Oct 2002 12:27:21 -0400 
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Iam trying to understand the mmap entry point for a driver.
This is how the mmap() is implemented 


himem_buf_allocated = 0;

int xxx_mmap(struct file *filp,
		  struct vm_area_struct *vma)
{
  unsigned long size;
  char * virt_addr;
  int		index;

  size = vma->vm_end - vma->vm_start;
  if ((size % PAGE_SIZE) != 0){
    size = (size / PAGE_SIZE) * PAGE_SIZE + PAGE_SIZE;
  }

  /* himem_buf_size is 0x80000000 */
  if (size + himem_buf_allocated >= himem_buf_size){
    
    return -ENOMEM;
  }
  
  /* himem_buf is calculated as high_memory - PAGE_OFFSET */
  umem_addr = himem_buf + himem_buf_allocated;
  if (umem_addr == 0){
    return -ENOMEM;
  }
  himem_buf_allocated += size;
  

  virt_addr = ioremap((unsigned long)umem_addr, PAGE_SIZE);  
  if (virt_addr == 0){
    return -ENOMEM;
  }
  /* write the index into the first 4 bytes */
  writel(index, (uint32_t *)virt_addr);

    /* the values of index and *(virt_addr) do not match */
    /*                      *(virt_addr) is always -1                */
    /* Is something wrong here                                   */
    dbg_printf(0,"index is %d, *(virt_addr) is %d\n", index,
(int)readl(virt_addr));
  iounmap(virt_addr);

   

  remap_page_range(vma->vm_start, (ulong)umem_addr, 
		   vma->vm_end - vma->vm_start, vma->vm_page_prot);

  return 0;
}

Can you help me in understanding what exactly is the mmap() doing here and
if its doing it right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
