Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 530826B0005
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 19:39:41 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id l22so2684303vbn.28
        for <linux-mm@kvack.org>; Sat, 16 Mar 2013 16:39:40 -0700 (PDT)
Message-ID: <514502B6.2090804@gmail.com>
Date: Sun, 17 Mar 2013 07:39:34 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: mmap sync issue
References: <DEACCBA4C6A9D145A6A68B5F5BE581B80FC057AB@HKXPRD0310MB353.apcprd03.prod.outlook.com>
In-Reply-To: <DEACCBA4C6A9D145A6A68B5F5BE581B80FC057AB@HKXPRD0310MB353.apcprd03.prod.outlook.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gil Weber <gilw@cse-semaphore.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Cc experts
On 03/15/2013 07:39 PM, Gil Weber wrote:
> Hello,
> I am experiencing an issue with my device driver. I am using mmap and ioctl to share information with my user space application.
> The thing is that the shared memory does not seems to be synced. Do check this, I have done a simple test:
>
> int fd = open("/dev/test", O_RDWR | O_SYNC);
> int * addr = mmap(0, 4, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
> 	
> for (i=0 ; i<100 ; i++ )
> {
> 	*addr = i;
> 	ioctl(fd, 0, 0);
> }
>
>
> In my device driver, the only thing I do in ioctl is to display the content of the shared memory, and here is the result:
>
> [ 5158.967000] Value : 0
> [ 5158.967000] Value : 1
> [ 5158.967000] Value : 1
> [ 5158.967000] Value : 1
> [ 5158.967000] Value : 1
> [ 5158.967000] Value : 1
> [ 5158.967000] Value : 1
> [ 5158.967000] Value : 1
> [ 5158.967000] Value : 1
> [ 5158.967000] Value : 1
> [ 5158.967000] Value : 1
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> [ 5158.968000] Value : 11
> ...
>
>
> So, clearly, memory is not synced...
> Here is the code in my device driver:
>
> static int test_open(struct inode *inode, struct file *filp)
> {
> 	return 0;
> }
>
> static int test_release(struct inode *inode, struct file *filp)
> {
> 	return 0;
> }
>
> static int test_mmap(struct file *filp, struct vm_area_struct *vma)
> {
> 	int ret;
> 	unsigned long start = vma->vm_start;
> 	unsigned long pfn;
>
> 	pfn = vmalloc_to_pfn(vmalloc_area);
> 	if ((ret = remap_pfn_range(vma, start, pfn, PAGE_SIZE, PAGE_SHARED)) < 0) {
> 		return ret;
> 	}
> 	
> 	return 0;
> }
>
> static long test_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
> {
> 	printk (KERN_INFO "Value : %d\n", vmalloc_area[0]);
> 	return 0;
> }
>
> static struct file_operations test_fops = {
> 	.open = test_open,
> 	.release = test_release,
> 	.mmap = test_mmap,
> 	.unlocked_ioctl = test_ioctl,
> 	.owner = THIS_MODULE,
> };
>
> This is done on an arm architecture (AT91 SAM9X5) with a kernel 3.5.
> I have done the test, with the same code, on a powerpc target, with a kernel 2.6.27, and it seems to work (but maybe by chance?)
> Am I missing something?
> Maybe I need to implement the sync function in file operations, but in that case, how can I know that all mapped memory is synced?
>
> Thanks in advance,
> Gil Weber
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
