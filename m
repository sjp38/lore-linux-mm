Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2B6BC6B00D3
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 09:53:51 -0500 (EST)
Date: Thu, 5 Mar 2009 22:52:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: drop_caches ...
Message-ID: <20090305145253.GA23945@localhost>
References: <200903041057.34072.M4rkusXXL@web.de> <200903051505.26584.M4rkusXXL@web.de> <20090305142230.GA23465@localhost> <200903051543.22516.M4rkusXXL@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903051543.22516.M4rkusXXL@web.de>
Sender: owner-linux-mm@kvack.org
To: Markus <M4rkusXXL@web.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lukas Hejtmanek <xhejtman@ics.muni.cz>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 05, 2009 at 04:43:22PM +0200, Markus wrote:
> > > > Could you please try the attached patch which will also show the
> > > > user and process that opened these files? It adds three more 
> fields
> > > > when CONFIG_PROC_FILECACHE_EXTRAS is selected.
> > > > 
> > > > Thanks,
> > > > Fengguang
> > > >  
> > > > On Thu, Mar 05, 2009 at 01:55:35PM +0200, Markus wrote:
> > > > > 
> > > > > # sort -n -k 3 filecache-2009-03-05 | tail -n 5
> > > > >      15886       7112     7112     100      1    d- 00:08
> > > > > (tmpfs)        /dev/zero\040(deleted)
> > > > >      16209      35708    35708     100      1    d- 00:08
> > > > > (tmpfs)        /dev/zero\040(deleted)
> > > > >      16212      82128    82128     100      1    d- 00:08
> > > > > (tmpfs)        /dev/zero\040(deleted)
> > > > >      15887     340024   340024     100      1    d- 00:08
> > > > > (tmpfs)        /dev/zero\040(deleted)
> > > > >      15884     455008   455008     100      1    d- 00:08
> > > > > (tmpfs)        /dev/zero\040(deleted)
> > > > > 
> > > > > The sum of the third column is 1013 MB.
> > > > > To note the biggest ones (or do you want the whole file?)... and 
> > > thats 
> > > > > after a sync and a drop_caches! (Can be seen in the commands 
> given.)
> > > 
> > > I could, but I know where these things belong to. Its from sphinx (a 
> > > mysql indexer) searchd. It loads parts of the index into memory.
> > > The sizes looked well-known and killing the searchd will 
> reduce "cached" 
> > > to a normal amount ;)
> > 
> > And it's weird about the file name: /dev/zero.  I wonder how it
> > managed to create that file, and then delete it, inside a tmpfs!
> 
> I dont know exactly. But in the source its just a:
> ... mmap ( NULL, m_iLength, PROT_READ | PROT_WRITE, MAP_SHARED | 
> MAP_ANON, -1, 0 );
> Perhaps thats the way shared anonymous memory is handled?!

Good to know this. The corresponding kernel function is:

        /**     
         * shmem_zero_setup - setup a shared anonymous mapping
         * @vma: the vma to be mmapped is prepared by do_mmap_pgoff
         */
        int shmem_zero_setup(struct vm_area_struct *vma)
        {       
                struct file *file;
                loff_t size = vma->vm_end - vma->vm_start;
                
                file = shmem_file_setup("dev/zero", size, vma->vm_flags);

Here goes the /dev/zero ^_^

> > Just out of curiosity, are they shm objects? Can you show us the
> > output of 'df'? In your convenient time.
> 
> Thats all:
> # df -h
> Filesystem            Size  Used Avail Use% Mounted on
> /dev/md6               14G  7.9G  5.9G  58% /
> udev                   10M  304K  9.8M   3% /dev
> cachedir              4.0M  100K  4.0M   3% /lib64/splash/cache
> /dev/md4               19G   15G  3.2G  82% /home
> /dev/md3              8.3G  4.5G  3.8G  55% /usr/portage

> shm                   2.0G     0  2.0G   0% /dev/shm

shm objects will be accounted here. It's clean.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
