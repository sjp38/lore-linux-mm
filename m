Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D97766B0184
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 17:09:10 -0400 (EDT)
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id o2HL93hE023875
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 14:09:05 -0700 (PDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; CHARSET=US-ASCII; delsp=yes; format=flowed
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KZG001002HJMB00@fe-sfbay-09.sun.com> for linux-mm@kvack.org; Wed,
 17 Mar 2010 14:09:03 -0700 (PDT)
Date: Wed, 17 Mar 2010 15:09:00 -0600
From: Andreas Dilger <adilger@sun.com>
Subject: Re: [C/R v20][PATCH 46/96] c/r: add checkpoint operation for opened
 files of generic filesystems
In-reply-to: <1268842164-5590-47-git-send-email-orenl@cs.columbia.edu>
Message-id: <BA0C23DE-E2B5-42A9-8478-CE216D18A6C6@sun.com>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Matt Helsley <matthltc@us.ibm.com>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 2010-03-17, at 10:08, Oren Laadan wrote:
> These patches extend the use of the generic file checkpoint  
> operation to
> non-extX filesystems which have lseek operations that ensure we can  
> save
> and restore the files for later use. Note that this does not include
> things like FUSE, network filesystems, or pseudo-filesystem kernel
> interfaces.

I didn't see any other patches posted to linux-fsdevel regarding what  
this code is, or what it is supposed to be doing.  Could you please  
repost the patches related to generic_file_checkpoint(), and the  
overview email that explains what you mean by "checkpoint".  I'm  
assuming this is related to HPC/process restart/migration, but better  
to not guess.

> @@ -718,6 +718,7 @@ static const struct file_operations  
> btrfs_ctl_fops = {
> 	.unlocked_ioctl	 = btrfs_control_ioctl,
> 	.compat_ioctl = btrfs_control_ioctl,
> 	.owner	 = THIS_MODULE,
> +	.checkpoint = generic_file_checkpoint,
> };
>
> const struct file_operations exofs_file_operations = {
> 	.llseek		= generic_file_llseek,
> +	.checkpoint	= generic_file_checkpoint,
> 	.read		= do_sync_read,
> 	.write		= do_sync_write,
> 	.aio_read	= generic_file_aio_read,
>
> static const struct file_operations hostfs_file_fops = {
> 	.llseek		= generic_file_llseek,
> +	.checkpoint	= generic_file_checkpoint,
> 	.read		= do_sync_read,
> 	.splice_read	= generic_file_splice_read,
> 	.aio_read	= generic_file_aio_read,
> @@ -430,6 +431,7 @@ static const struct file_operations  
> hostfs_file_fops = {
>
> static const struct file_operations hostfs_dir_fops = {
> 	.llseek		= generic_file_llseek,
> +	.checkpoint	= generic_file_checkpoint,
> 	.readdir	= hostfs_readdir,
> 	.read		= generic_read_dir,
> };
>
> const struct file_operations nilfs_file_operations = {
> 	.llseek		= generic_file_llseek,
> +	.checkpoint	= generic_file_checkpoint,
> 	.read		= do_sync_read,
> 	.write		= do_sync_write,
> 	.aio_read	= generic_file_aio_read,


Minor nit - it would be good to add this method in the same place in  
all of the *_file_operation structures for consistency.  Ideally these  
would already be in the order that they are declared in the structure,  
but at least new ones should be added consistently.

> static const struct vm_operations_struct nfs_file_vm_ops = {
> 	.fault = filemap_fault,
> 	.page_mkwrite = nfs_vm_page_mkwrite,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint = filemap_checkpoint,
> +#endif
> };

Why is this one conditional, but the others are not?


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
