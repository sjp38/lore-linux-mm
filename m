Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 849996B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 07:39:26 -0400 (EDT)
Received: from mail192-co1 (localhost [127.0.0.1])	by
 mail192-co1-R.bigfish.com (Postfix) with ESMTP id 23570C607CF	for
 <linux-mm@kvack.org>; Fri, 15 Mar 2013 11:39:25 +0000 (UTC)
Received: from CO1EHSMHS004.bigfish.com (unknown [10.243.78.240])	by
 mail192-co1.bigfish.com (Postfix) with ESMTP id 98B4BA400B3	for
 <linux-mm@kvack.org>; Fri, 15 Mar 2013 11:39:23 +0000 (UTC)
From: Gil Weber <gilw@cse-semaphore.com>
Subject: mmap sync issue
Date: Fri, 15 Mar 2013 11:39:20 +0000
Message-ID: <DEACCBA4C6A9D145A6A68B5F5BE581B80FC057AB@HKXPRD0310MB353.apcprd03.prod.outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello,
I am experiencing an issue with my device driver. I am using mmap and ioctl=
 to share information with my user space application.
The thing is that the shared memory does not seems to be synced. Do check t=
his, I have done a simple test:

int fd =3D open("/dev/test", O_RDWR | O_SYNC);
int * addr =3D mmap(0, 4, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
=09
for (i=3D0 ; i<100 ; i++ )
{
	*addr =3D i;
	ioctl(fd, 0, 0);
}


In my device driver, the only thing I do in ioctl is to display the content=
 of the shared memory, and here is the result:

[ 5158.967000] Value : 0
[ 5158.967000] Value : 1
[ 5158.967000] Value : 1
[ 5158.967000] Value : 1
[ 5158.967000] Value : 1
[ 5158.967000] Value : 1
[ 5158.967000] Value : 1
[ 5158.967000] Value : 1
[ 5158.967000] Value : 1
[ 5158.967000] Value : 1
[ 5158.967000] Value : 1
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
[ 5158.968000] Value : 11
...


So, clearly, memory is not synced...
Here is the code in my device driver:

static int test_open(struct inode *inode, struct file *filp)
{
	return 0;
}

static int test_release(struct inode *inode, struct file *filp)
{
	return 0;
}

static int test_mmap(struct file *filp, struct vm_area_struct *vma)
{
	int ret;
	unsigned long start =3D vma->vm_start;
	unsigned long pfn;

	pfn =3D vmalloc_to_pfn(vmalloc_area);
	if ((ret =3D remap_pfn_range(vma, start, pfn, PAGE_SIZE, PAGE_SHARED)) < 0=
) {
		return ret;
	}
=09
	return 0;
}

static long test_ioctl(struct file *file, unsigned int cmd, unsigned long a=
rg)
{
	printk (KERN_INFO "Value : %d\n", vmalloc_area[0]);
	return 0;
}

static struct file_operations test_fops =3D {
	.open =3D test_open,
	.release =3D test_release,
	.mmap =3D test_mmap,
	.unlocked_ioctl =3D test_ioctl,
	.owner =3D THIS_MODULE,
};

This is done on an arm architecture (AT91 SAM9X5) with a kernel 3.5.
I have done the test, with the same code, on a powerpc target, with a kerne=
l 2.6.27, and it seems to work (but maybe by chance?)
Am I missing something?
Maybe I need to implement the sync function in file operations, but in that=
 case, how can I know that all mapped memory is synced?

Thanks in advance,
Gil Weber

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
