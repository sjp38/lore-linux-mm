Message-ID: <20050608175808.31715.qmail@web25601.mail.ukl.yahoo.com>
Date: Wed, 8 Jun 2005 19:58:08 +0200 (CEST)
From: Vincenzo Mallozzi <vinjunior@yahoo.it>
Subject: dumping/restoring memory questions
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,
I'm trying to dumping/restore parts of a memory
descriptor without writing 
these informations on files.
To do this, I use the following data structures (only
the parts rilevant for 
this discussion are listed): 


1.   struct cmc_pages{
2.     char page[PAGE_SIZE];
3.   };

4.   struct cmc_vm_area_struct{
5.    int num_pages;
6.    int saved;
7.    struct cmc_pages *vm_pages;
 .................................
8.    struct cmc_vm_area_struct *vm_next; 
9.  };

10.  struct cmc_mm_struct{
11.    struct cmc_vm_area_struct *mmap;
  ......................
12.  };

These data structures are used in the following
functions:

13.  struct cmc_mm_struct 
cmc_dump_memory_descriptor(struct mm_struct *mm)
14.  {
15.    struct vm_area_struct *vm;
16.    struct cmc_vm_area_struct *vma;
17.    int cont;

18.    down_write(&mm->mmap_sem);

       ..............................

19.    for (cont = 0, vm=mm->mmap; vm!=NULL; cont++,
vm=vm->vm_next){
20.      if (this vma is to be saved){
21.      vma = cmc_dump_vm_area(mm, vm);
22.      vma->saved = 1;
23.      }
24.      else
25.      vma->saved = 0;
26.      }

    /* instructions to build the vmas' list */
27.    }


28.  struct cmc_vm_area_struct
*cmc_dump_vm_area(struct mm_struct *mm, struct 
vm_area_struct *vm)
29.  {
30.    unsigned long addr;
31.    struct cmc_vm_area_struct *vma;
32.    struct cmc_pages *vm_pages;
33.    int cont, num_pages;
34.    char *kern_addr;

       ........................
       .......................

35.    cont = 0;
36.    addr = vm->vm_start;
37.    while(addr<vm->vm_end){
    
38.       kern_addr = cmc_kernel_address(mm, addr);
        /* the function cmc_kernel_address is very
similar to follow_page(in 
         mm/memory.c) except that this one return a
(char *) */
     
39.       strncpy(vm_pages[cont].page, kern_addr,
PAGE_SIZE);

40.       cont++;
41.       addr += PAGE_SIZE;
42.    }
43.    vma->vm_pages = vm_pages;
  
44.    return vma;
45.  }


The functions to restore memory pages are similar to
the two above. The 
difference is in line 39 that is substituted by the
following line:


 copy_to_user(kern_addr, vma->vm_pages[cont].page,
PAGE_SIZE);

that do the opposite work.

Now I have three doubts:
1. When I try to execute this module, I notice that
nothing happens. In other 
words, nothing is dumped/restored out/in memory. The
strings 
(vm_pages[cont].page) that contain the page are not
NULL but they're empty.

2. After I do "kern_addr = cmc_kernel_address(mm,
addr)" I notice that are 
returned strange values.
Below I list the value of kern_addr and addr
variables. Someone can tell me 
why all but one converted address (kern_addr) have the
same address value?

addr: 0804a000   kern_addr: c0104000
addr: 0804b000   kern_addr: d62f2000
addr: 0804c000   kern_addr: c0104000
addr: 0804d000   kern_addr: c0104000
addr: 0804e000   kern_addr: c0104000
addr: 0804f000   kern_addr: c0104000
....................................
....................................
addr: 08069000   kern_addr: c0104000
addr: 0806a000   kern_addr: c0104000

3. Must I use set_fs /get_fs functions?

Thanks.
Vincenzo Mallozzi

P.S. I'm sorry if these are only newbies questions!!!



	

	
		
___________________________________ 
Yahoo! Mail: gratis 1GB per i messaggi e allegati da 10MB 
http://mail.yahoo.it
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
